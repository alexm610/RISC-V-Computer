// vga_framebuffer_sdram.sv
//
// SDRAM-backed 320x240 RGB565 framebuffer, line-doubled to 640x480@60.
// Replaces the M10K-backed vga_framebuffer.  Pixel data lives in SDRAM and
// is fetched one scanline at a time through the sdram_mmu burst port into a
// small ping-pong line buffer (2 banks x 512 x 16 bits = 2 M10Ks).
//
// ── Framebuffer memory layout (SDRAM) ───────────────────────────────────────
//   Pixel (x, y) lives at:   fb_base + y*1024 + x*2      (RGB565, uint16)
//
//   STRIDE IS 1024 BYTES (512 words), NOT 640.  Padding the stride to a
//   power of two guarantees every 320-word line starts at SDRAM column 0 or
//   512 and therefore never crosses a row boundary mid-burst (a row is 1024
//   columns = 2KB).  fb_base must be 2KB-aligned.
//
//   Default fb_base = 32'h0380_0000 (top 8MB of the 64MB SDRAM reserved for
//   video).  320x240 with 1KB stride occupies 240KB.
//
// ── Fetch scheduling ────────────────────────────────────────────────────────
//   VGA lines 2L and 2L+1 display framebuffer line L (line doubling).
//   At the start of hblank of VGA line 2L (the FIRST repeat), the next
//   framebuffer line L+1 is requested - giving ~63us of slack for a ~6.5us
//   burst, so refresh/CPU-cycle delays can never underrun the buffer.
//   Line 0 of the next frame is prefetched during vblank (VGA line 522).
//
//   Bank selection is parity-based and handshake-free: line L always lives
//   in bank L[0].  Scanout reads bank vcount[1]; the fetcher fills the other.
//
// ── Clock domains ───────────────────────────────────────────────────────────
//   clk_50 : fetcher FSM, burst port, line-buffer write side, CPU MMIO
//   clk_25 : VGA timing, line-buffer read side
//   The fetch trigger crosses 25 -> 50 as a toggle through a 2FF synchronizer
//   (both clocks come from the same PLL).  fetch_line is quasi-static around
//   the toggle and is sampled >= 2 clk_50 cycles after it changes.
//
// ── CPU MMIO registers (via Graphics_Select) ────────────────────────────────
//   offset 0x0  R/W  fb_base   (default 0x0380_0000; write 2KB-aligned values;
//                               takes effect at the next line fetch - write
//                               during vblank for clean double-buffer flips)
//   offset 0x4  R/W  enable    (bit 0; 0 = output black, fetches paused)
//
// VGA timing: 640x480@60, 25MHz pixel clock.
//   H: 640 vis, 16 fp, 96 sync (active low), 48 bp  (total 800)
//   V: 480 vis, 10 fp,  2 sync (active low), 33 bp  (total 525)

module vga_framebuffer_sdram #(
    parameter logic [31:0] FB_BASE_DEFAULT = 32'h0380_0000
)(
    input  logic        clk_50,
    input  logic        clk_25,
    input  logic        rst_n,

    // ── CPU MMIO (control registers only - pixels go via the CPU RAM port) ──
    input  logic        VGA_Select,
    input  logic        AS_L,
    input  logic        WE_L,
    input  logic [31:0] Address,
    input  logic [3:0]  ByteEnable,
    input  logic [31:0] DataIn,
    output logic [31:0] DataOut,

    // ── Burst port to sdram_mmu ─────────────────────────────────────────────
    output logic        fb_req,
    output logic [31:0] fb_addr,
    output logic [9:0]  fb_len,
    input  logic [15:0] fb_data,
    input  logic        fb_valid,
    input  logic        fb_done,

    // ── VGA ─────────────────────────────────────────────────────────────────
    output logic [9:0]  VGA_R,
    output logic [9:0]  VGA_G,
    output logic [9:0]  VGA_B,
    output logic        VGA_HS,
    output logic        VGA_VS,
    output logic        VGA_BLANK,
    output logic        VGA_SYNC,
    output logic        VGA_CLK
);

    // ════════════════════════════════════════════════════════════════════════
    // CPU MMIO registers (clk_50)
    // ════════════════════════════════════════════════════════════════════════

    logic [31:0] fb_base_reg;
    logic        enable_reg;

    always @(posedge clk_50 or negedge rst_n) begin
        if (!rst_n) begin
            fb_base_reg <= FB_BASE_DEFAULT;
            enable_reg  <= 1'b1;
        end else if ((VGA_Select == 1'b1) && (AS_L == 1'b0) && (WE_L == 1'b0)) begin
            case (Address[3:2])
                2'd0:    fb_base_reg <= {DataIn[31:11], 11'b0};  // force 2KB alignment
                2'd1:    enable_reg  <= DataIn[0];
                default: ;
            endcase
        end
    end

    always @(*) begin
        DataOut = 32'h0;
        if (VGA_Select == 1'b1) begin
            case (Address[3:2])
                2'd0:    DataOut = fb_base_reg;
                2'd1:    DataOut = {31'b0, enable_reg};
                default: DataOut = 32'h0;
            endcase
        end
    end

    // ════════════════════════════════════════════════════════════════════════
    // VGA timing (clk_25)
    // ════════════════════════════════════════════════════════════════════════

    logic [9:0] hcount;     // 0..799
    logic [9:0] vcount;     // 0..524

    always @(posedge clk_25 or negedge rst_n) begin
        if (!rst_n) begin
            hcount <= 10'd0;
            vcount <= 10'd0;
        end else begin
            if (hcount == 10'd799) begin
                hcount <= 10'd0;
                if (vcount == 10'd524)
                    vcount <= 10'd0;
                else
                    vcount <= vcount + 10'd1;
            end else begin
                hcount <= hcount + 10'd1;
            end
        end
    end

    logic vis_c, hs_c, vs_c;
    assign vis_c = (hcount < 10'd640) && (vcount < 10'd480);
    assign hs_c  = ~((hcount >= 10'd656) && (hcount <= 10'd751));   // active low
    assign vs_c  = ~((vcount >= 10'd490) && (vcount <= 10'd491));   // active low

    // ════════════════════════════════════════════════════════════════════════
    // Fetch trigger (clk_25): toggle + line number into clk_50 domain
    // ════════════════════════════════════════════════════════════════════════

    logic       fetch_toggle;
    logic [7:0] fetch_line;     // framebuffer line to fetch next (0..239)

    always @(posedge clk_25 or negedge rst_n) begin
        if (!rst_n) begin
            fetch_toggle <= 1'b0;
            fetch_line   <= 8'd0;
        end else if (hcount == 10'd640) begin               // start of hblank
            if ((vcount < 10'd478) && (vcount[0] == 1'b0)) begin
                // first repeat of FB line L = vcount/2 -> prefetch L+1
                fetch_line   <= vcount[8:1] + 8'd1;
                fetch_toggle <= ~fetch_toggle;
            end else if (vcount == 10'd522) begin
                // vblank: prefetch line 0 for the next frame (into bank 0)
                fetch_line   <= 8'd0;
                fetch_toggle <= ~fetch_toggle;
            end
        end
    end

    // ════════════════════════════════════════════════════════════════════════
    // Line fetcher (clk_50)
    // ════════════════════════════════════════════════════════════════════════

    logic [2:0] tog_sync;
    always @(posedge clk_50 or negedge rst_n) begin
        if (!rst_n)
            tog_sync <= 3'b000;
        else
            tog_sync <= {tog_sync[1:0], fetch_toggle};
    end
    wire fetch_start = tog_sync[2] ^ tog_sync[1];           // 1-cycle pulse per toggle

    typedef enum logic {F_IDLE, F_REQ} fstate_t;
    fstate_t    fstate;
    logic [8:0] wptr;           // word index within the line (0..319)
    logic       fill_bank;      // which line-buffer bank this fetch fills

    always @(posedge clk_50 or negedge rst_n) begin
        if (!rst_n) begin
            fstate    <= F_IDLE;
            fb_req    <= 1'b0;
            fb_addr   <= 32'h0;
            fb_len    <= 10'd0;
            wptr      <= 9'd0;
            fill_bank <= 1'b0;
        end else begin
            case (fstate)
                F_IDLE: begin
                    if (fetch_start && enable_reg) begin
                        fb_addr   <= fb_base_reg + ({24'd0, fetch_line} << 10);  // stride 1024B
                        fb_len    <= 10'd320;
                        fill_bank <= fetch_line[0];          // line L lives in bank L[0]
                        wptr      <= 9'd0;
                        fb_req    <= 1'b1;
                        fstate    <= F_REQ;
                    end
                end

                F_REQ: begin
                    if (fb_valid)
                        wptr <= wptr + 9'd1;
                    if (fb_done) begin
                        fb_req <= 1'b0;
                        fstate <= F_IDLE;
                    end
                end
            endcase
        end
    end

    // ════════════════════════════════════════════════════════════════════════
    // Ping-pong line buffer: 2 banks x 512 x 16 = one dual-clock M10K pair
    //   write side: clk_50 (burst fill)   read side: clk_25 (scanout)
    // ════════════════════════════════════════════════════════════════════════

    (* ramstyle = "M10K" *) logic [15:0] linebuf [0:1023];

    always @(posedge clk_50) begin
        if (fb_valid && (fstate == F_REQ))
            linebuf[{fill_bank, wptr}] <= fb_data;
    end

    logic [15:0] pix_q;
    logic        hs_d, vs_d, vis_d;

    always @(posedge clk_25) begin
        pix_q <= linebuf[{vcount[1], hcount[9:1]}];  // bank = FB-line parity
        hs_d  <= hs_c;                               // delay controls 1 clock to
        vs_d  <= vs_c;                               // match sync-read latency
        vis_d <= vis_c;
    end

    // ════════════════════════════════════════════════════════════════════════
    // RGB565 -> 10-bit DAC outputs
    // ════════════════════════════════════════════════════════════════════════

    logic [1:0] en_sync_25;
    always @(posedge clk_25 or negedge rst_n) begin
        if (!rst_n)
            en_sync_25 <= 2'b00;
        else
            en_sync_25 <= {en_sync_25[0], enable_reg};
    end

    wire [15:0] pix = (vis_d && en_sync_25[1]) ? pix_q : 16'h0000;

    assign VGA_R     = {pix[15:11], pix[15:11]};     // 5 -> 10 bits
    assign VGA_G     = {pix[10:5],  pix[10:7]};      // 6 -> 10 bits
    assign VGA_B     = {pix[4:0],   pix[4:0]};       // 5 -> 10 bits
    assign VGA_HS    = hs_d;
    assign VGA_VS    = vs_d;
    assign VGA_BLANK = vis_d;                        // active high during visible
    assign VGA_SYNC  = 1'b0;
    assign VGA_CLK   = clk_25;

endmodule: vga_framebuffer_sdram

// =============================================================================
// vga_framebuffer.sv
// 320x240 RGB565 framebuffer, scaled 2x to 640x480 @ 60Hz.
// CPU port: 32-bit, word-addressable, two RGB565 pixels per word
//           word[15:0]  = pixel at even x
//           word[31:16] = pixel at odd x
// VGA port: read-only at 25 MHz, scans out one pixel per VGA clock.
// Backed by Quartus-generated dual-port RAM `framebuffer_ram`.
// =============================================================================
module vga_framebuffer (
    input  logic        clk_50,           // CPU clock
    input  logic        clk_25,           // VGA pixel clock (from PLL)
    input  logic        rst_n,

    // CPU bus (looks just like SDRAM/RAM port)
    input  logic        VGA_Select,       // address decoder hit
    input  logic        AS_L,
    input  logic        WE_L,
    input  logic [31:0] Address,
    input  logic [3:0]  ByteEnable,
    input  logic [31:0] DataIn,
    output logic [31:0] DataOut,

    // VGA outputs
    output logic [9:0]  VGA_R,
    output logic [9:0]  VGA_G,
    output logic [9:0]  VGA_B,
    output logic        VGA_HS,
    output logic        VGA_VS,
    output logic        VGA_BLANK,
    output logic        VGA_SYNC,
    output logic        VGA_CLK
);

    // -----------------------------------------------------------------------
    // CPU side: decode address into framebuffer word index.
    // Address[16:3] selects one of 38400 words (320*240/2).
    //   Address[2] is don't-care because each word IS one 32-bit aligned pair.
    //   Wait -- we want word-aligned, so use Address[16:2].
    // Each word covers two horizontally adjacent pixels at (2k, y) and (2k+1, y).
    // Word index = y * 160 + (x >> 1)
    // Byte address from CPU: byte_addr = (y*320 + x) * 2
    //                                  = y*640 + x*2
    // Word address (Address[16:2])    = byte_addr >> 2 = (y*320 + x) >> 1
    //                                  = y*160 + (x>>1)   ✓
    // -----------------------------------------------------------------------

    logic        cpu_we;
    logic [15:0] cpu_word_addr;
    logic [31:0] cpu_q;

    assign cpu_word_addr = Address[17:2];
    assign cpu_we        = VGA_Select & ~AS_L & ~WE_L;
    assign DataOut       = cpu_q;       // CPU readback (one cycle latency)

    // -----------------------------------------------------------------------
    // VGA timing generator @ 25 MHz (640x480 @ 60Hz, standard timings)
    // -----------------------------------------------------------------------
    localparam int H_VISIBLE   = 640;
    localparam int H_FRONT     = 16;
    localparam int H_SYNC      = 96;
    localparam int H_BACK      = 48;
    localparam int H_TOTAL     = H_VISIBLE + H_FRONT + H_SYNC + H_BACK; // 800

    localparam int V_VISIBLE   = 480;
    localparam int V_FRONT     = 10;
    localparam int V_SYNC      = 2;
    localparam int V_BACK      = 33;
    localparam int V_TOTAL     = V_VISIBLE + V_FRONT + V_SYNC + V_BACK; // 525

    logic [10:0] hcount, vcount;

    always_ff @(posedge clk_25 or negedge rst_n) begin
        if (!rst_n) begin
            hcount <= '0;
            vcount <= '0;
        end else if (hcount == H_TOTAL - 1) begin
            hcount <= '0;
            vcount <= (vcount == V_TOTAL - 1) ? 11'd0 : vcount + 1'b1;
        end else begin
            hcount <= hcount + 1'b1;
        end
    end

    // active-low sync, active-high blank-during-active (we'll invert at output)
    logic h_active, v_active, active;
    assign h_active = (hcount < H_VISIBLE);
    assign v_active = (vcount < V_VISIBLE);
    assign active   = h_active & v_active;

    logic hs_n, vs_n;
    assign hs_n = ~((hcount >= H_VISIBLE + H_FRONT) &&
                    (hcount <  H_VISIBLE + H_FRONT + H_SYNC));
    assign vs_n = ~((vcount >= V_VISIBLE + V_FRONT) &&
                    (vcount <  V_VISIBLE + V_FRONT + V_SYNC));

    // -----------------------------------------------------------------------
    // Address-into-framebuffer for VGA read.
    // We scale 2x by halving the screen coordinates.
    //   fb_x = hcount >> 1    (0..319)
    //   fb_y = vcount >> 1    (0..239)
    //   word_index = fb_y * 160 + (fb_x >> 1)
    //   pixel_select = fb_x[0]    (which half of the word)
    //
    // We need the data 1 cycle BEFORE we use it because the RAM has 1-cycle
    // read latency. So we issue the address based on hcount, and pipeline the
    // pixel-select bit alongside the data.
    // -----------------------------------------------------------------------

    logic [8:0]  fb_x;       // 0..319
    logic [7:0]  fb_y;       // 0..239
    logic [15:0] vga_word_addr;
    logic        pixel_lane; // 0 = lower half (even x), 1 = upper half

    assign fb_x = hcount[9:1];
    assign fb_y = vcount[8:1];
    assign vga_word_addr = fb_y * 16'd160 + {7'd0, fb_x[8:1]};   // synth will collapse the mul
    assign pixel_lane    = fb_x[0];

    // Pipeline pixel_lane and active by 1 cycle to align with RAM Q output
    logic pixel_lane_d, active_d;
    logic hs_n_d, vs_n_d;
    always_ff @(posedge clk_25 or negedge rst_n) begin
        if (!rst_n) begin
            pixel_lane_d <= 1'b0;
            active_d     <= 1'b0;
            hs_n_d       <= 1'b1;
            vs_n_d       <= 1'b1;
        end else begin
            pixel_lane_d <= pixel_lane;
            active_d     <= active;
            hs_n_d       <= hs_n;
            vs_n_d       <= vs_n;
        end
    end

    // -----------------------------------------------------------------------
    // Dual-port framebuffer RAM (Quartus-generated)
    // -----------------------------------------------------------------------
    logic [31:0] vga_q;

    framebuffer_ram fb_ram (
        .address_a (cpu_word_addr),
        .address_b (vga_word_addr),
        .byteena_a (ByteEnable),
        .byteena_b (4'b1111),
        .inclock   (clk_50),
        .outclock   (clk_25),
        .data_a    (DataIn),
        .data_b    (32'd0),
        .wren_a    (cpu_we),
        .wren_b    (1'b0),
        .q_a       (cpu_q),
        .q_b       (vga_q)
    );

    // -----------------------------------------------------------------------
    // Pixel formatter: pick one RGB565 pixel out of the 32-bit word, expand
    // to 10-bit-per-channel for the DAC.
    // RGB565: [15:11]=R5, [10:5]=G6, [4:0]=B5
    // Expand R5/B5 -> 10 bits by replicating MSBs; G6 -> 10 bits similarly.
    // -----------------------------------------------------------------------
    logic [15:0] pixel;
    assign pixel = pixel_lane_d ? vga_q[31:16] : vga_q[15:0];

    logic [4:0] r5;
    logic [5:0] g6;
    logic [4:0] b5;
    assign r5 = pixel[15:11];
    assign g6 = pixel[10:5];
    assign b5 = pixel[4:0];

    // 5->10 and 6->10 bit expansion by replication
    logic [9:0] r10, g10, b10;
    assign r10 = {r5, r5};
    assign g10 = {g6, g6[5:2]};
    assign b10 = {b5, b5};

    always_ff @(posedge clk_25 or negedge rst_n) begin
        if (!rst_n) begin
            VGA_R     <= '0;
            VGA_G     <= '0;
            VGA_B     <= '0;
            VGA_HS    <= 1'b1;
            VGA_VS    <= 1'b1;
            VGA_BLANK <= 1'b0;
        end else begin
            VGA_R     <= active_d ? r10 : 10'd0;
            VGA_G     <= active_d ? g10 : 10'd0;
            VGA_B     <= active_d ? b10 : 10'd0;
            VGA_HS    <= hs_n_d;
            VGA_VS    <= vs_n_d;
            VGA_BLANK <= active_d;   // active-high blank on DE1-SoC DAC
        end
    end

    assign VGA_SYNC = 1'b1;          // tied high, same as old adapter
    assign VGA_CLK  = clk_25;

endmodule : vga_framebuffer

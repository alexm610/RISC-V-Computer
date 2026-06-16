// =============================================================================
// vga_timing.sv
// 640x480 @ 60Hz timing, displaying a 320x240 RGB565 framebuffer scaled 2x.
// Reads pixels from `line_buffer` instead of an embedded RAM.
// Outputs `target_fb_y` to coordinate with the DMA prefetcher.
// =============================================================================
module vga_timing (
    input  logic        clk_25,
    input  logic        rst_n,

    // Line buffer read interface (1-cycle read latency)
    output logic [7:0]  lb_rd_addr,    // 0..159
    output logic        lb_rd_sel,     // which ping-pong buffer
    input  logic [31:0] lb_rd_data,

    // DMA coordination (clk_25 domain; DMA syncs internally)
    output logic [7:0]  target_fb_y,   // line DMA should ensure is in buf target[0]

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
    localparam int H_VISIBLE = 640;
    localparam int H_FRONT   = 16;
    localparam int H_SYNC    = 96;
    localparam int H_BACK    = 48;
    localparam int H_TOTAL   = 800;
    localparam int V_VISIBLE = 480;
    localparam int V_FRONT   = 10;
    localparam int V_SYNC    = 2;
    localparam int V_BACK    = 33;
    localparam int V_TOTAL   = 525;

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

    logic h_active, v_active, active, hs_n, vs_n;
    assign h_active = (hcount < H_VISIBLE);
    assign v_active = (vcount < V_VISIBLE);
    assign active   = h_active & v_active;
    assign hs_n = ~((hcount >= H_VISIBLE + H_FRONT) &&
                    (hcount <  H_VISIBLE + H_FRONT + H_SYNC));
    assign vs_n = ~((vcount >= V_VISIBLE + V_FRONT) &&
                    (vcount <  V_VISIBLE + V_FRONT + V_SYNC));

    // 2x scale: fb_x = hcount>>1, fb_y = vcount>>1
    logic [8:0] fb_x;
    logic [7:0] fb_y;
    logic       pixel_lane;
    assign fb_x = hcount[9:1];
    assign fb_y = vcount[8:1];

    // Line buffer read address: word index within line = fb_x >> 1
    assign lb_rd_addr = fb_x[8:1];
    assign lb_rd_sel  = fb_y[0];        // ping-pong by line parity
    assign pixel_lane = fb_x[0];

    // Pipeline pixel_lane, sync, active by 1 cycle to align with lb_rd_data
    logic pixel_lane_d, active_d, hs_n_d, vs_n_d;
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

    // RGB565 -> 10-bit DAC via replication
    logic [15:0] pixel;
    assign pixel = pixel_lane_d ? lb_rd_data[31:16] : lb_rd_data[15:0];

    logic [9:0] r10, g10, b10;
    assign r10 = {pixel[15:11], pixel[15:11]};
    assign g10 = {pixel[10:5],  pixel[10:7]};
    assign b10 = {pixel[4:0],   pixel[4:0]};

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
            VGA_BLANK <= active_d;
        end
    end

    assign VGA_SYNC = 1'b1;
    assign VGA_CLK  = clk_25;

    // -------------------------------------------------------------------
    // Tell DMA what to prefetch.
    //   During visible: (fb_y + 1) mod 240
    //   During vblank : 0           (so line 0 is ready for next frame)
    // -------------------------------------------------------------------
    always_comb begin
        if (!v_active)            target_fb_y = 8'd0;
        else if (fb_y == 8'd239)  target_fb_y = 8'd0;
        else                      target_fb_y = fb_y + 8'd1;
    end

endmodule : vga_timing

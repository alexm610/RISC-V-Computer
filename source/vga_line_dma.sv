// =============================================================================
// vga_line_dma.sv
// One-line-at-a-time DMA engine.
// Monitors `current_target` from vga_timing (clk_25), and whenever the target
// differs from what was last fetched, bursts that 160-word line out of SDRAM
// into the ping-pong line_buffer. Acts as a master on the M68k-style bus.
// Waits for CPU to be idle on the RAM bus before starting (no preemption).
// =============================================================================
module vga_line_dma (
    input  logic        clk,             // clk_50
    input  logic        rst_n,
    input  logic [31:0] fb_base_addr,    // top of framebuffer region in SDRAM

    // From vga_timing (clk_25 domain - synced internally)
    input  logic [7:0]  current_target,

    // CPU bus state (for non-preemptive arbitration)
    input  logic        cpu_as_l,
    input  logic        cpu_ram_select,

    // SDRAM bus master (M68k style)
    output logic        dma_active,
    output logic        dma_as_l,
    output logic [31:0] dma_address,
    input  logic [31:0] dma_rdata,
    input  logic        dma_dtack,

    // Line buffer write
    output logic        lb_we,
    output logic        lb_wr_sel,
    output logic [7:0]  lb_wr_addr,
    output logic [31:0] lb_wr_data
);
    localparam int WORDS_PER_LINE = 160;

    // 2-FF sync for target_fb_y (multi-bit but stable for ~64us at a time)
    logic [7:0] target_s1, target_s2;
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            target_s1 <= 8'd0;
            target_s2 <= 8'd0;
        end else begin
            target_s1 <= current_target;
            target_s2 <= target_s1;
        end
    end

    logic [7:0] last_fetched;
    logic       need_fetch;
    assign need_fetch = (target_s2 != last_fetched);

    logic cpu_ram_active;
    assign cpu_ram_active = ~cpu_as_l & cpu_ram_select;

    typedef enum logic [1:0] { IDLE, ADDR, NEXT, DONE_LINE } state_t;
    state_t state;
    logic [7:0] word_idx;
    logic [7:0] fetch_line;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state        <= IDLE;
            word_idx     <= 8'd0;
            fetch_line   <= 8'd0;
            last_fetched <= 8'hFF;       // force initial fetch
            lb_we        <= 1'b0;
            lb_wr_addr   <= 8'd0;
            lb_wr_data   <= 32'd0;
            lb_wr_sel    <= 1'b0;
        end else begin
            lb_we <= 1'b0;
            case (state)
                IDLE: begin
                    if (need_fetch && !cpu_ram_active) begin
                        fetch_line <= target_s2;
                        word_idx   <= 8'd0;
                        state      <= ADDR;
                    end
                end

                ADDR: begin
                    if (dma_dtack) begin
                        lb_we      <= 1'b1;
                        lb_wr_sel  <= fetch_line[0];
                        lb_wr_addr <= word_idx;
                        lb_wr_data <= dma_rdata;
                        state      <= NEXT;
                    end
                end

                NEXT: begin
                    if (!dma_dtack) begin
                        if (word_idx == WORDS_PER_LINE - 1) begin
                            state <= DONE_LINE;
                        end else begin
                            word_idx <= word_idx + 8'd1;
                            state    <= ADDR;
                        end
                    end
                end

                DONE_LINE: begin
                    last_fetched <= fetch_line;
                    state        <= IDLE;
                end
            endcase
        end
    end

    // Combinational bus signals
    always_comb begin
        dma_active = 1'b0;
        dma_as_l   = 1'b1;
        case (state)
            ADDR: begin dma_active = 1'b1; dma_as_l = 1'b0; end
            NEXT: begin dma_active = 1'b1; dma_as_l = 1'b1; end
            default: ;
        endcase
    end

    assign dma_address = fb_base_addr +
                         ((fetch_line * WORDS_PER_LINE + word_idx) << 2);
endmodule : vga_line_dma
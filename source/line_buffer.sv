// =============================================================================
// line_buffer.sv
// Tiny ping-pong line buffer (~10 Kb total, 1x M10K) sitting between the DMA
// (clk_50 write side) and VGA timing (clk_25 read side).
// 2 buffers x 160 words x 32 bits. Each word holds two RGB565 pixels.
// =============================================================================
module line_buffer (
    // Write port (DMA, clk_50)
    input  logic        wr_clk,
    input  logic        wr_we,
    input  logic        wr_sel,        // which buffer (0/1)
    input  logic [7:0]  wr_addr,       // 0..159
    input  logic [31:0] wr_data,

    // Read port (VGA, clk_25)
    input  logic        rd_clk,
    input  logic        rd_sel,        // which buffer (0/1)
    input  logic [7:0]  rd_addr,       // 0..159
    output logic [31:0] rd_data
);
    // 9-bit address space: {sel, addr[7:0]}. Quartus will infer M10K.
    logic [31:0] mem [0:511];

    always_ff @(posedge wr_clk) begin
        if (wr_we) mem[{wr_sel, wr_addr}] <= wr_data;
    end

    always_ff @(posedge rd_clk) begin
        rd_data <= mem[{rd_sel, rd_addr}];
    end
endmodule : line_buffer
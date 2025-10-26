module ledr_peripheral  (input logic clk, input logic rst_n, input logic write, input logic [31:0] writedata,
                        output logic [9:0] ledr_output);

    always @(posedge clk) begin
        if (!rst_n) begin
            ledr_output     <= 10'h0;
        end else begin
            if (write) begin
                ledr_output     <= writedata[9:0];
            end else begin
                ledr_output     <= ledr_output;
            end
        end
    end
endmodule: ledr_peripheral
module sw_peripheral    (input logic clk, input logic rst_n, input logic [9:0] switch_input,
                        output logic [31:0] switch_output);

    always @(posedge clk) begin
        if (!rst_n) begin
            switch_output   <= 32'h0;
        end else begin
            switch_output   <= {{22{switch_input[9]}}, switch_input};
        end
    end
endmodule: sw_peripheral
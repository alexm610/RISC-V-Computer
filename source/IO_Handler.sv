module IO_Handler   (input logic [9:0] SW_input, input logic AS_L, input logic WE_L, input logic IO_Select, input logic [9:0] Address, input logic [31:0] IO_data_in, 
                    output logic [9:0] LEDR_output, output logic [31:0] IO_data_out);
    always @(*) begin
        IO_data_out     <= 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
        
        
    end
endmodule: IO_Handler
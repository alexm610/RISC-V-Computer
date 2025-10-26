module SRAM_Controller   (input logic Clock, 
                        input logic AS_L, 
                        input logic WE_L,
                        input logic [3:0] Byte_E,
                        input logic RAM_Select_H,
                        input logic [31:0] Data_In, 
                        input logic [9:0] Address,
                        output logic [31:0] Data_Out);

    logic write_enable;
    logic [31:0] SRAM_output;

    assign Data_Out = ((AS_L == 0) && (WE_L == 1) && (RAM_Select_H == 1)) ? SRAM_output : 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
    assign write_enable = ((AS_L == 0) && (WE_L == 0) && (RAM_Select_H == 1)) ? 1 : 0;
endmodule: SRAM_Controller
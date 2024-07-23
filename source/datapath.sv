    /**
     ** 
     ** Need to instantiate within this datapath module:
     **      - Instruction memory (ROM)
     **      - Data memory (RAM)
     **      - Register bank
     **      - ALU
     **      - Program counter hardware 
     **          - Including the multiplexers that either increment the 
     **              program counter by 4 or branches to somewhere else 
     **      - Connect output of data memory (RAM) to the "writedata" port of 
     **          the register bank
    */
module datapath (input logic clk, input logic rst_n, input logic write_rb,
                input logic [2:0] alu_control,  
                input logic [4:0] rs_1, rs_2, rd_0,
                input logic [31:0] writedata,
                output logic [31:0] alu_result);

    logic [31:0] A_out, B_out;

    reg_file REGISTER_BANK      (.clk(clk),
                                .reset_n(rst_n),
                                .rs1(rs_1),
                                .rs2(rs_2),
                                .rd(rd_0),
                                .write(write_rb),
                                .writedata(writedata),
                                .readdata_1(A_out),
                                .readdata_2(B_out));

    alu ALU                     (.Ain(A_out),
                                .Bin(B_out),
                                .ALUop(alu_control),
                                .out(alu_result),
                                .status());
endmodule: datapath 
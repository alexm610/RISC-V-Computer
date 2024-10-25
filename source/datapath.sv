module datapath (input logic clk, rst_n, write_rb, alu_source,
                input logic [3:0] alu_control,  
                input logic [4:0] rs_1, rs_2, rd_0,
                input logic [31:0] writedata, immediate,
                output logic negative, overflow, zero,
                output logic [31:0] alu_result, rs2);

    logic [31:0] A_in, B_in, rs_2_out;

    assign rs2  = rs_2_out;
    assign B_in = alu_source ? rs_2_out : immediate;

    reg_file REGISTER_BANK      (.clk(clk),
                                .reset_n(rst_n),
                                .rs1(rs_1),
                                .rs2(rs_2),
                                .rd(rd_0),
                                .write(write_rb),
                                .writedata(writedata),
                                .readdata_1(A_in),
                                .readdata_2(rs_2_out));

    alu ALU                     (.Ain(A_in),
                                .Bin(B_in),
                                .ALUop(alu_control),
                                .out(alu_result),
                                .status({negative, overflow, zero}));
endmodule: datapath 
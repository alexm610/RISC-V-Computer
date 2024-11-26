`timescale 1ps/1ps
//`include "defines.sv"

/*
    Register bank in RV32I ISA has 32 registers, each 32 bits wide;
    Register to be read/written to is given by input signal writenum/readnum
        these location signals are decoded into a one-hot signal, which is how the module knows which reg to write/read to/from

    Note that the `write' signal applies to whatever register is defined by the `rd' signal
*/
module reg_file    (input logic clk, input logic reset_n, input logic write, 
                    input logic [4:0] rs1, input logic [4:0] rs2, input logic [4:0] rd, 
                    input logic [31:0] writedata, output logic [31:0] readdata_1, output logic [31:0] readdata_2);

    logic [31:0] addr_1, addr_2, addr_d, x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31;

    decoder #(5, 32) RS_1 (rs1, addr_1);
    decoder #(5, 32) RS_2 (rs2, addr_2);
    decoder #(5, 32) RD_0 (rd, addr_d);

    multiplexer_32input #(32) DATA_OUT_1 (x31, x30, x29, x28, x27, x26, x25, x24, x23, x22, x21, x20, x19, x18, x17, x16, x15, x14, x13, x12, x11, x10, x9, x8, x7, x6, x5, x4, x3, x2, x1, x0, addr_1, readdata_1);
    multiplexer_32input #(32) DATA_OUT_2 (x31, x30, x29, x28, x27, x26, x25, x24, x23, x22, x21, x20, x19, x18, x17, x16, x15, x14, x13, x12, x11, x10, x9, x8, x7, x6, x5, x4, x3, x2, x1, x0, addr_2, readdata_2);

    register #(32) X0  (clk, reset_n, writedata, write & (addr_d[0]),  x0); //-> should be hardwired to ZERO
    register #(32) X1  (clk, reset_n, writedata, write & (addr_d[1]),  x1);
    register #(32) X2  (clk, reset_n, writedata, write & (addr_d[2]),  x2);
    register #(32) X3  (clk, reset_n, writedata, write & (addr_d[3]),  x3);
    register #(32) X4  (clk, reset_n, writedata, write & (addr_d[4]),  x4);
    register #(32) X5  (clk, reset_n, writedata, write & (addr_d[5]),  x5);
    register #(32) X6  (clk, reset_n, writedata, write & (addr_d[6]),  x6);
    register #(32) X7  (clk, reset_n, writedata, write & (addr_d[7]),  x7);
    register #(32) X8  (clk, reset_n, writedata, write & (addr_d[8]),  x8);
    register #(32) X9  (clk, reset_n, writedata, write & (addr_d[9]),  x9);
    register #(32) X10 (clk, reset_n, writedata, write & (addr_d[10]), x10);
    register #(32) X11 (clk, reset_n, writedata, write & (addr_d[11]), x11);
    register #(32) X12 (clk, reset_n, writedata, write & (addr_d[12]), x12);
    register #(32) X13 (clk, reset_n, writedata, write & (addr_d[13]), x13);
    register #(32) X14 (clk, reset_n, writedata, write & (addr_d[14]), x14);
    register #(32) X15 (clk, reset_n, writedata, write & (addr_d[15]), x15);
    register #(32) X16 (clk, reset_n, writedata, write & (addr_d[16]), x16);
    register #(32) X17 (clk, reset_n, writedata, write & (addr_d[17]), x17);
    register #(32) X18 (clk, reset_n, writedata, write & (addr_d[18]), x18);
    register #(32) X19 (clk, reset_n, writedata, write & (addr_d[19]), x19);
    register #(32) X20 (clk, reset_n, writedata, write & (addr_d[20]), x20);
    register #(32) X21 (clk, reset_n, writedata, write & (addr_d[21]), x21);
    register #(32) X22 (clk, reset_n, writedata, write & (addr_d[22]), x22);
    register #(32) X23 (clk, reset_n, writedata, write & (addr_d[23]), x23);
    register #(32) X24 (clk, reset_n, writedata, write & (addr_d[24]), x24);
    register #(32) X25 (clk, reset_n, writedata, write & (addr_d[25]), x25);
    register #(32) X26 (clk, reset_n, writedata, write & (addr_d[26]), x26);
    register #(32) X27 (clk, reset_n, writedata, write & (addr_d[27]), x27);
    register #(32) X28 (clk, reset_n, writedata, write & (addr_d[28]), x28);
    register #(32) X29 (clk, reset_n, writedata, write & (addr_d[29]), x29);
    register #(32) X30 (clk, reset_n, writedata, write & (addr_d[30]), x30);
    register #(32) X31 (clk, reset_n, writedata, write & (addr_d[31]), x31);
endmodule: reg_file

module register (clock, reset, in, enable, out);
    parameter k = 32;
    input logic clock, reset, enable;
    input logic [k-1:0] in;
    output logic signed [k-1:0] out;

    always @(posedge clock) begin
        if (!reset) begin
            out = {k{1'b0}};
        end else begin
            case (enable)
                1'b1: out <= in;
                1'b0: out <= out;
                default: out <= out;
            endcase
        end
    end
endmodule

module multiplexer_3input (a2, a1, a0, s, out); 
    parameter width = 32;
    input logic [2:0] s; // select signal is one-hot
    input logic [width-1:0] a2, a1, a0;
    output logic [width-1:0] out;

    always @(*) begin
        case (s)
            3'b001: out = a0;
            3'b010: out = a1;
            3'b100: out = a2;
            default: out = {width{1'b0}};
        endcase     
    end
endmodule: multiplexer_3input

module multiplexer_32input(a31, a30, a29, a28, a27, a26, a25, a24, a23, a22, a21, a20, a19, a18, a17, a16, a15, a14, a13, a12, a11, a10, a9, a8, a7, a6, a5, a4, a3, a2, a1, a0, s, out); // this multiplexer is the one that takes the register files as input, and outputs data_out
    parameter signal_width = 1;
    input logic [signal_width-1:0] a31, a30, a29, a28, a27, a26, a25, a24, a23, a22, a21, a20, a19, a18, a17, a16, a15, a14, a13, a12, a11, a10, a9, a8, a7, a6, a5, a4, a3, a2, a1, a0;
    input logic [31:0] s;
    output logic [signal_width-1:0] out;

    always @(*) begin // select signal is one-hot
        case(s)
            32'b00000000000000000000000000000001: out = 32'h0; // ISA dictates that register X0 be hardwired to zero
            32'b00000000000000000000000000000010: out = a1;
            32'b00000000000000000000000000000100: out = a2;
            32'b00000000000000000000000000001000: out = a3;
            32'b00000000000000000000000000010000: out = a4;
            32'b00000000000000000000000000100000: out = a5;
            32'b00000000000000000000000001000000: out = a6;
            32'b00000000000000000000000010000000: out = a7;
            32'b00000000000000000000000100000000: out = a8;
            32'b00000000000000000000001000000000: out = a9;
            32'b00000000000000000000010000000000: out = a10;
            32'b00000000000000000000100000000000: out = a11;
            32'b00000000000000000001000000000000: out = a12;
            32'b00000000000000000010000000000000: out = a13;
            32'b00000000000000000100000000000000: out = a14;
            32'b00000000000000001000000000000000: out = a15;
            32'b00000000000000010000000000000000: out = a16;
            32'b00000000000000100000000000000000: out = a17;
            32'b00000000000001000000000000000000: out = a18;
            32'b00000000000010000000000000000000: out = a19;
            32'b00000000000100000000000000000000: out = a20;
            32'b00000000001000000000000000000000: out = a21;
            32'b00000000010000000000000000000000: out = a22;
            32'b00000000100000000000000000000000: out = a23;
            32'b00000001000000000000000000000000: out = a24;
            32'b00000010000000000000000000000000: out = a25;
            32'b00000100000000000000000000000000: out = a26;
            32'b00001000000000000000000000000000: out = a27;
            32'b00010000000000000000000000000000: out = a28;
            32'b00100000000000000000000000000000: out = a29; 
            32'b01000000000000000000000000000000: out = a30;
            32'b10000000000000000000000000000000: out = a31;
            default: out = {signal_width{1'bx}};
        endcase
    end
endmodule

module decoder(a, b);
    parameter n = 3;
    parameter m = 8;
    input [n-1:0] a;
    output [m-1:0] b;

    wire [m-1:0] b = 1 << a;
endmodule
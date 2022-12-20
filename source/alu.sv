`include "defines.sv"

module ALU (Ain, Bin, ALUop, out, status);
    input logic [3:0] ALUop;
    input logic [31:0] Ain, Bin;
    output logic [2:0] status;
    output logic [31:0] out, dummy_output;
    logic overflow;

    AddSub #(32) overflow_detection (Ain, Bin, 1, dummy_output, overflow);

    always @(*) begin
        case (ALUop) 
            4'b0000: out = `ADD;
            4'b0001: out = `SUB;
            4'b0010: out = `AND;
            4'b0011: out = `OR;
            4'b0100: out = `NOT;
            4'b0101: out = `XOR;
            4'b0110: out = `SL; 
            4'b0111: out = `SR;
        endcase
    end

    // set status bits: status = {NEGATIVE, OVERFLOW, ZERO}
    always @(*) begin
        case (out) 
            32'd0: status[0] = 1
            default: status[0] = 0;
        endcase
        case (overflow)
            0: status[1] = 0;
            1: status[1] = 1;
        endcase
        case (out[31])
            1: status[2] = 1;
            default: status[2] = 0;
        endcase
    end
endmodule: ALU

module AddSub (a, b, sub, s, ovf);
    parameter n = 32;
    input logic sub;
    input logic [n-1:0] a, b;
    output logic ovf;
    output logic [n-1:0] s;
    logic c1, c2;

    assign ovf = c1 ^ c2;
    assign {c1, s[n-2:0]} = a[n-2:0] + (b[n-2:0] ^ {n-1{sub}}) + sub;
	assign {c2, s[n-1]} = a[n-1] + (b[n-1] ^ sub) + c1;
endmodule: AddSub
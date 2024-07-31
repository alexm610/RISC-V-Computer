`include "defines.sv"

module alu (Ain, Bin, ALUop, out, status);
    input logic [2:0] ALUop;
    input logic signed [31:0] Ain, Bin;
    output logic [2:0] status;
    output logic [31:0] out;
    logic [31:0] dummy_output;
    logic overflow;

    AddSub #(32) overflow_detection (Ain, Bin, 32'h1, dummy_output, overflow);

    always @(*) begin
        case (ALUop) 
            `ADD:   out = Ain + Bin;
            `XOR:   out = Ain ^ Bin;
            `OR:    out = Ain | Bin;
            `AND:   out = Ain & Bin;
            `SL:    out = Ain << Bin[4:0];
            `SR: begin    
                if (Bin[10]) begin
                    out = Ain >>> Bin[4:0];
                end else begin
                    out = Ain >> Bin[4:0];
                end
            end
            default: out = 32'd0;
        endcase
    end

    // set status bits: status = {NEGATIVE, OVERFLOW, ZERO}
    always @(*) begin
        case (out) 
            32'd0: status[0] = 1;
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
endmodule: alu

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
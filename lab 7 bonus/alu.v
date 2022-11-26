module ALU (Ain, Bin, ALUop, out, status);
    input [15:0] Ain, Bin;
    input [1:0] ALUop;
    output [15:0] out;
    output reg [2:0] status;
    reg [15:0] out;
    wire [15:0] dummy_output;
    wire overflow;

    always @(*) begin
        case(ALUop)
            2'b00: out = Ain + Bin;
            2'b01: out = Ain - Bin;
            2'b10: out = Ain & Bin;
            2'b11: out = ~Bin;
            default: out = 16'b0;
        endcase
    end
    
    // status bit settings ----- bit 0: Z, bit 1: V, bit 2: N
	always @(*) begin
		case (out)
 			16'b0: status[0] = 1;
			default: status[0] = 0;
		endcase
		
		case (out[15])
			1'b1: status[2] = 1'b1;
			default: status[2] = 1'b0;
		endcase
		
		case (overflow)
			1'b1: status[1] = 1'b1;
			1'b0: status[1] = 1'b0;
			default: status[1] = 1'b0;
		endcase
	end

	// check overflow
	AddSub1 #(16) overflow_detection(Ain, Bin, 1'b1, dummy_output, overflow); 
endmodule

module AddSub1 (a, b, sub, s, ovf); // this code is copied from the textbook
	parameter n = 16;
	input [n-1:0] a, b;
	input sub;
	output [n-1:0] s;
	output ovf;
	wire c1, c2;
		
	assign ovf = c1 ^ c2;
	assign {c1, s[n-2:0]} = a[n-2:0] + (b[n-2:0] ^{n-1{sub}}) + sub;
	assign {c2, s[n-1]} = a[n-1] + (b[n-1] ^ sub) + c1;
endmodule


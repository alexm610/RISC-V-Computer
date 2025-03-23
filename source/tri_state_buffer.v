module tri_state_buffer (input Enable, input [31:0] DataIn, output [31:0] DataOut);
	
	assign DataOut = Enable ? DataIn : 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;

endmodule

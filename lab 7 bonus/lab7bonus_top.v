`define M_READ	     7'b1100000
`define M_WRITE		 7'b1110000
`define M_NONE	 	 7'b1010000

module lab7bonus_top (KEY, SW, LEDR, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, CLOCK_50);
	input CLOCK_50;	
	input [3:0] KEY;
	input [9:0] SW;
	output [9:0] LEDR;
	output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;

	wire [15:0] data_out_memory, d_out, datapath_out;
	wire N, V, Z, halt_signal;
	wire [8:0] memory_address;
	wire [6:0] memory_command;
	wire write_equality_comparator, read_equality_comparator, bottom_equality_comparator; 
	wire LED_command_comparator, LED_address_comparator;
	wire LED_enable;
	wire SWITCH_command_comparator, SWITCH_address_comparator;
	
	RAM MEM (CLOCK_50, memory_address[7:0], memory_address[7:0], (write_equality_comparator & bottom_equality_comparator), datapath_out, d_out);
	CPU CPU (CLOCK_50, ~KEY[1], data_out_memory, datapath_out, N, V, Z, halt_signal, memory_address, memory_command); // don't connect wait_signal to anything for now
	
	assign read_equality_comparator = (memory_command == `M_READ) ? 1'b1 : 1'b0;
	assign write_equality_comparator = (memory_command == `M_WRITE) ? 1'b1 : 1'b0;
	assign bottom_equality_comparator = (memory_address[8] == 1'b0) ? 1'b1 : 1'b0;

	assign data_out_memory = (read_equality_comparator & bottom_equality_comparator) ? d_out : {16{1'bz}};      
	//////// SWITCH AND LED INTERFACE ////////

	// LED interface
	assign LED_command_comparator = (memory_command == `M_WRITE) ? 1'b1 : 1'b0;
	assign LED_address_comparator = (memory_address == 9'h100) ? 1'b1 : 1'b0;
	assign LED_enable = LED_command_comparator & LED_address_comparator;
	
	reg_load_enable #(8) LED_register (CLOCK_50, datapath_out[7:0], LED_enable, LEDR[7:0]);
	assign LEDR[8] = halt_signal;

	// SWITCH interface
	assign SWITCH_command_comparator = (memory_command == `M_READ) ? 1'b1 : 1'b0;
	assign SWITCH_address_comparator = (memory_address == 9'h140) ? 1'b1 : 1'b0;
	
	assign data_out_memory = (SWITCH_command_comparator & SWITCH_address_comparator) ? {8'b00000000, SW[7:0]} : {16{1'bz}};

endmodule


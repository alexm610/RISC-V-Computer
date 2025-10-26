// Copyright (C) 2018  Intel Corporation. All rights reserved.
// Your use of Intel Corporation's design tools, logic functions 
// and other software and tools, and its AMPP partner logic 
// functions, and any output files from any of the foregoing 
// (including device programming or simulation files), and any 
// associated documentation or information are expressly subject 
// to the terms and conditions of the Intel Program License 
// Subscription Agreement, the Intel Quartus Prime License Agreement,
// the Intel FPGA IP License Agreement, or other applicable license
// agreement, including, without limitation, that your use is for
// the sole purpose of programming logic devices manufactured by
// Intel and sold by Intel or its authorized distributors.  Please
// refer to the applicable agreement for further details.

// PROGRAM		"Quartus Prime"
// VERSION		"Version 18.1.0 Build 625 09/12/2018 SJ Lite Edition"
// CREATED		"Sat Jul 26 16:41:32 2025"

module OnChipROM16KWords(
	Clock,
	RomSelect_H,
	Write_Enable,
	Address,
	DataIn,
	DataOut
);


input wire	Clock;
input wire	RomSelect_H;
input wire	Write_Enable;
input wire	[11:0] Address;
input wire	[31:0] DataIn;
output wire	[31:0] DataOut;

wire	[31:0] SYNTHESIZED_WIRE_0;
wire	SYNTHESIZED_WIRE_1;





lpm_bustri0	b2v_inst(
	.enabledt(RomSelect_H),
	.data(SYNTHESIZED_WIRE_0),
	.tridata(DataOut)
	);


ROM_16kWords	b2v_inst1(
	.wren(Write_Enable),
	.clock(SYNTHESIZED_WIRE_1),
	.address(Address),
	.data(DataIn),
	.q(SYNTHESIZED_WIRE_0));

assign	SYNTHESIZED_WIRE_1 =  ~Clock;


endmodule

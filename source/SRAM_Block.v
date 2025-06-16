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
// CREATED		"Mon Apr 28 17:44:01 2025"

module SRAM_Block(
	Clock,
	AS_L,
	WE_L,
	RAM_Select_H,
	Address,
	Byte_Enable,
	Data_In,
	Data_Out
);


input wire	Clock;
input wire	AS_L;
input wire	WE_L;
input wire	RAM_Select_H;
input wire	[11:0] Address;
input wire	[3:0] Byte_Enable;
input wire	[31:0] Data_In;
output wire	[31:0] Data_Out;

wire	[31:0] Data_Out_bus;
wire	SYNTHESIZED_WIRE_0;
wire	SYNTHESIZED_WIRE_1;
wire	SYNTHESIZED_WIRE_2;
wire	SYNTHESIZED_WIRE_3;
wire	SYNTHESIZED_WIRE_12;
wire	SYNTHESIZED_WIRE_5;
wire	SYNTHESIZED_WIRE_13;





ram_block	b2v_inst(
	.wren(SYNTHESIZED_WIRE_0),
	.clock(Clock),
	.address(Address),
	.data(Data_In[31:24]),
	.q(Data_Out_bus[31:24]));


ram_block	b2v_inst1(
	.wren(SYNTHESIZED_WIRE_1),
	.clock(Clock),
	.address(Address),
	.data(Data_In[23:16]),
	.q(Data_Out_bus[23:16]));


ram_block	b2v_inst2(
	.wren(SYNTHESIZED_WIRE_2),
	.clock(Clock),
	.address(Address),
	.data(Data_In[15:8]),
	.q(Data_Out_bus[15:8]));


ram_block	b2v_inst3(
	.wren(SYNTHESIZED_WIRE_3),
	.clock(Clock),
	.address(Address),
	.data(Data_In[7:0]),
	.q(Data_Out_bus[7:0]));

assign	SYNTHESIZED_WIRE_12 =  ~AS_L;

assign	SYNTHESIZED_WIRE_5 =  ~WE_L;

assign	SYNTHESIZED_WIRE_13 = RAM_Select_H & SYNTHESIZED_WIRE_12 & SYNTHESIZED_WIRE_5;


assign	SYNTHESIZED_WIRE_0 = SYNTHESIZED_WIRE_13 & Byte_Enable[3];

assign	SYNTHESIZED_WIRE_1 = SYNTHESIZED_WIRE_13 & Byte_Enable[2];

assign	SYNTHESIZED_WIRE_3 = SYNTHESIZED_WIRE_13 & Byte_Enable[0];

assign	SYNTHESIZED_WIRE_2 = SYNTHESIZED_WIRE_13 & Byte_Enable[1];


shadow	b2v_inst8(
	.wren(SYNTHESIZED_WIRE_13),
	.clock(Clock),
	.address(Address),
	.byteena(Byte_Enable),
	.data(Data_In)
	);

assign	Data_Out = Data_Out_bus;

endmodule

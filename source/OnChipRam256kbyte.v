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
// CREATED		"Sat Jul 26 16:40:47 2025"

module OnChipRam256kbyte(
	Clock,
	RamSelect_H,
	WE_L,
	AS_L,
	Address,
	ByteEnable,
	DataIn,
	DataOut
);


input wire	Clock;
input wire	RamSelect_H;
input wire	WE_L;
input wire	AS_L;
input wire	[16:0] Address;
input wire	[3:0] ByteEnable;
input wire	[31:0] DataIn;
output wire	[31:0] DataOut;

wire	[31:0] gdfx_temp0;
wire	SYNTHESIZED_WIRE_0;
wire	SYNTHESIZED_WIRE_34;
wire	SYNTHESIZED_WIRE_2;
wire	SYNTHESIZED_WIRE_35;
wire	SYNTHESIZED_WIRE_36;
wire	SYNTHESIZED_WIRE_37;
wire	SYNTHESIZED_WIRE_38;
wire	SYNTHESIZED_WIRE_39;
wire	SYNTHESIZED_WIRE_40;
wire	SYNTHESIZED_WIRE_20;
wire	[31:0] SYNTHESIZED_WIRE_21;
wire	SYNTHESIZED_WIRE_22;
wire	SYNTHESIZED_WIRE_24;
wire	SYNTHESIZED_WIRE_26;
wire	SYNTHESIZED_WIRE_28;
wire	[31:0] SYNTHESIZED_WIRE_29;
wire	SYNTHESIZED_WIRE_30;
wire	[31:0] SYNTHESIZED_WIRE_31;
wire	SYNTHESIZED_WIRE_32;
wire	[31:0] SYNTHESIZED_WIRE_33;





SRAM_32kWords	b2v_inst(
	.wren(SYNTHESIZED_WIRE_0),
	.clock(SYNTHESIZED_WIRE_34),
	.address(Address[14:0]),
	.byteena(ByteEnable),
	.data(DataIn),
	.q(SYNTHESIZED_WIRE_29));


SramBlockDecoder_Verilog	b2v_inst1(
	.SRamSelect_H(RamSelect_H),
	.Address(Address),
	.Block0_H(SYNTHESIZED_WIRE_36),
	.Block1_H(SYNTHESIZED_WIRE_38),
	.Block2_H(SYNTHESIZED_WIRE_39),
	.Block3_H(SYNTHESIZED_WIRE_40));

assign	SYNTHESIZED_WIRE_2 =  ~WE_L;

assign	SYNTHESIZED_WIRE_35 =  ~AS_L;

assign	SYNTHESIZED_WIRE_37 = RamSelect_H & SYNTHESIZED_WIRE_2 & SYNTHESIZED_WIRE_35;

assign	SYNTHESIZED_WIRE_0 = SYNTHESIZED_WIRE_36 & SYNTHESIZED_WIRE_37;

assign	SYNTHESIZED_WIRE_22 = SYNTHESIZED_WIRE_38 & SYNTHESIZED_WIRE_37;

assign	SYNTHESIZED_WIRE_24 = SYNTHESIZED_WIRE_39 & SYNTHESIZED_WIRE_37;

assign	SYNTHESIZED_WIRE_26 = SYNTHESIZED_WIRE_40 & SYNTHESIZED_WIRE_37;

assign	SYNTHESIZED_WIRE_28 = WE_L & SYNTHESIZED_WIRE_35 & SYNTHESIZED_WIRE_36;

assign	SYNTHESIZED_WIRE_30 = WE_L & SYNTHESIZED_WIRE_35 & SYNTHESIZED_WIRE_38;

assign	SYNTHESIZED_WIRE_32 = WE_L & SYNTHESIZED_WIRE_35 & SYNTHESIZED_WIRE_39;

assign	SYNTHESIZED_WIRE_34 =  ~Clock;

assign	SYNTHESIZED_WIRE_20 = WE_L & SYNTHESIZED_WIRE_35 & SYNTHESIZED_WIRE_40;


lpm_bustri0	b2v_inst21(
	.enabledt(SYNTHESIZED_WIRE_20),
	.data(SYNTHESIZED_WIRE_21),
	.tridata(gdfx_temp0)
	);


SRAM_32kWords	b2v_inst3(
	.wren(SYNTHESIZED_WIRE_22),
	.clock(SYNTHESIZED_WIRE_34),
	.address(Address[14:0]),
	.byteena(ByteEnable),
	.data(DataIn),
	.q(SYNTHESIZED_WIRE_31));


SRAM_32kWords	b2v_inst4(
	.wren(SYNTHESIZED_WIRE_24),
	.clock(SYNTHESIZED_WIRE_34),
	.address(Address[14:0]),
	.byteena(ByteEnable),
	.data(DataIn),
	.q(SYNTHESIZED_WIRE_33));


SRAM_32kWords	b2v_inst5(
	.wren(SYNTHESIZED_WIRE_26),
	.clock(SYNTHESIZED_WIRE_34),
	.address(Address[14:0]),
	.byteena(ByteEnable),
	.data(DataIn),
	.q(SYNTHESIZED_WIRE_21));


lpm_bustri0	b2v_inst7(
	.enabledt(SYNTHESIZED_WIRE_28),
	.data(SYNTHESIZED_WIRE_29),
	.tridata(gdfx_temp0)
	);


lpm_bustri0	b2v_inst8(
	.enabledt(SYNTHESIZED_WIRE_30),
	.data(SYNTHESIZED_WIRE_31),
	.tridata(gdfx_temp0)
	);


lpm_bustri0	b2v_inst9(
	.enabledt(SYNTHESIZED_WIRE_32),
	.data(SYNTHESIZED_WIRE_33),
	.tridata(gdfx_temp0)
	);

assign	DataOut = gdfx_temp0;

endmodule

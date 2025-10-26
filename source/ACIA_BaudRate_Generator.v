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
// CREATED		"Mon Jun 16 11:30:34 2025"

module ACIA_BaudRate_Generator(
	Clk,
	Clk_50Mhz,
	Reset_L,
	Enable_H,
	DataIn,
	ACIA_Clock
);


input wire	Clk;
input wire	Clk_50Mhz;
input wire	Reset_L;
input wire	Enable_H;
input wire	[2:0] DataIn;
output wire	ACIA_Clock;

wire	[2:0] SYNTHESIZED_WIRE_0;





Latch3Bit	b2v_inst1(
	.Enable(Enable_H),
	.Clk(Clk),
	.Reset(Reset_L),
	.DataIn(DataIn),
	.Q(SYNTHESIZED_WIRE_0));


ACIA_Clock	b2v_inst20(
	.Clk(Clk_50Mhz),
	.BaudRateSelect(SYNTHESIZED_WIRE_0),
	.ACIA_Clk(ACIA_Clock));


endmodule

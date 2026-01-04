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
// CREATED		"Sat Jan 03 16:56:42 2026"

module OnChipM68xxIO(
	IOSelect,
	Clk,
	Reset_L,
	Clock_50Mhz,
	RS232_RxData,
	UDS_L,
	WE_L,
	AS_L,
	Address,
	DataIn,
	RS232_TxData,
	ACIA_IRQ,
	DataOut
);


input wire	IOSelect;
input wire	Clk;
input wire	Reset_L;
input wire	Clock_50Mhz;
input wire	RS232_RxData;
input wire	UDS_L;
input wire	WE_L;
input wire	AS_L;
input wire	[31:0] Address;
input wire	[7:0] DataIn;
output wire	RS232_TxData;
output wire	ACIA_IRQ;
output wire	[7:0] DataOut;

wire	SYNTHESIZED_WIRE_0;
wire	SYNTHESIZED_WIRE_1;
wire	SYNTHESIZED_WIRE_2;
wire	SYNTHESIZED_WIRE_7;
wire	SYNTHESIZED_WIRE_8;

assign	SYNTHESIZED_WIRE_8 = 0;




M68xxIODecoder	b2v_inst(
	.IOSelect(IOSelect),
	.UDS_L(UDS_L),
	.AS_L(AS_L),
	.Address(Address),
	.ACIA1_Port_Enable(SYNTHESIZED_WIRE_2),
	.ACIA1_Baud_Enable(SYNTHESIZED_WIRE_0));


ACIA_BaudRate_Generator	b2v_inst1(
	.Clk_50Mhz(Clock_50Mhz),
	.Enable_H(SYNTHESIZED_WIRE_0),
	.Clk(Clk),
	.Reset_L(Reset_L),
	.DataIn(DataIn[2:0]),
	.ACIA_Clock(SYNTHESIZED_WIRE_7));


ACIA_6850	b2v_inst16(
	.Clk(Clk),
	.Reset_H(SYNTHESIZED_WIRE_1),
	.CS_H(SYNTHESIZED_WIRE_2),
	.Write_L(WE_L),
	.RS(Address[2]),
	.RxClock(SYNTHESIZED_WIRE_7),
	.TxClock(SYNTHESIZED_WIRE_7),
	.RxData(RS232_RxData),
	.DCD_L(SYNTHESIZED_WIRE_8),
	.CTS_L(SYNTHESIZED_WIRE_8),
	.DataIn(DataIn),
	.IRQ_L(ACIA_IRQ),
	.TxData(RS232_TxData),
	
	.DataOut(DataOut));

assign	SYNTHESIZED_WIRE_1 =  ~Reset_L;



endmodule

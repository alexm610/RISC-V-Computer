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
// CREATED		"Fri May  1 08:50:31 2026"

module IIC_SPI_Interface(
	Clk,
	Reset_L,
	WE_L,
	AS_L,
	miso_i,
	IIC_SPI_Select,
	Address,
	DataIn,
	IIC0_IRQ_L,
	sck_o,
	mosi_o,
	SPI_IRQ,
	SCL_GPIO_0,
	SDA_GPIO_0,
	DataOut,
	SSN_O
);


input wire	Clk;
input wire	Reset_L;
input wire	WE_L;
input wire	AS_L;
input wire	miso_i;
input wire	IIC_SPI_Select;
input wire	[31:0] Address;
input wire	[7:0] DataIn;
output wire	IIC0_IRQ_L;
output wire	sck_o;
output wire	mosi_o;
output wire	SPI_IRQ;
inout wire	SCL_GPIO_0;
inout wire	SDA_GPIO_0;
output wire	[7:0] DataOut;
output wire	[7:0] SSN_O;

wire	SYNTHESIZED_WIRE_0;
wire	SYNTHESIZED_WIRE_10;
wire	SYNTHESIZED_WIRE_11;
reg	SYNTHESIZED_WIRE_12;
wire	SYNTHESIZED_WIRE_5;
wire	SYNTHESIZED_WIRE_6;
wire	SYNTHESIZED_WIRE_13;
wire	SYNTHESIZED_WIRE_8;

assign	SYNTHESIZED_WIRE_13 = 1;



assign	SPI_IRQ =  ~SYNTHESIZED_WIRE_0;

assign	SYNTHESIZED_WIRE_6 = SYNTHESIZED_WIRE_10 & SYNTHESIZED_WIRE_11 & WE_L;


simple_spi_top	b2v_inst11(
	.pclk_i(SYNTHESIZED_WIRE_12),
	.prst_i(Reset_L),
	.psel_i(SYNTHESIZED_WIRE_11),
	.penable_i(SYNTHESIZED_WIRE_10),
	.pwrite_i(SYNTHESIZED_WIRE_5),
	.miso_i(miso_i),
	.paddr_i(Address[3:1]),
	.pwdata_i(DataIn),
	.pirq_o(SYNTHESIZED_WIRE_0),
	.sck_o(sck_o),
	.mosi_o(mosi_o),
	.prdata_o(DataOut),
	.ssn_o(SSN_O));


SPI_BUS_Decoder	b2v_inst2(
	.SPI_Select_H(IIC_SPI_Select),
	.AS_L(AS_L),
	.Address(Address),
	.SPI_Enable_H(SYNTHESIZED_WIRE_10));


lpm_bustri2	b2v_inst21(
	.enabledt(SYNTHESIZED_WIRE_6)
	
	
	);


always@(posedge Clk or negedge SYNTHESIZED_WIRE_13 or negedge SYNTHESIZED_WIRE_13)
begin
if (!SYNTHESIZED_WIRE_13)
	begin
	SYNTHESIZED_WIRE_12 <= 0;
	end
else
if (!SYNTHESIZED_WIRE_13)
	begin
	SYNTHESIZED_WIRE_12 <= 1;
	end
else
	begin
	SYNTHESIZED_WIRE_12 <= SYNTHESIZED_WIRE_8;
	end
end

assign	SYNTHESIZED_WIRE_8 =  ~SYNTHESIZED_WIRE_12;

assign	SYNTHESIZED_WIRE_11 =  ~AS_L;

assign	SYNTHESIZED_WIRE_5 =  ~WE_L;



endmodule

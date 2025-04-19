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
// CREATED		"Wed Apr 16 15:10:29 2025"

module tri_state_buffer(
	Enable,
	DataIn,
	DataOut
);


input wire	Enable;
input wire	[31:0] DataIn;
output wire	[31:0] DataOut;





assign	DataOut[31] = Enable ? DataIn[31] : 1'bz;
assign	DataOut[30] = Enable ? DataIn[30] : 1'bz;
assign	DataOut[29] = Enable ? DataIn[29] : 1'bz;
assign	DataOut[28] = Enable ? DataIn[28] : 1'bz;
assign	DataOut[27] = Enable ? DataIn[27] : 1'bz;
assign	DataOut[26] = Enable ? DataIn[26] : 1'bz;
assign	DataOut[25] = Enable ? DataIn[25] : 1'bz;
assign	DataOut[24] = Enable ? DataIn[24] : 1'bz;
assign	DataOut[23] = Enable ? DataIn[23] : 1'bz;
assign	DataOut[22] = Enable ? DataIn[22] : 1'bz;
assign	DataOut[21] = Enable ? DataIn[21] : 1'bz;
assign	DataOut[20] = Enable ? DataIn[20] : 1'bz;
assign	DataOut[19] = Enable ? DataIn[19] : 1'bz;
assign	DataOut[18] = Enable ? DataIn[18] : 1'bz;
assign	DataOut[17] = Enable ? DataIn[17] : 1'bz;
assign	DataOut[16] = Enable ? DataIn[16] : 1'bz;
assign	DataOut[15] = Enable ? DataIn[15] : 1'bz;
assign	DataOut[14] = Enable ? DataIn[14] : 1'bz;
assign	DataOut[13] = Enable ? DataIn[13] : 1'bz;
assign	DataOut[12] = Enable ? DataIn[12] : 1'bz;
assign	DataOut[11] = Enable ? DataIn[11] : 1'bz;
assign	DataOut[10] = Enable ? DataIn[10] : 1'bz;
assign	DataOut[9] = Enable ? DataIn[9] : 1'bz;
assign	DataOut[8] = Enable ? DataIn[8] : 1'bz;
assign	DataOut[7] = Enable ? DataIn[7] : 1'bz;
assign	DataOut[6] = Enable ? DataIn[6] : 1'bz;
assign	DataOut[5] = Enable ? DataIn[5] : 1'bz;
assign	DataOut[4] = Enable ? DataIn[4] : 1'bz;
assign	DataOut[3] = Enable ? DataIn[3] : 1'bz;
assign	DataOut[2] = Enable ? DataIn[2] : 1'bz;
assign	DataOut[1] = Enable ? DataIn[1] : 1'bz;
assign	DataOut[0] = Enable ? DataIn[0] : 1'bz;


endmodule

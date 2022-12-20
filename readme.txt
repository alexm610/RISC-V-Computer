NEW MISSION STATEMENT: Create a RISC-V compatible computer on the FPGA

DECEMBER 15, 2022
	- Created documents folder, have included lab7 files from CPEN 211 for reference
	- reg_file.sv complete; simple testbench shows each register can be written to
	- RAM.v created; built using Quartus wizard
	- need to hardwire x0 output of reg_file module to ZERO

DECEMBER 19, 2022
	- I created a draft of the ALU, based on the ALU written for Lab 7 of CPEN 211
	- aluop definitions found based off of the video:
		https://www.youtube.com/watch?v=4dF4YbOy0oM
	- Upon further research, the ALUop's, although seemingly defined by a 4-bit wide bus,
		do not seem to be set in stone; ie. ADD has not been assigned a specific 4-bit 
		value to be inputted to the ALU
		- In fact, it seems as though I must use funct3 and funct7 to decode the exact 
			operation.
		- This is going to be fun
------NOTES------
Register file: 
	- 32 registers in total, denoted by xn (ie. x1, x31, etc.)
	- x0 is hardwired to 0 always; this is useful because:
		- any instruction that produces a result that is to be discarded can direct its target to x0, ie. saves time
		- it is an automatic source of 0

ALU:
	- operations:
		- ADD
		- SUB
		- XOR
		- OR
		- AND
		- NOT


/*
try writing a report!
	with project updates (including dates of modifications and whatnot)
	make very detailed notes along the way of this project
	when completed, write a report
*/

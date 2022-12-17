NEW MISSION STATEMENT: Create a RISC-V compatible computer on the FPGA

DECEMBER 15, 2022
	- Created documents folder, have included lab7 files from CPEN 211 for reference
	- reg_file.sv complete; simple testbench shows each register can be written to
	- RAM.v created; built using Quartus wizard
	- need to hardwire x0 output of reg_file module to ZERO


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

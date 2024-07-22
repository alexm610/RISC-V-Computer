	MOV R0, #1
	MOV R1, #3
	MOV R2, #5
	CMP R0, R1
	BLT less
	MOV R3, #44
	
less:
	MOV R3, #99
	CMP R2, R1	
	BLT nogo
	HALT

nogo:
	MOV R7, #55
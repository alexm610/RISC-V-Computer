	MOV R0, #5
	MOV R1, #4
	MOV R2, #33
	CMP R0, R1
	BNE not_equal
	MOV R3, R2

not_equal:
	MOV R3, #33
	CMP R2, R3
	BNE nogo
	HALT

nogo:
	MOV R7, #44

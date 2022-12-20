	MOV R0, #4
	MOV R1, #5
	MOV R2, #5
	CMP R2, R1
	BEQ equal
	MOV R3, R0
	
equal:
	ADD R3, R0, R2
	CMP R1, R0
	BEQ shouldnt_go_here
	HALT

shouldnt_go_here:
	MOV R7, #77
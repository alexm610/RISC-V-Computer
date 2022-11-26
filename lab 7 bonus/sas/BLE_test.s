	MOV R0, #4
	MOV R1, #5
	CMP R0, R1
	BLE lessequal
	MOV R2, #12

lessequal:
	MOV R3, #23
	CMP R1, R0
	BEQ nogo
	HALT

nogo:
	MOV R7, #8

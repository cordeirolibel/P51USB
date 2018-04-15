ORG 0000h

loop:
	MOV A, P0
	ANL A, #00010000b
	
	MOV R1,#4
rot:RR A
	DJNZ R1, rot
	CJNE A, #1, aux
	
	MOV P1, #1
	JMP loop
	
aux:
	MOV P1, #0
	JMP loop
	
	JMP $
END
ORG 0000h

	MOV A, #2h
	MOV B, #3h
	MUL AB
	MOV R1,A
	SJMP $
END
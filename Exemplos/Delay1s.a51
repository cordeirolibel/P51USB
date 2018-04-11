ORG 0000H

	;Carrega o R0 com um valor para fazer um laço
	MOV R0, #250d
	MOV R1, #250d
	MOV R2, #8d
	
	;Utilizaremos 3 laços para fazer o delay de 1 segundo
	;Clock de 12MHz
	;Ciclo de clock de 1 microsegundo ->1s ; DJNZ dois ciclos
	;ls -> 250 x 250 x 8 x 2
	
	delay2:
		MOV R1, #250d
	delay1:
		MOV R0, #250d
	delay0:
		DJNZ R0, delay0
		DJNZ R1, delay1
		DJNZ R2, delay2
		
;	JMP $
		
END
	
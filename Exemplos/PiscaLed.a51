ORG 0000H
	;estados iniciais dos pinos
	SETB P2.1
	CLR P1.7
	
	;LOOP PARA VERIFICAR O ESTADO DO PINO P0.3
	
	loop:
	JB P0.3, pinoON
	pinoOFF:
	JMP loop
	
	pinoON:
	;alternar os valores dos ports
	CPL P2.1
	CPL P1.7
	MOV A, #00000010b
	ANL A, P2
	MOV P2, A
	MOV A, #10000000b
	ANL A, P1
	MOV P1, A
	
	LCALL SubrotinaTimer
	
	JMP loop
	
	SubrotinaTimer:
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
		
	RET
		
END
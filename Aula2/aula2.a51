;Objetivo: Fazer varredura de uma string armazenada
;na memória de programa e colocar cada caracter no
;acumulador
;
; mais 8000!   =>    6D 61 69 73 20 38 30 30 30 21
	
;salva string na memoria
ORG 0x020
	DB 'm','a','i','s',' ','8','0','0','0','!',00h

ORG 0000h
	;ponto inicial
	MOV DPTR, #0x020
loop:    
		;read memory
		MOV A, #0
		MOVC A, @A+DPTR 
	
	INC DPTR 
	JNZ loop
	
	JMP $
END
	

;Tarefa 1) Desenvolver um pisca led contínuo. Utilizar 1 LED (pode ser um led da própria placa)
;para indicar um sinal de alerta. O LED deve piscar da seguinte forma:
;- Ficar 3 segundos aceso e 1 segundo apagado.

#include "at89c5131.h"

; Definições da P51USB
LED3 EQU P1.4
	

ORG 0000h
	
loop:
	;liga LED
	CLR LED3
	
	LCALL meioseg
	LCALL meioseg
	LCALL meioseg
	LCALL meioseg
	LCALL meioseg
	LCALL meioseg
	
	;Desliga LED
	SETB LED3
	
	LCALL meioseg
	LCALL meioseg
	
	JMP loop
	
JMP $



meioseg:
	;for(r4=255;r4!=0;r4--)
	MOV R4, #255					;1
lp1:
		;for(r5=245;r5!=0;r5--)
		MOV R5, #245				;255*1
	lp2:
			;for(r6=6;r6!=0;r6--)
			MOV R6, #6  		   	;255*245*1
		lp3:
			DJNZ R6,lp3				;255*245*6*2
			NOP						;255*245
			;endfor
		DJNZ R5,lp2					;255*245*2
		;endfor
	DJNZ R4,lp1						;255*2
	;endfor
	
	RET
	
END
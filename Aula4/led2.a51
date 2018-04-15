;Tarefa 2) Desenvolver um pisca led que seja acionado através de 1 botão (pode ser o botão e o
;led da placa). Funcionamento: após pressionar e soltar o botão, o led deve ficar 1 segundo aceso
;e 1 segundos apagado por tempo indeterminado. Quando o botão for pressionado e solto
;novamente o led deve permanecer apagado (como o pisca alerta de um veículo).

#include "at89c5131.h"
; Definições da P51USB
LED3 EQU P1.4
SW1 EQU P3.2

ORG 0000h

	
loop: ;Loop principal, aguarda o botão ser pressionado
	JNB SW1, turnOn
	JMP loop

turnOn: ;Aguarda soltar o botão
	JB SW1, loopLed
	JMP turnOn
	
turnOff: ;Aguarda soltar o botão
	JB SW1, loop
	JMP turnOff

loopLed:
	;liga LED
	CLR LED3
	
	LCALL meioseg
	LCALL meioseg
	
	;Desliga LED
	SETB LED3
	
	LCALL meioseg
	LCALL meioseg
	
	;Caso pressionado desliga
	JB SW1, loopLed
	JMP turnOff

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
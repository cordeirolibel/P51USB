;Tarefa 4) Realizar o deslocamento de 3 LEDs de um lado para o outro. Primeiramente, deve-se
;ascender 3 leds um seguido do outro e mantê-los acesos, respeitando a seguinte ordem (LED1
;– ascende, LED2 – ascende, LED3 - ascende), depois apagar os leds na seguinte ordem (LED3 –
;apaga, LED2 – apaga, LED1 – apaga). Está rotina deve ficar sendo executada por tempo
;indeterminado.

#include "at89c5131.h"
; Definições da P51USB
LED1 EQU P3.6
LED2 EQU P3.7
LED3 EQU P1.4
	
ORG 0000h
	
loop:
	;liga LEDs
	CLR LED1
	LCALL meioseg
	CLR LED2
	LCALL meioseg
	CLR LED3
	LCALL meioseg
	
	;Desligar LEDs
	SETB LED3
	LCALL meioseg
	SETB LED2
	LCALL meioseg
	SETB LED1
	LCALL meioseg

	JMP loop
	
	
	

;================================================

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
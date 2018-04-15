;Tarefa 3) Fazer um contador simples progressivo de módulo 8 e apresentar a contagem através
;de 3 leds. Semelhante ao vídeo do link (https://www.youtube.com/watch?v=LHFPT4_iMn0).
;NÃO É NECESSÁRIO VARIAR A VELOCIDADE COM QUE OS LEDS FICAM ACESOS. Cada estado deve
;permanecer ativado durante 3 segundos.


#include "at89c5131.h"
; Definições da P51USB
LED1 EQU P3.6
LED2 EQU P3.7
LED3 EQU P1.4

ORG 0000h
	
reset:
	MOV R0,#0
	
loop:
	LCALL a2pins
	LCALL tresseg
	
	INC R0
	CJNE R0,#08,loop 
	
	JMP reset
	
;================================================
a2pins:
	
	;if (A.0==1)
	MOV A, R0
	ANL A, #1b
	JZ else1
	CLR LED1;liga LED
	JMP endIF1
else1:;else
	SETB LED1;Desliga LED
endIF1:
	
	;if (A.1==1)
	MOV A, R0
	ANL A,  #10b
	JZ else2
	CLR LED2;liga LED
	JMP endIF2
else2:;else
	SETB LED2;Desliga LED
endIF2:
	
	;if (A.2==1)
	MOV A, R0
	ANL A, #100b
	JZ else3
	CLR LED3;liga LED
	JMP endIF3
else3:;else
	SETB LED3;Desliga LED
endIF3:
	RET
	
	
	
	
tresseg:
	LCALL meioseg
	LCALL meioseg
	LCALL meioseg
	LCALL meioseg
	LCALL meioseg
	LCALL meioseg
	RET

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
;Desenvolver um código assembly para "piscar"
;dois leds alternados, a cada 1 segundo,
;conectados aos pinos P1.7 e P2.1, quando a
;entrada P0.3 estiver ativa. Os demais pinos das
;Portas 1-2 devem permanecer inativos.

ORG 0000h

loop:
	;mascara em P0.3
	MOV A, P0
	ANL A, #00001000b
	
	;rotacao ate o P0.3 estiver na primeira posicao
	MOV R1,#3
rot:RR A
	DJNZ R1, rot
	CJNE A, #1, aux
	
	;se P0.3 == 1
	MOV P1, #10000000b
	MOV P2, #00000000b
	MOV R3, #0
	CALL umseg
fim1s:
	MOV P1, #00000000b
	MOV P2, #00000010b
	MOV R3, #1
	JMP umseg
fim1s2:
	JMP loop
	
aux:
	;se P0.3 == 0
	MOV P1, #0
	MOV P2, #0
	JMP loop
	
	JMP $
	
	
	;=========================
	;==== Funcao de 1seg
	; utiliza: R4,R5,R6
	; Parametro: R3
umseg:
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
	
	CJNE R3, #0, jmp2
	;endfor
	JMP fim1s
jmp2:
	JMP fim1s2
	
END
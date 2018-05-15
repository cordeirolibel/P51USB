;========================================================
; 2018 - UTFPR
; https://gitlab.com/gabrielsouzaesilva
; https://github.com/cordeirolibel/
;========================================================
;
;CSW40 - Sistemas Microcontrolados
;LABORAT�RIO 01 - MEIO PASSO

#include "at89c5131.h"
; Pinos Teclado
SW1 EQU P3.2   
LED1 EQU P1.4

ORG 0000h
SJMP main
	
ORG 0003h
;CLR EA
CALL sw1Inter
RETI

main:
	SETB EX0 ;Enable 
	SETB EA ;Enable todas as interrup�oes
	;SETB IE0
	CLR IT0 ;  sele��o de interrup��o externa por borda (1) ou por n�vel (0).
	SETB LED1
	SJMP $

; ======================================================================= ;	
; Interrup��o
; 
sw1Inter:
	JC cc
	CLR LED1
	SETB C
	RET
cc:
	SETB LED1
	CLR C
	RET
END
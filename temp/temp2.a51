;========================================================
; 2018 - UTFPR
; https://gitlab.com/gabrielsouzaesilva
; https://github.com/cordeirolibel/
;========================================================
;
;CSW40 - Sistemas Microcontrolados
;LABORATÓRIO 01 - MEIO PASSO

#include "at89c5131.h"
; Pinos Teclado
tec_A1 EQU P3.1   
tec_A2 EQU P3.3 
tec_A3 EQU P3.5 
tec_A4 EQU P3.4 
tec_B1 EQU P3.0 
tec_B2 EQU P3.2 
tec_B3 EQU P3.6 
	
LED1 EQU P3.6
LED2 EQU P3.7
LED3 EQU P1.4
	
MOTOR1 EQU P2.0
MOTOR2 EQU P2.1
MOTOR3 EQU P2.2
MOTOR4 EQU P2.3

ORG 0000h
SJMP main

ORG 000Bh
	CALL timerInter
	RETI

ORG 0033h
main:
	SETB ET0
	MOV TMOD, #01h
	MOV TH0, #0FFh
	MOV TL0, #0FFh
	SETB EA
	SETB TR0
	SETB 0x22.4
	CLR LED2
	
	MOV R5, #00h
	SJMP $

; ======================================================================= ;	
; Interrupção
; 
timerInter:
	MOV A, R5
	INC A
	MOV R5, A
	CJNE A, #20h, pula
	MOV R5, #0h
	JMP vai
pula:
	RET
vai:
	; Verifica flag de enable
	JB 0x22.4, girarMotor
	RET

girarMotor:
	; Salva registradores
	MOV 2fh, A
	MOV 2eh, R0
	
	; Lê memória e aplica mascara
	MOV A, 22h
	
	ANL A, #0Fh
	
	CJNE A, #00h, else1
	SETB MOTOR1
	CLR MOTOR2
	CLR MOTOR3
	CLR MOTOR4
	JMP fimInter
	
else1:
	SETB LED1
	
	CJNE A, #01h, else2
	SETB MOTOR1
	SETB MOTOR2
	CLR MOTOR3
	CLR MOTOR4
	JMP fimInter
	
else2:
	CJNE A, #02h, else3
	CLR MOTOR1
	SETB MOTOR2
	CLR MOTOR3
	CLR MOTOR4
	JMP fimInter
	
else3:
	CJNE A, #03h, else4
	CLR MOTOR1
	SETB MOTOR2
	SETB MOTOR3
	CLR MOTOR4
	JMP fimInter
	
else4:
	CLR LED1
	
	CJNE A, #04h, else5
	CLR MOTOR1
	CLR MOTOR2
	SETB MOTOR3
	CLR MOTOR4
	JMP fimInter
	
else5:
	CJNE A, #05h, else6
	CLR MOTOR1
	CLR MOTOR2
	SETB MOTOR3
	SETB MOTOR4
	JMP fimInter
	
else6:
	CJNE A, #06h, else7
	CLR MOTOR1
	CLR MOTOR2
	SETB MOTOR3
	CLR MOTOR4
	JMP fimInter
	
else7:
	CJNE A, #07h, else8
	SETB MOTOR1
	CLR MOTOR2
	CLR MOTOR3
	SETB MOTOR4
	JMP fimInter
	
else8:
fimInter:
	; Verifica sentido de rotação
	JB 0x22.5, sentidoRot
	;Anti-horario
	DEC A
	JMP fimMotor
	
sentidoRot:
	; Horario
	INC A
	JMP fimMotor
	
fimMotor:
	; Atualiza memoria com novo estado e os valores de flags
	MOV R0, A
	MOV A, 22h
	
	ANL A, 0F0h
	
	ORL A, R0
	
	MOV 22h, A
	
	MOV A, 2fh
	MOV R0, 2eh
	
	RET

; ======================================================================= ;	

ORG 2500h
	mensagem:
	
END
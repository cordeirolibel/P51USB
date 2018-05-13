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
	
LED1 EQU P1.4
	
MOTOR1 EQU P2.0
MOTOR2 EQU P2.1
MOTOR3 EQU P2.2
MOTOR4 EQU P2.3

ORG 2000h
SJMP main

	ORG 2033h
	CLR EA
	CALL timerInter
	CLR P1.0
	RETI

main:
	CLR P1.0
	SETB ET0
	MOV TMOD, #01h
	MOV TH0, #05h
	MOV TL0, #67h
	SETB EA
	SETB TR0
	SETB P1.0
	SJMP $

; ======================================================================= ;	
; Interrupção
; 
timerInter:
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
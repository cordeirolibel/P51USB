;========================================================
; 2018 - UTFPR
; https://gitlab.com/gabrielsouzaesilva
; https://github.com/cordeirolibel/
;========================================================
;
;CSW40 - Sistemas Microcontrolados
;LABORATÓRIO 03 - MEIO PASSO

#include "at89c5131.h"
; Pinos Teclado
tec_A1 EQU P3.1   
tec_A2 EQU P3.3 
tec_A3 EQU P3.5 
tec_A4 EQU P3.4 
tec_B1 EQU P3.0 
tec_B2 EQU P3.7
tec_B3 EQU P3.6 
	
LED1 EQU P3.6
LED2 EQU P3.7
LED3 EQU P1.4
SW1 EQU P3.2   
	
MOTOR4 EQU P2.0
MOTOR3 EQU P2.2
MOTOR2 EQU P2.1
MOTOR1 EQU P2.3
	
; Display
en    EQU     	P2.7   ;P3.5 enable display
rs    EQU     	P2.5    ;P3.4 alterna entre comando e dado (0-comando 1-dado) 
rw	  EQU		P2.6
dado  EQU		P0

ORG 0000h
SJMP main

main:
	CALL clearRAM
    CALL inidisp
	
	; Escreve msg inicial
	mov dptr, #msgParado
	CALL writeMsg
	
	; Pula linha
	CALL nextLine

	; Escreve msg set vel
	mov dptr, #msgVel
	CALL writeMsg
	
	CALL le_velocidade
	
	JMP main
	

; ======================================================================= ;
; Le velocidade
; Usa R4
le_velocidade:
		; Retorna tecla em R4
		CALL click_tcl
	
		CJNE R4, #00h, else1
		RET
		
	else1:
		CJNE R4, #01h, else2
		; Set vel 20%
		CALL clearLCD
		
		; Escreve msg vel1
		MOV dptr, #msgVel1
		CALL writeMsg
		
		CALL nextLine
		
		MOV dptr, #msgSentido
		CALL writeMsg

		CALL le_sentido
		
	else2:
		CJNE R4, #02h, else3
		; Set vel 40%
		CALL clearLCD
		
		; Escreve msg vel2
		MOV dptr, #msgVel2
		CALL writeMsg
		
		CALL nextLine
		
		MOV dptr, #msgSentido
		CALL writeMsg

		CALL le_sentido

	else3:
		CJNE R4, #03h, else4
		; Set vel 60%
		CALL clearLCD
		
		; Escreve msg vel3
		MOV dptr, #msgVel3
		CALL writeMsg
		
		CALL nextLine
		
		MOV dptr, #msgSentido
		CALL writeMsg

		CALL le_sentido
	
	else4:
		CJNE R4, #04h, else5
		; Set vel 80%
		CALL clearLCD
		
		; Escreve msg vel4
		MOV dptr, #msgVel4
		CALL writeMsg
		
		CALL nextLine
		
		MOV dptr, #msgSentido
		CALL writeMsg

		CALL le_sentido
	
	else5:
		CJNE R4, #05h, fim
		; Set vel 100%
		CALL clearLCD
		
		; Escreve msg vel5
		MOV dptr, #msgVel5
		CALL writeMsg
		
		CALL nextLine
		
		MOV dptr, #msgSentido
		CALL writeMsg

		CALL le_sentido
	
	fim:
		JMP le_velocidade
	
; ======================================================================= ;	
; LE SENTIDO DE ROTAÇÃO
; # ANTI / * HORARIO
le_sentido:

	; Retorna tecla em R4
	CALL click_tcl
	
	CJNE R4, #0Ah, antiHorario
	; Escreve msg vel+antiHorario
	
antiHorario:
	CJNE R4, #0Bh, le_sentido
	

; ======================================================================= ;
;Inicializacao do display
;------------------------------------------------------------------------;
;Rotina que inicializa o display para o uso                              ;
;nao tem dados de entrada e nao devolve nada                             ;
;------------------------------------------------------------------------;
; usa r0,r1,a,dptr
;
inidisp:    	mov dado,#38h
            CALL comdisp
			call delay2
				mov dado,#38h
            CALL comdisp
			call delay2
				MOV dado,#06h
            CALL comdisp
				call delay2
				MOV dado,#0eh
            CALL comdisp
				call delay2
				MOV dado,#01H
            CALL comdisp
				call delay2
            RET
; ======================================================================= ;
dadodisp:   clr  en
			clr rw
            setb rs
            setb en
            call delay
            clr  en
            ret
; ======================================================================= ;
comdisp:    clr  en
           	clr rw
		    clr  rs
            setb en
            call delay
            clr  en
            ret
; ======================================================================= ;
; Limpa LCD e volta cursor para o inicio
clearLCD:
		mov dado, #01h ;02h = Sobre escreve msg
		call comdisp
		call delay2
		ret
; ======================================================================= ;
; Pula linha
nextLine:	mov dado, #0C0h
			CALL comdisp
			call delay2
			ret

; ======================================================================= ;
; Escreve mensagem
; usa A
writeMsg:			mov 2ah, a
					clr a
					movc  a,@a+dptr
					
					cjne a, #00h, continuemsg ; Exclui bug ultimo caractere
					jmp exitmsg
continuemsg:			
					mov dado,a
					call dadodisp
					call delay2
					inc dptr
					cjne a, #00h, writeMsg
	exitmsg:		
					mov a, 2ah
					ret

; ======================================================================= ;
; Limpa memoria
clearRAM:
		mov 20h, #00h
		mov 21h, #00h
		mov 22h, #00h
		mov 23h, #00h
		mov 24h, #00h
		mov 25h, #00h
		mov 26h, #00h
		mov 27h, #00h
		mov 28h, #00h
		mov 29h, #00h
		mov 2Ah, #00h
		mov 2Bh, #00h
		ret
; ======================================================================= ;

; ======================================================================= ;
;=========== TECLADO ============
;
;   A4---7---8---9---x
;        |   |   |   |
;   A3---4---5---6---x
;        |   |   |   |
;   A2---1---2---3---x  
;        |   |   |   |
;   A1---*---0---#---x
;        |   |   |   |
;        |   |   |   |
;        B3  B2  B1  B4
;
; Regioes de memória
; RAM    BOTÃO
; 20.0 -> 0
; 20.1 -> 1
; 20.2 -> 2
; 20.3 -> 3
; 20.4 -> 4
; 20.5 -> 5
; 20.6 -> 6
; 20.7 -> 7
; 21.0 -> 8
; 21.1 -> 9
; 21.2 -> * (10)
; 21.3 -> # (11)

;==================================================
;Fica em loop ate uma tecla ser apertada e solta
; retorna em R4 a tecla. (Usa A, R0, R2, R4, R5)
click_tcl:
	;register save
	MOV 2ah, R0
	MOV 2bh, A
	MOV 2ch, R2
	MOV 2dh, R5
	
	CALL read_tcl
	
	;===================================
	;esperando uma tecla 
	MOV R0, #20h
	MOV A, @R0
	CJNE A, #00h, wait_depress1
	MOV R0, #21h
	MOV A, @R0
	ANL A, #0Fh
	CJNE A, #00h, wait_depress2
	JMP click_tcl
	
	;===================================
	;esperando soltar RAM(0x20)
wait_depress1:
	MOV R2, A
	call read_tcl
	MOV R0, #20h
	MOV A, @R0
	CJNE A, #00h, wait_depress1
	
	;===================================
	;converter r4 para botao 
	MOV A, R2
	MOV R2, #00h
	clr c
verifyBit1:
	RRC A
	clr c
	INC R2
	CJNE A, #00h, verifyBit1
	DEC R2
	MOV A, R2
	MOV R4, A
	RET
	
	;===================================
	;esperando soltar RAM(0x21)
wait_depress2:
	MOV R2, A
	
	CALL read_tcl
	
	MOV R0, #21h
	MOV A, @R0
	ANL A, #0Fh
	CJNE A, #00h, wait_depress2
	
	;===================================
	;converter r4 para botao 
	MOV A, R2
	MOV R2, #00h
	clr c
verifyBit2:
	RRC A
	clr c
	INC R2
	CJNE A, #00h, verifyBit2
	MOV A,R2
	ADD A,#07h
	MOV R4, A
	
	;register load
	MOV R0, 2ah
	MOV A,  2bh
	MOV R2, 2ch
	MOV R5, 2dh
	RET

jumpMain:
	LJMP main

; ====================================================================== ;
;======= leitura da tecla '1' do teclado =======
; ====================================================================== ;
; usa A,r4,r5
; salva em 0x20.0
read_tcl:
	JB 0x22.4, jumpMain
read:
	MOV A, #00
; ================== Coluna 1 =====================
	;====================
	;=======> Set Pins
	;somente tec_B1==0
	CLR tec_B1
	SETB tec_B2
	SETB tec_B3
	
	;====================
	;=======> read
	; read tec_A1, save in 0x20.0, A=0
	

	;Linha 1
	JB tec_A1, not_press_rd11; pula se tec_A1==1
		;save button press 
		SETB 0x21.3
		JMP press_rd11
not_press_rd11:
	;save button not press
	CLR 0x21.3
press_rd11:
	
	;Linha 2	
	JB tec_A2, not_press_rd3; pula se tec_A1==1
		;save button press 
		SETB 0x20.3
		JMP press_rd3
not_press_rd3:
	;save button not press
	CLR 0x20.3
press_rd3:

	;Linha3
	JB tec_A3, not_press_rd6; pula se tec_A1==1
		;save button press 
		SETB 0x20.6
		JMP press_rd6
not_press_rd6:
	;save button not press
	CLR 0x20.6
press_rd6:

	;Linha4
	JB tec_A4, not_press_rd9; pula se tec_A1==1
		;save button press 
		SETB 0x21.1
		JMP press_rd9
not_press_rd9:
	;save button not press
	CLR 0x21.1
press_rd9:
		
; ================== Coluna 2 =====================
	;====================
	;=======> Set Pins
	;somente tec_B1==0
	SETB tec_B1
	CLR tec_B2
	SETB tec_B3
	
	;====================
	;=======> read
	; read tec_A1, save in 0x20.0, A=0

	;Linha 1
	JB tec_A1, not_press_rd0; pula se tec_A1==1
		;save button press 
		SETB 0x20.0
		JMP press_rd0
not_press_rd0:
	;save button not press
	CLR 0x20.0
press_rd0:
	
	;Linha 2	
	JB tec_A2, not_press_rd2; pula se tec_A1==1
		;save button press 
		SETB 0x20.2
		JMP press_rd2
not_press_rd2:
	;save button not press
	CLR 0x20.2
press_rd2:

;Tecla3
	JB tec_A3, not_press_rd5; pula se tec_A1==1
		;save button press 
		SETB 0x20.5
		JMP press_rd5
not_press_rd5:
	;save button not press
	CLR 0x20.5
press_rd5:

;Tecla4
	JB tec_A4, not_press_rd8; pula se tec_A1==1
		;save button press 
		SETB 0x21.0
		JMP press_rd8
not_press_rd8:
	;save button not press
	CLR 0x21.0
press_rd8:

;======================= Coluna 3 =======================
	;====================
	;=======> Set Pins
	;somente tec_B1==0
	SETB tec_B1
	SETB tec_B2
	CLR tec_B3
	
	;====================
	;=======> read
	; read tec_A1, save in 0x20.0, A=0

	;Tecla 1
	JB tec_A1, not_press_rd10; pula se tec_A1==1
		;save button press 
		SETB 0x21.2
		JMP press_rd10
not_press_rd10:
	;save button not press
	CLR 0x21.2
press_rd10:
	
;Tecla 2	
	JB tec_A2, not_press_rd1; pula se tec_A1==1
		;save button press 
		SETB 0x20.1
		JMP press_rd1
not_press_rd1:
	;save button not press
	CLR 0x20.1
press_rd1:

;Tecla3
	JB tec_A3, not_press_rd4; pula se tec_A1==1
		;save button press 
		SETB 0x20.4
		JMP press_rd4
not_press_rd4:
	;save button not press
	CLR 0x20.4
press_rd4:

;Tecla4
	JB tec_A4, not_press_rd7; pula se tec_A1==1
		;save button press 
		SETB 0x20.7
		JMP press_rd7
not_press_rd7:
	;save button not press
	CLR 0x20.7
press_rd7:


	;====================
	;=======> ch
	; changed?
change:
;======================= Coluna 1 =======================
	JMP jmp_read1
read1:
	LJMP read
jmp_read1:

	;====================
	;=======> Set Pins
	;somente tec_B1==0
	CLR tec_B1
	SETB tec_B2
	SETB tec_B3
	
	;Linha 1
	JB tec_A1, not_press_ch1; pula se tec_A1==1
		;button press 
		JNB 0x21.3, read1 ;changed
		JMP press_ch1
not_press_ch1:
	;button not press 
	JB 0x21.3, read1 ;changed
press_ch1:

	;Linha 2
	JB tec_A2, not_press_ch2; pula se tec_A1==1
		;button press 
		JNB 0x20.3, read1 ;changed
		JMP press_ch2
not_press_ch2:
	;button not press 
	JB 0x20.3, read1 ;changed
press_ch2:

	;Linha 3
	JB tec_A3, not_press_ch3; pula se tec_A1==1
		;button press 
		JNB 0x20.6, read1 ;changed
		JMP press_ch3
not_press_ch3:
	;button not press 
	JB 0x20.6, read1 ;changed
press_ch3:

	;Linha 4
	JB tec_A4, not_press_ch4; pula se tec_A1==1
		;button press 
		JNB 0x21.1, read1 ;changed
		JMP press_ch4
not_press_ch4:
	;button not press 
	JB 0x21.1, read1 ;changed
press_ch4:

;======================= Coluna 2 =======================
	JMP jmp_read2
read2:
	LJMP read
jmp_read2:

	;====================
	;=======> Set Pins
	;somente tec_B2==0
	SETB tec_B1
	CLR tec_B2
	SETB tec_B3
	
	;Linha 1
	JB tec_A1, not_press_ch5; pula se tec_A1==1
		;button press 
		JNB 0x20.0, read2 ;changed
		JMP press_ch5
not_press_ch5:
	;button not press 
	JB 0x20.0, read2 ;changed
press_ch5:

	;Linha 2
	JB tec_A2, not_press_ch6; pula se tec_A1==1
		;button press 
		JNB 0x20.2, read2 ;changed
		JMP press_ch6
not_press_ch6:
	;button not press 
	JB 0x20.2, read2 ;changed
press_ch6:

	;Linha 3
	JB tec_A3, not_press_ch7; pula se tec_A1==1
		;button press 
		JNB 0x20.5, read2 ;changed
		JMP press_ch7
not_press_ch7:
	;button not press 
	JB 0x20.5, read2 ;changed
press_ch7:

	;Linha 4
	JB tec_A4, not_press_ch8; pula se tec_A1==1
		;button press 
		JNB 0x21.0, read2 ;changed
		JMP press_ch8
not_press_ch8:
	;button not press 
	JB 0x21.0, read2 ;changed
press_ch8:

;======================= Coluna 3 =======================
	JMP jmp_read3
read3:
	LJMP read
jmp_read3:

	;====================
	;=======> Set Pins
	;somente tec_B3==0
	SETB tec_B1
	SETB tec_B2
	CLR tec_B3
	
	;Linha 1
	JB tec_A1, not_press_ch9; pula se tec_A1==1
		;button press 
		JNB 0x21.2, read3 ;changed
		JMP press_ch9
not_press_ch9:
	;button not press 
	JB 0x21.2, read3 ;changed
press_ch9:

	;Linha 2
	JB tec_A2, not_press_ch10; pula se tec_A1==1
		;button press 
		JNB 0x20.1, read3 ;changed
		JMP press_ch10
not_press_ch10:
	;button not press 
	JB 0x20.1, read3 ;changed
press_ch10:

	;Linha 3
	JB tec_A3, not_press_ch11; pula se tec_A1==1
		;button press 
		JNB 0x20.4, read3 ;changed
		JMP press_ch11
not_press_ch11:
	;button not press 
	JB 0x20.4, read3 ;changed
press_ch11:

	;Linha 4
	JB tec_A4, not_press_ch12; pula se tec_A1==1
		;button press 
		JNB 0x20.7, read3 ;changed
		JMP press_ch12
not_press_ch12:
	;button not press 
	JB 0x20.7, read3 ;changed
press_ch12:
		
	;====================
	;===== A++, A==20?
	INC A
	CJNE A, #20, wait_ms
	RET
	
	;====================
	;=======> wait_ms
	; espera de 1ms
wait_ms:
	MOV R4, #250			;1
lp1_ms:
		MOV R5, #2			;250*1
		NOP 				;250*1
		lp2_ms:
			DJNZ R5,lp2_ms	;250*2*2
		DJNZ R4,lp1_ms		;250*2
	JMP change
	
; ====================================================================== ;


ORG 0500h
msgParado:  DB 'Motor parado',0
msgSentido: DB 'Set sentido...', 0
msgVel: DB 'Set vel...', 0
msgVel1: DB 'Velocidade 20%',0 
msgVel2: DB 'Velocidade 40%',0 
msgVel3: DB 'Velocidade 60%',0 	
msgVel4: DB 'Velocidade 80%',0 
msgVel5: DB 'Velocidade 100%',0 	

END
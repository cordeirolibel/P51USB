#include "at89c5131.h"
; Pinos Teclado
tec_A1 EQU P3.7   
tec_A2 EQU P3.6 
tec_A3 EQU P3.5 
tec_A4 EQU P3.4 
tec_B1 EQU P3.3 
tec_B2 EQU P3.2 
tec_B3 EQU P3.1 
tec_B4 EQU P3.0

; Display
en    EQU     	P2.7   ;P3.5 enable display
rs    EQU     	P2.5    ;P3.4 alterna entre comando e dado (0-comando 1-dado) 
rw	  EQU		P2.6
dado  EQU		P0

LED3 EQU P1.4
	
ORG 00h
jmp inicio

ORG 33h

inicio: 
    call inidisp
	call escrevemsg
		
;muda o estado do led se botao '1' pressionado
loop_tcl:
	CALL read_tcl
	JB 0x20.0, press
		
	JMP loop_tcl
press:
	CALL read_tcl
	JB 0x20.0, press
		
	;troca mensagem
	CJNE R2,#0h,r0e1
		CALL escrevemsg
		MOV R2, #01h
		JMP loop_tcl
r0e1:
		CALL escrevemsg2
		MOV R2, #00h
		
	JMP loop_tcl
	
	
;================================
;=========== TECLADO ============
;
;   A1---1---2---3---A
;        |   |   |   |
;   A2---4---5---6---B
;        |   |   |   |
;   A3---7---8---9---C  
;        |   |   |   |
;   A4---*---0---#---D
;        |   |   |   |
;        |   |   |   |
;        B1  B2  B3  B4
;
;
;
;

;===============================================
;======= leitura da tecla '1' do teclado =======
;===============================================
; usa A,r4,r5
; salva em 0x20.0
read_tcl:
	
	;====================
	;=======> Set Pins
	;somente tec_B1==0
	CLR tec_B1
	SETB tec_B2
	SETB tec_B3
	SETB tec_B4
	
	;====================
	;=======> read
	; read tec_A1, save in 0x20.0, A=0
read:
	MOV A, #00
	JB tec_A1, not_press_rd; pula se tec_A1==1
		;save button press 
		SETB 0x20.0
		JMP press_rd
not_press_rd:
	;save button not press
	CLR 0x20.0
press_rd:
		
	
	;====================
	;=======> ch
	; changed?
change:
	JB tec_A1, not_press_ch; pula se tec_A1==1
		;button press 
		JNB 0x20.0, read ;changed
		JMP press_ch
not_press_ch:
	;button not press 
	JB 0x20.0, read ;changed
press_ch:
		
	;====================
	;===== A++, A==20?
	INC A
	CJNE A, #20, wait_ms
	RET
	
	;====================
	;=======> wait_ms
wait_ms:
	MOV R4, #250			;1
lp1_ms:
		MOV R5, #2			;250*1
		NOP 				;250*1
		lp2_ms:
			DJNZ R5,lp2_ms	;250*2*2
		DJNZ R4,lp1_ms		;250*2
	JMP change
	
	
;================================================
;=============== Meio segundo ;==================
;================================================
; usa r4,r5,r6
;
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

dadodisp:   clr  en
			clr rw
            setb rs
            setb en
            call delay
            clr  en
            ret

comdisp:    clr  en
           	clr rw
		    clr  rs
            setb en
            call delay
            clr  en
            ret

clearLCD:
		mov dado, #02h
		call comdisp
		call delay2
		ret

escrevemsg:	   call clearLCD
               mov  dptr,#mensagem  
			   jmp escrevemsgloop
			   
escrevemsg2:	   call clearLCD
					mov  dptr,#mensagem2  
escrevemsgloop:		clr a
					movc  a,@a+dptr
					cjne a, #00h, continuemsg
					jmp exitmsg
continuemsg:
					mov dado, a
					call dadodisp
					call delay2
					inc dptr
					cjne a, #00h, escrevemsgloop
exitmsg:
					ret

 org 500h
mensagem:  DB 'UTFPR 2018                              GABRIEL GUSTAVO',0 
mensagem2:  DB 'UTFPR 2020                              GUSTAVO GABRIEL',0 

delay:      mov r0,#0FH
loop:			mov r1, #0FH
				djnz r1,$
			   djnz r0, loop
			   ret
			   
delay2:      mov r0,#0FFH
loop2:		mov r1, #0FFH
				djnz r1,$
			   djnz r0, loop2
			   ret
			   
END

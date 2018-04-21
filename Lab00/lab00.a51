;========================================================
; 2018 - UTFPR
; https://gitlab.com/gabrielsouzaesilva
; https://github.com/cordeirolibel/
;========================================================
;
;CSW40 - Sistemas Microcontrolados
;LABORATÓRIO 00 - LCD E TECLADO MATRICIAL
;
;Roteiro: Interface via módulo display LCD 16x2 e teclado matricial (mínimo 3x4). Modo de
;operação livre para as equipes porém deve ter os seguintes requisitos mínimos:
;
;1. Implementar as tabuadas de 1 a 9.
;
;2. A cada vez que uma tecla for pressionada a tabuada daquele número deve ser mostrada no
;LCD e depois incrementada. Por exemplo, número 3 pressionado 1 vez ele efetua a operação
;3x0 e mostra no display “3x0=0”. Quando pressionado pela segunda vez ele efetua a operação
;3x1 e mostra no display “3x1=3”... Se outro número for pressionado, a tabuada daquele outro
;número começa do 0, enquanto a tabuada do 3 volta de onde parou quando solicitado.
;
;3. O que será escrito adicionalmente no display fica por conta da equipe, por exemplo, uma
;frase de saudação ao iniciar o programa. E depois deixar uma frase na primeira linha, “tabuada
;do número x” e na segunda linha a multiplicação.
;
;4. Quando chegar ao último valor da tabuada daquele número, por exemplo, supondo a
;tabuada do 9 (última operação 9x10), um relé deve ser disparado por 3 segundos. LEMBRAR
;DE POLARIZAR UM TRANSISTOR. O relé deve estar conectado com qualquer dispositivo, por
;exemplo, lâmpada ou buzzer.
;Observação: O bounce das teclas deve ser tratado via hardware ou software.





#include "at89c5131.h"
; Pinos Teclado
tec_A1 EQU P3.1   
tec_A2 EQU P3.3 
tec_A3 EQU P3.5 
tec_A4 EQU P3.4 
tec_B1 EQU P3.0 
tec_B2 EQU P3.2 
tec_B3 EQU P3.6 


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
	
    CALL inidisp
	CALL escrevemsg
		
;muda o estado do led se botao '1' pressionado
loop_main:

	;R4 <- botao
	CALL click_tcl 
	;salva em R6 o resultado em R4
	MOV A, R4 
	MOV R6, A
	
	;R4 <- mult, R5 <- RAM
	CALL save_num 
	
	;salva na memoria a mensagem:
	;  "Tabuada do R6"
	;  "R6*R5 = R4"
	CALL criar_msg
	
	;manda para o lcd
	CALL escrevemsg_tab
	
	JMP loop_main
	
;================================
;=========== Calculadora ============
;===================================

;Salva na memoria a seguinte mensagem
;  "Tabuada do R6"
;  "R6*R5 = R4"
; usa R0
criar_msg:
	
	MOV  dptr, #mensagem_tab  
	
	;======================
	;  "Tabuada do [R6]"
	;  "R6*R5 = R4"

	MOV R0, #0Bh
	;==> dptr += R0
sum_dptr1:
	INC dptr
	DJNZ R0,sum_dptr1
	
	;==> memoria[dprt] = R6
	MOV A, R6
	MOV R0, A
	CALL save_one_numb
	
	;======================
	;  "Tabuada do R6"
	;  "[R6]*R5 = R4"

	MOV R0, #1Bh
	;==> dptr += R0
sum_dptr2:
	INC dptr
	DJNZ R0,sum_dptr2
	
	;==> memoria[dprt] = R6
	MOV A, R6
	MOV R0, A
	CALL save_one_numb
	
	;======================
	;  "Tabuada do R6"
	;  "R6[*]R5 = R4"
	MOV A, #2Ah ;2Ah = '*' ascii
	MOVX @dptr,A
	INC dptr
	
	;======================
	;  "Tabuada do R6"
	;  "R6*[R5] = R4"
	
	;==> memoria[dprt] = R5
	MOV A, R5
	MOV R0, A
	CALL save_one_numb
	
	;======================
	;  "Tabuada do R6"
	;  "R6*R5[ = ]R4"
	
	MOV A, #20h ;20h = ' ' ascii
	MOVX @dptr,A
	INC dptr
	
	MOV A, #3Dh ;3Dh = '=' ascii
	MOVX @dptr,A
	INC dptr
	
	MOV A, #20h ;20h = ' ' ascii
	MOVX @dptr,A
	INC dptr
	
	;======================
	;  "Tabuada do R6"
	;  "R6*R5 = [R4]"
	
	;==> memoria[dprt] = R4
	MOV A, R4
	MOV R0, A
	CALL save_one_numb
	
	RET

;============================================
; sava R0 numero em decimal na memoria
; na regiao apontada por dprt
; usa A,B, R0

save_one_numb:
	MOV A, #09h
	SUBB A, R0
	
	;se der carry
	JC more_than_ten
		;r0<10
		;primeiro digito
		MOV A, #30h ;00110000b = 30h = '0' ascii
		MOVX @dptr,A
		
		INC dptr
		
		;segundo digito
		MOV A, R0
		ADD A, #30h ;00110000b = 30h
		MOVX @dptr,A
		
more_than_ten:
		;r0>=10
		;primeiro digito
		MOV A, R0
		MOV B, #0Ah
		DIV AB   ; A = A/B, B = A%B 
		ADD A, #30h ;00110000b = 30h
		MOVX @dptr,A
		
		INC dptr
		
		;segundo digito
		MOV A, B
		ADD A, #30h ;00110000b = 30h = '0' ascii
		MOVX @dptr,A	
	
	INC dptr
	RET



; verifica se tem o numero 10 salvo na RAM
; retorna em R4 1 se tiver
; nos enderecos [22,2A]
; usa R5, R4, R0
;tem_10:
;	MOV A, #22h
;	MOV R4,#00h
;	
;proximo_ram:
;	MOV R0, A
;	;MOV R5, @A
;	CJNE R5, #0Ah, nao_he_10
;	MOV R4,#01h
;	RET ;return 1
;nao_he_10:
;	INC A
;	CJNE A,#2Bh,proximo_ram
;	MOV R4, #00h
;	RET ;return 0
;


;===================================
;soma +1 na posicao 21+R4 da RAM
;se for maior q 10 salva 0
;retorna em R4 o valor salvo na RAM vezes R4
;retorna em R5 o valor da RAM
;usa A, R0,r4,r5
;R0 = endereco da RAM
;R4 = numero da calculadora
;R5 = valor RAM(21+R4)
save_num:

	; R5 <= RAM(21+R4)
	MOV A, #21h
	ADD A, R4
	MOV R0, A
	MOV A, @R0 
	MOV R5, A
	
	; RAM(21+R4) += 1
	INC R5
	;if (R5==10) R5 = 0
	CJNE R5,#11,menor_q_10
		MOV R5, #00h
		CALL rele ;evento de multiplicacao
menor_q_10:
	MOV A, R5
	MOV @R0, A
	
	
	; R4 = R5*R4
	MOV A, R5
	MOV B, R4
	MUL AB
	MOV R4, A
	
	RET
	
	

;===============================================
; rele disparado por 3 segundos
rele:
	SETB LED3
	;3 seg
	CALL meioseg
	CALL meioseg
	CALL meioseg
	CALL meioseg
	CALL meioseg
	CALL meioseg
	
	CLR LED3
	RET
	

;================================
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
; retorna em R4 a tecla
click_tcl:
	CALL read_tcl
	
	;===================================
	;esperando uma tecla 
	MOV R0, 20h
	MOV A, @R0
	CJNE A, #00h, wait_depress1
	MOV R0, 21h
	MOV A, @R0
	CJNE A, #00h, wait_depress2
	JMP click_tcl
	
	;===================================
	;esperando soltar RAM(0x20)
wait_depress1:
	MOV R4, A
	
	MOV R0, 20h
	MOV A, @R0
	CJNE A, #00h, wait_depress1
	
	;===================================
	;converter r4 para botao 
	MOV A, R4
	MOV R4, #00h
verifyBit1:
	RR A
	INC R4
	CJNE A, #00h, verifyBit1
	DEC R4
	RET
	
	;===================================
	;esperando soltar RAM(0x21)
wait_depress2:
	MOV R4, A
	
	MOV R0, 21h
	MOV A, @R0
	CJNE A, #00h, wait_depress2
	
	;===================================
	;converter r4 para botao 
	MOV A, R4
	MOV R4, #00h
verifyBit2:
	RR A
	INC R4
	CJNE A, #00h, verifyBit2
	MOV A,R4
	ADD A,#07h
	MOV R4,A
	
	RET


;===============================================
;======= leitura da tecla '1' do teclado =======
;===============================================
; usa A,r4,r5
; salva em 0x20.0
read_tcl:
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
		mov dado, #01h ;02h
		call comdisp
		call delay2
		ret

escrevemsg:   call clearLCD
               mov  dptr,#mensagem  
			   jmp escrevemsgloop
			   
escrevemsg_tab:call clearLCD
               mov  dptr,#mensagem_tab  
			   jmp escrevemsgloop
			   
			   
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
mensagem_tab:  DB 'Tabuada do ',0 
mensagem:  DB 'Tabuada         Gabriel Gustavo',0 


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

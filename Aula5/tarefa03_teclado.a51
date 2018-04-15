

;======= Pinos Teclado
tec_A1 EQU P3.7   
tec_A2 EQU P3.6 
tec_A3 EQU P3.5 
tec_A4 EQU P3.4 
tec_B1 EQU P3.3 
tec_B2 EQU P3.2 
tec_B3 EQU P3.1 
tec_B4 EQU P3.0
LED3 EQU P1.4

ORG 0000h
	
;muda o estado do led se botao '1' pressionado
loop:
	CALL read_tcl
	JB 0x20.0,press
		SETB LED3
	JMP loop
press:
		CLR LED3
	JMP loop
	
	
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
ch:
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
	JMP ch
	
	
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
	
END

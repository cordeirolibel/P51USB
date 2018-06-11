;============================================================
; Autor: Mikhail A. Koslowski
; Placa P51USB v1sem2013
;============================================================
; Escreve "LCD P51USB" na primeira linha do display
;============================================================
#include "..\P51USBv1.0.h"
    
;============================================================
; Vari�veis
;============================================================
DADO EQU 0x41 ; dados a serem escritos no display
INST EQU 0x42 ; instrucoes a serem executadas no display
COUNT EQU 0x43 ; usado para contar as letras ja escritas no display
;============================================================
; Vetor de interrup��o (0x0000 at� 0x007A)
;============================================================
ORG 0x0000 ;reset do sistema
JMP main

;============================================================
; Programa (0x007B at� 0x7FFF)
;============================================================
ORG 0x007B
main:

    MOV LEDCON, #0xA0

    CLR LED1
    CLR LED2
    CLR LED3

    ; inicializa o display
    CALL lcd_ini    

    ; carrega DPTR com o ponteiro para o inicio da frase
    MOV DPTR, #frase1 
    CALL lcd_string

fim:
    JMP $

;============================================================
; Fun��es do LCD
;============================================================

;------------------------------------------------------------
; Inicializa
;------------------------------------------------------------
lcd_ini:
    ; Enviar 3x a instru��o 0x30 
    ; como utiliza o busy flag, n�o precisa de delay
    MOV INST, #0x30
    CALL lcd_inst
    CALL lcd_inst
    CALL lcd_inst
    
    ; defini��es do usu�rio
    ; 8bits, 2 linhas, 5x8
    MOV INST, #0x38 
    CALL lcd_inst
    
    ; liga o display, mostra o cursor, n�o pisca.
    MOV INST, #0x0E 
    CALL lcd_inst
    
    ; N�o desloca a frase, cursor vai para direita.
    MOV INST, #0x06 
    CALL lcd_inst
    
    ; Return home.
    MOV INST, #0x02 
    CALL lcd_inst
    
    ; Clear display
    MOV INST, #0x01 
    CALL lcd_inst
    
    RET

;------------------------------------------------------------
; Verifica o busy_flag
; Retorna quando o LCD estiver dispon�vel (busy == 0)
;------------------------------------------------------------
lcd_busy:
    CLR LCD_RS
    SETB LCD_RW
    SETB P0.7    ; Seta o bit P0.7, para poder ler o valor correto do busy flag
lcd_busy_1:
    SETB LCD_E
    JNB P0.7, lcd_busy_2 ; se busy==0, terminou!
    CLR LCD_E
    JMP lcd_busy_1
lcd_busy_2:
    CLR LCD_RW
    RET

;------------------------------------------------------------
; Envia uma instru��o
; Par�metros: INST
;------------------------------------------------------------
lcd_inst:
    CALL lcd_busy
    CLR LCD_RS
    SETB LCD_E
    MOV LCD_DADO, INST
    CLR LCD_E
    RET

;------------------------------------------------------------
; Envia um dado
; Par�metros: DADO
;------------------------------------------------------------
lcd_dado:
    CALL lcd_busy
    SETB LCD_RS
    SETB LCD_E
    MOV LCD_DADO, DADO
    CLR LCD_E
    RET

;------------------------------------------------------------
; Escreve uma string
; Par�metros: DPTR (ponteiro para o string)
; Destroi: A, DPTR
;------------------------------------------------------------
lcd_string:
    MOV A, #0x00
    MOVC A, @A+DPTR      ; carrega o caracter em A
    JZ fim_lcd_string    ; Se for zero, acabou
    MOV DADO, A          ; sen�o
    CALL lcd_dado        ; escreve no display
    INC DPTR             ; incrementa DPTR
    JMP lcd_string       ; e vai pro pr�ximo
fim_lcd_string:        
    RET


;============================================================
; Constantes definidas na mem�ria de c�digo.
;============================================================
frase1:
;  '                ' 16chars
DB '   LCD P51USB   '
DB 0x00

END
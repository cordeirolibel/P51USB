;============================================================
; Autor: Mikhail A. Koslowski
; Placa P51USB v1sem2013
;============================================================
; Configura a interface SPI do AT89C5131A-M.
; Solicita amostragem de sinal do ADC (ADC0832)
; lê e armazena os valores.
;============================================================

;============================================================
; Definições de cada bit do byte de config do ADC
;============================================================
; Bit3 = start bit
#define START	0x08
; Bit2 = single/diff
#define SINGLE	0x04
; Bit1 = Signal
#define CH1p	0x02

;============================================================
; Conversões
;============================================================
; Single
#define CVT_CH0 (START | SINGLE)
#define CVT_CH1 (START | SINGLE | CH1p)
;============================================================
; Diferencial
#define CVT_DF1 (START | CH1p)
#define CVT_DF0 (START)
;============================================================
#define DUMMY 0xAA
#define SPIF 0x80 
#define SPEN 0x40 


;============================================================
; Includes
;============================================================
#include "..\P51USBv1.0.h"

;============================================================
; Defines
;============================================================
SAMPLE0 EQU 0x40
SAMPLE1 EQU 0x41
SAMPLE2 EQU 0x42

;============================================================
; Vetor de interrupções
;============================================================
	ORG 0x2000 ; reset
	LJMP ini
	
	ORG 0x2023 ; serial placeholder
	RETI

	ORG	0x204B ; SPI placeholder
	RETI	 ; não iremos utilizar a int da SPI
;============================================================
; Programa
;============================================================
	ORG 0x207B ; após o intvec, começa o progama
ini:
; 1 setup

; 1-1 disable ints
	MOV IEN0, #0x00
	MOV IEN1, #0x00

; 1-2 setup peripherals
; 1-2-1 SPI
	
	; SPR = 110, fclk_periph/128
	MOV SPCON, #10111110b 
			;	||||||||__ 	SPR0
			;	|||||||___	SPR1
			;	||||||____	Phase 1
			;	|||||_____	Polarity 1
			;	||||______	Master
			;	|||_______	¬SPI_SS
			;	||________	SPEN (disabled at configuring)
			;	|_________	SPR2

; 1-3 enable ints
	MOV IEN1, #0x00
	MOV	IEN0, #0x10	; int da serial para o flashmon

	SETB EA

main: ; 2 main code (loop)

	; liga o SPI
	MOV A, SPCON
	ORL A, #SPEN
	MOV SPCON, A

	SETB SPI_SS ; desabilita o ADC

loop:
; 2-1 sample ADC
	MOV A, #CVT_CH1
	LCALL ADC_SAMPLE
; 2-2 display data
	LCALL DISPLAY

	JMP loop

	JMP main

;============================================================
; Nome: ADC_SAMPLE
; Descrição: amostra o ADC utilizando a SPI
; Parâmetros:
; Retorna: SAMPLE0, SAMPLE1, SAMPLE2
; Destrói: A
;============================================================
ADC_SAMPLE:

	CLR SPI_SS;	habilita o ADC

	; carrega o buffer de saída com o primeiro byte.
	MOV SPDAT, A
	LCALL Tx	; aguarda concluir a operação
	
	MOV SAMPLE2, SPDAT

	; recarrego com DUMMY (tanto faz o valor)
	MOV SPDAT, #DUMMY
	LCALL Tx

	MOV SAMPLE1, SPDAT

	; recarrego com DUMMY (tanto faz o valor)
	MOV SPDAT, #DUMMY
	LCALL Tx

	MOV SAMPLE0, SPDAT ; lê para liberar o SPI

	SETB SPI_SS; desabilita o ADC

	RET
Tx:
	MOV A, SPSTA
	ANL A, #SPIF ; isola o bit.
	JZ	tx
	RET

;============================================================
; Nome:	DISPLAY
; Descrição: Placeholder para a função que
; 			 irá mostrar o valor.
; Parâmetros:
; Retorna:
; Destrói:
;============================================================
DISPLAY:
	; não implementado
	RET
END
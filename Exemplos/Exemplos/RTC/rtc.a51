;===============================================================================
; Autor: Mikhail A. Koslowski
; Placa P51USB v1.0
;============================================================
; Configura o RTC utilizando a interface I2C(TWI) 
; do AT89C5131A-M
; Ap�s a configura��o, l� periodicamente o valor do RTC.
;============================================================

; endere�os de leitura e escrita do RTC
#define RADDR 0xD1
#define WADDR 0xD0

; SSCON
#define SSIE	0x40
#define STA		0x20
#define STO		0x10	
#define SI		0x08
#define AA 		0x04


#include "..\P51USBv1.0.h"

;============================================================
; Vari�veis
;============================================================
MULT EQU 40h 

; Ser�o utilizados para setar e pegar a data/hora do RTC
SEC EQU 50h
MIN EQU 51h
HOU EQU 52h
DAY EQU 53h
DAT EQU 54h
MON EQU 55h
YEA EQU 56h
CTR EQU 57h


; ser�o utilizados para chamar as fun��es do i2c
B2W	EQU 66h 	; bytes to write
B2R EQU 67h 	; bytes to read
ADDR EQU 68h 	; internal register address
DBASE EQU 69h 	; endere�o base dos dados a serem escritos.


;============================================================
; bit endere��veis
;============================================================
; Uma vez que o HW I2C executa "paralelo" ao 51 e o SW � 
; totalmente composto de interrup��es
; devemos evitar que uma comunica��o se inicie antes
; de outra terminar
I2C_BUSY EQU 00h ; 0 - I2C livre, 1 - I2C ocupada
;============================================================
; Vetor de interrup��o (0x0000 at� 0x007A)
;============================================================
	ORG 0x0000 ; reset
	LJMP init

	ORG 0x0023 ; serial	(Place-holder)
	RETI
	
	ORG	0x0043 ; TWI (I2C)		
	LJMP i2c_int
;============================================================
; C�digo (0x007B at� 0x7FFF)
;============================================================
	ORG 0x007B
;------------------------------------------------------------
; 1 - Inicializar o HW.
;------------------------------------------------------------
init:
;	1.0 - Desabilita as interrup��es
	MOV IEN0, #0x00
	MOV IEN1, #0x00

; 	1.1 - Configurar o Timer 0
	MOV TMOD, #0x01 ; T0 no modo timer 16bits

;	1.2 - Configurar o I2C (TWI)
	SETB I2C_SCL
	SETB I2C_SDA ; Coloca os latches em high-Z

	; CR2 = 0, CR1 = 0, CR0 = 1, divisor XX,
	; clock 24MHz, I2C = XXXk

	MOV SSCON, #01000001b
			   ;||||||||_ CR0
		 	   ;|||||||__ CR1
			   ;||||||___ AA 
			   ;|||||____ SI  flag de int
			   ;||||_____ STO to send a stop
			   ;|||______ STA to send a start
			   ;||_______ SSIE Enable TWI
			   ;|________ CR2

;	1-3 Habilita as interrup��es
	MOV IPL1, #0x02
	MOV IPH1, #0x02
	MOV IEN1, #0x02	; habilita a int do i2c

	SETB EA	; liga as ints habilitadas
	
;------------------------------------------------------------
; Configurar o RTC com data e hora definidos
;------------------------------------------------------------
; 	2.1 - SEG, 24/06/2013 - 22:27:00
	MOV SEC, #0x00 ; BCD segundos, deve ser iniciado 
				   ; com valor PAR para o relogio funcionar.
	MOV MIN, #0x27 ; BCD minutos
	MOV HOU, #0x22 ; BCD hora, se o bit mais alto for 1,
				   ; o rel�gio � 12h, sen�o BCD 24h
	MOV DAY, #0x02 ; Dia da semana
	MOV DAT, #0x24 ; Dia
	MOV MON, #0x06 ; M�s
	MOV YEA, #0x13 ; Ano
	MOV CTR, #0x00 ; SQW desativada em n�vel 0

	LCALL RTC_SET_TIME
	 
main:
;------------------------------------------------------------
;Ler o RTC periodicamente
;------------------------------------------------------------
	MOV R7, #0x05
reload:
	CPL LED1			; toggle no led
	MOV R6, #0x04		; 4x
again:
	MOV MULT, #0xFA		; 250x
	LCALL runT0			; 0.5ms
	DJNZ R6, again		; = 1s

	DJNZ R7, reload		; 5s

	LCALL	RTC_GET_TIME

	JMP main
;------------------------------------------------------------
; Nunca dever� chegar aqui!
	 JMP init
;------------------------------------------------------------

;============================================================
; Fun��es do Timer0
;============================================================
;------------------------------------------------------------
; Nome: runT0
; Descri��o: Gera atraso de tempo utilizando Timer0
; Par�metros: MULT
; Retorna:
; Destr�i: MULT
;------------------------------------------------------------
runT0:
    MOV TH0,#0FCh 	;fclk CPU = 24MHz
    MOV TL0,#17h 	; ... base de tempo de 0,5ms
    SETB TR0 		;dispara timer

    JNB TF0,$ 		;preso CLR TR0 ;stop timer
    CLR TR0 		;para o timer 0
    CLR TF0 		;zera flag overflow
    DJNZ MULT,runT0
    RET   
;============================================================
; Fun��es do I2C
;============================================================
;------------------------------------------------------------
; Nome:	RTC_SET_TIME
; Descri��o: escreve data e hora no RTC
; Par�metros: SEC, MIN, HOU
; Retorna:
; Destr�i: A
;------------------------------------------------------------
RTC_SET_TIME:
	MOV ADDR, #0x00		; endere�o do reg interno
	MOV B2W, #(8+1) 	; a quantidade de bytes que dever�o 
						; ser enviados + 1.
	MOV B2R, #(0+1)		; a quantidade de bytes que ser�o 
						; lidos + 1.
	MOV DBASE, #SEC		; endere�o base dos dados

	; gera o start, daqui pra frente � tudo na interrup��o.
	MOV A, SSCON
	ORL A, #STA
	MOV SSCON, A

	; devemos aguardar um tempo "suficiente"
	; para ser gerada a interrup��o de START
	MOV MULT, #0xA ; 5ms
	LCALL runT0

	JB I2C_BUSY, $

	RET
;------------------------------------------------------------
; Nome:	RTC_GET_TIME
; Descri��o: l� data e hora do RTC
; Par�metros:
; Retorna: SEC, MIN, HOU
; Destr�i: A
;------------------------------------------------------------
RTC_GET_TIME:
	MOV ADDR, #0x00		; endere�o do reg interno
	MOV B2W, #(0+1) 	; a quantidade de bytes que dever�o 
						; ser enviados + 1.
	MOV B2R, #(3+1)		; a quantidade de bytes que ser�o 
	 					; lidos + 1.
	MOV DBASE, #SEC		; endere�o base dos dados (buffer)

	; gera o start, daqui pra frente � tudo na interrup��o.
	MOV A, SSCON
	ORL A, #STA
	MOV SSCON, A

	; devemos aguardar um tempo "suficiente"
	; para ser gerada a interrup��o de START
	MOV MULT, #0xA
	LCALL runT0

	JB I2C_BUSY, $

	RET
;------------------------------------------------------------
; Nome:	i2c_int
; Descri��o: Rotina de atendimento da interrup��o do TWI
; Par�metros:
; Retorna:
; Destr�i: A, DPH, DPL (DPTR)
;------------------------------------------------------------
i2c_int:
	CPL LED2 ; "pisca" um led na int somente para debug.
   	
	MOV A, SSCS ; pega o valor do Status
	RR A		; faz 1 shift (divide por 2)

	LCALL decode ; opera o PC, faz cair exatamente no
				 ; local correto abaixo.
								 
	; Como isso funciona? :
	; cada LJMP tem 3 bytes, NOP 1 byte.
	; LJMP + NOP = 4 bytes.
	; os c�digos de retorno do SSCS s�o multiplos de 8, 
	; dividindo por 2 ficam multiplos de 4
	; quando "chamamos" decode com LCALL, o PC de retorno (
	; que � o primeiro LJMP abaixo deste coment�rio)
	; fica salvo na pilha.
	; capturo o PC de retorno da pilha e somo esse multiplo.
	; quando acontecer o RET, estaremos no LJMP exato
	; para atender a int!
	
	; Erro no Bus (00h)
	LJMP ERRO ; 0
	NOP
	; start	(8h >> 1 = 4)
	LJMP START
	NOP	
	; re-start (10h >> 1 = 8)
	LJMP RESTART
	NOP
	; W ADDR ack (18h >> 1 = 12)
	LJMP W_ADDR_ACK
	NOP
	; W ADDR Nack (20h >> 1 = 16)
	LJMP W_ADDR_NACK
	NOP
	; Data ack W (28h >> 1 = 20)
	LJMP W_DATA_ACK
	NOP
	; Data Nack W (30h >> 1 = 24)
	LJMP W_DATA_NACK
	NOP
	; Arb-Lost (38h >> 1  = 28)
	LJMP ARB_LOST
	NOP
	; R ADDR ack (40h >> 1 = 32)
	LJMP R_ADDR_ACK
	NOP
	; R ADDR Nack (48h >> 1 = 36)
	LJMP R_ADDR_NACK
	NOP
	; Data ack R (50h >> 1 = 40)
	LJMP R_DATA_ACK
	NOP
	; Data Nack R (58h >> 1 = 44)
	LJMP R_DATA_NACK
	NOP

	; slave receive n�o implementado
	LJMP not_impl
	NOP ; 60
	LJMP not_impl
	NOP ; 68
	LJMP not_impl
	NOP ; 70
	LJMP not_impl
	NOP ; 78
	LJMP not_impl
	NOP ; 80
	LJMP not_impl
	NOP ; 88
	LJMP not_impl
	NOP ; 90
	LJMP not_impl
	NOP ; 98
	LJMP not_impl
	NOP ; A0
	;slave transmit n�o implementado
	LJMP not_impl
	NOP ; A8
	LJMP not_impl
	NOP ; B0
	LJMP not_impl
	NOP ; B8
	LJMP not_impl
	NOP ; C0
	LJMP not_impl
	NOP ; C8

	; c�digos n�o implementados
	LJMP not_impl
	NOP ; D0
	LJMP not_impl
	NOP ; D8
	LJMP not_impl
	NOP ; E0
	LJMP not_impl
	NOP ; E8
	LJMP not_impl
	NOP ; F0

	; nada a ser feito (apenas "cai" no fim da int)
	LJMP end_i2c_int
	NOP ; F8
;------------------------------------------------------------
not_impl:
end_i2c_int:
	RETI
;============================================================
; Est� � a fun��o que opera o PC e faz o retorno
; ir para o local correto.
;============================================================
decode:
	POP DPH
	POP DPL			; captura o PC "de retorno"
	ADD A, DPL
	MOV DPL, A		; soma nele o valor de A (A = SSCS/2)
	JNC termina
	MOV A, #1
	ADD A, DPH		; se tiver carry, aumenta a parte alta.
	MOV DPH, A
termina:
	PUSH DPL		; p�em o novo pc na pilha 
	PUSH DPH		; e ...
	RET				; pula pra ele!
;============================================================
	
;------------------------------------------------------------
; Aqui se iniciam as "verdadeiras" ISRs
; A implementa��o dessas ISRs seguiu os modelos 
; propostos no datasheet
; Por�m n�o foram implementadas todas as possibilidades
; para todos os c�digos
; foram implementadas apenas as necess�rias para garantir
; um fluxo de dados de escrita e leitura como master, 
; contemplando inclusive as poss�veis falhas
;------------------------------------------------------------
ERRO:
	MOV A, SSCON
	ANL A, #STO ; gera um stop
	MOV SSCON, A
	CLR	I2C_BUSY ; zera o flag de ocupado
	LJMP end_i2c_int
;------------------------------------------------------------
START:
; um start SEMPRE vai ocasionar uma escrita
; pois para ler, preciso primeiro escrever de onde vou ler!
; SSDAT = SLA + W
; STO = 0 e SI = 0
	SETB I2C_BUSY		; seta o flag de ocupado
	MOV SSDAT, #WADDR
	MOV A, SSCON
	ANL A, #~(STO | SI)	; zera os bits STO e SI
	MOV SSCON, A
	LJMP end_i2c_int
;------------------------------------------------------------
RESTART:
; o Restart ser� utilizado apenas para leituras,
; onde h� a necessidade de fazer um
; start->escrita->restart->leitura->stop
; SSDAT = SLA + R
; STO = 0 e SI = 0
	MOV SSDAT, #RADDR
	MOV A, SSCON
	ANL A, #~(STO | SI)	; zera os bits STO e SI
	MOV SSCON, A
	LJMP end_i2c_int
;------------------------------------------------------------
W_ADDR_ACK:
; ap�s um W_addr_ack temos que escrever o
; registrador interno!
; SSDAT = ADDR
; STA = 0, STO = 0, SI = 0
	MOV SSDAT, ADDR
	MOV A, SSCON
	ANL A, #~(STA | STO | SI)	; zera os bits STA, STO e SI
	MOV SSCON, A
	LJMP end_i2c_int
;------------------------------------------------------------
W_ADDR_NACK:
; em caso de nack, ou o end ta errado ou o slave
; n�o est� conectado. n�o vamos fazer retry,
; encerramos a comunica��o.
; STA = 0, SI = 0
; STO = 1
	MOV A, SSCON
	ANL A, #~(STA | SI)	; zera os bits STA e SI
	ORL A, #STO					; seta STO
	MOV SSCON, A
	LJMP end_i2c_int
;------------------------------------------------------------
W_DATA_ACK:
; ap�s o primeiro data ack (registrador interno)
; temos 2 op��es:
; 1 - escrever um novo byte
; 2 - gerar um restart para leitura
	DJNZ B2W, wda1		; enquanto tiver bytes para
						; escrever, pula para wda1

	; se n�o tiver mais bytes para escrever, come�e a ler
	DJNZ B2R, wda2		;se tiver algum byte pra ler,
						; pula para wd
	MOV A, SSCON 
	ANL A, #~(STA | SI)	; sen�o..
	ORL A, #STO			; gera um STOP
	MOV SSCON, A
	CLR	I2C_BUSY ; zera o flag de ocupado
	LJMP end_i2c_int
wda2:
	MOV A, SSCON 
	ANL A, #~(STO | SI)
	ORL A, #STA			; ..gera um restart!
	MOV SSCON, A
	LJMP end_i2c_int
wda1:
	MOV R0, DBASE
	MOV SSDAT, @R0	; ...escreve o proximo!
	MOV A, SSCON
	ANL A, #~(STA | STO | SI) ; zera STA, STO e SI
	MOV SSCON, A
	INC DBASE		; incrementa o indice do buffer
	LJMP end_i2c_int
;------------------------------------------------------------
W_DATA_NACK:
; ap�s um data_nack, podemos repetir ou encerrar
; vamos encerrar
	MOV A, SSCON 
	ANL A, #~(STA | SI)
	ORL A, #STO			; gera um STOP
	MOV SSCON, A
	CLR	I2C_BUSY ; zera o flag de ocupado
	LJMP end_i2c_int	
;------------------------------------------------------------
ARB_LOST:
; ap�s um arb-lost podemos acabar sendo
; endere�ados como slave
; o arb-lost costuma ocorrer em 2 situa��es:
; 1 - problemas f�sicos no bus
; 2 - ambiente multi-master (n�o � o caso)
; em ambos os casos, n�o vamos fazer nada!
; pois n�o estamos implementando a comunica��o em modo slave.
	LJMP end_i2c_int	
;------------------------------------------------------------
R_ADDR_ACK:
; depois de um R ADDR ACK, recebemos os bytes!
	MOV A, SSCON
	ANL A, #~(STA | STO | SI) ; receberemos o proximo byte
	
	DJNZ B2R, raa1 ; decrementa a quantidade de
				   ; bytes a receber!
	; se der 0, � o ultimo byte a ser recebido
	ANL A, #~AA	; retorne NACK
	SJMP raa2
	; se n�o...
raa1:
	ORL A, #AA	; retorne ACK para o slave!
raa2:	
	MOV SSCON, A
	LJMP end_i2c_int	
;------------------------------------------------------------
R_ADDR_NACK:
; idem ao w_addr_nack
	MOV A, SSCON 
	ANL A, #~(STA | SI)
	ORL A, #STO			; gera um STOP
	MOV SSCON, A
	CLR	I2C_BUSY ; zera o flag de ocupado
	LJMP end_i2c_int	
;------------------------------------------------------------
R_DATA_ACK:
; se tiver mais bytes pra ler, de um ack, sen�o de um nack

	MOV R0, DBASE
	MOV	@R0, SSDAT ; le o byte que j� chegou

	MOV A, SSCON
	ANL A, #~(STA | STO | SI) ; receberemos o proximo byte
	
	DJNZ B2R, rda1  ; decrementa a quantidade de 
					; bytes a receber!
	; se der 0, � o ultimo byte a ser recebido
	ANL A, #~AA	; retorne NACK
	SJMP rda2
	; se n�o...
rda1:
	ORL A, #AA	; retorne ACK para o slave!
rda2:	
	MOV SSCON, A
	INC DBASE ; incrementa o buffer
	LJMP end_i2c_int
;------------------------------------------------------------
R_DATA_NACK:
; salva o ultimo byte e termina

	MOV R0, DBASE
	MOV	@R0, SSDAT ; le o byte que j� chegou

	MOV A, SSCON 
	ANL A, #~(STA | SI)
	ORL A, #STO			; gera um STOP
	MOV SSCON, A

	INC DBASE ; inc o buffer

	CLR	I2C_BUSY ; zera o flag de ocupado
	LJMP end_i2c_int	

END
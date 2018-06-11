;===============================================================================
; Autor: Mikhail A. Koslowski
; Placa P51USB v1.0
;============================================================
; Configura o RTC utilizando a interface I2C(TWI) 
; do AT89C5131A-M
; Após a configuração, lê periodicamente o valor do RTC.
;============================================================

; endereços de leitura e escrita do RTC
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
; Variáveis
;============================================================
MULT EQU 40h 

; Serão utilizados para setar e pegar a data/hora do RTC
SEC EQU 50h
MIN EQU 51h
HOU EQU 52h
DAY EQU 53h
DAT EQU 54h
MON EQU 55h
YEA EQU 56h
CTR EQU 57h


; serão utilizados para chamar as funções do i2c
B2W	EQU 66h 	; bytes to write
B2R EQU 67h 	; bytes to read
ADDR EQU 68h 	; internal register address
DBASE EQU 69h 	; endereço base dos dados a serem escritos.


;============================================================
; bit endereçáveis
;============================================================
; Uma vez que o HW I2C executa "paralelo" ao 51 e o SW é 
; totalmente composto de interrupções
; devemos evitar que uma comunicação se inicie antes
; de outra terminar
I2C_BUSY EQU 00h ; 0 - I2C livre, 1 - I2C ocupada
;============================================================
; Vetor de interrupção (0x0000 até 0x007A)
;============================================================
	ORG 0x0000 ; reset
	LJMP init

	ORG 0x0023 ; serial	(Place-holder)
	RETI
	
	ORG	0x0043 ; TWI (I2C)		
	LJMP i2c_int
;============================================================
; Código (0x007B até 0x7FFF)
;============================================================
	ORG 0x007B
;------------------------------------------------------------
; 1 - Inicializar o HW.
;------------------------------------------------------------
init:
;	1.0 - Desabilita as interrupções
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

;	1-3 Habilita as interrupções
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
				   ; o relógio é 12h, senão BCD 24h
	MOV DAY, #0x02 ; Dia da semana
	MOV DAT, #0x24 ; Dia
	MOV MON, #0x06 ; Mês
	MOV YEA, #0x13 ; Ano
	MOV CTR, #0x00 ; SQW desativada em nível 0

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
; Nunca deverá chegar aqui!
	 JMP init
;------------------------------------------------------------

;============================================================
; Funções do Timer0
;============================================================
;------------------------------------------------------------
; Nome: runT0
; Descrição: Gera atraso de tempo utilizando Timer0
; Parâmetros: MULT
; Retorna:
; Destrói: MULT
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
; Funções do I2C
;============================================================
;------------------------------------------------------------
; Nome:	RTC_SET_TIME
; Descrição: escreve data e hora no RTC
; Parâmetros: SEC, MIN, HOU
; Retorna:
; Destrói: A
;------------------------------------------------------------
RTC_SET_TIME:
	MOV ADDR, #0x00		; endereço do reg interno
	MOV B2W, #(8+1) 	; a quantidade de bytes que deverão 
						; ser enviados + 1.
	MOV B2R, #(0+1)		; a quantidade de bytes que serão 
						; lidos + 1.
	MOV DBASE, #SEC		; endereço base dos dados

	; gera o start, daqui pra frente é tudo na interrupção.
	MOV A, SSCON
	ORL A, #STA
	MOV SSCON, A

	; devemos aguardar um tempo "suficiente"
	; para ser gerada a interrupção de START
	MOV MULT, #0xA ; 5ms
	LCALL runT0

	JB I2C_BUSY, $

	RET
;------------------------------------------------------------
; Nome:	RTC_GET_TIME
; Descrição: lê data e hora do RTC
; Parâmetros:
; Retorna: SEC, MIN, HOU
; Destrói: A
;------------------------------------------------------------
RTC_GET_TIME:
	MOV ADDR, #0x00		; endereço do reg interno
	MOV B2W, #(0+1) 	; a quantidade de bytes que deverão 
						; ser enviados + 1.
	MOV B2R, #(3+1)		; a quantidade de bytes que serão 
	 					; lidos + 1.
	MOV DBASE, #SEC		; endereço base dos dados (buffer)

	; gera o start, daqui pra frente é tudo na interrupção.
	MOV A, SSCON
	ORL A, #STA
	MOV SSCON, A

	; devemos aguardar um tempo "suficiente"
	; para ser gerada a interrupção de START
	MOV MULT, #0xA
	LCALL runT0

	JB I2C_BUSY, $

	RET
;------------------------------------------------------------
; Nome:	i2c_int
; Descrição: Rotina de atendimento da interrupção do TWI
; Parâmetros:
; Retorna:
; Destrói: A, DPH, DPL (DPTR)
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
	; os códigos de retorno do SSCS são multiplos de 8, 
	; dividindo por 2 ficam multiplos de 4
	; quando "chamamos" decode com LCALL, o PC de retorno (
	; que é o primeiro LJMP abaixo deste comentário)
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

	; slave receive não implementado
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
	;slave transmit não implementado
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

	; códigos não implementados
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
; Está é a função que opera o PC e faz o retorno
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
	PUSH DPL		; põem o novo pc na pilha 
	PUSH DPH		; e ...
	RET				; pula pra ele!
;============================================================
	
;------------------------------------------------------------
; Aqui se iniciam as "verdadeiras" ISRs
; A implementação dessas ISRs seguiu os modelos 
; propostos no datasheet
; Porém não foram implementadas todas as possibilidades
; para todos os códigos
; foram implementadas apenas as necessárias para garantir
; um fluxo de dados de escrita e leitura como master, 
; contemplando inclusive as possíveis falhas
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
; o Restart será utilizado apenas para leituras,
; onde há a necessidade de fazer um
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
; após um W_addr_ack temos que escrever o
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
; não está conectado. não vamos fazer retry,
; encerramos a comunicação.
; STA = 0, SI = 0
; STO = 1
	MOV A, SSCON
	ANL A, #~(STA | SI)	; zera os bits STA e SI
	ORL A, #STO					; seta STO
	MOV SSCON, A
	LJMP end_i2c_int
;------------------------------------------------------------
W_DATA_ACK:
; após o primeiro data ack (registrador interno)
; temos 2 opções:
; 1 - escrever um novo byte
; 2 - gerar um restart para leitura
	DJNZ B2W, wda1		; enquanto tiver bytes para
						; escrever, pula para wda1

	; se não tiver mais bytes para escrever, começe a ler
	DJNZ B2R, wda2		;se tiver algum byte pra ler,
						; pula para wd
	MOV A, SSCON 
	ANL A, #~(STA | SI)	; senão..
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
; após um data_nack, podemos repetir ou encerrar
; vamos encerrar
	MOV A, SSCON 
	ANL A, #~(STA | SI)
	ORL A, #STO			; gera um STOP
	MOV SSCON, A
	CLR	I2C_BUSY ; zera o flag de ocupado
	LJMP end_i2c_int	
;------------------------------------------------------------
ARB_LOST:
; após um arb-lost podemos acabar sendo
; endereçados como slave
; o arb-lost costuma ocorrer em 2 situações:
; 1 - problemas físicos no bus
; 2 - ambiente multi-master (não é o caso)
; em ambos os casos, não vamos fazer nada!
; pois não estamos implementando a comunicação em modo slave.
	LJMP end_i2c_int	
;------------------------------------------------------------
R_ADDR_ACK:
; depois de um R ADDR ACK, recebemos os bytes!
	MOV A, SSCON
	ANL A, #~(STA | STO | SI) ; receberemos o proximo byte
	
	DJNZ B2R, raa1 ; decrementa a quantidade de
				   ; bytes a receber!
	; se der 0, é o ultimo byte a ser recebido
	ANL A, #~AA	; retorne NACK
	SJMP raa2
	; se não...
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
; se tiver mais bytes pra ler, de um ack, senão de um nack

	MOV R0, DBASE
	MOV	@R0, SSDAT ; le o byte que já chegou

	MOV A, SSCON
	ANL A, #~(STA | STO | SI) ; receberemos o proximo byte
	
	DJNZ B2R, rda1  ; decrementa a quantidade de 
					; bytes a receber!
	; se der 0, é o ultimo byte a ser recebido
	ANL A, #~AA	; retorne NACK
	SJMP rda2
	; se não...
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
	MOV	@R0, SSDAT ; le o byte que já chegou

	MOV A, SSCON 
	ANL A, #~(STA | SI)
	ORL A, #STO			; gera um STOP
	MOV SSCON, A

	INC DBASE ; inc o buffer

	CLR	I2C_BUSY ; zera o flag de ocupado
	LJMP end_i2c_int	

END








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

;======= Pinos Teclado
tec_A1 EQU P3.7   
tec_A2 EQU P3.6 
tec_A3 EQU P3.5 
tec_A4 EQU P3.4 
tec_B1 EQU P3.3 
tec_B2 EQU P3.2 
tec_B3 EQU P3.1 
tec_B4 EQU P3.0

;======= Funcao de Leitura
read_tcl:
	
	;Ligar somente tec_B1
	CLR tec_B1
	SETB tec_B2
	SETB tec_B3
	SETB tec_B4
	;pula se A1 esta ligado, 0 se esta precionado
	JB tec_A1, jp_B1_A1
		
jp_B1_A1:








end

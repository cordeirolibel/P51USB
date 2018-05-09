;Placa P51USB v1.0
;Programa de teste
;------------------------------------------------------
;Chave SW1(P3.2) faz toogle do Led3(P1.4)

#include "at89c5131.h"

; Definições da P51USB
LED3 EQU P1.4
SW1 EQU P3.2

ORG 0x2000
LJMP main

main:
	JNB SW1, toggle
  SJMP main
toggle:
	CPL LED3
	SJMP main
END
; -----------------------------------------------------------------
; Programa para deslocamento dos leds
; ------------------------------------------------------------------
org 0000h

jmp inicio	; jump para pular a região de interrupções 

;org 100h

;----- programa principal----

inicio:	jnb P3.2, crescente       ;verifica se este port foi selecionado
		jnb P3.3, decrescente	  ;verifica se este port foi selecionado	
		jmp inicio				  ;retorna ao inicio caso nenhum dos ports tenha sido selecionado

;---------------------------
crescente:	mov a, #01H
cre1:      	mov p1,a
			inc a
	   		;acall delay
			cjne a, #0ffh, cre1
			mov p1,a
			jmp inicio

decrescente:mov a, #0ffH
decre1:    	mov p1,a
			RRC a
	   		;acall delay
			cjne a, #00h, decre1
			mov p1,a
			jmp inicio



;-----Rotina de delay---------	
delay:	 		mov r0,#03h
loop1:	      	mov r1,#0FFh
loop:			mov R2,#0ffh
               	djnz r2,$ ; jump para a mesma linha
		      	djnz r1,loop
				djnz r0,loop1
	            ret

;-----------------------------

end      


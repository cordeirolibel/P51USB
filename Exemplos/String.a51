ORG 0000H
		;coisas que eu só irei fazer uma vez
		;carrego um registrador com 0 para guardar um
		;valor inicial de índice
		MOV R0, #0h
		;copio o endereço da tabela para o DPTR
		MOV DPTR, #TABELA
	laco:
		;Primeiro coloco o indice guardado no R0 do acumulador
		MOV A, R0
		;copio o offset da tabela + o indice de A em A
		MOVC A, @A+DPTR
		;vejo se o acumulador é zero , ou seja,
		;string chegou ao fim
		INC R0
		;pulo de volta para o laço
		JNZ laco
		
		
		;Declaração da string com finalizador de 0
	TABELA:
		DB "UTFPR Micro", 0h
			
END
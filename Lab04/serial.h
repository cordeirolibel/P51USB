

//===================================Serial
//http://ww1.microchip.com/downloads/en/AppNotes/doc4348.pdf
// Usa P3.0 e P3.1
// 57600 Baud Rate
void initSerial(void){
//
	T2CON = 0x34;
	RCAP2H = 0xFF;
	RCAP2L = 0xF3;
	TR2 = 1; // Inicia o timer
	//TCLK  = 0;
	//RCLK  = 1;				// RCLK = 1 e TCLK= 0 para recepção
	SCON 	= 0x50; 		//modo 1, ren =1 (reciver enable bit(ativa a serial)
	//PCON 	= 0x00;			//80= Dobra a relação serial
	//RI 		= 0;
	//TI 		= 0;
}


char getChar(void){
	unsigned char caractere;
	while(!RI){}
	caractere = SBUF;
	RI = 0;
	return caractere;
}

void sendChar(unsigned char caractere){
	SBUF = caractere;
	TI = 0;
	while(!TI){}
}

void sendString(unsigned char* mensagem){
	int k;
	for(k=0;mensagem[k]!='\0';k++){
		sendChar(mensagem[k]);
	}
}

#include <PWM.h>
#include <lcd.h>
#include <at89c5131.h>


// NÃO USAR PINOS 3.0 E 3.1 (NAO USAR/DO NOT USE)

void initSerial(void);
void sendChar(unsigned char);

void main(void)
{
	initSerial();
	
	while(1){
		escreveArray("8000!!");
		msdelay(2000);
		escreveArray("joaodasneves>\nragnar");
		msdelay(2000);
		sendChar(41);
	}
}

void initSerial(void){
	RCAP2H = 0xF6;
	RCAP2L = 0x3C;
	TR2 = 1; // Inicia o timer
	TCLK  = 0;
	RCLK  = 1;				// RCLK = 1 e TCLK= 0 para recepção
	SCON 	= 0x50; 		//modo 1, ren =1 (reciver enable bit(ativa a serial)
	PCON 	= 0x00;			//80= Dobra a relação serial
	RI 		= 0;
	TI 		= 0;
}

void sendChar(unsigned char c){
	SBUF = c;
	TI = 0;
	while(!TI){}
}
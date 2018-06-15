#include <PWM.h>
#include <at89c5131.h>
#include <lcd.h>

// NAO USAR P3.0 E P3.1

char getChar (void);
void sendChar(unsigned char c);
void init_serial(void);
void escreveArray(unsigned char mensagem[15]);
unsigned char mensagem[15];
unsigned char d;


// Main Function
void main(void)
{
	lcd_init();
	init_serial();
	
	escreveArray("12h AM/PM");
	lcd_cmd(0xC0);
	escreveArray("24h");
	
	while(1)
	{
		escreveArray("ronaldo");
		msdelay(10);
		escreveArray("pele");
		msdelay(10);
	}
}

void init_serial(void){
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

char getChar(void){
	char d;
	while(!RI){}
	d = SBUF;
	RI = 0;
	return d;
}

void sendChar(unsigned char c){
	SBUF = c;
	TI = 0;
	while(!TI){}
}

void escreveArray(unsigned char mensagem[15])
{
	unsigned char k;
	lcd_init();	
	lcd_cmd(0x80);
	k = 0;
	while(mensagem[k] != '\0')
	{
		lcd_data(mensagem[k]);
		k++;
	}
}
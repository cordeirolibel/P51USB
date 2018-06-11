#include <PWM.h>
#include <lcd.h>
#include <at89c5131.h>

sbit LED2 = P3^7;

//Teclado
sbit A1 = P2^1;
sbit A2 = P3^3;
sbit A3 = P3^5;
sbit A4 = P3^4;
sbit B1 = P2^0;
sbit B2 = P3^7;
sbit B3 = P3^6;

// NÃO USAR PINOS 3.0 E 3.1 (NAO USAR/DO NOT USE/ N'UTILLISEZ PAS/ NON Y USES)

void initSerial(void);
void sendChar(unsigned char);
unsigned char readTcl(void);

void main(void)
{
	unsigned char c;
	
	initSerial();
	EA = 1;
  
	
	while(1){
		while(!(c = readTcl()));
		lcd_data(c);
		//escreveArray("8001!!");
		//msdelay(2000);
		sendChar('a');
		//escreveArray("jhonisnow>\nragnar");
		//msdelay(2000);
		sendChar('1');
	}
}

void initSerial(void){
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

void sendChar(unsigned char c){
	SBUF = c;
	TI = 0;
	LED2 = 0;
	while(!TI){}
	LED2 = 1;
}

unsigned char readTcl(void)
{
  B1=1;
  B2=1;
  B3=1;
  
  A1=0;
  A2=1;
  A3=1;
  A4=1;
	
  if(B1==0){msdelay(100);while(B1==0);return '#';}
  if(B2==0){msdelay(100);while(B2==0);return '0';}
  if(B3==0){msdelay(100);while(B3==0);return '*';}
  
  A1=1;
  A2=0;
  A3=1;
  A4=1;
	
  if(B1==0){msdelay(100);while(B1==0);return '3';}
  if(B2==0){msdelay(100);while(B2==0);return '2';}
  if(B3==0){msdelay(100);while(B3==0);return '1';}
  
  A1=1;
  A2=1;
  A3=0;
  A4=1;
	
  if(B1==0){msdelay(100);while(B1==0);return '6';}
  if(B2==0){msdelay(100);while(B2==0);return '5';}
  if(B3==0){msdelay(100);while(B3==0);return '4';}
  
  A1=1;
  A2=1;
  A3=1;
  A4=0;
	
  if(B1==0){msdelay(100);while(B1==0);return '9';}
  if(B2==0){msdelay(100);while(B2==0);return '8';}
  if(B3==0){msdelay(100);while(B3==0);return '7';}
  
  return 0;
}

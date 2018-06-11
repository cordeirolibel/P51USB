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

//SPI
char serial_data;
char data_example=0x55;
char data_save;
bit transmit_completed= 0;

// N�O USAR PINOS 3.0 E 3.1 (NAO USAR/DO NOT USE/ N'UTILLISEZ PAS/ NON Y USES)

void initSerial(void);
void sendChar(unsigned char);
unsigned char readTcl(void);
void initSPI(void);
char SPI_sample();

void main(void)
{
	unsigned char c;

	//inits
	initSerial();
	initSPI();	
	EA = 1;
  
	escreveArray("Oi");
	
	
	
	sendChar('O');
	sendChar('l');
	sendChar('a');
	
	while(1){
		//while(!(c = readTcl()));
		//lcd_data(c);
		//escreveArray("8001!!");
		//msdelay(2000);
		//sendChar('a');
		//escreveArray("jhonisnow>\nragnar");
		//msdelay(2000);
		//sendChar('1');
		
		c = SPI_sample();
		sendChar(c);
		msdelay(1);
	}
}

//Usa P1.1 P1.7 P1.5 P1.6
void initSPI(void){
	SPCON |= 0x10; /* Master mode */
	P1_1=1; /* enable master */
	SPCON |= 0x82; /* Fclk Periph/128 */
	SPCON &= ~0x08; /* CPOL=0; transmit mode example */
	SPCON |= 0x04; /* CPHA=1; transmit mode example */
	IEN1 |= 0x04; /* enable spi interrupt */
	SPCON |= 0x40; /* run spi */
}

/**
 * FUNCTION_PURPOSE:interrupt
 * FUNCTION_INPUTS: void
 * FUNCTION_OUTPUTS: transmit_complete is software transfert flag
 */
void it_SPI(void) interrupt 9 /* interrupt address is 0x004B */
{
	switch( SPSTA ) /* read and clear spi status register */
	{
		case 0x80:
			serial_data=SPDAT; /* read receive data */
			transmit_completed=1;/* set software flag */
		break;
		case 0x10:
		/* put here for mode fault tasking */
		break;
		case 0x40:
		/* put here for overrun tasking */
		break;
	}
}

char SPI_sample(){
	SPDAT=data_example; /* send an example data */
	while(!transmit_completed);/* wait end of transmition */
	transmit_completed = 0; /* clear software transfert flag */
	SPDAT=0x00; /* data is send to generate SCK signal */
	while(!transmit_completed);/* wait end of transmition */
	transmit_completed = 0; /* clear software transfert flag */
	data_save = serial_data; /* save receive data */ 
	
	return data_save;
}

// Usa P3.0 e P3.1
void initSerial(void){
	T2CON = 0x34;
	RCAP2H = 0xFF;
	RCAP2L = 0xF3;
	TR2 = 1; // Inicia o timer
	//TCLK  = 0;
	//RCLK  = 1;				// RCLK = 1 e TCLK= 0 para recep��o
	SCON 	= 0x50; 		//modo 1, ren =1 (reciver enable bit(ativa a serial)
	//PCON 	= 0x00;			//80= Dobra a rela��o serial
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
	
	msdelay(1);
  if(B1==0){msdelay(1);while(B1==0);return '#';}
  if(B2==0){msdelay(1);while(B2==0);return '0';}
  if(B3==0){msdelay(1);while(B3==0);return '*';}
  
  A1=1;
  A2=0;
  A3=1;
  A4=1;
	
	msdelay(1);
  if(B1==0){msdelay(1);while(B1==0);return '3';}
  if(B2==0){msdelay(1);while(B2==0);return '2';}
  if(B3==0){msdelay(1);while(B3==0);return '1';}
  
  A1=1;
  A2=1;
  A3=0;
  A4=1;
	
	msdelay(1);
  if(B1==0){msdelay(1);while(B1==0);return '6';}
  if(B2==0){msdelay(1);while(B2==0);return '5';}
  if(B3==0){msdelay(1);while(B3==0);return '4';}
  
  A1=1;
  A2=1;
  A3=1;
  A4=0;
	
	msdelay(1);
  if(B1==0){msdelay(1);while(B1==0);return '9';}
  if(B2==0){msdelay(1);while(B2==0);return '8';}
  if(B3==0){msdelay(1);while(B3==0);return '7';}
  
  return 0;
}

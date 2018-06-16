#include <at89c5131.h>

#define display_port P0      //Data pins connected to port 2 on microcontroller
sbit rs = P2^5;  //RS pin connected to pin 2 of port 3
sbit rw = P2^6;  // RW pin connected to pin 3 of port 3
sbit e =  P2^7;  //E pin connected to pin 4 of port 3


void lcd_cmd(unsigned char command)  //Function to send command instruction to LCD
{
    display_port = command;
    rs= 0;
    rw=0;
    e=1;
    msdelay(1);
    e=0;
}

void lcd_data(unsigned char disp_data)
{
    display_port = disp_data;
    rs= 1;
    rw=0;
    e=1;
    msdelay(1);
    e=0;
}

 void initLCD()    
{
    lcd_cmd(0x38);
    msdelay(10);
    lcd_cmd(0x0F);
    msdelay(10);
    lcd_cmd(0x01);
    msdelay(10);
    lcd_cmd(0x81);
    msdelay(10);
		lcd_cmd(0x80);
		msdelay(10);
}

void clearLCD(){
	lcd_cmd(0x01);
}

void escreveLCD(unsigned char* mensagem)
{
	int k=0;
	//lcd_init();	
	//lcd_cmd(0x80);
	
	//clear
	if(mensagem[0]=='\r'){
		clearLCD();
		k=1;
	}

	//for caractere
	for(;mensagem[k]!='\0';k++){
		if (mensagem[k]=='\n')
			lcd_cmd(0xC0);
			//lcd_data(0xC0);
		else
			lcd_data(mensagem[k]);
	}
}
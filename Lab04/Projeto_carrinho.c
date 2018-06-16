#include <PWM.h>
#include <at89c5131.h>
#include <stdio.h>
#include <lcd.h>
#include <rtc.h>
#include <serial.h>

// NAO USAR P3.0 E P3.1

void escreveTime(Time* time);
	
// Main Function
void main(void)
{
	Time time;
	
	//init
	initLCD();
	initSerial();
	initRTC();
	
	//set time
	time.segundo = 2;
	time.minuto = 3;
	time.hora = 4;
	time.dia = 5;
	time.dia_semana = 6;
	time.mes = 7;
	time.ano = 18;
	
	setTimeRTC(&time);
	
	//mostrar time 
	while(1){
		escreveTime(&time);
		msdelay(2000);
		getTimeRTC(&time);
	}
}

void hex2str(unsigned char hex, char* str){
	sprintf(str,"%x",hex);
}

void escreveTime(Time* time){
	char str[3];
	
	clearLCD();
	
	//dia
	hex2str(time->dia,str);
	escreveLCD(str);
	escreveLCD(":");
	
	//minuto
	hex2str(time->minuto,str);
	escreveLCD(str);
	escreveLCD(":");
	
	//segundo
	hex2str(time->segundo,str);
	escreveLCD(str);
	escreveLCD("\n");
	
	//dia
	hex2str(time->dia,str);
	escreveLCD(str);
	escreveLCD(":");
	
	//mes
	hex2str(time->mes,str);
	escreveLCD(str);
	escreveLCD(":20");
	
	//ano
	hex2str(time->dia,str);
	escreveLCD(str);
	escreveLCD(" - ");
	
	//dia da semana
	hex2str(time->dia_semana,str);
	escreveLCD(str);
}










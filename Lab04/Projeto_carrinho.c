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
	char mensagem[10];
	
	//init
	initLCD();
	initSerial();
	initRTC();
	
	//set time
	time.segundo = 0x02;
	time.minuto = 0x03;
	time.hora = 0x04;
	time.dia = 0x05;
	time.dia_semana = 0x06;
	time.mes = 0x07;
	time.ano = 0x18;
	
	setTimeRTC(&time);
	
//mostrar time 
	while(1){
  getString(mensagem,10);
  sendString(mensagem);
  clearLCD();
  escreveLCD(mensagem);
 }
}

void hex2str(unsigned char hex, char* str){
 str[0] = hex/16+'0';
 str[1] = hex%16+'0';
 str[2] = '\0';
}

//monstradata no lcd
//hora:min:seg
//dia:mes:ano - dia_semana
void escreveTime(Time* time){
 char str[3];
 
 clearLCD();
 
 //hora
 hex2str(time->hora,str);
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
 escreveLCD(":");
 
 //ano
 hex2str(time->ano,str);
 escreveLCD(str);
 escreveLCD(" - ");
 
 //dia da semana
 hex2str(time->dia_semana,str);
 escreveLCD(str);
}
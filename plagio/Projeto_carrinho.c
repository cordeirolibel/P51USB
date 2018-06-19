//#include <PWM.h>
#include <at89c5131.h>
#include "rtc.h"
#include "serial.h"
#include "lcd.h"
#include "relogio.h"

sbit BUZZER = P1^4;//=================EDITAR ISSO
sbit LED = P1^4;

// NAO USAR P3.0 E P3.1

void telaRelogio(void);
void telaAlarme(void);
void verificaAlarme(void);

Time tm_atual;
Time tm_alarme;

// Main Function
void main(void)
{
	idata char key;
	idata int selectKey = 1;
	//init
	initLCD();
	initSerial();
	initRTC();
	
	while(1)
	{
		key = getCharLivre();
		
		if (key == 'k')
		{
			if (selectKey >= 5)
			{
				selectKey = 1;
			}
			else
			{
				selectKey += 1;
			}
		}
		
		if (selectKey == 1)
		{
			lcd_cmd(0x01);
			escreveLCD("Menu RTC");
			lcd_cmd(0xC0);
			escreveLCD("Relogio");
		}
		else if (selectKey == 2)
		{
			lcd_cmd(0x01);
			escreveLCD("Menu RTC");
			lcd_cmd(0xC0);
			escreveLCD("Fuso Moscow");
		}
		else if (selectKey == 3)
		{
			lcd_cmd(0x01);
			escreveLCD("Menu RTC");
			lcd_cmd(0xC0);
			escreveLCD("Cronometro");
		}
		else if (selectKey == 4)
		{
			lcd_cmd(0x01);
			escreveLCD("Menu RTC");
			lcd_cmd(0xC0);
			escreveLCD("Ano bissexto");
		}
		
	}
 }


//tela de relogio, sai com enter
void telaRelogio(void){
 int atual;
 int antigo = -1;
 char car;
 
 //sai com enter
 while(1){
  verificaAlarme();
  
  car = getCharLivre();
  //edicao
  if (car == 'e'){ 

   recebeTime(&tm_atual,1);
   setTimeRTC(&tm_atual);
  }
  //edicao alarme
  else if (car == 'c') 
   recebeTime(&tm_alarme,0);
  //ativa
  else if (car == 'a'){
   escreveLCD("\rAlarme \nAtivado");
   tm_alarme.estado = ON;
   msdelay(1000);
  }
  //desativa
  else if (car == 'd'){
   escreveLCD("\rAlarme \nDesativado");
   tm_alarme.estado = OFF;
   msdelay(1000);
  }
  else if (car == 'q')//saida
   return;
  
  getTimeRTC(&tm_atual);
  
  atual = tm_atual.segundo;
  //so mostra no LCD se mudou
  if (atual!=antigo){
   escreveTime(&tm_atual,"Atual");
   antigo = atual;
  }
 }
}

void verificaAlarme(void){
 int i;
 char car;
 int estadoLED = 1;
 
 //alarme ativado e deu o horario
 if ((tm_alarme.estado == ON) &&
   (isEqual(tm_alarme,tm_atual,0))){
   while(1){
    getTimeRTC(&tm_atual);
    escreveTime(&tm_atual,"Alarme!!");
     
    car = getCharLivre();
    
    //saida
    if (car == 'q'){
     //desativa tudo
     BUZZER = 1;
     LED = 1;
     return;
    }
    //soneca
    else if (car == 's'){
     //desativa tudo
     BUZZER = 1;
     LED = 1;
     //espera 15s
     for(i=0;i<30;i++){
      //mostra horario atual
      getTimeRTC(&tm_atual);
      escreveTime(&tm_atual,"Soneca");
      
      car = getCharLivre();
      if(car=='q'){
       //saida
       BUZZER = 1;
       LED = 1;
       return;
      }
      msdelay(50);
     }
    }
    
    //pica led/buzzer
    //liga o buzzer
    if(estadoLED==1){
     BUZZER = 0;
     LED = 0;
     estadoLED = 0;
     msdelay(130);
    }
    //desliga
    else{
     BUZZER = 1;
     LED = 1;
     estadoLED = 1;
     msdelay(130); 
    }
  }
 }
}

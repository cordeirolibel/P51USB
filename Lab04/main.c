//#include <PWM.h>
#include <at89c5131.h>
#include <lcd.h>
#include <relogio.h>

sbit BUZZER = P3^5;//=================EDITAR ISSO
sbit LED = P1^4;

// NAO USAR P3.0 E P3.1

void telaRelogio(void);
void telaAlarme(void);
void verificaAlarme(void);
void showMoscow(void);
void saiMoscow(void);

idata Time tm_atual;
idata Time tm_alarme;
idata Time tm_moscow;
idata Time tm_cron;
int moscow;

// Main Function
void main(void)
{
	BUZZER = 0;
	LED = 1;
	
	moscow = 0;
	
	//init
	initLCD();
	initSerial();
	initRTC();
	
	telaRelogio();
	
	clearLCD();
	escreveLCD("OFF");
}

//tela de relogio, sai com enter
void telaRelogio(void){
	int exitCron_flag = 0;
 int atual;
 int antigo = -1;
 char car;
	int fuso = 1;
 
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
	// Fuso horario Moscow
	else if(car == 'm')
	{
		if(!moscow){
			showMoscow();
			escreveLCD("\rMoscow \nAtivo");
			msdelay(1000);
			moscow = 1;
		}
		else{
			saiMoscow();
			escreveLCD("\rMoscow \nDesativo");
			msdelay(1000);
			moscow = 0;
		}
	}
	// Time mode 12AMPM / 24h 
	else if (car == 't')
	{
		if(tm_atual._24h == 0){
			escreveLCD("\rModo 24h");
		  msdelay(1000);
			tm_atual._24h = 1;
			if(tm_atual.pm){
				tm_atual.hora += 12;
				if (tm_atual.hora == 24)
						tm_atual.hora = 0;
			}
		}
		else{
			escreveLCD("\rModo 12h");
		  msdelay(1000);
			tm_atual._24h = 0;
			if (tm_atual.hora>12){
				tm_atual.hora -= 12;
				tm_atual.pm = 1;
			}
			else if(tm_atual.hora==0){
				tm_atual.hora = 12;
				tm_atual.pm = 0;
			}
			else
				tm_atual.pm = 0;
		}
	}
	// Cronometro
	else if (car == 'k')
	{
		getTimeRTC(&tm_atual);
		tm_cron.segundo = 0;
		tm_cron.minuto = 0;
		tm_cron.hora = 0;
		tm_cron.dia = tm_atual.dia;
		tm_cron.mes = tm_atual.mes;
		tm_cron.ano = tm_atual.ano;
		tm_cron.dia_semana = tm_atual.dia_semana;
		
		// Loop Cronometro
		while(1)
		{
			car = getCharLivre();
			verificaAlarme();
			escreveTime(&tm_cron, "Crono");
			
			if (car == 'q')
			{
				break;
			}
			else if(car == 'r')
			{
				tm_cron.segundo = 0;
				tm_cron.minuto = 0;
				tm_cron.hora = 0;
			}
			else if(car == 'p')
			{
				while(1)
				{
					verificaAlarme();
					car = getCharLivre();
					
					if (car == 'k')
					{
						break;
					}
					else if (car == 'r')
					{
						tm_cron.segundo = 0;
						tm_cron.minuto = 0;
						tm_cron.hora = 0;
						
						escreveTime(&tm_cron, "Crono");
					}
					else if (car == 'q')
					{
						exitCron_flag = 1;
						break;
					}
				}
			}
			
			if (exitCron_flag)
			{
				exitCron_flag = 0;
				break;
			}
			
			getTimeRTC(&tm_atual);
			atual = tm_atual.segundo;
			
			if (atual!= antigo)
			{
				tm_cron.segundo += 1;
				if (tm_cron.segundo >= 60)
				{
					tm_cron.segundo = 0;
					tm_cron.minuto += 1;
					if (tm_cron.minuto >= 60)
					{
						tm_cron.minuto = 0;
						tm_cron.hora += 1;
					}
				}
				
				antigo = atual;
			}
		}
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

void saiMoscow(void)
{
	tm_atual.hora = tm_atual.hora - 6;
	if ((tm_atual.hora <= 0))
	{
		if (tm_atual._24h == 0){
			tm_atual.hora = 12 + tm_atual.hora;			
		}
		else{
			tm_atual.hora %= 24;
		}
		
		tm_atual.dia -= 1;
		
		if (tm_atual.dia <= 0)
		{
			tm_atual.dia = 30;
			tm_atual.mes -= 1;
			if (tm_atual.mes <= 0)
			{
				tm_atual.mes = 12;
				tm_atual.ano -= 1;
			}
		}
	}
	
	setTimeRTC(&tm_atual);
}

void showMoscow(void)
{
	tm_atual.hora = tm_atual.hora + 6;
	if ((tm_atual.hora >= 13 && tm_atual._24h == 0) || (tm_atual.hora >= 24 && tm_atual._24h == 1))
	{
		if (tm_atual._24h == 0){
			tm_atual.hora %= 12;
			tm_atual.hora += 1;
		}
		else {tm_atual.hora %= 24;}
		
		tm_atual.dia += 1;
		
		if (tm_atual.dia > 30)
		{
			tm_atual.dia = 1;
			tm_atual.mes += 1;
			if (tm_atual.mes > 12)
			{
				tm_atual.mes = 1;
				tm_atual.ano += 1;
			}
		}
	}
	
	setTimeRTC(&tm_atual);
	
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
     BUZZER = 0;
     LED = 1;
     return;
    }
    //soneca
    else if (car == 's'){
     //desativa tudo
     BUZZER = 0;
     LED = 1;
     //espera 15s
     for(i=0;i<30;i++){
      //mostra horario atual
      getTimeRTC(&tm_atual);
      escreveTime(&tm_atual,"Soneca");
      
      car = getCharLivre();
      if(car=='q'){
       //saida
       BUZZER = 0;
       LED = 1;
       return;
      }
      msdelay(80);
     }
    }
    
    //pica led/buzzer
    //liga o buzzer
    if(estadoLED==1){
     BUZZER = 1;
     LED = 0;
     estadoLED = 0;
     msdelay(130);
    }
    //desliga
    else{
     BUZZER = 0;
     LED = 1;
     estadoLED = 1;
     msdelay(130); 
    }
  }
 }
}

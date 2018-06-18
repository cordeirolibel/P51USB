//#include <PWM.h>
#include <at89c5131.h>
#include <lcd.h>
#include <relogio.h>

sbit BUZZER = P2^5;//=================EDITAR ISSO
sbit LED = P2^5;

// NAO USAR P3.0 E P3.1

void telaRelogio(void);
void telaAlarme(void);

Time tm_atual;
Time tm_alarme;

// Main Function
void main(void)
{
	//init
	initLCD();
	initSerial();
	initRTC();
	
	relogio();
	
 }


//tela de relogio, sai com enter
void telaRelogio(void){
	int atual;
	int antigo = -1;
	char car;
	
	//sai com enter
	while(1){
		car = getCharLivre();
		if (car == 'e') //edicao
			recebeTime(&tm_atual,1);
		else if (car == '\n')//saida
			return;
			
		atual = tm_atual.segundo;
		//so mostra no LCD se mudou
		if (atual!=antigo){
			escreveTime(&tm_atual,"Atual");
			antigo = atual;
		}
	}
	
}

void telaAlarme(void){
	char car;
	
	while(1){
		
		escreveTime(&tm_alarme,"Alarme");
		
		car = getCharLivre();
		if (car == 'e') //edicao
			recebeTime(&tm_alarme,0);
		else if (car == '\n')//saida
			return;
		else if (car == 'a'){
			escreveLCD("\rAlarme \nAtivado");
			tm_alarme.estado = ON;
			msdelay(1000);
		}
		else if (car == 'd'){
			escreveLCD("\rAlarme \nDesativado");
			tm_alarme.estado = OFF;
			msdelay(1000);
		}
	}
}

void verificaAlarme(){
	//alarme ativado e deu o horario
	if ((tm_alarme.estado == ON) &&
			(isEqual(tm_alarme,tm_atual,0))){
			escreveLCD("\rAlarme!!\n");
				
			car = getCharLivre();
			
			//verifica carectere
				
			//pica led
				
				
			
				
	}
			
}

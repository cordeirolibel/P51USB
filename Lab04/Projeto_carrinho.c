//#include <PWM.h>
#include <at89c5131.h>
#include <lcd.h>
#include <relogio.h>

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
	//init
	initLCD();
	initSerial();
	initRTC();
	
	
	telaRelogio();
	telaAlarme();
	telaRelogio();
	
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
		if (car == 'e') //edicao
			recebeTime(&tm_atual,1);
		else if (car == '\n')//saida
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

void telaAlarme(void){
	char car;
	
	while(1){
		verificaAlarme();
		
		escreveTime(&tm_alarme,"Alarme");
		
		car = getCharLivre();
		
		//edicao
		if (car == 'e') 
			recebeTime(&tm_alarme,0);
		//saida
		else if (car == '\n')
			return;
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
	}
}

void verificaAlarme(void){
	int i;
	char car;
	
	escreveLCD("\rAlarme!!\n");
	
	//alarme ativado e deu o horario
	if ((tm_alarme.estado == ON) &&
			(isEqual(tm_alarme,tm_atual,0))){
				
			getTimeRTC(&tm_atual);
			escreveTime(&tm_atual,"Alarme!!");
				
			car = getCharLivre();
			
			//saida
			if (car == '\n'){
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
				for(i=0;i<150;i++){
					//mostra horario atual
					getTimeRTC(&tm_atual);
					escreveTime(&tm_atual,"Soneca");
					
					car = getCharLivre();
					if(car=='s'||car=='\n')
						break;
					msdelay(100);
				}
				
			}
			
			//pica led/buzzer
			//liga o buzzer
			BUZZER = 0;
			LED = 0;
			msdelay(500);
			//liga
			BUZZER = 1;
			LED = 1;
			msdelay(500);	
	}
			
}

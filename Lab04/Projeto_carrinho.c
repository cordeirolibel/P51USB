//#include <PWM.h>
#include <at89c5131.h>
#include <lcd.h>
#include <relogio.h>

// NAO USAR P3.0 E P3.1

void relogio(void);

Time tm_atual;

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
void relogio(){
	int atual;
	int antigo = -1;
	char car;
	
	//sai com enter
	while(1){
		car = getCharLivre();
		if (car == 'e') //edicao
			recebeTime(&tm_atual,1);
		//else if (car == '\n')//saida
			//return;
			
		atual = tm_atual.segundo;
		//so mostra no LCD se mudou
		if (atual!=antigo){
			escreveTime(&tm_atual);
			antigo = atual;
		}
	}
	
}



//#include <PWM.h>
#include <at89c5131.h>
#include <relogio.h>
// NAO USAR P3.0 E P3.1

Time tm_atual;

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
		else if (car == '\n')//saida
			return;
			
		atual = tm_atual.segundo;
		//so mostra no LCD se mudou
		if (atual!=antigo){
			escreveTime(&tm_atual);
			antigo = atual;
		}
	}
	
}



#include <stdio.h>
#include <at89c5131.h>
#include <lcd.h>
#include <rtc.h>
#include <serial.h>

void hex2str(unsigned char hex, char* str){
	str[0] = hex/16+'0';
	str[1] = hex%16+'0';
	str[2] = '\0';
}

int str2int(char *str){
    int i;
    int saida = 0;
    for (i=0;str[i]!='\0';i++){
        saida *= 10;
        saida += str[0]-'0';
    }
    return saida;
}

//funcao auxiliar de recebeTime
int __recebe1argumeto(char *str){
	char mensagem[5];
	
	clearLCD();
	escreveLCD("Escolha de data\n");
	escreveLCD(str);
	escreveLCD(": ");
	sendString(str);
	sendString(": ");
	
	getString(mensagem,5);
	escreveLCD(mensagem);
	
	return str2int(mensagem);
}

//recebe uma data do usuario
void recebeTime(Time* time, int completo){
	int dado;
	
	sendString("Escolha de data\n");
	
	dado = __recebe1argumeto("Hora");
	time->hora = dado;
	
	dado = __recebe1argumeto("Minuto");
	time->minuto = dado;
	
	dado = __recebe1argumeto("segundo");
	time->segundo = dado;
	
	if (!completo)
		return;
		
	dado = __recebe1argumeto("Dia");
	time->dia = dado;
	
	dado = __recebe1argumeto("Mes");
	time->mes = dado;
	
	dado = __recebe1argumeto("Ano");
	time->ano = dado;
	
	dado = __recebe1argumeto("Dia semana");
	time->dia_semana = dado;
	
	dado = __recebe1argumeto("(0-12h/1-24h)");
	time->_24h = dado;
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

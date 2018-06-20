#include <stdio.h>
#include <at89c5131.h>
#include <rtc.h>
#include <serial.h>

char hex2dec(char hex);

void hex2str(unsigned char hex, char* str){
	str[0] = hex/16+'0';
	str[1] = hex%16+'0';
	str[2] = '\0';
	//str[0] = hex/10 + 0x30;
	//str[1] = hex%10 + 0x30;
}

unsigned char str2hex(char *str){
    int i;
    unsigned char saida = 0;
    for (i=0;str[i]!='\0';i++){
        saida  = saida<<4;
        saida += str[i]-'0';
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
	
	return str2hex(mensagem);
}

//recebe uma data do usuario
void recebeTime(Time* time, int completo){
	int dado;
	int ano;
	int bissexto = 0;
	int mes_int = 0;
	idata char dias_meses[12] = { 0x31, 0x29, 0x31, 0x30, 0x31, 0x30, 0x31, 0x31, 0x30, 0x31, 0x30, 0x31 };
	
	sendString("Escolha de data\n");
	
	dado = __recebe1argumeto("(0-12h/1-24h)");
	time->_24h = dado;
	
	if (time->_24h == 0)
	{
		dado = __recebe1argumeto("(0-AM/1-PM)");
		time->pm = dado;
		
		dado = __recebe1argumeto("Hora");
		
		if (dado >= 0x12)
		{
			time->hora = 0x12;
		}
		else
		{
			time->hora = dado;
		}
	}
	else
	{
		dado = __recebe1argumeto("Hora");
		
		if (dado >= 0x23)
		{
			time->hora = 0x23;
		}
		else
		{
			time->hora = dado;
		}
	}
	
	
	dado = __recebe1argumeto("Minuto");
	if (dado >= 0x59)
	{
		time->minuto = 0x59;
	}
	else
	{
		time->minuto = dado;
	}
	
	dado = __recebe1argumeto("segundo");
	
	if (dado >= 0x59)
	{
		time->segundo = 0x59;
	}
	else
	{
		time->segundo = dado;
	}
	
	if (!completo)
		return;
		
	dado = __recebe1argumeto("Ano");
	time->ano = dado;
	ano = hex2dec(dado)+2000;
	
	if ( ( ano % 4 == 0 && ano % 100 != 0 ) || ano % 400 == 0 )
	{
		bissexto = 1;
	}
	
	
	dado = __recebe1argumeto("Mes");
	if (dado >= 0x12)
	{
		time->mes = 0x12;
	}
	else
	{
		time->mes = dado;
	}
	
	dado = __recebe1argumeto("Dia");
	mes_int = hex2dec(time->mes);
	if (time->mes == 0x02)
	{
		if (bissexto)
		{
			if(dado >= 0x29){time->dia = 0x29;}
			else{time->dia = dado;}
		}
		else
		{
			if (dado >= 0x28){time->dia = 0x28;}
			else{time->dia = dado;}
		}
	}
	else
	{
		if(dado >= dias_meses[mes_int]){time->dia = dias_meses[mes_int];}
		else{time->dia = dado;}
	}
	
	
	dado = __recebe1argumeto("Dia semana");
	if (dado >= 0x01 && dado <= 0x07)
	{
		time->dia_semana = dado;
	}
	else
	{
		time->dia_semana = 0x07;
	}

}


//monstradata no lcd
//len(nome)<=7
//
//hora:min:seg nome
//dia:mes:ano - dia_semana
void escreveTime(Time* time, char* nome){
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
	
	escreveLCD(" ");
	escreveLCD(nome);
	escreveLCD("\n");

	//dia
	hex2str(time->dia,str);
	escreveLCD(str);
	escreveLCD("/");

	//mes
	hex2str(time->mes,str);
	escreveLCD(str);
	escreveLCD("/");

	//ano
	hex2str(time->ano,str);
	escreveLCD(str);
	escreveLCD(" - ");

	//dia da semana
	hex2str(time->dia_semana,str);
	escreveLCD(str);
}

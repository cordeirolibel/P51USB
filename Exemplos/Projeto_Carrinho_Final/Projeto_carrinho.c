#include <PWM.h>
#include <at89c5131.h>
#include <lcd.h>

sbit motor1_Pin1 = P2^2;		   // Pin P2.0 is named as PWM1_Pin
sbit motor1_Pin2 = P2^3;
sbit motor2_Pin1 = P2^1;		   // Pin P2.0 is named as PWM1_Pin
sbit motor2_Pin2 = P2^4;
// Pinos dos motores

void horarioMotor1(void);
void horarioMotor2(void);
void motorFrente(void);
void motorAtras(void);
void anti_HorarioMotor1(void);
void anti_HorarioMotor2(void);
void esquerdaFrente(void);
void direitaFrente(void);
void esquerdaAtras(void);
void direitaAtras(void);
void aceleraMotores(void);
void reduzMotores(void);
void rotacionaEsquerda(void);
void rotacionaDireita(void);
void paraMotor1(void);
void paraMotor2(void);
void putchar(char c);
char getchar (void);
void init_serial(void);
void escreveArray(unsigned char mensagem[15], unsigned char t);
void escreveVelocidade(unsigned char c);
unsigned char abc[15] = "VELOCIDADE:";    //string of 14 characters with a null terminator.
unsigned char mensagem[15];
unsigned char d;
unsigned char j;
unsigned char z;
void ESC_DADO_NUMERO_COMPLETO(unsigned char numero);

bit motor1 = 0;
bit motor2 = 0;

// Main Function
void main(void)
{
	
	//lcd_cmd(0x80); //cima comeca no 0
	
	//lcd_cmd(0xc0); //baixo cpmeca no 0

	init_serial();

   InitPWM();              // Start PWM
 	//cct_init();   	       // Make all ports zero
	
   PWM1 = 0;              // Make 50% duty cycle of PWM
   PWM2 = 0;              // Make 50% duty cycle of PWM
	

  while(1){
	d = getchar();
	if(d == '%'){
		d = getchar();
		if(d == '#'){
			d = getchar();
		
			if(j != d){
				j = d;
				if(d == 'w'){
					motorFrente();
					escreveArray("FRENTE", d);
					
				}
				else if(d == 's'){
					motorAtras();
					escreveArray("TRAS", d);
				}
				else if(d == 'q'){
					esquerdaFrente();
					escreveArray("FRENTE-ESQUERDA", d);
				}
				else if(d == 'e'){
					direitaFrente();
					escreveArray("FRENTE-DIREITA", d);
				}
				else if(d == 'z'){
					esquerdaAtras();
					escreveArray("TRAS-ESQUERDA", d);
				}
				else if(d == 'c'){
					direitaAtras();
					escreveArray("TRAS-DIREITA", d);
				}
				else if(d == 'g'){
					aceleraMotores();
					escreveArray("ACELERANDO", d);
				}
				else if(d == 'h'){
					reduzMotores();
					escreveArray("REDUZINDO", d);
				}
				else if(d == 'a'){
					rotacionaEsquerda();
					escreveArray("ROTACIONA-HORA", d);
				}
				else if(d == 'd'){
					rotacionaDireita();
					escreveArray("ROTACIONA-ANTI", d);
				}
				else if(d == 'p'){
					paraMotor1();
					paraMotor2();
					escreveArray("PARA!!!", d);
				}
				j = '*';
			}
		}
	}
	

	}
}

void init_serial(void){
	RCAP2H = 0xF6;
	RCAP2L = 0x3C;
	TR2 = 1; // Inicia o timer
	TCLK  = 0;
	RCLK  = 1;				// RCLK = 1 e TCLK= 0 para recepção
	SCON 	= 0x50; 		//modo 1, ren =1 (reciver enable bit(ativa a serial)
	PCON 	= 0x00;			//80= Dobra a relação serial
	RI 		= 0;
	TI 		= 0;
}

char getchar(void){
	char d;
	while(!RI){}
	d = SBUF;
	RI = 0;
	return d;
}



void horarioMotor1(void)
{
	 motor1_Pin1 = 0;	
	 motor1_Pin2 = 1;		

}
void horarioMotor2(void)
{
	  motor2_Pin1 = 0;	
	  motor2_Pin2 = 1;				
}

void anti_HorarioMotor1(void)
{
	  motor1_Pin1 = 1;	
	  motor1_Pin2 = 0;			
}
void anti_HorarioMotor2(void)
{
	  motor2_Pin1 = 1;	
	  motor2_Pin2 = 0;			
}

void esquerdaFrente(void)
{
	
	PWM1=0;
	PWM2=0;
	horarioMotor1();	
	horarioMotor2();
	msdelay(10);	
	PWM1 = 100;
	PWM2 =180;
	
	
}
void direitaFrente(void)
{
	
	PWM2=0;
	PWM2=0;
	horarioMotor1();	
	horarioMotor2();	
	msdelay(10);
	PWM1=180;
	PWM2=100;
}
void esquerdaAtras(void)
{
	PWM1=0;
	PWM2=0;
	anti_HorarioMotor1();	
	anti_HorarioMotor2();	
	msdelay(10);
	PWM1= 100;
	PWM2= 180;
}
void direitaAtras(void)
{
	PWM1=0;
	PWM2=0;
	anti_HorarioMotor1();	
	anti_HorarioMotor2();
	msdelay(10);
	PWM1 =180;
	PWM2= 100;
}

void paraMotor1(void)
{

	 PWM1=180;
	 motor1_Pin1 = 1;	
	 motor1_Pin2 = 1;		
   msdelay(10); 
	 PWM1=0;
	
}
void paraMotor2(void)
{
	 PWM2=180;
	 motor2_Pin1 = 1;	
	 motor2_Pin2 = 1;		  
   msdelay(10); 
	 PWM2=0;
}



void motorFrente(void)
{
	PWM1= 0;
	PWM2= 0;
	
	horarioMotor1();
	horarioMotor2();
	msdelay(10);
	
	PWM1= 180;
	PWM2= 180;

	
}
void motorAtras(void)
	
{
	PWM1= 0;
	PWM2= 0;
	
	anti_HorarioMotor1();
	anti_HorarioMotor2();
	msdelay(10);	
	PWM1= 180;
	PWM2= 180;
	
}

void aceleraMotores(void)
{
	acelera1();
	acelera2();

}
void reduzMotores(void)
{

			reduz1();
			reduz2();
}

void rotacionaEsquerda(void)
{
	reduz1();
	acelera2();
}
void rotacionaDireita(void)
{
	
	acelera1();
	reduz2();
}


void escreveArray(unsigned char mensagem[15], unsigned char t)
{
	unsigned char k;
	lcd_init();	
	lcd_cmd(0x80);
	k = 0;
	while(mensagem[k] != '\0') // searching the null terminator in the sentence
	{
		lcd_data(mensagem[k]);
		k++;
	}
	escreveVelocidade(t);
}

void escreveVelocidade(unsigned char c)
{
	
	unsigned char k;
	unsigned char w;
	unsigned char aux = 100;
	unsigned char temp;
	unsigned char numero;
	
	if(c == 'w' || c =='s' ||c == 'g' || c =='h' )
	{
		numero = PWM1;
	}	

	else if(c == 'a' || c == 'q' || c == 'z')	
	{
		numero = PWM2-PWM1;
	}
		
	else if(c == 'e' || c == 'd' || c == 'c')	
	{
		numero = PWM1-PWM2;
	}

	else if(c == 'p')	
	{
		numero = 0;
	}
	
	lcd_cmd(0xc0);

	for(w = 0; w < 11; w++) // searching the null terminator in the sentence
	{
		lcd_data(abc[w]);
	}

	temp = numero % aux;
	
	numero /= aux;

	lcd_data(numero+48);
		
	aux = 10;
	
	numero = temp;
	temp = numero % aux;
		
	numero /= aux;
	lcd_data(numero+48);
	
	numero = temp;
	lcd_data(numero+48);
	
}






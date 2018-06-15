#include <at89c5131.h>

// PWM1_Pin
sbit PWM1_Pin = P1^6;		   // Pin P2.0 is named as PWM1_Pin
sbit PWM2_Pin = P1^7;

// Function declarations
void cct_init(void);
void InitTimer0();
void InitTimer1();
void InitPWM();
void msdelay(unsigned int time);


// Global variables
unsigned char PWM1 = 0;	  // It can have a value from 0 (0% duty cycle) to 255 (100% duty cycle)
unsigned char PWM2 = 0;	  // It can have a value from 0 (0% duty cycle) to 255 (100% duty cycle)
unsigned int temp1;    // Used inside Timer0 ISR
unsigned int temp2 ;    // Used inside Timer1 ISR


// PWM frequency selector
/* PWM_Freq_Num can have values in between 1 to 257	only
 * When PWM_Freq_Num is equal to 1, then it means highest PWM frequency
 * which is approximately 1000000/(1*255) = 3.9kHz
 * When PWM_Freq_Num is equal to 257, then it means lowest PWM frequency
 * which is approximately 1000000/(257*255) = 15Hz
 *
 * So, in general you can calculate PWM frequency by using the formula
 *     PWM Frequency = 1000000/(PWM_Freq_Num*255)
 */
#define PWM_Freq_Num1   1	 // Highest possible PWM Frequency
#define PWM_Freq_Num2   1	


// Timer0 initialize
void InitTimer0(void)
{
	TMOD &= 0x00;    // Clear 8bit field for timer1
	TMOD |= 0x11;    // Set timer1 and timer 0 in mode 1 = 16bit mode
	
	TH0 = 0x00;      // First time value
	TL0 = 0x00;      // Set arbitrarily zero
	
	ET0 = 1;         // Enable Timer0 interrupts
	EA  = 1;         // Global interrupt enable
	
	TR0 = 1;         // Start Timer 0
}

void InitTimer1(void)
{
	TH1 = 0x00;      // First time value
	TL1 = 0x00;      // Set arbitrarily zero
	
	ET1 = 1;         // Enable Timer0 interrupts
	
	TR1 = 1;         // Start Timer 0
}

// PWM initialize
void InitPWM()
{
	PWM1 = 0;         // Initialize with 0% duty cycle
	PWM2 = 0;
	InitTimer0();    // Initialize timer0 to start generating interrupts
	InitTimer1();				 // PWM generation code is written inside the Timer0 ISR
}

// Timer0 ISR
void Timer0_ISR (void) interrupt 1   
{
	TR0 = 0;    // Stop Timer 0
			if(PWM1_Pin)	// if PWM1_Pin is high
			{
				PWM1_Pin = 0;
				temp1 = (255-PWM1)*PWM_Freq_Num1;
				TH0  = 0xFF - (temp1>>8)&0xFF;
				TL0  = 0xFF - temp1&0xFF;	
			}
			else	     // if PWM1_Pin is low
			{
				PWM1_Pin = 1;
				temp1 = PWM1*PWM_Freq_Num1;
				TH0  = 0xFF - (temp1>>8)&0xFF;
				TL0  = 0xFF - temp1&0xFF;
			}
	
	TF0 = 0;     // Clear the interrupt flag
	TR0 = 1;     // Start Timer 0
}

void Timer1_ISR (void) interrupt 3  
{
	TR1 = 0;    // Stop Timer 0

	
			if(PWM2_Pin)	// if PWM1_Pin is high
			{
				PWM2_Pin = 0;
				temp2 = (255-PWM2)*PWM_Freq_Num2;
				TH1  = 0xFF - (temp2>>8)&0xFF;
				TL1  = 0xFF - temp2&0xFF;	
			}
			else	     // if PWM1_Pin is low
			{
				PWM2_Pin = 1;
				temp2 = PWM2*PWM_Freq_Num2;
				TH1  = 0xFF - (temp2 >> 8) & 0xFF;
				TL1  = 0xFF - temp2 & 0xFF;
			}
		

	TF1 = 0;     // Clear the interrupt flag
	TR1 = 1;     // Start Timer 0
}

void msdelay(unsigned int time)  // Function for creating delay in milliseconds.
{
    unsigned i,j ;
    for(i=0;i<time;i++)    
    for(j=0;j<1275;j++);
}


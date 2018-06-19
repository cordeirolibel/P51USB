#include <at89c5131.h>
int PWM;
int count_ms;
int count_clk;
char data_save;


sbit LED3 = P1^4; // LED3 = 1.4 , LED2 = 3.7




void msdelay(unsigned int time)  // Function for creating delay in milliseconds.
{
    unsigned i,j ;
    for(i=0;i<time;i++)    
    for(j=0;j<1275;j++);
}

void msdelayint(unsigned int time)  // Function for creating delay in milliseconds.
{
    count_clk = 0;
		count_ms = time;
		while(count_ms);
}

// Timer0 initialize
void InitTimer0(void)
{
	TMOD &= 0x00;    // Clear 8bit field for timer1
	TMOD |= 0x11;    // Set timer1 and timer 0 in mode 1 = 16bit mode
	
	TH0 = 0xFF;      // First time value
	TL0 = 0x9B;      // Set arbitrarily zero
	
	ET0 = 1;         // Enable Timer0 interrupts
	//EA  = 1;         // Global interrupt enable
	
	TR0 = 1;         // Start Timer 0
}

// Timer0 ISR
void Timer0_ISR (void) interrupt 1   
{
	TR0 = 0;    // Stop Timer 0
	
	PWM += 1;
	count_clk += 1;
	
	if (PWM > 255)
	{
		PWM = 0;
	}
	
	if (PWM > data_save)
	{
		LED3 = 1;
	}
	else
	{
		LED3 = 0;
	}
	
	if (count_clk > 20)
	{
		count_clk = 0;
		if (count_ms>0)
			count_ms -= 1;
	}
	
	TH0 = 0xFF;      // First time value
	TL0 = 0x9B;      // Set arbitrarily zero
	
	TF0 = 0;     // Clear the interrupt flag
	TR0 = 1;     // Start Timer 0
}
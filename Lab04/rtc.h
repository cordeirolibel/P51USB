
#include <at89c5131.h>
#define ON 1
#define OFF 0

#define C_Ds1307ReadMode_U8   0xD1u  // DS1307 ID in read mode
#define C_Ds1307WriteMode_U8  0xD0u  // DS1307 ID in write mode

#define C_Ds1307SecondRegAddress_U8   0x00u   // Address to access Ds1307 SEC register
#define C_Ds1307DateRegAddress_U8     0x04u   // Address to access Ds1307 DATE register
#define C_Ds1307ControlRegAddress_U8  0x07u   // Address to access Ds1307 CONTROL register

sbit SCL_PIN = P4^0;		   // Pin P2.0 is named as PWM1_Pin
sbit SDA_PIN = P4^1;

void i2c_Clock(void);
void i2c_Ack(void);
void i2c_NoAck(void);
void I2C_Init(void);
void I2C_Start(void);
void I2C_Stop(void);
void I2C_Write(unsigned char);
unsigned char I2C_Read(unsigned char);


typedef struct
{ 
	unsigned char ano; //para 2018: ano = 18;
	unsigned char mes;
	unsigned char dia_semana;
	unsigned char dia;
	unsigned char hora;
	unsigned char minuto;
	unsigned char segundo; //sempre iniciar com numero par
	int _24h;
	int estado; //para alarme
	int pm;
} Time; 

int isEqual(Time t1, Time t2, int completo){
	
		if (t1.segundo != t2.segundo)
			return 0;
		else if (t1.minuto != t2.minuto)
			return 0;
		else if (t1.hora != t2.hora)
			return 0;
		else if (t1._24h == 0)
		{
			if (t1.pm != t2.pm)
			{
				return 0;
			}
		}
		else if(t1._24h != t2._24h)
			return 0;
		
		if (!completo)
			return 1;
		
		else if (t1.dia != t2.dia)
			return 0;
		else if (t1.dia_semana != t2.dia_semana)
			return 0;
		else if (t1.mes != t2.mes)
			return 0;
		else if (t1.ano != t2.ano)
			return 0;
		
		return 1;
}


void initRTC(void)
{
    I2C_Init();                             // Initialize the I2c module.
    I2C_Start();                            // Start I2C communication

    I2C_Write(C_Ds1307WriteMode_U8);        // Connect to DS1307 by sending its ID on I2c Bus
    I2C_Write(C_Ds1307ControlRegAddress_U8);// Select the Ds1307 ControlRegister to configure Ds1307

    I2C_Write(0x00);                        // Write 0x00 to Control register to disable SQW-Out

    I2C_Stop();                             // Stop I2C communication after initializing DS1307
}

void I2C_Init(void){
 //1.2 - Configurar o I2C (TWI)
 SCL_PIN  = 1;
 SDA_PIN  = 1;// Coloca os latches em high-Z
}

void setTimeRTC(Time* time)
{
		char write;
    I2C_Start();                          // Start I2C communication
 
    I2C_Write(C_Ds1307WriteMode_U8);      // connect to DS1307 by sending its ID on I2c Bus
    I2C_Write(C_Ds1307SecondRegAddress_U8); // Request sec RAM address at 00H
 
    I2C_Write(time->segundo);                    // Write sec from RAM address 00H
    I2C_Write(time->minuto);                    // Write min from RAM address 01H
		if(!time->_24h){//12
			write = time->hora|0x40;
			if(time->pm) // pm
				write = write|0x20;			
			I2C_Write(write);
		}
		else//24
			I2C_Write(time->hora);                    // Write hour from RAM address 02H
    I2C_Write(time->dia_semana);                // Write weekDay on RAM address 03H
    I2C_Write(time->dia);                    // Write date on RAM address 04H
    I2C_Write(time->mes);                    // Write month on RAM address 05H
    I2C_Write(time->ano);                    // Write year on RAM address 06h
 
    I2C_Stop();                              // Stop I2C communication after Setting the Date
}

/***************************************************************************************************
                     void RTC_GetDateTime(rtc_t *rtc)
****************************************************************************************************
 * I/P Arguments: rtc_t *: Pointer to structure of type rtc_t. Structure contains hour,min,sec,day,date,month and year 
 * Return value    : none
 * description  :This function is used to get the Date(d,m,y) from Ds1307 RTC.
    Note: The date and time read from Ds1307 will be of BCD format, 
          like 0x12,0x39,0x26 for 12hr,39min and 26sec.    
               0x15,0x08,0x47 for 15th day,8th month and 47th year.              
***************************************************************************************************/

void getTimeRTC(Time *time)
{
    I2C_Start();                            // Start I2C communication

    I2C_Write(C_Ds1307WriteMode_U8);        // connect to DS1307 by sending its ID on I2c Bus
    I2C_Write(C_Ds1307SecondRegAddress_U8); // Request Sec RAM address at 00H

    I2C_Stop();                                // Stop I2C communication after selecting Sec Register

    I2C_Start();                            // Start I2C communication
    I2C_Write(C_Ds1307ReadMode_U8);            // connect to DS1307(Read mode) by sending its ID

    time->segundo	= I2C_Read(1);                // read second and return Positive ACK
    time->minuto = I2C_Read(1);                 // read minute and return Positive ACK
    time->hora = I2C_Read(1);
	
		if((time->hora)&0x40)//12h
		{
			if((time->hora)&0x20)//pm
			{
				time->hora = time->hora&0x1F;
				time->pm = 1;
			}
			else {
				time->hora = time->hora&0x1F;
				time->pm = 0;
			}
			time->_24h = 0;
		}
		else //24h
		{
			time->hora = time->hora&0x3F;
			time->_24h = 1;
		}
    time->dia_semana = I2C_Read(1);           // read weekDay and return Positive ACK
    time->dia = I2C_Read(1);              // read Date and return Positive ACK
    time->mes =I2C_Read(1);            // read Month and return Positive ACK
    time->ano =I2C_Read(0);             // read Year and return Negative/No ACK

    I2C_Stop();                              // Stop I2C communication after reading the Date
}

/***************************************************************************************************
                         void I2C_Start(void)
****************************************************************************************************
 * I/P Arguments: none.
 * Return value  : none
 * description  :This function is used to generate I2C Start Condition.
                 Start Condition: SDA goes low when SCL is High.
                               ____________
                SCL:          |            |
                      ________|            |______
                           _________
                SDA:      |         |
                      ____|         |____________
***************************************************************************************************/

// Function for creating delay in microseconds.
// he uma aproximacao
void DELAY_us(unsigned int time)  
{
    unsigned int i;
    for(i=0;i<time*10;i++);
}

void I2C_Start(void)
{
    SCL_PIN = 0;        // Pull SCL low
    SDA_PIN = 1;        // Pull SDA High
    DELAY_us(1);
    SCL_PIN = 1;        //Pull SCL high
    DELAY_us(1);
    SDA_PIN = 0;        //Now Pull SDA LOW, to generate the Start Condition
    DELAY_us(1);
    SCL_PIN = 0;        //Finally Clear the SCL to complete the cycle
}





/***************************************************************************************************
                         void I2C_Stop(void)
****************************************************************************************************
 * I/P Arguments: none.
 * Return value  : none
 * description  :This function is used to generate I2C Stop Condition.
                 Stop Condition: SDA goes High when SCL is High.
                               ____________
                SCL:          |            |
                      ________|            |______
                                 _________________
                SDA:            |
                      __________|
***************************************************************************************************/

void I2C_Stop(void)
{
    SCL_PIN = 0;            // Pull SCL low
    DELAY_us(1);
    SDA_PIN = 0;            // Pull SDA  low
    DELAY_us(1);
    SCL_PIN = 1;            // Pull SCL High
    DELAY_us(1);
    SDA_PIN = 1;            // Now Pull SDA High, to generate the Stop Condition
}


/***************************************************************************************************
                         void I2C_Write(uint8_t v_i2cData_u8)
****************************************************************************************************
 * I/P Arguments: uint8_t-->8bit data to be sent.
 * Return value  : none
 * description  :This function is used to send a byte on SDA line using I2C protocol
                 8bit data is sent bit-by-bit on each clock cycle.
                 MSB(bit) is sent first and LSB(bit) is sent at last.
                 Data is sent when SCL is low.
         ___     ___     ___     ___     ___     ___     ___     ___     ___     ___
 SCL:   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |
      __|   |___|   |___|   |___|   |___|   |___|   |___|   |___|   |___|   |___|   |___
 SDA:    D8       D7     D6      D5      D4       D3      D2      D1      D0     ACK
***************************************************************************************************/
void I2C_Write(unsigned char v_i2cData_u8)
{
    unsigned char i;

    for(i=0;i<8;i++)                   // loop 8 times to send 1-byte of data
    {
        SDA_PIN = v_i2cData_u8 & 0x80;     // Send Bit by Bit on SDA line
        i2c_Clock();                   // Generate Clock at SCL
        v_i2cData_u8 = v_i2cData_u8<<1;// Bring the next bit to be transmitted to MSB position
    }
                             
    i2c_Clock();
}

/***************************************************************************************************
                         uint8_t I2C_Read(uint8_t v_ackOption_u8)
****************************************************************************************************
 * I/P Arguments: none.
 * Return value  : uint8_t(received byte)
 * description :This fun is used to receive a byte on SDA line using I2C protocol.
               8bit data is received bit-by-bit each clock and finally packed into Byte.
               MSB(bit) is received first and LSB(bit) is received at last.
         ___     ___     ___     ___     ___     ___     ___     ___     ___     ___
SCL:    |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |
      __|   |___|   |___|   |___|   |___|   |___|   |___|   |___|   |___|   |___|   |__
 SDA:    D8       D7     D6      D5       D4     D3       D2      D1     D0      ACK
***************************************************************************************************/
unsigned char I2C_Read(unsigned char v_ackOption_u8)
{
    unsigned char i, v_i2cData_u8=0x00;

    SDA_PIN =1;               //Make SDA as I/P
    for(i=0;i<8;i++)     // loop 8times read 1-byte of data
    {
        DELAY_us(1);
        SCL_PIN = 1;         // Pull SCL High
        DELAY_us(1);

        v_i2cData_u8 = v_i2cData_u8<<1;    //v_i2cData_u8 is Shifted each time and
        v_i2cData_u8 = v_i2cData_u8 | SDA_PIN; //ORed with the received bit to pack into byte

        SCL_PIN = 0;         // Clear SCL to complete the Clock
    }
    if(v_ackOption_u8==1)  /*Send the Ack/NoAck depending on the user option*/
    {
        i2c_Ack();
    }
    else
    {
        i2c_NoAck();
    }

    return v_i2cData_u8;           // Finally return the received Byte*
}






/***************************************************************************************************
                                Local functions
***************************************************************************************************/
                                

/***************************************************************************************************
                         static void i2c_Clock()
****************************************************************************************************
 * I/P Arguments: none.
 * Return value  : none
 * description  :This function is used to generate a clock pulse on SCL line.
***************************************************************************************************/
static void i2c_Clock(void)
{
    DELAY_us(1);
    SCL_PIN = 1;            // Wait for Some time and Pull the SCL line High
    DELAY_us(1);        // Wait for Some time
    SCL_PIN = 0;            // Pull back the SCL line low to Generate a clock pulse
}





/***************************************************************************************************
                         static void i2c_Ack()
****************************************************************************************************
 * I/P Arguments: none.
 * Return value  : none
 * description  :This function is used to generate a the Positive ACK
                 pulse on SDA after receiving a byte.
***************************************************************************************************/
static void i2c_Ack(void)
{
    SDA_PIN = 0;        //Pull SDA low to indicate Positive ACK
    i2c_Clock();    //Generate the Clock
    SDA_PIN = 1;        // Pull SDA back to High(IDLE state)
}





/***************************************************************************************************
                        static void i2c_NoAck()
****************************************************************************************************
 * I/P Arguments: none.
 * Return value  : none
 * description  :This function is used to generate a the Negative/NO ACK
                 pulse on SDA after receiving all bytes.
***************************************************************************************************/
static void i2c_NoAck(void)
{
    SDA_PIN = 1;         //Pull SDA high to indicate Negative/NO ACK
    i2c_Clock();     // Generate the Clock  
    SCL_PIN = 1;         // Set SCL 
}
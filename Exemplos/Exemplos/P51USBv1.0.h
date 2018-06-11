
/*******************************************************************************
* Arquivo P51USBv1.0.h
* 
* Versão 1.0
* 
* Macros úteis para utilização da placa P51USB v1.0
* 
* Mikhail A. Koslowski
*******************************************************************************/

// Desmarque o flag"Define 8051 SFR names" na aba A51 das opções.
#include <at89c5131.h>

/******
* SFR        *
******/
// apenas aqueles que não estão definidos no at89c5131.h com o nome padrão
#define IE IEN1

/******
* LCD        *
******/
#define LCD_RS                P2.5
#define LCD_RW                P2.6
#define LCD_E                        P2.7
#define LCD_DADO        P0
#define LCD_BUSY        P0.7 // bit mais alto do dado pode ser lido como busy flag.

/*******
* LEDs *
*******/
// Driver interno de corrente. deve ser configurado via LEDCON
#define LED1        P3.6
#define LED2        P3.7
// Transistor externo
#define LED3        P1.4

/*********
* Botoes *
*********/
#define SW1        P3.2
// Deve ser colocado na posição correta do JP5.
#define SW2        P3.4

/************
* I2C e RTC        *
************/
#define I2C_SDA P4.1
#define I2C_SCL P4.0
// Deve ser colocado na posição correta do JP5.
#define RTC_SQW        P3.4

/************
* SPI e ADC        *
************/
#define SPI_SS                P1.1
#define SPI_MISO        P1.5
#define SPI_SCK                P1.6
#define SPI_MOSI        P1.7

/**********
* Jumpers *
***********

J_VCC - Alimenta a placa com o 5V da USB

J_USB - Habilita a interface de dados da USB

JP1 - Habilita LED1
JP2 - Habilita LED2
JP3 - Habilita LED3

LCD - Barra do LCD.

14                         1   
 o o o o o o o o o o o o o o x x 
 |             | | | | | | | Backlight
 |             | | | | | | |_ GND
 |             | | | | | |___ VCC
 |             | | | | |_____ VREF
 |             | | | |_______ RS
 |             | | |_________ RW
 |             | |___________ E
 |_ LCD_DADO __|
 

J_SW2/SQE - Escolhe entre saída SQW do RTC e SW2 no P3.4
         
         |o| -> SW2
         |o| -> P3.4
         |o| -> RTC-SQW
         
J_ADC - Escolhe o que vai em cada entrada do ADC
        
        VBAT <-        |o o| -> LCD_VREF
        CH0  <-        |o o| -> CH1
        GND  <-        |o-o| -> GND
        
*/
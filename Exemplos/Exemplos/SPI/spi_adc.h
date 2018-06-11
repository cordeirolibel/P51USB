// SPI_ADC

//===============================================================================
// Definições de cada bit do byte de config do ADC
//===============================================================================
// Bit3 = start bit
#define START	0x08
// Bit2 = single/diff
#define SINGLE	0x04
// Bit1 = Signal
#define CH1p	0x02

//===============================================================================
// Conversões
//===============================================================================
// Single
//===============================================================================
#define CVT_CH0 (START | SINGLE)
#define CVT_CH1 (START | SINGLE | CH1p)
//===============================================================================
// Diferencial
#define CVT_DF1 (START | CH1p)
#define CVT_DF0 (START)
//===============================================================================


#define DUMMY 0xAA // dummy, para quando precisa enviar qualquer coisa.

#define SPIF 0x80 // posição de alguns bits dos registradores da SPI
#define SPEN 0x40 //

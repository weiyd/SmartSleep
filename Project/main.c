#include <msp430.h>
#include "include/ADC_INIT.h"
#include "include/TIMER_INIT.h"
#include "include/OA_INIT.h"
#include "include/Delay.h"
int main(void)
{
	WDTCTL = WDTPW | WDTHOLD;                 // Stop WDT
	ADC_INIT();
	//TIMER_INIT();
	OA_INIT();                          // P6.0 ADC option select
	P5DIR |= 0x02;
	while (1)
	{
		ADC12CTL0 |= ADC12SC;                   // Start sampling/conversion
		__bis_SR_register(GIE);
		delay_ms(1);
	}
}
unsigned int result[512];
int pos=0;
#pragma vector = ADC12_VECTOR
__interrupt void ADC12_ISR(void)
{
	//if (ADC12MEM0 >= 0xcff)                   // If ADC12MEM = A0 > 0.5AVcc
	//    P5OUT |= 0x02;                          // Set P5.1
	//  else
	//    P5OUT &= ~0x02;                         // Otherwise reset P5.1
	//
	//  __bic_SR_register_on_exit(LPM0_bits);     // Exit LPM0
	result[pos]=ADC12MEM0;
	if(result[pos]>0xaff)
		 P5OUT |= 0x02;
	else
		P5OUT &= ~0x02;
	pos++;
	if(pos==512)
		pos=0;
	//__bic_SR_register_on_exit(LPM0_bits);
}
int i=0;
#pragma vector=TIMERA0_VECTOR
__interrupt void Timer_A (void)
{
	if(i==10)
	{
		ADC12CTL0 &= ~ADC12SC;
		P5OUT |= 0x02;
		i=0;
	}
	i++;
}



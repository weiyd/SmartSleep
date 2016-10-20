#include <msp430.h>

int main(void)
{
	  WDTCTL = WDTPW +WDTHOLD;
	  P5DIR |= 0x02;

	  TACCTL0 = CCIE;
	  TACCR0 = 50000;//计数器中断阈值
	  TACTL = TASSEL_2 + MC_1 + ID_0 ;//采用SMCLK不分频

	  __bis_SR_register(LPM0_bits + GIE);
}
int i = 0;


#pragma vector=TIMERA0_VECTOR
__interrupt void Timer_A (void)
{
	i++;
	if(i==20)
	{
		P5OUT ^= 0x02;
		i=0;
	}
}
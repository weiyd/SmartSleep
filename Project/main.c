#include <msp430.h>
#include "include/ADC_INIT.h"
#include "include/TIMER_INIT.h"
#include "include/OA_INIT.h"
#include "include/Delay.h"
#include "include/CA_INIT.h"
int main(void)
{
	WDTCTL = WDTPW | WDTHOLD;
	//ADC_INIT();
	//TIMER_INIT();
	//OA_INIT();
	CA_INIT();
	P5DIR |= 0x02;
	while (1)
	{
		//ADC12CTL0 |= ADC12SC;                   	// 开始采样
		__bis_SR_register(GIE);						// 使能全局中断
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
//比较器的中断函数
#pragma vector=COMPARATORA_VECTOR
__interrupt void Comp_A_ISR (void)
{
  CACTL1 ^= CAIES;                          // 改变比较器的中断触发方式 上升沿下降沿轮转
  P5OUT ^= 0x02;                            // 外部LED 输入电压高与0.55v点亮,反之,熄灭
}




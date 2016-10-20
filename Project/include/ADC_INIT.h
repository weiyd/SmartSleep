#ifndef ADC_INIT_H
#define ADC_INIT_H

#include <msp430.h>
void ADC_INIT()
{	
	ADC12CTL0 &= ~ENC; 				// 配置ADC前需要 禁用ADC

	ADC12CTL0 = SHT0_2 | ADC12ON;  	// Sampling time, ADC12 on
	ADC12CTL1 = SHP;              	// Use sampling timer
	ADC12IE = 0x01;            		// Enable interrupt
	ADC12MCTL0 |= 1;				//P6.0��ΪADC12�Ĳ���ͨ��
	P6SEL |= 0x01;					//P6.0��ΪADC12�Ĳ���ͨ��

	ADC12CTL0 |= ENC;				//����ADC
}
#endif

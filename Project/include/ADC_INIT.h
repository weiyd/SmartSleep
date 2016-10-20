#ifndef ADC_INIT_H
#define ADC_INIT_H

#include <msp430.h>
void ADC_INIT()
{	
	ADC12CTL0 &= ~ENC; 				// 禁用ADC12 开始配置ADC END控制着采样保持源

	ADC12CTL0 = SHT0_2 | ADC12ON;  	// Sampling time, ADC12 on
	ADC12CTL1 = SHP;              	// Use sampling timer
	ADC12IE = 0x01;            		// Enable interrupt
	ADC12MCTL0 |= 1;				//P6.0作为ADC12的采样通道
	P6SEL |= 0x01;					//P6.0作为ADC12的采样通道

	ADC12CTL0 |= ENC;				//启动ADC
}
#endif

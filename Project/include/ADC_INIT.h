/*
 * ADC_INIT.h
 *
 *  Created on: 201年10月18日
 *      Author: AD
 */

#ifndef ADC_INIT_H
#define ADC_INIT_H

#include <msp430.h>
void ADC_INIT()
{	
	ADC12CTL0 &= ~ENC; 				// 配置ADC前需要 禁用ADC

	ADC12CTL0 |= SHT0_2 | ADC12ON;  // 采样保持时间8个ADC时钟, ADC12 on
	ADC12CTL1 |= SHP;              	// 使用采样定时器
	ADC12IE |= 0x01;            	// 采样中断使能
	//P6SEL |= 0x02;					// P6.1 A1GPIO复用
	ADC12MCTL0|= INCH_3;			// 采样A1通道

	ADC12CTL0 |= ENC;				// 启动ADC
}
#endif/* ADC_INIT.h_H */

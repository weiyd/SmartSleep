/*
 * TIMER_INIT.h
 *
 *  Created on: 2016年10月18日
 *      Author: AD
 */


#ifndef TIMER_INIT_H
#define TIMER_INIT_H

#include <msp430.h>
void TIMER_INIT()
{	
	 TACCR0 = 50000;					// 计数器中断阈值
	 TACTL = TASSEL_2 + MC_1 + ID_0 ;	// 采用SMCLK不分频
}
#endif

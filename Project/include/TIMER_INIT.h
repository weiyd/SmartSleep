/*
 * TIMER_INIT.h
 *
 *  Created on: 2016��10��18��
 *      Author: AD
 */


#ifndef TIMER_INIT_H
#define TIMER_INIT_H

#include <msp430.h>
void TIMER_INIT()
{	
	 TACCR0 = 50000;					// �������ж���ֵ
	 TACTL = TASSEL_2 + MC_1 + ID_0 ;	// ����SMCLK����Ƶ
}
#endif

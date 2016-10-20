/*
 * OA.h
 *
 *  Created on: 2016年10月18日
 *      Author: AD
 */

#ifndef OA_H_
#define OA_H_

#include<msp430.h>
void OA_INIT()
{
	 OA0CTL0 = OAPM_3 ;    			// 快速运放模式
	 OA0CTL1 = OAFC_4 + OAFBR_1;   	// 正相比例放大 反馈为1/4
     OA1CTL0 |= OAPM_3 ;
     OA1CTL1 |= OAFC_4 + OAFBR_7;
	 OA2CTL0 |= OAPM_3;
	 OA2CTL1 |= OAFC_4 + OAFBR_7;
	 P6SEL |= 0x01;					//6.0 OA0I0
	 P6SEL |= 0x02;					//6.1 OA0O
	 P6SEL |= 0x08;					//6.3 OA1O
	 P6SEL |= 0x10;					//6.4 OA1I0
	 P6SEL |= 0x20;					//6.5 OA2O
	 P6SEL |= 0x40;					//6.6 OA2I0
}
#endif /* OA_H_ */

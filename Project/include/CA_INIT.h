/*
 * CA_INIT.h
 *
 *  Created on: 201年10月20日
 *      Author: AD
 */

#ifndef CA_INIT_H_
#define CA_INIT_H_


void CA_INIT()
{
	CACTL1 |= CAON+CAREF_3+CARSEL;	// 开启CA比较器,开启0.55v参考电压,参考电压输入运放的反向输入端
	CACTL2 |= P2CA0;				// 正相输入选择A0外部端口P1.6

	P2SEL |= 0x40;					// 复用P1.6GPIO
	CAPD  |= 0x40;					// 禁用P1.6的缓冲器,防止产生寄生电流
	CACTL1 |= CAIE;					// 对比较器的中断进行使能
}


#endif /* CA_INIT_H_ */

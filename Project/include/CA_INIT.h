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
	CACTL1 = CAON+CAREF_3+CARSEL;
	CACTL2 = P2CA0;

	P2SEL |= 0x040;
	CAPD |= 0x40;
	CACTL1 |= CAIE;
}


#endif /* CA_INIT_H_ */

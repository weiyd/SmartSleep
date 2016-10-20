/*
 * Delay.h
 *
 *  Created on: 2016Äê10ÔÂ19ÈÕ
 *      Author: AD
 */

#ifndef DELAY_H_
#define DELAY_H_

#define CPU_F ((double)8000000)
#define delay_us(x) _delay_cycles(CPU_F*(double)x/1000000.0)
#define delay_ms(x) _delay_cycles(CPU_F*(double)x/1000.0)


#endif /* DELAY_H_ */

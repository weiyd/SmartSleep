//******************************************************************************
//  MSP430FG4618 Experimenter's Board Real Time Clock in Low-power mode
//
//           MSP430FG4618
//         ---------------
//     /|\|            XIN|-
//      | |               | 32kHz
//      --|RST        XOUT|-
//        |               |
//
//
//  Built with IAR Embedded Workbench Version: 3.42A
//******************************************************************************
#include "msp430xG46x.h"

void LCD_CHECK(void);
void LCD_1_8(void);
unsigned int offset = 5;                  // LCD memory offset variable
int count=0;


unsigned char lcd_segL[]={
  0x53,
  0x03,
  0x71,
  0x73,
  0x23,
  0x72,
  0x72,
  0x13,
  0x73,
  0x73,
};
unsigned char lcd_segH[]={
  0x03,
  0x00,
  0x02,
  0x00,
  0x01,
  0x01,
  0x03,
  0x00,
  0x03,
  0x01,
};
void delay();
void main(void)
{
    // Stop watchdog timer to prevent time out reset
    WDTCTL = WDTPW + WDTHOLD;//WDTPW相当于执行后面命令的密码 WDTHOLD 看门狗使能
    FLL_CTL0 |= XCAP14PF;//配置晶振负载电容
    LCDACTL = LCDON + LCD3MUX + LCDFREQ_128;  // LCDON  3MUX  LCD时钟是晶振/128
    LCDAPCTL0 = 0x7E;                         // Segments 4-27
    P5SEL |= (BIT3 | BIT2 );//com2 com3口
    P5DIR |= (BIT3 | BIT2 );//com2 com3输出
    LCDAPCTL1 = 0;
    LCDAVCTL0 = LCDCPEN;//启动电荷泵
    LCDAVCTL1 = VLCD_2_60;
    LCD_CHECK();
    while(1)
    {
    	//LCDMEM[9]|=0x10+0x20;
    	LCD_1_8();
    }

}

void LCD_CHECK()
{
    int j,i;
    const unsigned int delay = 30000;         // SW delay for LCD stepping
    for( j = 0; j < 6; j ++)
    {
      LCDMEM[j+offset] = 0;                   // Clear LCD
    }

    for( j = 0; j < 6; j ++)
    {
      LCDMEM[j+offset] = 0xFF;                // All segments on
      for (i = delay; i>0; i--);              // Delay
    }

    for (i = delay; i>0; i--);                // Delay

    for( j = 0; j < 6; j ++)
    {
      LCDMEM[j+offset] = 0;                   // Clear LCD
    }
}
void delay()
{
	int i;
	for(i=10000;i>0;--i);
}
void LCD_1_8()
{
    int j;//循环控制变量
    unsigned char t1,t2,t3,t4;//LCD每一位的数字
    const unsigned int delay = 30000;//延迟时间
    unsigned int temp;

    if(count>10000)
      count = 0;//数字超过四位数自动归零

    for( j = 0; j < 6; j ++)// Clear LCD
    {
        LCDMEM[j+offset] = 0x00;
    }

    t4 = count%10000/1000;          //求千位数
    t3 = count%1000/100;            //求百位数
    t2 = count%100/10;              //求十位数
    t1 = count%10;                  //求个位数

    //千位
    {
        temp = lcd_segH[t4];  // 找t4对应的高8位
        temp = temp<< 8;      // 左移8位
        temp |= lcd_segL[t4]; // 加上t4对应的低8位
        temp = temp<< 4;      // 向左移动4位
        LCDMEM[4+offset] |= temp;
        LCDMEM[4+1+offset] =temp>>8;
    }
    //百位
    {

        LCDMEM[3+offset] = lcd_segL[t3];
        LCDMEM[4+offset] |=lcd_segH[t3];
    }
  //十位
    {
        temp = lcd_segH[t2];
        temp = temp<< 8;
        temp |= lcd_segL[t2];
        temp = temp<< 4;
        LCDMEM[1+offset] |= temp;
        LCDMEM[1+1+offset] =temp>>8;
    }
    //个位
    {

        LCDMEM[offset] = lcd_segL[t1];
        LCDMEM[1+offset] |=lcd_segH[t1];
    }
    for (j = delay; j>0; j--);
    count++;
}

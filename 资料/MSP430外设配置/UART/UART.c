//  //* An external watch crystal is required on XIN XOUT for ACLK *//
//
//                MSP430xG461x
//            -----------------
//        /|\|              XIN|-
//         | |                 | 32kHz
//         --|RST          XOUT|-
//           |                 |
//           |             P4.0|----------->
//           |                 | 2400 - 8N1
//           |             P4.1|<-----------
//
//
//  K. Quiring/ M. Mitchell
//  Texas Instruments Inc.
//  October 2006
//  Built with CCE Version: 3.2.0 and IAR Embedded Workbench Version: 3.41A
//******************************************************************************

#include <msp430.h>

int main(void)
{
	  volatile unsigned int i;

	  WDTCTL = WDTPW + WDTHOLD;                 
	  FLL_CTL0 |= XCAP14PF;                     

	  do
	  {
	  IFG1 &= ~OFIFG;                           
	  for (i = 0x47FF; i > 0; i--);          
	  }
	  while ((IFG1 & OFIFG));                   

	  P4SEL |= 0x03;                            
	  ME2 |= UTXE1 + URXE1;                    
	  U1CTL |= CHAR;                            
	  U1TCTL |= SSEL1;                          
	  U1BR0 = 0x0D;                            
	  U1BR1 = 0x00;                             
	  U1MCTL = 0x6B;                           
	  TXBUF1=0x30;
	  U1CTL &= ~SWRST;                          
	  IE2 |= URXIE1;                           

	// Mainloop
	  int count=0;
	  for (;;)
	  {
		  __bis_SR_register(GIE);      
		  while (!(IFG2 & UTXIFG1));                
		  TXBUF1=count;
		  count++;
	  }
}

#pragma vector=USART1RX_VECTOR
__interrupt void USART1_rx (void)
{
	unsigned char temp = RXBUF1;
}


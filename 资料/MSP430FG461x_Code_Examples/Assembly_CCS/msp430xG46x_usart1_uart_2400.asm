; --COPYRIGHT--,BSD_EX
;  Copyright (c) 2012, Texas Instruments Incorporated
;  All rights reserved.
; 
;  Redistribution and use in source and binary forms, with or without
;  modification, are permitted provided that the following conditions
;  are met:
; 
;  *  Redistributions of source code must retain the above copyright
;     notice, this list of conditions and the following disclaimer.
; 
;  *  Redistributions in binary form must reproduce the above copyright
;     notice, this list of conditions and the following disclaimer in the
;     documentation and/or other materials provided with the distribution.
; 
;  *  Neither the name of Texas Instruments Incorporated nor the names of
;     its contributors may be used to endorse or promote products derived
;     from this software without specific prior written permission.
; 
;  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
;  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
;  THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
;  PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
;  CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
;  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
;  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
;  OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
;  WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
;  OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
;  EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
; 
; ******************************************************************************
;  
;                        MSP430 CODE EXAMPLE DISCLAIMER
; 
;  MSP430 code examples are self-contained low-level programs that typically
;  demonstrate a single peripheral function or device feature in a highly
;  concise manner. For this the code may rely on the device's power-on default
;  register values and settings such as the clock configuration and care must
;  be taken when combining code from several examples to avoid potential side
;  effects. Also see www.ti.com/grace for a GUI- and www.ti.com/msp430ware
;  for an API functional library-approach to peripheral configuration.
; 
; --/COPYRIGHT--
;******************************************************************************
;  MSP430xG46x Demo - USART1, Ultra-Low Pwr UART 2400 Echo ISR, 32kHz ACLK
;
;  Description: Echo a received character, RX ISR used. In the Mainloop USART1
;  is made ready to receive one character with interrupt active. The Mainloop
;  waits in LPM3. The USART1 ISR forces the Mainloop to exit LPM3 after
;  receiving one character which echo's back the received character.
;  ACLK = UCLK1 = LFXT1 = 32768, MCLK = SMCLK = DCO~ 1048k
;  Baud rate divider with 32768kHz XTAL @2400 = 32768Hz/2400 = 13.65 (000Dh)
;  //* An external watch crystal is required on XIN XOUT for ACLK *//	
;
;                MSP430xG461x
;            -----------------
;        /|\|              XIN|-
;         | |                 | 32kHz
;         --|RST          XOUT|-
;           |                 |
;           |             P4.0|----------->
;           |                 | 2400 - 8N1
;           |             P4.1|<-----------
;
;
;  JL Bile
;  Texas Instruments Inc.
;  June 2008
;  Built Code Composer Essentials: v3 FET
;*******************************************************************************
 .cdecls C,LIST, "msp430.h"
;-------------------------------------------------------------------------------
			.text	;Program Start
;-------------------------------------------------------------------------------
RESET       mov.w   #900,SP         ; Initialize stackpointer
StopWDT     mov.w   #WDTPW+WDTHOLD,&WDTCTL  ; Stop WDT
SetupFLL    bis.b   #XCAP14PF,&FLL_CTL0     ; Configure load caps

OFIFGcheck  bic.b   #OFIFG,&IFG1            ; Clear OFIFG
            mov.w   #047FFh,R15             ; Wait for OFIFG to set again if
OFIFGwait   dec.w   R15                     ; not stable yet
            jnz     OFIFGwait
            bit.b   #OFIFG,&IFG1            ; Has it set again?
            jnz     OFIFGcheck              ; If so, wait some more

SetupP3     bis.b   #003h,&P4SEL            ; P4.0,1 = USART1 TXD/RXD
SetupUART0  bis.b   #UTXE1+URXE1,&ME2       ; Enable USART1 TXD/RXD
            bis.b   #CHAR,&U1CTL            ; 8-bit characters
            mov.b   #SSEL0,&U1TCTL          ; UCLK = ACLK
            mov.b   #00Dh,&U1BR0            ; 32k/2400 - 13.65
            mov.b   #000h,&U1BR1            ; 32k 2400
            mov.b   #06Bh,&U1MCTL           ; 32k 2400 modulation
            bic.b   #SWRST,&U1CTL           ; **Initialize USART state machine**
            bis.b   #URXIE1,&IE2            ; Enable USART1 RX interrupt
                                            ;
Mainloop    bis.b   #LPM3+GIE,SR            ; Enter LPM3, enable interrupts
            jmp     Mainloop                ; Do nothing
                                            ;
;------------------------------------------------------------------------------
USART1RX_ISR;  Echo back RXed character, confirm TX buffer is ready first
;------------------------------------------------------------------------------
TX0         bit.b   #UTXIFG1,&IFG2          ; USART1 TX buffer ready?
            jz      TX0                     ; Jump if TX buffer not ready
            mov.b   &U1RXBUF,&U1TXBUF       ; TX -> RXed character
            reti                            ;
                                            ;
;------------------------------------------------------------------------------
;			Interrupt Vectors
;------------------------------------------------------------------------------
            .sect    ".int19"
            .short   USART1RX_ISR
            .sect	".reset"            	
            .short   RESET
            .end
 

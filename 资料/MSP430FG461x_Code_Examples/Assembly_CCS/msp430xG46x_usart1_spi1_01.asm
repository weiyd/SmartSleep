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
;   MSP430xG46x Demo - USART1, SPI Interface to TLC549 8-Bit ADC
;
;   Description:  This program demonstrates USART1 in SPI mode, interfaced to a
;   TLC549 8-bit ADC. If AIN > 0.5(REF+ - REF-), then P5.1 is set, otherwise it
;   is reset.  R15 = 8-bit ADC code.
;   ACLK = 32.768kHz, MCLK = SMCLK = default DCO ~ 1048k, UCLK1 = SMCLK/2
;   //* VCC must be at least 3V for TLC549 *//
;
;                           MSP430FG461x
;                       -----------------
;                   /|\|              XIN|-
;        TLC549      | |                 |
;    -------------   --|RST          XOUT|-
;   |           CS|<---|P4.6             |
;   |      DATAOUT|--->|P4.4/SOMI1       |
; ~>| IN+  I/O CLK|<---|P4.5/UCLK1       |
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
StopWDT     mov.w   #WDTPW+WDTHOLD,&WDTCTL  ; Stop watchdog timer
SetupFLL    bis.b   #XCAP14PF,&FLL_CTL0     ; Configure load caps

OFIFGcheck  bic.b   #OFIFG,&IFG1            ; Clear OFIFG
            mov.w   #047FFh,R15             ; Wait for OFIFG to set again if
OFIFGwait   dec.w   R15                     ; not stable yet
            jnz     OFIFGwait
            bit.b   #OFIFG,&IFG1            ; Has it set again?
            jnz     OFIFGcheck              ; If so, wait some more

SetupP1     bis.b   #02h,&P5DIR             ; P5.1 as output
SetupP5     bis.b   #30h,&P4SEL             ; P4.2,3 SPI option select
            bis.b   #60h,&P4DIR             ; P4.3,0 as outputs
SetupSPI1   bis.b   #USPIE1,&ME2            ; Enable USART1 SPI
            bis.b   #CKPH+SSEL1+SSEL0+STC,&U1TCTL ; SMCLK, 3-pin mode
            bis.b   #CHAR+SYNC+MM,&U1CTL    ; 8-bit SPI master
            mov.b   #02h,&U1BR0             ; SMCLK/2 for baud rate
            clr.b   &U1BR1                  ; SMCLK/2 for baud rate
            clr.b   &U1MCTL                 ; Clear modulation
            bic.b   #SWRST,&U1CTL           ; Initialize USART state machine
                                            ;
Mainloop    bic.b   #40h,&P4OUT             ; Enable TLC549 by enabling /CS
            mov.b   #00h,&U1TXBUF           ; Dummy write to start SPI
L1          bit.b   #URXIFG1,&IFG2          ; RXBUF ready?
            jnc     L1                      ; wait until ready
            mov.b   &U1RXBUF,R15            ; R15 = 00|DATA
            bis.b   #40h,&P4OUT             ; Disable '549 by driving /CS high
            bic.b   #02h,&P5OUT             ; P5.1 = 0
            cmp.b   #07Fh,R15               ; Is AIN > 0.5(REF+ - REF-)?
            jlo     Mainloop                ; Again
            bis.b   #02h,&P5OUT             ; P5.1 = 1
            jmp     Mainloop                ; Again
                                            ;
;------------------------------------------------------------------------------
;			Interrupt Vectors
;------------------------------------------------------------------------------
            .sect	".reset"            	
            .short   RESET
            .end
            

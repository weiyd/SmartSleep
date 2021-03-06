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
;   MSP430xG46x Demo - Timer_A, Toggle P1.0,P1.2 & P2.0 Cont. Mode ISR, 32kHz ACLK
;
;   Description: Use Timer_A CCRx units and overflow to generate four
;   independent timing intervals. For demonstration, TACCR0, TACCR1 and TACCR2
;   output units are optionally selected with port pins P1.0, P1.2 and P2.0
;   in toggle mode. As such, these pins will toggle when respective CCRx
;   registers match the TAR counter. Interrupts are also enabled with all
;   CCRx units, software loads offset to next interval only - as long as
;   the interval offset is added to CCRx, toggle rate is generated in
;   hardware. Timer_A overflow ISR is used to toggle P5.1 with software.
;   Proper use of the TAIV interrupt vector generator is demonstrated.
;   ACLK = TACLK = 32kHz, MCLK = SMCLK = default DCO ~1048kHz
;   //* An external watch crystal on XIN XOUT is required for ACLK *//	
;
;   As coded and with TACLK = 32768Hz, toggle rates are:
;   P1.0 = TACCR0     = 32768/(2*4)     = 4096 Hz
;   P1.2 = TACCR1     = 32768/(2*16)    = 1024 Hz
;   P2.0 = TACCR2     = 32768/(2*100)   = 163.84 Hz
;   P5.1 = overflow = 32768/(2*65536)   = 0.25 Hz
;
;                MSP430xG461x
;             -----------------
;         /|\|              XIN|-
;          | |                 | 32kHz
;          --|RST          XOUT|-
;            |                 |
;            |         P1.0/TA0|--> TACCR0
;            |         P1.2/TA1|--> TACCR1
;            |         P2.0/TA2|--> TACCR2
;            |             P5.1|--> Overflow/software
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


SetupP1     bis.b   #005h,&P1SEL            ; P1.0,P1.2 - TA0,TA1 options
            bis.b   #005h,&P1DIR            ; P1.0,P1.2 outputs

SetupP2     bis.b   #001h,&P2DIR            ; P2.0 output
            bis.b   #001h,&P2SEL            ; P2.0 - TA2 options


SetupP5     bis.b   #002h,&P5DIR            ; P5.1 output


SetupC0     mov.w   #OUTMOD_4 +CCIE,&TACCTL0  ; TACCR0 toggle, interrupt enabled
SetupC1     mov.w   #OUTMOD_4 +CCIE,&TACCTL1  ; TACCR1 toggle, interrupt enabled
SetupC2     mov.w   #OUTMOD_4 +CCIE,&TACCTL2  ; TACCR2 toggle, interrupt enabled
SetupTA     mov.w   #TASSEL_1+MC_2+TAIE,&TACTL ; ACLK, contmode, interrupt
                                        			
Mainloop    bis.w   #LPM3+GIE,SR            ; Enter LPM3, interrupts enabled
            nop                             ; Required for debug
                                            ;
;------------------------------------------------------------------------------
TA0_ISR;
;------------------------------------------------------------------------------
            add.w   #4,&TACCR0              ; Offset until next interrupt
            reti                            ;		
                                            ;
;------------------------------------------------------------------------------
TAX_ISR;    Common ISR for TACCR1-4 and overflow
;------------------------------------------------------------------------------
            add.w   &TAIV,PC                ; Add Timer_A offset vector
            reti                            ; TACCR0 - no source
            jmp     TACCR1_ISR              ; TACCR1
            jmp     TACCR2_ISR              ; TACCR1
            reti                            ; CCR3
            reti                            ; CCR4
TA_over     xor.b   #002h,&P5OUT            ; Toggle P5.1
            reti                            ; Return from overflow ISR		
                                            ;
TACCR1_ISR  add.w   #16,&TACCR1             ; Offset until next interrupt
            reti                            ; Return ISR		
                                            ;
TACCR2_ISR  add.w   #100,&TACCR2            ; Offset until next interrupt
            reti                            ; Return ISR		
                                            ;
;------------------------------------------------------------------------------
;			Interrupt Vectors
;-----------------------------------------------------------------------------
            .sect	".reset"            	; MSP430 RESET Vector
            .short   RESET
            .sect	".int22"    		    ; Timer_A0 Vector
            .short   TA0_ISR                ;
            .sect	".int21"	        	; Timer_AX Vector
            .short   TAX_ISR                 ;
            .end

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
;*******************************************************************************
;   MSP430xG41x Demo - USCI_B0 I2C Slave RX multiple bytes from MSP430 Master
;
;   Description: This demo connects two MSP430's via the I2C bus. The master
;   transmits to the slave. This is the slave code. The interrupt driven
;   data receiption is demonstrated using the USCI_B0 RX interrupt.
;
;     ***to be used with "msp430xG46x_uscib0_i2c_08.asm" ***
;
;                                 /|\  /|\
;                MSP430xG461x     10k  10k   MSP430xG461x
;                    slave         |    |        master
;              -----------------   |    |  -----------------
;            -|XIN  P3.1/UCB0SDA|<-|---+->|P3.1/UCB0SDA  XIN|-
;       32kHz |                 |  |      |                 | 32kHz
;            -|XOUT             |  |      |             XOUT|-
;             |     P3.2/UCB0SCL|<-+----->|P3.2/UCB0SCL     |
;             |                 |         |                 |
;
;  JL Bile
;  Texas Instruments Inc.
;  June 2008
;  Built Code Composer Essentials: v3 FET
;*******************************************************************************
 .cdecls C,LIST, "msp430.h"
;-------------------------------------------------------------------------------
RxData      .usect ".bss",128                     ; Allocate 128 byte of RAM
;-------------------------------------------------------------------------------
			.text	;Program Start
;-------------------------------------------------------------------------------
RESET       mov.w   #900,SP         ; Initialize stackpointer
StopWDT     mov.w   #WDTPW+WDTHOLD,&WDTCTL  ; Stop WDT
SetupP3     bis.b   #06h,&P3SEL             ; Assign I2C pins to USCI_B0
SetupUCB0   bis.b   #UCSWRST,&UCB0CTL1      ; Enable SW reset
            mov.b   #UCMODE_3+UCSYNC,&UCB0CTL0
                                            ; I2C Slave, synchronous mode
            mov.w   #048h,&UCB0I2COA        ; Own Address is 048h
            bic.b   #UCSWRST,&UCB0CTL1      ; Clear SW reset, resume operation
            bis.b   #UCSTPIE+UCSTTIE,&UCB0I2CIE
                                            ; Enable STT and STP interrupt
            bis.b   #UCB0RXIE,&IE2          ; Enable RX interrupt

Main        mov.w  #RxData,R5              ; Start of RX buffer
            clr.w   R6                      ; Clear RX byte count
            bis.b   #LPM0+GIE,SR            ; Enter LPM0, enable interrupts
                                            ; Remain in LPM0 until master
                                            ; finishes TX
            nop                             ; Set breakpoint >>here<< and
                                            ; read out the RxData buffer
            jmp     Main                    ; Repeat
;-------------------------------------------------------------------------------
; The USCI_B0 data ISR is used to move received data from the I2C master
; to the MSP430 memory.
;-------------------------------------------------------------------------------
USCIAB0TX_ISR;      USCI_B0 Data ISR
;-------------------------------------------------------------------------------
            mov.b   &UCB0RXBUF,0(R5)        ; Move RX data to address R5
            inc.w   R5                      ; Increment address pointer
            inc.w   R6                      ; Increment RX byte count
            reti
;-------------------------------------------------------------------------------
; The USCI_B0 state ISR is used to wake up the CPU from LPM0 in order to
; process the received data in the main program. LPM0 is only exit in case
; of a (re-)start or stop condition when actual data was received.
;-------------------------------------------------------------------------------
USCIAB0RX_ISR;      USCI_B0 State ISR
;-------------------------------------------------------------------------------
            bic.b   #UCSTPIFG+UCSTTIFG,&UCB0STAT
                                            ; Clear interrupt flags
            tst.w   R6                      ; Check RX byte counter
            jz      USCIAB0RX_ISR_1         ; Jump if nothing was received
            bic.w   #LPM0,0(SP)             ; Clear LPM0

USCIAB0RX_ISR_1
            reti
;-------------------------------------------------------------------------------
;			Interrupt Vectors
;-------------------------------------------------------------------------------
            .sect     ".int24"        ; USCI_B0 I2C Data Int Vector
            .short  USCIAB0TX_ISR
            .sect   ".int25"        ; USCI_B0 I2C Sate Int Vector
            .short  USCIAB0RX_ISR
            .sect   ".reset"            ; POR, ext. Reset, Watchdog
            .short  RESET
            .end


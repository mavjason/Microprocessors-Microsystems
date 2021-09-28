/*
 * AVRAssembler2.asm
 *
 *  Created: 8/11/2017 12:32:24 ??
 *   Author: theovaka
 */ 

 .include "m16def.inc"
 .def leds = r20
 .def reg = r16
 .def temp = r18
 ldi reg, low(RAMEND)
 out SPL, r24
 ldi reg, high(RAMEND)
 out SPH, r24
 ser reg
 out DDRB, reg		//PortB as output
 clr reg
 out DDRA, reg		//PortA as input
 flash:
 rcall on
 in reg, PINA
 andi reg, 0x0f		//Isolate PA0-PA3
 //Delay
 rcall calculate_Delay
 rcall wait_msec
 
 rcall off
 in reg, PINA
 andi reg, 0xf0
 swap reg
 //Delay
 rcall calculate_Delay 
 rcall wait_msec
 
 rjmp flash

 on:
 ser leds
 out PORTB, leds
 ret

 off:
 clr leds
 out PORTB, leds
 ret

 calculate_Delay:
 clr r24
 clr r25
 inc reg
 ldi temp, 0xc8		//Temp = 200d
 mul reg, temp
 mov r24, r0
 mov r25, r1
 ret

 wait_msec:
 push r24 
 push r25 
 ldi r24 , low(998) 
 ldi r25 , high(998) 
 rcall wait_usec 
 pop r25 
 pop r24 
 sbiw r24 , 1 
 brne wait_msec 
 ret

 wait_usec:
 sbiw r24 ,1 
 nop 
 nop 
 nop 
 nop 
 brne wait_usec 
 ret
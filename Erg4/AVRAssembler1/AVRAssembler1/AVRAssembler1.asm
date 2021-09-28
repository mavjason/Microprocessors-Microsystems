/*
 * AVRAssembler1.asm
 *
 *  Created: 7/11/2017 3:30:54 ??
 *   Author: theovaka
 */ 
 		.include "m16def.inc"
		.def reg = r16
		.def leds = r17	//Status of Leds
		.def flag = r18	//Determines the shift of Leds left or right
		ldi flag, low(RAMEND)
		out SPL, flag
		ldi flag, high(RAMEND)
		out SPH, flag
		clr flag		//Initialise flag = 0 => move left
		ldi leds, 0x01	//Initialise Leds
		clr reg
		out DDRA, reg	//Define PortA as input
		ser reg
		out DDRB, reg	//Define PortB as output
		start:
		out PORTB, leds
		ldi r25, HIGH(500)
		ldi r24, LOW(500)	//Initialise registers for 500ms delay 
		rcall wait_msec
		sbis PINA, 0x00	//Read input
		rjmp start
		cpi flag, 0x00
		breq Move_Left
		cpi leds, 0x01
		breq right_border
		lsr leds
		rjmp start
		
		right_border:
		com flag
		lsl leds
		rjmp start
		
		Move_Left:
		cpi leds, 0x80
		breq left_border
		lsl leds
		rjmp start

		left_border:
		com flag
		lsr leds
		rjmp start

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
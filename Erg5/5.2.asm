/*
 * AVRAssembler3.asm
 *
 *  Created: 17-Nov-17 10:47:50 AM
 *   Author: Dimitra
 */ 

 .INCLUDE "m16def.inc"
 .DEF counter = r20
 .DEF reg = r16
 .DEF mask = r18
 .DEF temp = r17
 .org 0x00
 rjmp reset
 .org 0x02
 rjmp ISR0
 
 reset:
 ldi r24, low(RAMEND)
 out SPL, r24
 ldi r24, high(RAMEND)
 out SPH, r24
 ser reg
 out DDRB, reg		;PortB as counter output
 out DDRC, reg		;PortC as interr output
 clr reg
 out DDRD, reg		;PortD as input
 out DDRA,reg		;PortA as input
 clr counter
 ldi reg,(1<<ISC01)|(1<<ISC00)
 out MCUCR,reg
 ldi reg,1<<INT0
 out GICR,reg
 sei  
 out PORTC, counter
 
 count:
 out PORTB, counter
 ldi r24,low(200)
 ldi r25,high(200)
 rcall wait_msec
 inc counter
 rjmp count
 
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
 
 ISR0:
 push r24     ; save delay registers
 push r25
 in reg,SREG   ; save status register
 push reg
 check:    
 ldi reg,(1<<INTF0)
 out GIFR,reg
 ldi r24,low(5)
 ldi r25,high(5)
 rcall wait_msec
 in reg,GIFR
 andi reg,0x80 ;isolate 1st bit
 cpi reg,0x00
 brne check    ; if carry is set wait again 5msec and check
 in reg, PIND
 andi reg, 0x80		;Isolate PD7
 cpi reg,0x00
 breq leave
 ldi mask,0xff ;11111111 at first
 ldi temp,0x08 ;8 switches, 8 bits to check through carry
 in reg, PINA
 loop1: 
 ror reg
 brcc not_on
 lsl mask ;11111110 add zeros at the end every time you find 1 at a switches
 not_on:
 dec temp
 brne loop1
 com mask  ;take complement of mask to light the leds
 out PORTA,mask  
 ldi r24, low(998)	; wait
 ldi r25, high(998)
 rcall wait_msec
 leave:    
 pop reg
 out SREG,reg
 pop r25
 pop r24
 reti
 

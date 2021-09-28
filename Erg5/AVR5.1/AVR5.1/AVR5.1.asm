.INCLUDE "m16def.inc"
 .DEF counter = r20
 .DEF reg = r16
 .DEF interr = r18
 .org 0x00
 rjmp reset
 .org 0x04
 rjmp ISR1
 
 reset:
 ldi r24, low(RAMEND)
 out SPL, r24
 ldi r24, high(RAMEND)
 out SPH, r24
 ser reg
 out DDRB, reg		;PortB as counter output
 out DDRA, reg		;PortA as interr output
 clr reg
 out PORTA,reg
 out DDRD, reg		;PortD as input
 clr counter
 clr interr         ; interrupt number is zero initially
 ldi reg, ( 1 << ISC11) | ( 1 << ISC10)  ; posedge for int1
 out MCUCR,reg
 ldi reg, (1 << INT1)
 out GICR,reg
 sei
 
 count:
 out PORTB, counter
 ldi r24,low(200)
 ldi r25,high(200)    ; delay 200ms=0.2sec
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
 
 ISR1:    
 push r24      ; save delay registers
 push r25
 in reg,SREG   ; save status register
 push reg 
 check:
 ldi reg, (1 << INTF1)
 out GIFR,reg
 ldi r24,low(5)
 ldi r25,high(5)
 rcall wait_msec
 in reg,GIFR    ; INTF1 must be zero to start interrupt
 andi reg,0x80
 cpi reg,0x00
 brne check  ; if carry is set wait again 5msec and check
 in reg, PIND
 andi reg, 0x80		;Isolate PD7
 cpi reg,0x00
 breq leave   ; if PD7=0, skip interruption (return)
 inc interr
 out PORTA,interr   ; show number of interrupts
 ldi r24, low(998)		; wait 1sec for this interrupt
 ldi r25, high(998)
 rcall wait_msec    
 leave:  
 pop reg
 out SREG,reg
 pop r25
 pop r24
 reti
 
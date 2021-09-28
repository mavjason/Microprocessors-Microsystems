.include "m16def.inc"
.def reg = r20
.def temp = r21 
.def flag = r22
.org 0x0
rjmp reset
.org 0x4
rjmp int1  
.org 0x10
rjmp ISR_TIMER1_OVF

reset:   
ldi reg, low(RAMEND)
out SPL, reg
ldi reg, high(RAMEND)
out SPH, reg 
ser flag
ser reg
out DDRB, reg   ;Port B as output
clr reg
out DDRA, reg   ;Port A as input
out DDRD, reg   ;Port D as input
ldi reg,(1<<ISC11)|(1<<ISC10)
out MCUCR, reg
ldi reg, (1<<INT1)
out GICR, reg
ldi reg, (1<<TOIE1)
out TIMSK, reg
ldi reg, (1<<CS12)|(0<<CS11)|(1<<CS10)
out TCCR1B, reg
ldi reg, 0x85   ;Initialise start point of timer1 at 34286(10)
out TCNT1H, reg ;so as to cause an interrupt after 4s
ldi reg, 0xEE
out TCNT1L, reg
sei


start:          
in reg, PINA
andi reg, 0x80   
cpi reg, 0x00
breq start   
ldi reg, 0x85   ;Initialise start point of timer1 at 34286(10)
out TCNT1H, reg ;so as to cause an interrupt after 4s
ldi reg, 0xEE   
out TCNT1L, reg 
cpi flag, 0xff  
breq next        ;At first don't switch all leds on for 0.5s
clr GICR         ;Disable interrupts
ldi r24, low(500)
ldi r25, high(500)
rcall wait_msec     ;Call routine for delay 0.5s
ldi temp, (1<<INT1)
out GICR, temp   ;Enable interrupts

next:
clr flag
ldi reg, 0x01
out reg, PORTB

loop1:
in reg, PINA
andi reg, 0x80
cpi reg, 0x80
breq loop1
rjmp start

ISR_TIMER1_OVF:
clr temp
out PORTB, temp
reti

int1:
ldi temp,(1<<INTF1)
out GIFR,temp
ldi r24,low(5)
ldi r25,high(5)
rcall wait_msec  
;;in temp, GIFR
andi temp,0x80
cpi temp,0x00
brne int1   
ldi temp, 0x85   ;Initialise start point of timer1 at 34286(10)
out TCNT1H, temp ;so as to cause an interrupt after 4s
ldi temp, 0xEE   
out TCNT1L, temp
ser temp
out PORTB, temp  ;Switch on all leds of Port B for 0.5s 
clr GICR         ;Disable interrupts
ldi r24, low(500)
ldi r25, high(500)
rcall wait_msec     ;Call routine for delay 0.5s
ldi temp, (1<<INT1)
out GICR, temp   ;Enable interrupts
rcall wait_msec
ldi temp, 0x01
out PORTB, temp
reti


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



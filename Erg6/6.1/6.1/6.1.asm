.include "m16def.inc"
.def reg = r19
.def temp1 = r20
.def temp2 = r21
.def temp3 = r26   
.def lastA = r22
.def lastC = r23
.def counter = r24
.def var = r25
main:
ldi reg, low(RAMEND)
out SPL, reg
ldi reg, high(RAMEND)
out SPH, reg
clr lastA
clr lastC
ser reg
out DDRB, reg   ;PortB as output
clr reg
out DDRA, reg   ;PortA as input 
out DDRC, reg   ;PortC as input
out PORTB, reg  ;Initialise leds

repeat:
in lastA, PINA       ;Read push buttons PA0-PA7
clr reg            ;Create output in register reg
mov temp1, lastA
andi temp1, 0xc0    ;Isolate PA7-PA6
cpi temp1, 0x00
breq case1    
cpi temp1, 0xc0
breq case1
next1:
mov temp1, lastA
andi temp1, 0x30    ;Isolate PA5-PA4
cpi temp1, 0x00
breq case2
next2:
mov temp1, lastA
andi temp1, 0x0c    ;Isolate PA3-PA2
cpi temp1, 0x00
brne case3
next3:
mov temp2, reg
andi temp2, 0x02
breq next4
mov temp2, lastA
andi temp2, 0x03    ;Isolate PA1-PA0
cpi temp2, 0x01
breq case4
cpi temp2, 0x02
breq case4
next4:
in temp1, PINC     
ldi counter, 0x08
ldi var, 0x80
loop3:
rol temp1
brcc next_it
eor reg, var
next_it:
lsr var
dec counter   
cpi counter, 0x00
brne loop3
out PORTB, reg      ;Display leds
rjmp repeat 

case1:
ldi temp3, 0x08
add reg, temp3
rjmp next1
case2:
ldi temp3, 0x04
add reg, temp3
rjmp next2
case3:
ldi temp3, 0x02
add reg, temp3
rjmp next3
case4:
ldi temp3, 0x01
add reg, temp3
rjmp next4




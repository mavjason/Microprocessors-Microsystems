.include "m16def.inc"
.def reg = r19
.def temp1 = r20
.def temp2 = r21   
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
in reg, PINA    ;Read push buttons PA0-PA7
mov temp1, reg  
mov temp2, lastA
ldi counter, 0x08 
ldi var, 0x80
loop1:    
and temp1, var
and temp2, var
cmp temp2, temp1
brcs continue
mov temp1, reg
mov temp2, lastA
lsr var
dec counter
cmp counter, 0x00
brne loop1  
mov lastA, reg  ;Refresh content of register lastA

in reg, PINC    ;Read push buttons PC0-PC7
mov temp1, reg
mov temp2, lastC
ldi counter, 0x08
ldi var, 0x80
loop2:
and temp1, var
and temp2, var
cmp temp2, temp1
brcs continue
mov temp1, reg
mov temp2, lastC
lsr var
dec counter
cmp counter, 0x00
brne loop2
mov lastC, reg     ;Refresh content of register lastC
rjmp repeat        ;If no press of any push button check again

continue:
clr reg            ;Create output in register reg
mov temp1, lastA
andi temp1, 0xc0    ;Isolate PA7-PA6
cmp temp1, 0x80
breq case1    
cmp temp1, 0x70
breq case1
next1:
mov temp1, lastA
andi temp1, 0x30    ;Isolate PA5-PA4
cmp temp1, 0x00
breq case2
next2:
mov temp1, lastA
andi temp1, 0x0c    ;Isolate PA#-PA2
cmp temp1, 0x0c
breq case3
next3:
mov temp2, lastA
andi temp2, 0x03    ;Isolate PA1-PA0
cmp temp2, 0x01
breq case4
cmp temp2, 0x02
breq case4
next4:
mov temp1, lastC     
ldi counter, 0x08
ldi var, 0x80
loop3:
rol temp1
brcc next_it
xor reg, var
next_it:
lsr var
dec counter   
cmp counter, 0x00
brne loop3
out PORTB, reg      ;Display leds
rjmp repeat 

case1:
addi reg, 0x08
rjmp next1
case2:
addi reg, 0x04
rjmp next2
case3:
addi reg, 0x02
rjmp next3
case4:
cmp temp1, 0x0c
brne next4
addi reg, 0x01
rjmp next4











































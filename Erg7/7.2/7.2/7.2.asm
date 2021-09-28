
 .include "m16def.inc"  

 .def reg = r18
 .def hund = r19 
 .def deca = r17
 .def units = r16 
 .def cnt = r20
 .def flag = r21
 .def temp = r22
 .def mask = r23
 
 reset:           
     ldi reg, low(RAMEND)
     out SPL, reg
     ldi reg, high(RAMEND)
     out SPH, reg 
     clr reg
     out DDRA, reg		;PortA as input    
	 ser reg
	 out DDRD,reg
 main:  
     rcall lcd_init
     clr flag           ;0->positive
	 ldi mask,0x80
	 ldi cnt,0x08
     in reg,PINA
	 mov temp,reg
	 and temp,mask
	 cpi temp,0x00
     breq loopA
     ldi flag,0x01
 loopA:
	 
	 cpi temp, 0x00
	 breq pr0
	 ldi r24, '1'
	 rcall lcd_data
	 jmp step
pr0:
	 ldi r24, '0'
	 rcall lcd_data
step:
	 CLC
     ror mask	
	 mov temp,reg
	 and temp,mask
     dec cnt
     brne loopA
     ldi r24,'='
     rcall lcd_data
     cpi reg,0x00
     breq print0
     cpi reg,0xff
     breq print0
     cpi flag,0x00
     breq positive
     ldi r24,'-'
     rcall lcd_data
     com reg
     jmp BCD
 positive:
     ldi r24,'+'
     rcall lcd_data
 BCD:
     clr hund
     clr deca
     clr units
 loopB:             ;Convert hex number to decimal
     subi reg,0x64  ;Subtract 1 hundred
     brcs case1
     inc hund       ;hundreds++
     jmp loopB
 case1:
     ldi temp,0x64
     add reg,temp   ;Restore one extra subtraction	
     loopC:
     subi reg,0x0a  ;Subtract 1 ten
     brcs case2
     inc deca       ;tens++
     jmp loopC
 case2:
     ldi temp,0x0a
     add reg,temp   ;Restore one extra subtraction
     mov units,reg  ;what is left is the units  
     ldi flag,0x00  ;hund=0 
     cpi hund,0x00
     breq dig2 
     ldi flag,0x01
     mov r24,hund
	 ldi reg,0x30
	 add r24,reg
     rcall lcd_data 
 dig2:
     cpi flag,0x00
     brne show  
     cpi deca,0x00
     breq dig1
 show:     
     mov r24,deca
	 ldi reg,0x30
	 add r24,reg
     rcall lcd_data  
 dig1:
     mov r24,units
	 ldi reg,0x30
	 add r24,reg
     rcall lcd_data
     ldi r25, HIGH(1000) 
     ldi r24, LOW(1000)     ;Initialise registers for 1s delay  
     rcall wait_msec    
     jmp main
 
 print0:
     ldi r24,'0'
     rcall lcd_data    
     ldi r25, HIGH(1000)
     ldi r24, LOW(1000)	    ;Initialise registers for 1s delay  
     rcall wait_msec    
	 jmp main
 
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

write_2_nibbles:
    push r24 
    in r25 ,PIND 
    andi r25 ,0x0f 
    andi r24 ,0xf0 
    add r24 ,r25 
    out PORTD ,r24 
    sbi PORTD ,PD3 
    cbi PORTD ,PD3 
    pop r24 
    swap r24 
    andi r24 ,0xf0 
    add r24 ,r25
    out PORTD ,r24
    sbi PORTD ,PD3 
    cbi PORTD ,PD3
    ret    

lcd_data:
    sbi PORTD ,PD2 
    rcall write_2_nibbles 
    ldi r24 ,43 
    ldi r25 ,0 
    rcall wait_usec
    ret  

lcd_command:
    cbi PORTD ,PD2 
    rcall write_2_nibbles 
    ldi r24 ,39 
    ldi r25 ,0 
    rcall wait_usec 
    ret  

lcd_init:
    ldi r24 ,40 
    ldi r25 ,0 
    rcall wait_msec 
    ldi r24 ,0x30 
    out PORTD ,r24 
    sbi PORTD ,PD3 
    cbi PORTD ,PD3 
    ldi r24 ,39
    ldi r25 ,0 
    rcall wait_usec 
    ldi r24 ,0x30
    out PORTD ,r24
    sbi PORTD ,PD3
    cbi PORTD ,PD3
    ldi r24 ,39
    ldi r25 ,0
    rcall wait_usec
    ldi r24 ,0x20 
    out PORTD ,r24
    sbi PORTD ,PD3
    cbi PORTD ,PD3
    ldi r24 ,39
    ldi r25 ,0
    rcall wait_usec
    ldi r24 ,0x28 
    rcall lcd_command 
    ldi r24 ,0x0c
    rcall lcd_command
    ldi r24 ,0x01 
    rcall lcd_command
    ldi r24 ,low(1530)
    ldi r25 ,high(1530)
    rcall wait_usec
    ldi r24 ,0x06 
    rcall lcd_command 
    ret  



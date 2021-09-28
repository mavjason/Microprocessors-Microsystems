.include "m16def.inc"  

 .def reg = r18
 .def flag = r19 
 .def temp = r17   
                  
 .DSEG
 _tmp_:.byte 2
 
 .CSEG
                  
 ldi reg, low(RAMEND)
 out SPL, reg
 ldi reg, high(RAMEND)
 out SPH, reg
 ser reg
 out DDRB, reg		//PortB as output
 ldi r24 ,(1 << PC7) | (1 << PC6) | (1 << PC5) | (1 << PC4)  
 out DDRC ,r24 
 ldi r26,low(_tmp_) ;r26-r27 -> X
 ldi r27,high(_tmp_) 
 clr reg
 st X+,reg
 st X,reg        
 out PORTB,reg
 reading:    
 ldi flag,0x01 ;0->wrong combination,1->right 
 ldi r24, 10	;Initialise for 0.01s delay
 rcall scan_keypad_rising_edge
 rcall keypad_to_ascii
 cpi r24,0x00
 breq reading
 cpi r24,'1'   
 breq read2nd
 clr flag     
 
 read2nd:
 ldi r24, 10	;Initialise registers for 0.01s delay
 rcall scan_keypad_rising_edge
 rcall keypad_to_ascii
 cpi r24,0x00
 breq read2nd
 cpi r24,'2' 
 breq leds
 clr flag
  
 leds:
 cpi flag,0x00
 breq wrong
 ldi r25, HIGH(4000)
 ldi r24, LOW(4000)	//Initialise registers for 4s delay 
 ser reg
 out PORTB,reg
 rcall wait_msec
 clr reg
 out PORTB,reg 
 jmp reading     
 
 wrong:
 ldi temp,0x08   
 
 on_off:
 ser reg
 out PORTB,reg
 ldi r25, HIGH(250)
 ldi r24, LOW(250)	//Initialise registers for 0.25s delay  
 rcall wait_msec
 ldi r25, HIGH(250)
 ldi r24, LOW(250)
 clr reg
 out PORTB,reg
 rcall wait_msec
 dec temp
 brne on_off
 jmp reading

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
 
 scan_row:
 ldi r25,0x08
 back:
 lsl r25
 dec r24
 brne back
 out PORTC, r25
 nop
 nop
 in r24, PINC
 andi r24, 0x0f
 ret
 
 scan_keypad:
 ldi r24,0x01
 rcall scan_row
 swap r24
 mov r27,r24
 ldi r24,0x02
 rcall scan_row
 add r27,r24
 ldi r24,0x03
 rcall scan_row
 swap r24
 mov r26,r24
 ldi r24,0x04
 rcall scan_row
 add r26,r24
 movw r24,r26
 ret
 
 scan_keypad_rising_edge:
 mov r22, r24
 rcall scan_keypad
 push r24
 push r25
 mov r24, r22
 clr r25
 rcall wait_msec   
 rcall scan_keypad
 pop r23
 pop r22
 and r24,r22
 and r25,r23
 ldi r26,low(_tmp_) ;r26-r27 -> X
 ldi r27,high(_tmp_) 
 ld r23,X+
 ld r22,X
 st X,r24
 st -X,r25
 com r23
 com r22
 and r24,r22
 and r25,r23
 ret
 
 
keypad_to_ascii: 
movw r26 ,r24 
ldi r24 ,'*'
sbrc r26 ,0
ret
ldi r24 ,'0'
sbrc r26 ,1
ret
ldi r24 ,'#'
sbrc r26 ,2
ret
ldi r24 ,'D'
sbrc r26 ,3 
ret 
ldi r24 ,'7'
sbrc r26 ,4
ret
ldi r24 ,'8'
sbrc r26 ,5
ret
ldi r24 ,'9'
sbrc r26 ,6
ret
ldi r24 ,'C'
sbrc r26 ,7
ret
ldi r24 ,'4' 
sbrc r27 ,0 
ret
ldi r24 ,'5'
sbrc r27 ,1
ret
ldi r24 ,'6'
sbrc r27 ,2
ret
ldi r24 ,'B'
sbrc r27 ,3
ret
ldi r24 ,'1'
sbrc r27 ,4
ret
ldi r24 ,'2'
sbrc r27 ,5
ret
ldi r24 ,'3'
sbrc r27 ,6
ret
ldi r24 ,'A'
sbrc r27 ,7
ret
clr r24
ret
 

.include "m16def.inc"  

 .def reg = r18
 .def flag = r19 
 .def temp = r17
 .org 0x10
 rjmp ISR_TIMER1_OVF 
; .org 0x00  
 ;rjmp reset
 
 .DSEG
 _tmp_:.byte 2
 
 .CSEG
 
 reset:           
     ldi reg, low(RAMEND)
     out SPL, reg
     ldi reg, high(RAMEND)
     out SPH, reg 
     ser reg
     out DDRA, reg		//PortA as output 
	 out DDRD,reg		//lcd screen
     clr reg
     out DDRB, reg		//PortB as input
     ldi r24 ,(1 << PC7) | (1 << PC6) | (1 << PC5) | (1 << PC4)  
     out DDRC ,r24     
     ;ldi r24 ,0xfc ;11111100, PD7-2 output 
     ;out DDRD ,r24 
     ldi r26,low(_tmp_) ;r26-r27 -> X
     ldi r27,high(_tmp_) 
     clr reg
     st X+,reg
     st X,reg 
     out PORTA,reg       
     ldi reg, (1<<TOIE1)
     out TIMSK, reg         ;timer1
     ldi reg, (1<<CS12)|(0<<CS11)|(1<<CS10)
     out TCCR1B, reg
     sei  
     
 initialize:
    rcall lcd_init
	;jmp reset
 read_sensors:
     in reg,PINB
     cpi reg,0x00     ;reading sensors
     breq read_sensors
     
     ldi reg, 0x67   ;Initialise start point of timer1 at 67(hex)
     out TCNT1H, reg ;so as to cause an interrupt after 5s
     ldi reg, 0x69   
     out TCNT1L, reg   
     
     ;show cursor
 read_shift:    
     clr flag ;0,1,2->wrong combination,3->right 
     clr temp ;indicates number of keys pressed
     ldi r24, 10	;Initialise for 0.01s delay
     rcall scan_keypad_rising_edge
     rcall keypad_to_ascii
     cpi r24,0x00
     breq read_shift 
     rcall lcd_data 
     ;show cursor
     inc temp
     cpi r24,'4'   
     brne read1st
     inc flag
 
 read1st:
     ldi r24, 10	;Initialise for 0.01s delay
     rcall scan_keypad_rising_edge
     rcall keypad_to_ascii
     cpi r24,0x00
     breq read1st  
     rcall lcd_data 
     ;show  cursor 
     inc temp
     cpi r24,'1'   
     brne read2nd
     inc flag     
     
 read2nd:
     ldi r24, 10	;Initialise registers for 0.01s delay
     rcall scan_keypad_rising_edge
     rcall keypad_to_ascii
     cpi r24,0x00
     breq read2nd  
     ;show cursor    
     rcall lcd_data
     inc temp
     cpi r24,'2' 
     brne wrong
     inc flag
     
     cpi flag,0x03
     brne wrong 
 right:
     rcall ALARM_O
     ldi r24,'F'
     rcall lcd_data 
     ldi r24,'F'
     rcall lcd_data    
     ldi r25, HIGH(3000)  ;;;;;;;;;;;; xreiazetai??
     ldi r24, LOW(3000)	//Initialise registers for 3s delay  
     rcall wait_msec    ;;;;;;;;;;;;
     jmp initialize     
 
 wrong: 
     rcall ALARM_O
     ldi r24,'N'
     rcall lcd_data    
 again:
     ser reg
     out PORTA,reg
     ldi r25, HIGH(400)
     ldi r24, LOW(400)	//Initialise registers for 0.4s delay  
     rcall wait_msec
     ldi r25, HIGH(100) //Initialise registers for 0.1s delay 
     ldi r24, LOW(100)
     clr reg
     out PORTA,reg
     rcall wait_msec
     jmp again

 
ISR_TIMER1_OVF: 
    cpi flag,0x03
    breq leave
    cpi temp,0x03
    breq leave  
    rcall ALARM_O
    ldi r24,'N'
    rcall lcd_data 
on_off:
    ser reg
    out PORTA,reg
    ldi r25, HIGH(400)
    ldi r24, LOW(400)	//Initialise registers for 0.4s delay  
    rcall wait_msec
    ldi r25, HIGH(100) //Initialise registers for 0.1s delay 
    ldi r24, LOW(100)
    clr reg
    out PORTA,reg
    rcall wait_msec
    jmp on_off
leave:
    ret

ALARM_O:
    ldi r24,'A'
    rcall lcd_data 
    ldi r24,'L'
    rcall lcd_data
    ldi r24,'A'
    rcall lcd_data
    ldi r24,'R'
    rcall lcd_data
    ldi r24,'M'
    rcall lcd_data
    ldi r24,' '
    rcall lcd_data
    ldi r24,'O'
    rcall lcd_data 
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
;   ldi r24 ,0x0c
;   rcall lcd_command
    ldi r24 ,0x01 
    rcall lcd_command
    ldi r24 ,low(1530)
    ldi r25 ,high(1530)
    rcall wait_usec
    ldi r24 ,0x06 
    rcall lcd_command 
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

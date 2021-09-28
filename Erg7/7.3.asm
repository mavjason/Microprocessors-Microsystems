.include "m16def.inc"
.def reg = r20
.def temp = r21   
.def flag1 = r22
.def flag2 = r23
.def Min = r18
.def Sec = r19
.def tens = r16
.def units = r17

.org 0x00
rjmp reset

reset:           
    ldi reg, low(RAMEND)
    out SPL, reg
    ldi reg, high(RAMEND)
    out SPH, reg 
    clr reg
    out DDRB, reg	;PortB as input
    ldi r24 ,0xfc   ;11111100, PD7-2 output 
    out DDRD ,r24  

main:
    rcall lcd_init
    clr Min
    clr Sec
    ldi flag1 , 0x00        ;Initialise flag1=0 meaning clock not running
    ldi flag2 , 0x00        ;Initialise flag2=0 meaning odd next press of PB0
    rcall display_init_clk

start:
    in reg, PINB   
    mov temp, reg
    andi temp, 0x80
    cpi temp, 0x80
    brne next
    clr Min                 ;Reset clock
    clr Sec
    ldi flag1, 0x00
    ldi flag2, 0x00
    rcall display_init_clk
    wait_loop:              ;Wait until user unpresses PB7
    in reg, PINB
    andi reg, 0x80
    cpi reg, 0x80
    breq wait_loop
    rjmp start

next:
    mov temp, reg
    andi temp, 0x01
    cpi temp, 0x01      ;Check for PB0 press
    breq pressed  
    cpi flag1, 0x00     ;If PB0 is not pressed check if clock is running
    breq start          ;If PB0 not pressed and clock not running
                        ;do not change anything
    ;else increase clock and display result in lcd display
    rcall inc_clock_and_display                 
    rjmp start

pressed:            ;If PB0 is pressed check if it is odd or even press
    cpi flag2, 0x00 
    brne stop           
    ;If odd press of PB0 button start the clock
    xor flag1, flag1    ;Update flag1 meaning clock running
    xor flag2, flag2    ;Update flag2 for next press of PB0
    rcall inc_clock_and_display
    rjmp start
    ;If even press of PB0 button stop the clock
    stop:               ;If even current press of PB0 stop clock
    xor flag2, flag2    ;Update flag2 for next press of PB0
    xor flag1, flag1    ;Update flag1 meaning clock not running
    rjmp start

;This routine displays the following message to LCD display
;                      "00 MIN:00 SEC"
display_init_clk:       
    ldi r24, '0'
    rcall lcd_display
    rcall lcd_display
    ldi r24, ' '
    rcall lcd_display
    ldi r24, 'M'
    rcall lcd_display
    ldi r24, 'I'
    rcall lcd_display
    ldi r24, 'N'
    rcall lcd_display
    ldi r24, ':'
    rcall lcd_display
    ldi r24, '0'
    rcall lcd_display
    rcall lcd_display     
    ldi r24, ' '
    rcall lcd_display
    ldi r24, 'S'
    rcall lcd_display
    ldi r24, 'E'
    rcall lcd_display
    ldi r24, 'C'
    rcall lcd_display
ret    
             

inc_clock_and_display: 
    push temp
    push reg
    inc Sec
    cpi Sec, 0x3C       
    brne display
    clr Sec              ;If Sec=60(10) Sec=0 and Min=Min+1 
    inc Min
    cpi Min, 0x3C
    brne display
    clr Min              ;If Min=60(10) Min=0
display: 
    ldi r24, LOW(1000)
    ldi r25, HIGH(1000)
    rcall wait_msec      ;Wait for 1s   
    
    mov reg, Min
    rcall hex_to_bcd     ;Convert minutes to BCD
    mov temp, tens
    ldi reg, 0x30
    add temp, reg        ;Convert to ASCII code 
    mov r24, temp
    rcall lcd_data       ;Display
    mov temp, units  
    add temp, reg        ;Convert to ASCII code
    mov r24, temp
    rcall lcd_data       ;Display minutes
    
    ;Display " MIN:"
    ldi r24, ' '
    rcall lcd_display
    ldi r24, 'M'
    rcall lcd_display
    ldi r24, 'I'
    rcall lcd_display
    ldi r24, 'N'
    rcall lcd_display
    ldi r24, ':'
    rcall lcd_display        
    
    mov reg, Sec         
    rcall hex_to_bcd     ;Convert seconds to BCD
    mov temp tens
    ldi reg, 0x30
    add temp, reg        ;Convert to ASCII code  
    mov r24, temp
    rcall lcd_data       ;Display
    mov temp, units
    add temp, reg        ;Convert to ASCII code
    mov r24, temp
    rcall lcd_data       ;Display seconds 
    
    ;Display " SEC"   
    ldi r24, ' '
    rcall lcd_display
    ldi r24, 'S'
    rcall lcd_display
    ldi r24, 'E'
    rcall lcd_display
    ldi r24, 'C'
    rcall lcd_display    
    
    pop reg
    pop temp
ret

;This routine takes a hex number as input stored in reg register
;and returns the BCD representation of this number
;The units are stored in units register and the tens in tens register     
hex_to_bcd:    
     push temp
     clr tens
     clr units
loopA:
     subi reg, 0x0A  ;Subtract 1 ten
     brcs case1
     inc tens        ;tens++
     jmp loopA
 case1:
     ldi temp,0x0A
     add reg,temp    ;Restore one extra subtraction	 
     mov units, reg
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
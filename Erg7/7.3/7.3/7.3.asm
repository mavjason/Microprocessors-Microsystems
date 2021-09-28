.include "m16def.inc"
.def reg = r20
.def temp = r21   
.def Min = r16
.def Second = r17
.def tens = r18
.def units = r19

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
    clr Second
    rcall display_init_clk

start:
    in reg, PINB   
    mov temp, reg
    andi temp, 0x80
    cpi temp, 0x80
    breq main
next:
    mov temp, reg
    andi temp, 0x01
    cpi temp, 0x01      ;Check for PB0 press
    brne start  

    rcall inc_clock_and_display
    rjmp start

;This routine displays the following message to LCD display
;                      "00 MIN:00 SEC"
display_init_clk:       
    ldi r24, '0'
    rcall lcd_display
	ldi r24, '0'
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
	ldi r24, '0'
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
    inc Second
    cpi Second, 0x3C       
    brne display
    clr Second              ;If Sec=60(10) Sec=0 and Min=Min+1 
    inc Min
    cpi Min, 0x3C
    brne display
    clr Min              ;If Min=60(10) Min=0
display: 
    ldi r24, LOW(1000)
    ldi r25, HIGH(1000)
    rcall wait_msec      ;Wait for 1s  
	rcall lcd_init 
    mov reg, Min
    rcall hex_to_bcd     ;Convert minutes to BCD
    mov temp, tens
    ldi reg, 0x30
    add temp, reg        ;Convert to ASCII code 
    mov r24, temp
    rcall lcd_display      ;Display
    mov temp, units  
    add temp, reg        ;Convert to ASCII code
    mov r24, temp
    rcall lcd_display       ;Display minutes 
    
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
  
    mov reg, Second        
    rcall hex_to_bcd     ;Convert seconds to BCD
    mov temp, tens
    ldi reg, 0x30
    add temp, reg        ;Convert to ASCII code  
    mov r24, temp
    rcall lcd_display       ;Display
    mov temp, units
	out PORTA, units
	ldi reg, 0x30
    add temp, reg        ;Convert to ASCII code
    mov r24, temp
    rcall lcd_display     ;Display seconds 
    
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
	 pop temp
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

lcd_display:
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



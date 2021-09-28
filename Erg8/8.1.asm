.include "m16def.inc"
.def flag = r20
.def reg = r21       


main:
    ldi reg, low(RAMEND)
    out SPL, reg
    ldi reg, high(RAMEND)
    out SPH, reg 
    ser reg
    out DDRA, reg	;PortB as output    
    rcall my_routine
    jmp main 



my_routine: 
    rcall one_wire_reset
    cpi r24,0x01
    brne not_connected 
    ldi r24,0xcc
    rcall one_wire_transmit_byte
    ldi r24,0x44
    rcall one_wire_transmit_byte 
not_ready:
    rcall one_wire_receive_bit
    sbrs r24,0
    rjmp not_ready
wake_up:
    rcall one_wire_reset
    cpi r24,0x01
    brne not_connected
    ldi r24,0xcc
    rcall one_wire_transmit_byte
    ldi r24,0xbe
    rcall one_wire_transmit_byte  
    rcall one_wire_receive_byte
    ;mov r25,r24               
    push r24
    rcall one_wire_receive_byte 
    pop r25            
    cpi r25, 0xff
    brne show_temperature
    subi r24,0x01               ;2's->1's complement    
    ;lsr r24 ;thelei k to /2?? ->anagkastika akeraia diairesh omws?!
    rjmp show_temperature
not_connected:
    ldi r25,0x80
    clr r24
show_temperature:   
     push r24            ;Divide by 2 to convert to Celsius degrees
     push r25
     lsr r24             
     out PORTA,r24  
     ldi r24, LOW(1000)
     ldi r25, HIGH(1000)
     rcall wait_msec     ;Wait for 1s   
     pop r25
     pop r24
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

one_wire_reset:
    sbi DDRA ,PA4 ; PA4 configured for output
    cbi PORTA ,PA4 ; 480 ìsec reset pulse
    ldi r24 ,low(480)
    ldi r25 ,high(480)
    rcall wait_usec
    cbi DDRA ,PA4 ; PA4 configured for input
    cbi PORTA ,PA4
    ldi r24 ,100 ; wait 100 ìsec for devices
    ldi r25 ,0 ; to transmit the presence pulse
    rcall wait_usec
    in r24 ,PINA ; sample the line
    push r24
    ldi r24 ,low(380) ; wait for 380 ìsec
    ldi r25 ,high(380)
    rcall wait_usec
    pop r25 ; return 0 if no device was
    clr r24 ; detected or 1 else
    sbrs r25 ,PA4
    ldi r24 ,0x01
    ret     
    
one_wire_receive_bit:
    sbi DDRA ,PA4
    cbi PORTA ,PA4 ; generate time slot
    ldi r24 ,0x02
    ldi r25 ,0x00
    rcall wait_usec
    cbi DDRA ,PA4 ; release the line
    cbi PORTA ,PA4
    ldi r24 ,10 ; wait 10 ìs
    ldi r25 ,0
    rcall wait_usec
    clr r24 ; sample the line
    sbic PINA ,PA4
    ldi r24 ,1
    push r24
    ldi r24 ,49 ; delay 49 ìs to meet the standards
    ldi r25 ,0 ; for a minimum of 60 ìsec time slot
    rcall wait_usec ; and a minimum of 1 ìsec recovery time
    pop r24
    ret          
    
one_wire_transmit_bit:
    push r24 ; save r24
    sbi DDRA ,PA4
    cbi PORTA ,PA4 ; generate time slot
    ldi r24 ,0x02
    ldi r25 ,0x00
    rcall wait_usec
    pop r24 ; output bit
    sbrc r24 ,0
    sbi PORTA ,PA4
    sbrs r24 ,0
    cbi PORTA ,PA4
    ldi r24 ,58 ; wait 58 ìsec for the
    ldi r25 ,0 ; device to sample the line
    rcall wait_usec
    cbi DDRA ,PA4 ; recovery time
    cbi PORTA ,PA4
    ldi r24 ,0x01
    ldi r25 ,0x00
    rcall wait_usec
    ret

one_wire_receive_byte:
    ldi r27 ,8
    clr r26
    loop_:
    rcall one_wire_receive_bit
    lsr r26
    sbrc r24 ,0
    ldi r24 ,0x80
    or r26 ,r24
    dec r27
    brne loop_
    mov r24 ,r26
    ret
    
one_wire_transmit_byte:
    mov r26 ,r24
    ldi r27 ,8
    _one_more_:
    clr r24
    sbrc r26 ,0
    ldi r24 ,0x01
    rcall one_wire_transmit_bit
    lsr r26
    dec r27
    brne _one_more_
    ret
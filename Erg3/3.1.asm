include macros.txt  

data_seg segment    
    msg1 db ".",'$'
    msg2 db 0ah,0dh,'$'   ;new line  
    msg3 db "Decimal:",'$'
data_seg ends       

stack segment
    dw 50 DUP(?)
stack ends

code segment
    assume cs:code,ss:stack,ds:data_seg,es:data_seg
start:
      mov ax,data_seg
      mov ds,ax
      mov es,ax             
begin:      
      mov ch,00h ;ch is a flag:if given D12, ch equals 3
      call hex_keyb   
      cmp al,0dh
      jne p1
      add ch,01h ;if 1st digit is D increase flag            
p1:   mov cl,4  
      rol al,cl ;1st digit is MSD so we shift it 4 steps left  
      mov bl,al         
      call hex_keyb 
      print_str msg1 ;print digital point  
      mov cl,al
      cmp al,01h  
      jne p2
      add ch,01h  ;if 2nd digit is 1 increase flag
p2:   add bl,al  ;add the 2 digits to get the 2-digit hex number 
      call hex_keyb 
      mov cl,al ;keep copy of decimal point
      cmp al,02h
      jne p3
      add ch,01h  ;if 3rd digit is 2 increase flag   
p3:   cmp ch,03h
      je ending  ;if flag is 3 we have to stop the program
      print_str msg2  ;new line
      print_str msg3  
      call print_dec ;print bl
      print_str msg1  
      mov bl,cl ;ah : arithmos sto [0,16]
      call printdp 
      print_str msg2
      jmp begin
ending:
      exit



print_dec proc near
      push bx 
      push dx 
hund: 
      mov bh,00h
      mov ax,bx
      mov dl,100 ;divide with 100 to find hundreds
      div dl ;al holds div, ah holds mod
      cmp al,00h
      je deca ;if hundreds=0 dont print it 
      add al,'0'
      print al ;print hundreds
deca: mov bl,ah ;take mod of previous division  
      mov ax,bx
      mov dl,10 ;divide with 10 the remaining to find tens
      div dl  ;al holds div, ah holds mod 
      add al,'0'
      print al  ;print tens
mon:  mov bl,ah ;take mod of previous division  
      add bl,'0'
      print bl  ;print units(the remainder)
      pop dx
      pop bx   
      ret    
print_dec endp 
  

hex_keyb proc near 
ignore:
       read 
       cmp al,30h ;10 digits have codes from 30 to 39
       jl ignore       
       cmp al,39h
       jle valid1          
       cmp al,41h ;hex lowercase letters have codes from 41 to 46
       jl ignore
       cmp al,46h        
       jle valid2
       cmp al,61h ;hex uppercase letters have codes from 61 to 66
       jl ignore
       cmp al,66h
       jle valid3 
       jmp ignore
valid1:
       print al
       sub al,30h   ;leave ascii code      
       jmp leave        
valid2: 
       print al
       add al,0ah
       sub al,41h  ;leave ascii code
       jmp leave          
valid3:
       print al
       add al,0ah
       sub al,61h   ;leave ascii code        
leave:       
       ret
hex_keyb endp     
                              
               
printdp proc near
    push ax
    push cx     ;to map [0,16] at [0,9] multiply with 10 and divideby 16  
    mov ch,16	;map [0,16] -> [0,9]  
    mov ah,00
    mov al,bl	;bl : arithmos sto [0,16]
    mov cl,10
    mul cl  ;multiply hex decimal point with 10
    div ch  ;divide by 16->al holds current decimal point
	add al,'0' ;go to ascii and print
	print al   
	mov bh,03h ;counter so that it prints 4 decimal digits(we've checked that's the maximum number) 
loop1:
	mov al,ah  ;take remainder print div->2nd decimal digit
	mul cl
	div ch     ;x10/16 to find the i-th decimal digit
	add al,'0' ;go to ascii 
	print al 
	sub bh,01h ;execute loop 3 times
	jnz loop1
	pop cx
    pop ax
	ret
printdp endp   
               
code ends
end START        


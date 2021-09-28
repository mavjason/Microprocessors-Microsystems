include macros.txt  

data_seg segment  
    msg1 db 0ah,0dh,'$'  ;new line
    msg2 db "input: ",0ah,0dh,'$'  
    msg3 db "changed_input: ",0ah,0dh,'$'  
    msg4 db "2 greatest numbers: ",0ah,0dh,'$' 
    msg5 db " '=' was given, end of program",0ah,0dh,'$' 
    msg6 db " ", 0ah,0dh,'$'  ;keno
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
      mov si,1840h ;1840h ,memory for numbers
      mov [si],00h
      mov si,1820h ;1820h, memory for capitals
      mov [si],00h
      mov si,1800h ;1800h, memory for lower-case
      mov [si],00h 
      mov si,1860h  ;1860h, memory for max
      mov [si],20h 
      mov si,1861h ;1861h, memory for second biggest
      mov [si],20h 
      print_str msg2 ;input:                             
      call input
      print_str msg1 ;print new line
      cmp bh,01h  ;if = is given, stop execution
      je ending 
      print_str msg3 ;changed input: 
      mov ch,00h 
      mov ah,00h ;counter of appearances of max
      mov di,1840h
      mov cl,[di] ;initialise counter of loops with content of[1840h]
      cmp cl,00h ;if no number was given print space and go on
      je print_keno
print_Num: ;increase pointer of the array "counter" times and print every number
      add di,01h
      push cx
      mov cx,di  ;keep copy of address
      mov al,[di] 
      print al  ;print current number
      mov di,1861h ;if (second max<current & second max!=max) second max=current
      mov bl,[di] ;bl contains second max
      cmp bl,al 
      jg move_on2
      mov si,1860h
      mov bl,[si] ;bl contains max
      cmp al,bl
      je move_on3 
      mov [di],al ;if condition change second max in memory 
      jmp move_on2 
move_on3:
      add ah,01h  ;if current=max increase counter of appearances of max
move_on2: 
      mov di,cx ;di takes its former value for next loop
      pop cx
      loop print_Num 
print_keno:
      print " "
      mov ch,00h
      mov di,1820h
      mov cl,[di] ;initialise counter
      cmp cl,00h ;if no capitals were given print space and go on
      je print_keno2
print_upper:;increase pointer of the array "counter" times and print every char 
      add di,01h
      mov al,[di] 
      print al  ;take current char and print it
      loop print_upper
print_keno2:
      print " "
      mov ch,00h
      mov di,1800h
      mov cl,[di];initialise counter
      cmp cl,00h  ;if no capitals were given print space and go on
      je print_biggest
print_lower:;increase pointer of the array "counter" times and print every char  
      add di,01h
      mov al,[di]
      print al ;take current char and print it
      loop print_lower
print_biggest:
      print_str msg1 ;print new line
      print_str msg4 ;2 greatest numbers: 
      mov di,1840h
      mov cl,[di] 
      cmp cl,00h ;if no number was given, print nothing and start over
      je return
      cmp cl,01h 
      jne p2
      add di,01h ;if one number was given, print it and start over
      mov al,[di]
      print al
      jmp return
p2: ;if at least 2 numbers were given  
      mov cl,02h ;initialise counter of numbers printed
      cmp ah,01h
      je printbig 
      mov si,1860h ;if maximum appears at least 2 times
      mov al,[si]  ;print it two times and start over
      print al
      print al
      jmp return
printbig:;if 2 different numbers have to be printed(1st and 2nd max)  
      add di,01h
      mov al,[di];traverse the array and print max and second max with
      mov si,1860h ;without changing their sequence
      mov bh,[si]
      cmp al,bh ;if current=max print it
      jne nope
      print al 
      sub cl,01h ;if one is printed, renew the number of numbers that still need to be printed
      jmp p1
nope:
      mov si,1861h
      mov bh,[si]
      cmp al,bh  ;if current =second max print it
      jne p1
      print al 
      sub cl,01h
p1:
      jne printbig ;continue until 2 are printed
return: 
      print_str msg1  ;print new line
      jmp begin
ending:
      print_str msg5 ;print end of program
      exit
      
input proc near 
    mov ch,00h
    mov cl,14 ;14 chars maximum will be given 
    mov bh,00h   ;flag, if '=' is given bh=1
ignore:
    read 
    cmp al,0dh     ;if enter, return
    je leave           
    cmp al,3dh     ;if '=', change flag and return
    je stop  
    cmp al,20h     ;if space, print space and continue
    je valid
    cmp al,30h
    jl ignore
    cmp al,39h    
    jle valid1   ;if number,store in memory,print and continue
    cmp al,41h
    jl ignore
    cmp al,5ah
    jle valid2  ;if capital,store in memory,print and continue
    cmp al,61h
    jl ignore
    cmp al,7ah
    jg ignore  
valid3:        ;if lower-case,store in memory,print and continue
    mov di,1800h ;[1800h] is counter of lower-case letters given
    mov bl,[di]
    add bl,01h  ;every time we increase it by one and store it again
    mov [di],bl
    print al  ;print char
    push bx
    add bx,1800h ;find address 1800h+counter
    mov di,bx  
    pop bx
    mov [di],al ;store char in[1800h+counter]
    loop ignore
    jmp leave 
valid2:  
    mov di,1820h ;[1820h] is counter of upper-case letters given
    mov bl,[di]
    add bl,01h ;every time we increase it by one and store it again
    mov [di],bl
    print al  ;print char
    push bx
    add bx,1820h ;find address 1820h+counter
    mov di,bx  
    pop bx
    mov [di],al ;store char in[1820h+counter]
    loop ignore
    jmp leave 
valid1: 
    mov di,1860h 
    mov bl,[di]
    cmp bl,al ;if current>max, max=current
    jg move_on
    mov [di],al 
move_on:
    mov di,1840h ;[1840h] is counter of numbers given
    mov bl,[di]
    add bl,01h ;every time we increase it by one and store it again
    mov [di],bl 
    print al ;print num      
    push bx
    add bx,1840h ;find address 1840h+counter 
    mov di,bx  
    pop bx
    mov [di],al ;store char in[1840h+counter]
    loop ignore
    jmp leave    
valid:
    print " "  ;print space if given
    loop ignore 
    jmp leave
stop:
    mov bh,01h ;flag set
leave:  
       ret
input endp  


code ends
end START
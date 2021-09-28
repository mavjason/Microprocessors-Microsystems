
;****** Define Macros *******

READ MACRO      ;Read character from keyboard
    MOV AH, 8   ;The ASCII code of the character is
    INT 21H     ;stored in register AL
ENDM

PRINT MACRO CHAR    ;Print character CHAR
    MOV DL, CHAR
    MOV AH, 2
    INT 21H
ENDM  

PRINT_STR MACRO STRING      ;Print a sequence of characters
    MOV DX, OFFSET STRING
    MOV AH, 9
    INT 21H
ENDM    

EXIT MACRO          ;Exit program
    MOV AX, 4C00H
    INT 21H
ENDM    

;*****************************

DATA_SEG    SEGMENT
    MSG1    DB  0AH, 0DH, 'GIVE 2 DECIMAL DIGITS:$'
    MSG2    DB  0AH, 0DH, 'OCTAL= $'
DATA_SEG    ENDS

CODE_SEG    SEGMENT
    ASSUME  CS:CODE_SEG, DS:DATA_SEG
    
MAIN    PROC    FAR
    MOV AX, DATA_SEG
    MOV DS, AX        
START:  
    PRINT_STR MSG1
    MOV CL, 0           ;Counter of the decimal digits inserted
LOOP1:
    CALL DEC_KEYB       ;Read one decimal digit
    CMP AL, 'Q'         ;If 'Q' was pressed exit program
    JE QUIT
    CMP AL, 0DH         ;If '/n' was pressed check counter
    JE CHECK
    INC CL              ;Otherwise increase counter
    MOV BH, BL          ;Store the last two decimal digits in
    MOV BL, AL          ;registers BH and BL respectively 
    JMP LOOP1           ;Continue read process

CHECK:                  
    CMP CL, 02H         ;Check if at least 2 decimal digits have
    JGE NEXT            ;already been inserted
    JMP LOOP1           ;If yes go on, otherwise continue reading
    
NEXT:
    MOV AL, BH          ;Create hex number from decimal
    ROL BH, 3           ;BH = 8 * first_digit 
    ADD BH, AL          ;Add two more times BH to the result so
    ADD BH, AL          ;that BH = 10 * first_digit
    ADD BH, BL          ;BH = 10 * first_digit + second_digit
    
    PRINT_STR MSG2
    MOV CL, BH          ;Copy BH to CL
    AND BH, 00C0H       ;Isolate 2 MSBs of BH
    ROL BH, 2           ;Rotate them to become 2 LSBs
    ADD BH, 30H         ;Create ASCII code of the number
    PRINT BH            ;Display MSB octal digit
    
    MOV BH, CL          ;Restore initial value of BH
    AND BH, 38H         ;Isolate bytes 4-6
    ROR BH, 3           ;Rotate them to become LSBs
    ADD BH, 30H         ;Create ASCII code of the number
    PRINT BH            ;Display middle octal digit
    
    AND CL, 07H         ;Isolate 3 LSBs
    ADD CL, 30H         ;Create ASCII code of the number
    PRINT CL            ;Display LSB octal digit
    
    JMP START           ;Loop forever
             

QUIT:
    EXIT
MAIN    ENDP    
       

DEC_KEYB    PROC    NEAR
    PUSH DX
IGNORE:
    READ
    CMP AL, 'Q'
    JE RETURN
    CMP AL, 0DH
    JE RETURN
    CMP AL, 30H
    JL IGNORE
    CMP AL, 39H
    JG IGNORE
    PUSH AX
    PRINT AL
    POP AX
    SUB AL, 30H
RETURN:
    POP DX
    RET
DEC_KEYB    ENDP  

CODE_SEG    ENDS
            END MAIN





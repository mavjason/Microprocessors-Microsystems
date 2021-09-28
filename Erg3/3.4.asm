include macros.txt


CODE_SEG    SEGMENT
    ASSUME  CS:CODE_SEG, DS:DATA_SEG
    
MAIN    PROC    FAR      
START:     
    MOV SI, 1844H       ;Store in address 1844H a flag
    MOV [SI],00H        ;flag=0 => 1st call of READ_NUMBER routine
                        ;flag=1 => 2nd call of READ_NUMBER routine
    CALL READ_NUMBER    ;Read first decimal number
    CMP AL, "Q"         ;Check if abort button was pressed
    JE QUIT             ;If yes end program
CONTINUE:
    PUSH AX             ;Save operator to stack
    PRINT AL            ;Print operator    
    
    MOV SI, 1840H       ;Source address
    MOV DI, 183DH       ;Destnation address
    MOV CX, 03H
COPY:                   ;Copy 3 decimal digits from memory
    MOV AL, [SI]        ;addresses 1840-1842H to addresses
    MOV [DI], AL        ;183D-183FH
    INC SI
    INC DI
    LOOP COPY
    MOV SI, 1844H       ;Chnage flag in memory address 1844H
    MOV [SI], 01H       ;to prepare for second call of READ_NUMBER routine
    CALL READ_NUMBER    ;Read second decimal number
    CMP AL, "Q"         ;Check again if abort button was pressed
    JE QUIT             ;If yes end program
    PRINT AL            ;Print "=" which is stored in AL register
                        ;after return from READ_NUMBER routine
    POP AX              ;Restore operator in AL register
    CMP AL, "+"         ;Check which operator was pressed 
    JNE SUBTRACT
;ADD
    MOV SI,183DH        ;Start address of first decimal number
    CALL CREATE_HEX     ;Convert first decimal number to hex
    MOV BX, AX          ;Save first hex number to BX register
    
    MOV SI, 1840H       ;Start address of second decimal number
    CALL CREATE_HEX     ;Convert second decimal number to hex
    ADD AX, BX          ;Add the two hex numbers
    
    JMP DISPLAY_RESULT
    
SUBTRACT:
    MOV SI,183DH
    CALL CREATE_HEX
    MOV BX, AX
    MOV SI, 1840H
    CALL CREATE_HEX
    SUB BX, AX
    MOV AX, BX          ;Subtract the two hex numbers
    
DISPLAY_RESULT:
    ROL AX, 1           ;Check if result is positive or negative
    JNC  POSITIVE
    PUSH AX
    PRINT "-"           ;If negative print "-" and take 2's
    POP AX              ;complement
    ROR AX, 1
    NOT AX
    ADD AX, 0001H
    
    MOV SI, 1845H       ;Store in memory address 1845H a flag
    MOV [SI], 01H       ;Flag = 1 means negative number
    
    JMP PRINT_NUMBER
POSITIVE: 
    ROR AX, 1           ;Rotate rigth to restore the result
    MOV SI, 1845H
    MOV [SI], 00H       ;Flag = 0 means positive number
PRINT_NUMBER:    
    CALL PRINT_HEX      ;Print the result as a hex number
    PUSH AX
    PRINT "="           ;Print "="
    POP AX
    CALL CREATE_DECIMAL ;Print the result as a decimal number  
    PRINT 0DH           ;Newline
    PRINT 0AH
    JMP START           ;Start again
    
QUIT:
    EXIT
MAIN    ENDP
    


READ_NUMBER    PROC  NEAR ;This procedure reads a 3-digit decimal
    PUSH DX               ;number and stores it in memory addresses
    PUSH CX               ;1840h-1842h
    PUSH SI 
    MOV SI, 1840H         ;Clean memory
    MOV [SI] ,00H
    INC SI
    MOV [SI], 00H
    INC SI
    MOV [SI], 00H
    MOV CL, 00H    
IGNORE:
    READ                    ;Read a character from keyboard
    CMP AL, 'Q'             ;If "Q" was pressed return
    JE RETURN  
    CMP AL, "+"             ;If "+" was pressed check
    JE CHECK_OPERATOR
    CMP AL, "-"             ;If "-" was pressed check
    JE CHECK_OPERATOR
    CMP AL, "="             ;If "=" was pressed check
    JE CHECK_FOR_EQUAL
    CMP AL, 30H
    JL IGNORE
    CMP AL, 39H
    JG IGNORE    
    CMP CL, 03H             ;If already 3 digits have been pressed
    JGE IGNORE              ;ignore current digit
    JMP NEXT                ;If it is a valid digit continue
    
CHECK_OPERATOR: 
    PUSH SI                 ;Save SI to stack
    MOV SI,1844H            ;Check flag if it is the first call
    MOV DH, [SI]            ;of the routine
    POP SI      
    CMP DH, 00H
    JNE IGNORE              ;If no ignore character
    CMP CL, 01H             ;Else if at least one digit has already
    JL IGNORE               ;been pressed return
    JMP RETURN
    
CHECK_FOR_EQUAL:
    PUSH SI                 ;Save SI to stack
    MOV SI, 1844H           ;Check flag if it is the second call
    MOV DH, [SI]            ;of the routine
    POP SI
    CMP DH, 01H
    JNE IGNORE              ;If no ignore character "="
    CMP CL, 01H             ;Else if at least one digit has already
    JL IGNORE               ;been pressed return
    JMP RETURN
    
NEXT:                       ;If we have a valid digit
    PUSH AX
    PRINT AL                ;Print current digit
    POP AX
    SUB AL, 30H             ;Convert from ASCII code to its value
    MOV SI, 1841H           ;Shift the values stored in memory
    MOV DI, 1840H           ;addresses 1840-1842H 1 position left
    MOV DH, [SI]
    MOV [DI], DH
    INC DI
    INC SI      
    MOV DH, [SI]
    MOV [DI], DH
    MOV SI, 1842H           ;Save current digit in memory address
    MOV [SI], AL            ;AL
    INC CL                  ;Increse counter for digits inserted
    JMP IGNORE
RETURN:
    POP SI
    POP CX
    POP DX
    RET
READ_NUMBER    ENDP  


CREATE_HEX      PROC    NEAR    ;This procedure converts a 3-digit
                                ;decimal number which is stored in
    PUSH BX                     ;memory starting from address 1840H
    PUSH CX                     ;to a hex number which is contained
                                ;in AX registe
    
    MOV AL, [SI]                ;AL = MSD
    MOV AH, 00H                 
    ROL AX, 6                   ;AX = 64 * MSD
    MOV BL, [SI]                ;BL = MSD
    MOV BH, 00H
    ROL BX, 5                   ;BX = 32 * MSD
    MOV CL, [SI]                ;CL = MSD
    MOV CH, 00H
    ROL CX, 2                   ;CX = 4 * MSD
    ADD AX, BX
    ADD AX, CX                  ;AX = 100 * MSD
    INC SI
    MOV BH, [SI]                ;BH = Second MSD
    ROL BH, 3                   ;BH = 8 * Second MSD
    MOV BL, [SI]                ;BL = Second MSD
    ROL BL, 1                   ;BL = 2 * Second MSD
    ADD BL, BH
    MOV BH, 00H                 ;BX = 10 * Second MSD
    INC SI
    MOV CL, [SI]    
    MOV CH, 00H                 ;CX = LSD
    ADD AX, BX
    ADD AX, CX                  ;AX holds the hex number  
    POP CX
    POP BX
    RET
CREATE_HEX  ENDP 

PRINT_HEX       PROC    NEAR    ;This procedure takes a 16bit hex
                                ;number contained in BX register                                
    MOV BH, AH                  ;and prints it
    AND BH, 0FH                 ;Isolate MSD
    JZ NEXT_DIGIT1
    CALL PRINT_DIGIT            ;If MSD != 0 print it
NEXT_DIGIT1:
    MOV BH, AL                  
    AND BH, 00F0H               ;Isolate second MSD
    ROR BH, 4
    JNZ PRINT_DIG1              ;If second MSD != 0 print it
    MOV CL, AH                  ;Else check if MSD was 0
    AND CL, 0FH
    CMP CL, 00H
    JZ NEXT_DIGIT2              ;If both are zero continue to next 
PRINT_DIG1:    
    CALL PRINT_DIGIT            ;Otherwise print it
NEXT_DIGIT2:
    MOV BH, AL                  ;Isolate LSD
    AND BH, 0FH
    CALL PRINT_DIGIT            ;Print LSD
    RET
PRINT_HEX   ENDP

PRINT_DIGIT     PROC    NEAR    ;This procedure takes a digit
    CMP BH, 09H                 ;contained in BH register and
    JG ADDR1                    ;prints it
    ADD BH, 30H                 ;If digit is 0-9
    JMP ADDR2
ADDR1:
    ADD BH, 37H                 ;If digit is A-F
ADDR2:
    PUSH AX
    PRINT BH
    POP AX
    RET
PRINT_DIGIT ENDP      

CREATE_DECIMAL      PROC    NEAR 
                                ;This procedure converts a hex
    MOV SI, 1845H               ;number stored in AX register 
    MOV CL, [SI]                ;to decimal and prints it
    CMP CL, 00H                 ;Check flag to check if number
    JZ POS                      ;is positive or negative
    PUSH AX
    PRINT "-"                   ;If negative print "-"
    POP AX
POS:   
    MOV BL, 00FFH               ;Counter of thousands
THND:
    INC BL                      ;Increase thousands
    SUB AX, 03E8H               ;AX <= AX - 1000(10)
    CMP AX, 0000H
    JGE THND                    ;If still positive loop
    ADD AX, 03E8H               ;Else add 1 thousand to become
                                ;again positive and continue
    MOV CL, 00FFH               ;Counter of hundreds
HUND:
    INC CL                      ;Increase hundreds
    SUB AX, 0064H               ;AX <= AX - 100(10)
    CMP AX, 0000H
    JGE HUND                    ;If still positive loop
    ADD AX, 0064H               ;Else add 1 hundred to become
                                ;again positive and continue
    MOV CH, 00FFH               ;Counter of tens
DECA:
    INC CH                      ;Increase tens
    SUB AX, 000AH               ;AX = AX - 10(10)
    CMP AX, 0000H               ;If still positive loop
    JGE DECA                    ;Else add 1 ten to become
    ADD AX, 000AH               ;again positive and continue
                                
    CMP BL, 00H                 ;Check thousands
    JZ NEXT_DIGIT3              ;If thousands = 0 continue to next
                                ;digit
    MOV BH, BL                  ;Else print thousands
    CALL PRINT_DIGIT

NEXT_DIGIT3:     
    MOV BH, CL                  ;Check hundreds
    CMP CL, 00H                 ;If hundreds = 0 check thousands
    JNE PRINT_DIG2              ;If hundreds != 0 print them
    CMP BL, 00H                 ;If both 0 continue to next digit
    JZ NEXT_DIGIT4
PRINT_DIG2:    
    CALL PRINT_DIGIT

NEXT_DIGIT4:    
    MOV BH, CH                  ;Check tens
    CMP CH, 00H                 ;If tens = 0 check thousands and hundreds
    JNE PRINT_DIG3              ;If all 0 continue to next digit
    CMP CL, 00H                 ;Else print tens
    JNE PRINT_DIG3
    CMP BL, 00H
    JZ NEXT_DIGIT5
PRINT_DIG3:    
    CALL PRINT_DIGIT

NEXT_DIGIT5:    
    MOV BH, AL                  ;Print units
    CALL PRINT_DIGIT
    RET
CREATE_DECIMAL  ENDP    
     
        
CODE_SEG    ENDS
            END MAIN
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
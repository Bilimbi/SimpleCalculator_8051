    LJMP START
    ORG 100H ; Jump over debuger to the start of the program
START:
    LCALL LCD_INIT

MAIN_LOOP:
	MOV SP,#60H ; Set stack adress to the 60H

    LCALL LCD_CLR

    MOV R0, #30H ; Point R0 to the first number storage location
    LCALL GET_NUM ; Get the first number (stored in R0)
    MOV R0, #30H 
    LCALL BCD_HEX ; Convert the first number to hex

    ; Store the first number on the stack
    PUSH 31H ; [STACK] <- First num high byte
    PUSH 30H ; [STACK] <- First num low byte

    ; Get the operation
    LCALL WAIT_KEY
    CJNE A, #10, CHECK_SUB
    SJMP ADD_FUNC

CHECK_SUB:
    CJNE A, #11, CHECK_MUL
    SJMP SUB_FUNC

CHECK_MUL:
    CJNE A, #12, CHECK_DIV
    SJMP MUL_FUNC
    
CHECK_DIV:
    CJNE A, #13, WRONG_OP
    SJMP DIV_FUNC

; --------------------------------------------------
; \/ Operations \/
; --------------------------------------------------

ADD_FUNC: ; Addition Function "A"
    MOV A, #'+'
    LCALL WRITE_DATA

    MOV R0, #30H 
    LCALL GET_NUM ; Get the second number   
    MOV R0, #30H
    LCALL BCD_HEX

    MOV A, #'='
    LCALL WRITE_DATA

    POP 33H ; First num low byte <- [STACK]
    POP 32H ; First num high byte <- [STACK]

; --------------------------------------------------
; First number popped into 33H=LOW, 32H=HIGH
; Second number is currently in 30H=LOW, 31H=HIGH
; --------------------------------------------------

    ; Add the low bytes  
    MOV A, 30H           
    ADD A, 33H       
    MOV 30H, A 

    ; Add the high bytes with carry from the low byte addition
    MOV A, 31H   
    ADDC A, 32H       
    MOV 31H, A  

    ; Convert the result back to BCD
    MOV R0, #30H        
    LCALL HEX_BCD        
    
    ; Display the result 
    MOV A, 32H
    LCALL WRITE_HEX
    MOV A, 31H
    LCALL WRITE_HEX      
    MOV A, 30H
    LCALL WRITE_HEX

    SJMP STOP
    
SUB_FUNC: ; Substraction Function "B"
    SJMP STOP

MUL_FUNC: ; Multiplication Function "C"
    SJMP STOP

DIV_FUNC: ; Division Function "D"
    SJMP STOP

WRONG_OP: ; Wrong operation key
    LJMP MAIN_LOOP

STOP:
    SJMP $ ; Stopping the program
    NOP ; No operation for the program counter
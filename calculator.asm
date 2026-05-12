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
    LJMP ADD_FUNC

CHECK_SUB:
    CJNE A, #11, CHECK_MUL
    LJMP SUB_FUNC

CHECK_MUL:
    CJNE A, #12, CHECK_DIV
    LJMP MUL_FUNC
    
CHECK_DIV:
    CJNE A, #13, CHECK_DIV_NOT
    LJMP DIV_FUNC
CHECK_DIV_NOT:
    LJMP WRONG_OP

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

    ; ----------------------------------------------
    ; First number popped into 33H=LOW, 32H=HIGH
    ; Second number is currently in 30H=LOW, 31H=HIGH
    ; ----------------------------------------------

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
    MOV A, 32H ; Highest byte (carry)
    LCALL WRITE_HEX
    MOV A, 31H ; High byte
    LCALL WRITE_HEX      
    MOV A, 30H ; Low byte
    LCALL WRITE_HEX

    LJMP NEXT_OP
    
SUB_FUNC: ; Substraction Function "B"
    MOV A, #'-'
    LCALL WRITE_DATA

    MOV R0, #30H 
    LCALL GET_NUM ; Get the second number   
    MOV R0, #30H
    LCALL BCD_HEX

    MOV A, #'='
    LCALL WRITE_DATA

    POP 33H ; First num low byte <- [STACK]
    POP 32H ; First num high byte <- [STACK]

    ; Subtract the low bytes
    MOV A, 33H
    CLR C ; Clear carry for subtraction
    SUBB A, 30H
    MOV 30H, A

    ; Subtract the high bytes with borrow from the low byte subtraction
    MOV A, 32H
    SUBB A, 31H
    MOV 31H, A

    JNC SUB_POS ; If no borrow, the result is positive or zero

    ; Negative result handling
    MOV A, 30H
    CPL A
    MOV 30H, A ; Invert the low byte
    MOV A, 31H
    CPL A
    MOV 31H, A ; Invert the high byte

    INC 30H ; +1 on low byte
    JNZ SUB_MAG_OK ; If low byte is not zero after increment, skip the carry
    INC 31H ; propagate carry to high byte if low byte was zero

SUB_MAG_OK:

    MOV R0, #30H
    LCALL HEX_BCD ; Convert the magnitude of the result to BCD

    MOV A, #'-'
    LCALL WRITE_DATA ; Display the negative sign

    MOV A, 32H 
    ANL A, #0FH ; Keep only the lowest BCD digit
    ADD A, #'0'
    LCALL WRITE_DATA

    MOV A, 31H
    LCALL WRITE_HEX
    MOV A, 30H
    LCALL WRITE_HEX

    LJMP NEXT_OP

SUB_POS: ; Positive or '0' result from subtraction
    ; Convert the result back to BCD
    MOV R0, #30H        
    LCALL HEX_BCD        
    
    ; Display the result
    MOV A, 31H ; High byte
    LCALL WRITE_HEX      
    MOV A, 30H ; Low byte
    LCALL WRITE_HEX

    LJMP NEXT_OP

MUL_FUNC: ; Multiplication Function "C"
    MOV A, #'*'
    LCALL WRITE_DATA

    MOV R0, #30H 
    LCALL GET_NUM ; Get the second number   
    MOV R0, #30H
    LCALL BCD_HEX

    MOV A, #'='
    LCALL WRITE_DATA

    POP 33H ; First num low byte <- [STACK]
    POP 32H ; First num high byte <- [STACK]

    ; ----------------------------------------------
    ; Multiplicand = @R0 (30H=LOW,31H=HIGH), 
    ; Multiplier = B,A (B=HIGH,A=LOW)
    ; ----------------------------------------------

    MOV A, 33H
    MOV B, 32H
    MOV R0, #30H
    LCALL MUL_2_2

    ; Result (in hexadecimal) is 4 bytes at 30H - 33H
    MOV A, 33H
    LCALL WRITE_HEX
    MOV A, 32H
    LCALL WRITE_HEX
    MOV A, 31H
    LCALL WRITE_HEX
    MOV A, 30H
    LCALL WRITE_HEX

    LJMP NEXT_OP

DIV_FUNC: ; Division Function "D"
    MOV A, #'/'
    LCALL WRITE_DATA

    MOV R0, #36H 
    LCALL GET_NUM ; Get the second number   
    MOV R0, #36H
    LCALL BCD_HEX

    MOV A, #'='
    LCALL WRITE_DATA

    POP 35H ; First num low byte <- [STACK]
    POP 34H ; First num high byte <- [STACK]

    ; ----------------------------------------------
    ; Dividend = @R0 (36H=HIGHEST,37H=LOWEST),
    ; Divisor = B,A (B=HIGH,A=LOW)
    ; ----------------------------------------------

    MOV A, 36H ; Divisor low byte
    MOV B, 37H ; Divisor high byte

    MOV 30H, 35H ; Dividend low byte
    MOV 31H, 34H ; Dividend high byte
    ; Zero 2 higher bytes \/
    MOV 32H, #00H 
    MOV 33H, #00H

    MOV R0, #30H
    LCALL DIV_4_2

    ; Convert the result back to BCD
    MOV R0, #30H        
    LCALL HEX_BCD ; Quotient
    MOV R0, #34H
    LCALL HEX_BCD ; Remainder
    MOV R0, #36H
    LCALL HEX_BCD ; Divisor (the second number)

    ; Display the result 
    MOV A, 31H ; High byte
    LCALL WRITE_HEX      
    MOV A, 30H ; Low byte
    LCALL WRITE_HEX

    MOV A, #' '
    LCALL WRITE_DATA
    MOV A, 35H ; Remainder high byte
    LCALL WRITE_HEX
    MOV A, 34H ; Remainder low byte
    LCALL WRITE_HEX

    SJMP NEXT_OP

WRONG_OP: ; Wrong operation key
    LJMP MAIN_LOOP

NEXT_OP:
    LCALL WAIT_ENT_ESC ; Wait for the user to press "Enter" or "Escape"
    LJMP MAIN_LOOP

STOP:
    SJMP $ ; Stopping the program
    NOP ; No operation for the program counter
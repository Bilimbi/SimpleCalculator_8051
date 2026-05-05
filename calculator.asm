    LJMP START
    ORG 100H ; Jump over debuger to the start of the program
START:
    LCALL LCD_CLR
	MOV SP,#60H ; Set stack adress to the 60H

    ; Get the first number
    LCALL WAIT_KEY
    PUSH ACC ; Store the first number on the stack
    LCALL WRITE_HEX

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
    CJNE A, #13, STOP
    SJMP DIV_FUNC

; \/ Operations \/ ---------------------------

ADD_FUNC: ; Addition Function "A"
    MOV A, #'+'
    LCALL WRITE_DATA

    LCALL WAIT_KEY
    MOV R0, A ; Store the second number in R0
    LCALL WRITE_HEX ; Display the second number

    MOV A, #'='
    LCALL WRITE_DATA

    POP ACC ; Get the first number from the stack
    ADD A, R0 ; Add the two numbers
    LCALL WRITE_HEX
    
    SJMP STOP ; Jump to the end of the program
    
SUB_FUNC: ; Substraction Function "B"
    SJMP STOP

MUL_FUNC: ; Multiplication Function "C"
    SJMP STOP

DIV_FUNC: ; Division Function "D"
    SJMP STOP

STOP:
    SJMP $ ; Stopping the program
    NOP ; No operation for the program counter
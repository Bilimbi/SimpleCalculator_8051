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

; \/ Operations \/ ---------------------------

ADD_FUNC: ; Addition Function 

SUB_FUNC: ; Substraction Function

MUL_FUNC: ; Multiplication Function

DIV_FUNC: ; Division Function

STOP:
    SJMP $ ; Stopping the program
    NOP ; No operation for the program counter
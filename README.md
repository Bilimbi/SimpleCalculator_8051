# SimpleCalculator_8051
A simple calculator program written in assembly for the Intel 8051 microprocessors. A project for the University.

# How to use:
This calculator can add, subtract, multiply and divide 4-digit decimal numbers. You need an Intel 8051 microcontroller or a emulator program (DSM-51 or similar) to use the .hex file.
 - Write the first number with 4 digits and leading zeroes, then press enter ("E"). Examples: 0001, 0067, 0394, 6793.
 - Choose the desired operation by pressing: "A" for addition, "B" for subtraction, "C" for multiplication and "D" for division. (You don't need to press enter here).
 - Write the second number like before, with 4 digits and leading zeroes, then press enter ("E").
 - After getting the result, press enter ("E") to reset the screen and start another calculation.

# Examples:
 - 0067+3336=003403, (result in DEC)
 - 0473-2694=-02221, (result in DEC with a sign)
 - 4571*0064=000476C0, (result in HEX)
 - 9846/2310=0004 0606, (result in DEC with the remainder)

# RISC-V Computer

This project is an implementation of a RISC-V CPU core on an FPGA. It is a work in progress.
The processor will be of my own design, and will be run on a DE1-SoC. The end goal will to have all instructions in the RV32I instruction set implemented in the processor, such that a standard RISC-V compiler may be used to compile code that can be directly run on this custom processor. 

As of June 16, 2025, all RV32I base integer instructions have been successfully implemented (except environment call/break instructions). Furthermore, basic C programs have been compiled using the standard RISC-V GCC compiler for 32-bit systems, along with a custom linker script and start assembly program. C programs that allow for user control of the switches on the DE1 board to control some LEDs and printing colourful stripes on a VGA monitor have been implemented to date. Currently in progress is the addition of an external LCD controller, allowing for C programs to write text out. In the near future, I plan to implement the following:
- PS/2 keyboard
- High-precision hardware timers
- SPI controller for external connection to flash IC
- I2C controller for external connection to an EEPROM and an ADC connected to various sensors
- UART controller for serial communication with a terminal

The end goal of this project is to run DOOM (1993) for my Dad to play, for the first time since the game was initially released.

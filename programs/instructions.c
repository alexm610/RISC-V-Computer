#include "instructions.h"

int main (void) {
    char *message = "hello";
    long address = (long) message;
    Initialize_LCD();
    LCD_char('h');
    LCD_char('e');
    LCD_char('l');
    LCD_char('l');
    LCD_char('o');

    LCD_Command_Register = (char)(0xC0);
    Wait3ms();
    HEX = address;
    LCD_char(*message);
    message++;
    LCD_char(*message);

    

    
    //LCD_line0(message);
    //char *message = "hello world";
    //char c = *(message + 4);
    //LCD_Data_Register = (char)(c);
    //HEX = c;
    //Wait3ms();
    
    //LCD_char(0x48);
    //LCD_char(0x45


    //HEX = RS232_Status;
    //_putch(104); // h
    /*_putch(101); // e
    _putch(108); // l
    _putch(108); // l
    _putch(111); // o
    _putch(32);  // <space>
    _putch(119); // w
    _putch(111); // o
    _putch(114); // r
    _putch(108); // l
    _putch(100); // d
    _putch(10);  // <new line, carriage return>
    */
    print_stripes();
    while (1) {
        LEDR = SWITCHES;
        //HEX = SWITCHES;
    }
}
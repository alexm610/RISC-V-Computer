#include "instructions.h"

void Wait1ms(void) {
    long int i;
    
    for (i=0; i<1000; i++) {
        ;
    }
}

void Wait3ms(void) {
    int i;

    for (i=0; i<3; i++) {
        Wait1ms();
    }
}

void Initialize_LCD(void) {
    //LCD_Command_Register = (char)(0x0C);
    //Wait3ms();
    //LCD_Command_Register = (char)(0x0E);
    //Wait3ms();
    //LCD_Command_Register = (char)(0x06);
    //Wait3ms();
    LCD_Command_Register = (char)(0x0F); // Display on ; cursor on; blinking on;
    Wait3ms();
    LCD_Command_Register = (char)(0x3C); // data length = 8 bit; two-line display; 5 x 10 dots character font
    Wait3ms();
    LCD_Command_Register = (char)(0x01); // clear display;
    Wait3ms();

}

void LCD_char(char c) {
    LCD_Data_Register = (char)(c);
    Wait3ms();
}

void LCD_message(char *message) {
	char c;
    while ((c = *message++) != (char)(0)) {
        LCD_char(c);
    }
}

void LCD_clear(void) {
    int i;

    for (i=0; i<16; i++) {
        LCD_char(32);
    }
}

void LCD_line0(char *message) {
    LCD_Command_Register = (char)(0x80);
    Wait3ms();
    LCD_clear();
    LCD_Command_Register = (char)(0x80);
    Wait3ms();
    LCD_message(message);
}

void LCD_line1(char *message) {
    LCD_Command_Register = (char)(0xC0);
    Wait3ms();
    LCD_clear();
    LCD_Command_Register = (char)(0xC0);
    Wait3ms();
    LCD_message(message);
}


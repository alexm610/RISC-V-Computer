#define VGA                     *(volatile unsigned long *)(0x04010000)
#define SWITCHES                *(volatile unsigned long *)(0x04000000)
#define LEDR                    *(volatile unsigned long *)(0x04000004)
#define HEX                     *(volatile unsigned long *)(0x04000008)
#define LCD_Command_Register    *(volatile unsigned long *)(0x0400000C)
#define LCD_Data_Register       *(volatile unsigned long *)(0x04000010)

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
    LCD_Command_Register = (char)(0x0C);
    Wait3ms();
    LCD_Command_Register = (char)(0x38);
    Wait3ms();
}

void LCD_char(int c) {
    LCD_Data_Register = (char)(c);
    Wait1ms();
}

void LCD_message(char *message) {
    char c;
    while ((c = *message++) != (char)(0)) {
        LCD_char(c);
    }
}

void LCD_clear(void) {
    unsigned char i;

    for (i=0; i<16; i++) {
        LCD_char(' ');
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

int main (void) {
    int x, y, colour;

    colour = 0;
    for (y=0; y<120; y++) {
        for (x=0; x<160; x++) {
            VGA |= (y << 24) | (x << 16) | colour;
            colour++;
        }
    }

    LCD_line0("Alex");
    LCD_line1("Hel");

    while (1) {
        LEDR = SWITCHES;
        HEX = SWITCHES;
    }
}
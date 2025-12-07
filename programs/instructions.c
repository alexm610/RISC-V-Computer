#include "instructions.h"

int main (void) {
    int line_index = 0;
    char *message1 = "Hello Somya,";
    
    Initialize_LCD();

    LCD_line0(message1);
    LCD_line1("I love you!");
    
    Timer0_Data_Register = (0xFFFFFFFF);
    Timer0_Control_Register = (0x00000003);
    print_stripes();
    while (1) {
        HEX = Timer0_Data_Register;
        LEDR = SWITCHES;
    }
}
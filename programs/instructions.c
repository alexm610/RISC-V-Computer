#include "instructions.h"

int main (void) {
    int line_index = 0;
    char *message1 = "Hello Somya,";
    
    Initialize_LCD();

    LCD_line0(message1);
    LCD_line1("I love you!");
        
    print_stripes();
    while (1) {
        LEDR = SWITCHES;
        HEX = SWITCHES;
    }
}
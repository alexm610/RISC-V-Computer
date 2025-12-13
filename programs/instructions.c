#include <stdint.h>
#include "instructions.h"
#include "vga.h"
#include "rs232.h"
#include "lcd_display.h"

extern volatile uint32_t timer_ticks;

int main(void) {
    char *message1 = "Hello Somya,";

    Initialize_LCD();
    LCD_line0(message1);
    LCD_line1("I love you!");

    timer_ticks = 0;
    Timer0_Data_Register = 0x02FAF080;
    Timer0_Control_Register = 0x00000003;


    print_stripes();
    while (1) {
        HEX = timer_ticks;
        LEDR = SWITCHES;
    }
}

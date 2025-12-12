#include "instructions.h"
#include <stdint.h>

volatile uint32_t timer_ticks = 0;

void timer_isr (void) {
    timer_ticks++;
    Timer0_Control_Register = 0x00000003;
}

void trap_handler (void) {
    //timer_isr();
    
    timer_ticks++;
    Timer0_Control_Register = 0x00000003;
}

int main (void) {
    char *message1 = "Hello Somya,";
    
    Initialize_LCD();
    LCD_line0(message1);
    LCD_line1("I love you!");
//
//
    timer_ticks = 0;
    Timer0_Data_Register = (0x02FAF080);
    Timer0_Control_Register = (0x00000003);
    
    print_stripes();
    while (1) {
        HEX = timer_ticks;
        LEDR = SWITCHES;
    }
}
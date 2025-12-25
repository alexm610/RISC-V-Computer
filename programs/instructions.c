//#include <stdint.h>
#include "instructions.h"
#include "vga.h"
#include "rs232.h"
#include "lcd_display.h"
#include "kstdio.h"

extern volatile uint32_t timer_ticks;

int main(void) {
    char *message1 = "Hello dearest,";
    char *message2 = "you almost home!";

    //rs232_init();
    //uart_puts_crlf("Hello Somya\n");
    //kprintf("Hello world!\n");
    Initialize_LCD();



    LCD_line0(message1);
    LCD_line1(message2);


    timer_ticks = 0;
    Timer0_Data_Register = 0x02FAF080;
    Timer0_Control_Register = 0x00000003;
    //uint8_t c = 'z';
    print_stripes();

    //kprintf("Enter a number: ");
    //c = kgetint();
    //kprintf("You entered: %d (0x%x)\n", c);
    while (1) {
        //HEX = timer_ticks;
        LEDR = SWITCHES;
        //c = rs232_getch_nb();
        
    }
}

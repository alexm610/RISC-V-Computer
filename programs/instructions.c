//#include <stdint.h>
#include "instructions.h"
#include "vga.h"
#include "rs232.h"
#include "lcd_display.h"

extern volatile uint32_t timer_ticks;

int main(void) {
    char *message1 = "Hello dearest,";
    char *message2 = "you almost home!";

    //uart_init(UART0_BASE, 50000000u, 115200);
    //uart_puts_crlf(UART0_BASE, "Hello Somya\n");

    Initialize_LCD();



    LCD_line0(message1);
    LCD_line1(message2);


    timer_ticks = 0;
    Timer0_Data_Register = 0x02FAF080;
    Timer0_Control_Register = 0x00000003;

    print_stripes();
    while (1) {
        HEX = timer_ticks;
        LEDR = SWITCHES;

        //uint8_t c = uart_getc(UART0_BASE);
        //uart_putc(UART0_BASE, c);
    }
}

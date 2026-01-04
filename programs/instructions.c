#include <stdint.h>
#include "instructions.h"
#include "vga.h"
#include "lcd_display.h"
#include "uart.h"
extern volatile uint32_t timer_ticks;

int main(void) {
    char *message1 = "Hello Somya,";


    Initialize_LCD();
    //uart_clear_errors();
    LCD_line0(message1);
    LCD_line1("I love you!");



    char c = 'b';
    RS232_TxData = (char)(c);

    timer_ticks = 0;
    Timer0_Control_Register = 0x0;
    Timer0_Data_Register = 0x02FAF080;
    Timer0_Control_Register = 0x00000003;

    //uart_puts_crlf("Hello world!\n");
Init_RS232();
    print_stripes();
    while (1) {
        HEX = timer_ticks;

        LEDR = RS232_Status;
        

        c = _getch();
}
}

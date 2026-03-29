//#include <stdint.h>
#include "instructions.h"
#include "vga.h"
#include "lcd_display.h"
#include "uart.h"

#define BUFFER_MAX_LENGTH   32

extern volatile int timer_ticks;

int main(void) {
    char *message1 = "Hello dearest,";
    char *message2 = "you almost home!";
    char buf[32];

    Initialize_LCD();    
    FlushKeyboard();
    Init_RS232();
    
    LCD_line0(message1);
    LCD_line1(message2);

    timer_ticks = 0;
    Timer0_Control_Register = 0x0;
    Timer0_Data_Register = 0x017D7840;
    Timer0_Control_Register = 0x00000003;

    _puts("Enter your name: ");
    FlushKeyboard();
    _gets(buf, 32);              // blocks until user presses Enter
    _puts("Hello, ");
    _puts(buf);
    _puts("!\n");

    print_stripes();
    while (1) {
        HEX = timer_ticks;
        LEDR = SWITCHES;

        if (kbhit()) {
            char c = _getch();
            if (c == '\r') {
                _puts("\nYou pressed enter!\n");
            }
        }
    }
}

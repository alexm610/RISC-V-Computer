#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include "instructions.h"
#include "vga.h"
#include "lcd_display.h"
#include "uart.h"
#include "spi.h"
#include "framebuffer.h"

#define BUFFER_MAX_LENGTH 32

void Help(void)
{
    char *banner = "\r\n----------------------------------------------------------------" ;

    printf(banner) ;
    printf("\r\n    Debugger Command Summary") ;
    printf(banner) ;
    printf("\r\n    h               Help Menu");
    printf(banner) ;
}

void menu(void) {
    char c0, c1;
    while (1) {
        FlushKeyboard();
        printf("\r\n$ ");
        scanf("%c", &c0);

        switch (c0) {
            case 'c': 
                printf("\r\nCOLOUR!\n(b)lue or (r)ed or (g)reen?\r\n= ");
                scanf("%c", &c1);
                switch (c1) {
                    case 'b': 
                        fb_clear(FB_BLUE);
                        break;
                    case 'r': 
                        fb_clear(FB_RED);
                        break;
                    case 'g': 
                        fb_clear(FB_GREEN);
                        break;
                    default:
                        printf("\r\nInvalid choice.");
                        break;
                }
                break;
                
            case 'h':
                printf("\r\nYou asked for help!");
                break;
            
            default: 
                printf("\r\nUnknown command...\r\n");
                Help();
                break;
        }
    }
}

int main(void) {
    int read_byte;
    char *message1 = "Rip and tear,";
    char *message2 = "until it is done.";

    Initialize_LCD();
    Init_RS232();
    SPI_Init();

    LCD_line0(message1);
    LCD_line1(message2);

    Timer0_Control_Register = 0x0;
    Timer0_Data_Register    = 50000000;
    Timer0_Control_Register = 0x00000003;
    
    printf("\r\nWelcome to DOOM (%i)!\r\n", 1993);
    menu();

    return 0;
}

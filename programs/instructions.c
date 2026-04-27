#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include "instructions.h"
#include "vga.h"
#include "lcd_display.h"
#include "uart.h"

#define BUFFER_MAX_LENGTH 32

void Help(void)
{
    char *banner = "\r\n----------------------------------------------------------------" ;

    printf(banner) ;
    printf("\r\n  Debugger Command Summary") ;
    printf(banner) ;
    printf("\r\n  .(reg)       - Change Registers: e.g A0-A7,D0-D7,PC,SSP,USP,SR");
    printf("\r\n  BD/BS/BC/BK  - Break Point: Display/Set/Clear/Kill") ;
    printf("\r\n  C            - Copy Program from Flash to Main Memory") ;
    printf("\r\n  D            - Dump Memory Contents to Screen") ;
    printf("\r\n  E            - Enter String into Memory") ;
    printf("\r\n  F            - Fill Memory with Data") ;
    printf("\r\n  G            - Go Program Starting at Address:") ;
    printf("\r\n  L            - Load Program (.HEX file) from Laptop") ;
    printf("\r\n  M            - Memory Examine and Change");
    printf("\r\n  P            - Program Flash Memory with User Program") ;
    printf("\r\n  R            - Display 68000 Registers") ;
    printf("\r\n  S            - Toggle ON/OFF Single Step Mode") ;
    printf("\r\n  TM           - Test Memory") ;
    printf("\r\n  TS           - Test Switches: SW7-0") ;
    printf("\r\n  TD           - Test Displays: LEDs and 7-Segment") ;
    printf("\r\n  WD/WS/WC/WK  - Watch Point: Display/Set/Clear/Kill") ;
    printf(banner) ;
}

void menu(void) {
    char c0;
    while (1) {
        FlushKeyboard();
        printf("\r\n$ ");
        scanf("%c", &c0);

        switch (c0) {
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
    Initialize_LCD();
    Init_RS232();

    char *message1 = "Rip and tear,";
    char *message2 = "until it is done.";
    LCD_line0(message1);
    LCD_line1(message2);

    Timer0_Control_Register = 0x0;
    Timer0_Data_Register    = 50000000;
    Timer0_Control_Register = 0x00000003;

    printf("\r\nWelcome to DOOM (%i)!\r\n", 1993);
    menu();

    return 0;
}

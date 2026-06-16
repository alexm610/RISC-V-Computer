#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include "instructions.h"
#include "vga.h"
#include "lcd_display.h"
#include "uart.h"
#include "framebuffer.h"
#include "sd_spi.h"
#include "filesystem.h"

#define BUFFER_MAX_LENGTH 32

static void cmd_clear_colour(void) {
    char c1;
    printf("\r\nCOLOUR!\n(b)lue or (r)ed or (g)reen?\r\n= ");
    scanf("%c", &c1);
    switch (c1) {
        case 'b': fb_clear(FB_BLUE);  break;
        case 'r': fb_clear(FB_RED);   break;
        case 'g': fb_clear(FB_GREEN); break;
        default:  printf("\r\nInvalid choice."); break;
    }
}

void Help(void) {
    char *banner = "\r\n----------------------------------------------------------------";
    printf(banner);
    printf("\r\n    Debugger Command Summary");
    printf(banner);
    printf("\r\n    c   Clear framebuffer to a colour");
    printf("\r\n    m   Mount SD card");
    printf("\r\n    l   List files in root directory");
    printf("\r\n    b   Load and display a .bmp file");
    printf("\r\n    i   Show SD card info");
    printf("\r\n    d   Dump sector 0");
    printf("\r\n    h   Help menu");
    printf(banner);
}

void menu(void) {
    char c0;
    while (1) {
        FlushKeyboard();
        printf("\r\n$ ");
        scanf("%c", &c0);
        switch (c0) {
            case 'c': cmd_clear_colour(); break;
            case 'm': cmd_mount();        break;
            case 'i': cmd_card_info();    break;
            case 'l': cmd_list_dir();     break;
            case 'b': cmd_load_bmp();     break;
            case 'h': Help();             break;
            case 'd': cmd_dump_sector0(); break;
            default:
                printf("\r\nUnknown command...");
                Help();
                break;
        }
    }
}

int main(void) {
    char *message1 = "Rip and tear,";
    char *message2 = "until it is done.";

    Initialize_LCD();
    Init_RS232();
    LCD_line0(message1);
    LCD_line1(message2);

    Timer0_Control_Register = 0x0;
    Timer0_Data_Register    = 50000000;
    Timer0_Control_Register = 0x00000003;

    printf("\r\nWelcome to DOOM (1993)!\r\n");
    printf("\r\nInitializing SD card...");
    int sd_rc = sd_init();
    if (sd_rc != SD_OK) {
        printf("\r\nsd_init failed: %d", sd_rc);
        printf("\r\nCheck wiring, power, card insertion.");
        printf("\r\nContinuing with menu (use 'm' to retry).");
    } else {
        init_filesystem();
    }

    menu();
    return 0;
}

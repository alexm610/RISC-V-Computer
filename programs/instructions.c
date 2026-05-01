#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include "instructions.h"
#include "vga.h"
#include "lcd_display.h"
#include "uart.h"
#include "spi.h"

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
    SPI_Init();
    int read_byte;
    char *message1 = "Rip and tear,";
    char *message2 = "until it is done.";
    LCD_line0(message1);
    LCD_line1(message2);

    Timer0_Control_Register = 0x0;
    Timer0_Data_Register    = 50000000;
    Timer0_Control_Register = 0x00000003;
    
    
    printf("\r\nPERFORMING FLASH MEMORY TEST\n");
    printf("\r\nErasing flash chip...");
    read_byte = WriteSPIChar(0x06, 0);      // write enable
    read_byte = WriteSPIChar(0xC7, 0);      // erase chip
    ReadStatusRegisterBUSY();               // wait for status register 'busy' bit to go low, indicating the erase operation has finished
    printf("\r\nChip erased.\n");


    printf("\r\nWriting 0xBA to flash memory location = 0...");
    read_byte = WriteSPIChar(0x06, 0);      // write-enable
    read_byte = WriteSPIChar(0x02, 1);      // page program
    read_byte = WriteSPIChar(0x00, 1);      // first byte of address
    read_byte = WriteSPIChar(0x00, 1);      // second byte of address
    read_byte = WriteSPIChar(0x00, 1);      // third byte of address
    read_byte = WriteSPIChar(0xBA, 0);      // data byte to be written to memory
    ReadStatusRegisterBUSY();
    printf("\r\n0xBA written to flash memory.\n");

    
    printf("\r\nReading back byte that was just written to flash memory...");
    read_byte = WriteSPIChar(0x03, 1);      // read enable
    read_byte = WriteSPIChar(0x00, 1);      // first byte of address
    read_byte = WriteSPIChar(0x00, 1);      // second byte of address
    read_byte = WriteSPIChar(0x00, 1);      // third byte of address
    read_byte = WriteSPIChar(0x00, 0);      // dummy byte

    printf("\r\nByte read from flash that was just written to flash: %X\n", read_byte);
    
    printf("\r\nWelcome to DOOM (%i)!\r\n", 1993);
    menu();

    return 0;
}

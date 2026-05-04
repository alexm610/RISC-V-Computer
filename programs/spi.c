#include <stdio.h>
#include "spi.h"
#include "instructions.h"

void SPI_Init(void) {
    Disable_SPI_CS();
    SPI_Control = 0x53;
    SPI_Ext     = 0x00;
    SPI_Status  = 0xC0;
}

int TestForSPITransmitDataComplete(void) {
    return (SPI_Status & (1 << SR_SPIF));                                                                         
}

void WaitForSPITransmitComplete(void) {
    while(TestForSPITransmitDataComplete() == 0);
    SPI_Status      |= ((1 << SR_WCOL) | (1 << SR_SPIF));                                                          
}

int WriteSPIChar(int c, int follow_up) {    
    Enable_SPI_CS();
    SPI_Data = c;
    WaitForSPITransmitComplete();

    if (!follow_up) {
        Disable_SPI_CS();
    }

    return SPI_Data;
}

void ReadStatusRegisterBUSY(void) {
    int read_byte = WriteSPIChar(0x05, 1);      // read status register command; follow-up dummy bytes will be sent until the 'busy' bit of the register goes low
    read_byte = WriteSPIChar(0x00, 1);          // send a dummy byte so we can continuously poll the status register on the chip

    while (read_byte && 0x1) {
        read_byte = WriteSPIChar(0x00, 1);
    }

    read_byte = WriteSPIChar(0x00, 0);          // 'busy' bit of status register has gone low, so we write last dummy byte with no follow-up bytes and end the command
}

void ReadPageVerify(unsigned char *memory_address, int flash_address, int pages) {
    int read_byte, zeroth_byte, first_byte, second_byte, counter, i, error;
    volatile unsigned char * address;
    
    printf("\r\nVerifying memory content copied successfully...");
    error = 0;

    zeroth_byte = (flash_address >> 0) & 0xFF;
    first_byte = (flash_address >> 8) & 0xFF;
    second_byte = (flash_address >> 16) & 0xFF;
    counter = 0;
    address = memory_address;

    read_byte = WriteSPIChar(0x03, 1);              // read enable
    read_byte = WriteSPIChar(second_byte, 1);       // first byte of address
    read_byte = WriteSPIChar(first_byte, 1);        // second byte of address
    read_byte = WriteSPIChar(zeroth_byte, 1);       // third byte of address
    
    while (counter < (256 * pages)) {
        read_byte = WriteSPIChar(0x00, 1);          // send 255 dummy bytes, to read the 255 consecutive bytes
        
        if (*address != read_byte) {
            printf("\r\nError at %X: DRAM: %X    Flash: %X\n", address, *address, read_byte);
            error = 1;
        }
        
        address++;
        counter++;
    }  
        
    read_byte = WriteSPIChar(0x00, 0);              // final dummy byte, ends command

    if (!error) {
        printf("\r\nMemory verification complete; no errors detected.\n");
    } else {
        printf("\r\nMemory mismatch detected, see above.\n");
    }
}


void WritePage(unsigned char *memory_address, int flash_address) {

    volatile unsigned char * address;
    int byte, zeroth_byte, first_byte, second_byte;
    zeroth_byte = (flash_address >> 0) & 0xFF;
    first_byte = (flash_address >> 8) & 0xFF;
    second_byte = (flash_address >> 16) & 0xFF;

    byte = WriteSPIChar(0x06, 0);                                               // write enable
    byte = WriteSPIChar(0x02, 1);                                               // page program
    byte = WriteSPIChar(second_byte, 1);                                        // first byte of address 
    byte = WriteSPIChar(first_byte, 1);                                         // second byte of address
    byte = WriteSPIChar(zeroth_byte, 1);                                        // third byte of adress
    for (address=memory_address; address<(memory_address + 255); address++) {   // Pages in the flash chip are limited to 256 bytes total; must page program command after 256 bytes are written
        byte = WriteSPIChar(*address, 1);                                       // byte in memory
    }
    byte = WriteSPIChar(*address, 0);                                     // last byte to be written
    ReadStatusRegisterBUSY();
}

void WriteProgramToFlash(void) {
    int read_byte, i, j, k, flash_address, page_increment;
    unsigned int start, end;
    char choice, pattern;
    volatile unsigned char * address_start;
    volatile unsigned char * address_end;
    volatile unsigned char * address;

    printf("\r\nErasing flash chip...");
    read_byte = WriteSPIChar(0x06, 0);      // write enable
    read_byte = WriteSPIChar(0xC7, 0);      // erase chip
    ReadStatusRegisterBUSY();               // wait for status register 'busy' bit to go low, indicating the erase operation has finished
    printf("\r\nFlash chip successfully erased.\n");
  
    printf("\r\nWriting program at 0x08000000 to flash memory...");
    address_start = (volatile unsigned char *) 0x08000000;
    address_end = (volatile unsigned char *) 0x0803FFFF;

    flash_address = 0;
    page_increment = 256;
    i = 0;
    
    for (address=address_start; address<=address_end; address=address+256) {
        WritePage(address, flash_address);
        flash_address += 256;
    }
    
    printf("\r\n256 kilobytes written to flash memory.\n");
}

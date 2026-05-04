#include <stdio.h>
#include <string.h>
#include <ctype.h>


//IMPORTANT
//
// Uncomment one of the two #defines below
// Define StartOfExceptionVectorTable as 08030000 if running programs from sram or
// 0B000000 for running programs from dram
//
// In your labs, you will initially start by designing a system with SRam and later move to
// Dram, so these constants will need to be changed based on the version of the system you have
// building
//
// The working 68k system SOF file posted on canvas that you can use for your pre-lab
// is based around Dram so #define accordingly before building

//#define StartOfExceptionVectorTable 0x08030000
#define StartOfExceptionVectorTable 0x0B000000

/**********************************************************************************************
**	Parallel port addresses
**********************************************************************************************/

#define PortA   *(volatile unsigned char *)(0x00400000)
#define PortB   *(volatile unsigned char *)(0x00400002)
#define PortC   *(volatile unsigned char *)(0x00400004)
#define PortD   *(volatile unsigned char *)(0x00400006)
#define PortE   *(volatile unsigned char *)(0x00400008)

/*********************************************************************************************
**	Hex 7 seg displays port addresses
*********************************************************************************************/

#define HEX_A        *(volatile unsigned char *)(0x00400010)
#define HEX_B        *(volatile unsigned char *)(0x00400012)
#define HEX_C        *(volatile unsigned char *)(0x00400014)    // de2 only
#define HEX_D        *(volatile unsigned char *)(0x00400016)    // de2 only

/**********************************************************************************************
**	LCD display port addresses
**********************************************************************************************/

#define LCDcommand   *(volatile unsigned char *)(0x00400020)
#define LCDdata      *(volatile unsigned char *)(0x00400022)

/********************************************************************************************
**	Timer Port addresses
*********************************************************************************************/

#define Timer1Data      *(volatile unsigned char *)(0x00400030)
#define Timer1Control   *(volatile unsigned char *)(0x00400032)
#define Timer1Status    *(volatile unsigned char *)(0x00400032)

#define Timer2Data      *(volatile unsigned char *)(0x00400034)
#define Timer2Control   *(volatile unsigned char *)(0x00400036)
#define Timer2Status    *(volatile unsigned char *)(0x00400036)

#define Timer3Data      *(volatile unsigned char *)(0x00400038)
#define Timer3Control   *(volatile unsigned char *)(0x0040003A)
#define Timer3Status    *(volatile unsigned char *)(0x0040003A)

#define Timer4Data      *(volatile unsigned char *)(0x0040003C)
#define Timer4Control   *(volatile unsigned char *)(0x0040003E)
#define Timer4Status    *(volatile unsigned char *)(0x0040003E)

/*********************************************************************************************
**	RS232 port addresses
*********************************************************************************************/

#define RS232_Control     *(volatile unsigned char *)(0x00400040)
#define RS232_Status      *(volatile unsigned char *)(0x00400040)
#define RS232_TxData      *(volatile unsigned char *)(0x00400042)
#define RS232_RxData      *(volatile unsigned char *)(0x00400042)
#define RS232_Baud        *(volatile unsigned char *)(0x00400044)

/*********************************************************************************************
**	PIA 1 and 2 port addresses
*********************************************************************************************/

#define PIA1_PortA_Data     *(volatile unsigned char *)(0x00400050)         // combined data and data direction register share same address
#define PIA1_PortA_Control *(volatile unsigned char *)(0x00400052)
#define PIA1_PortB_Data     *(volatile unsigned char *)(0x00400054)         // combined data and data direction register share same address
#define PIA1_PortB_Control *(volatile unsigned char *)(0x00400056)

#define PIA2_PortA_Data     *(volatile unsigned char *)(0x00400060)         // combined data and data direction register share same address
#define PIA2_PortA_Control *(volatile unsigned char *)(0x00400062)
#define PIA2_PortB_data     *(volatile unsigned char *)(0x00400064)         // combined data and data direction register share same address
#define PIA2_PortB_Control *(volatile unsigned char *)(0x00400066)

/*********************************************************************************************
**  SPI Controller Registers
*********************************************************************************************/

#define SPI_Control         (*(volatile unsigned char *)(0x00408020))
#define SPI_Status          (*(volatile unsigned char *)(0x00408022))
#define SPI_Data            (*(volatile unsigned char *)(0x00408024))
#define SPI_Ext             (*(volatile unsigned char *)(0x00408026))
#define SPI_CS              (*(volatile unsigned char *)(0x00408028))
#define Enable_SPI_CS()     SPI_CS = 0xFE
#define Disable_SPI_CS()    SPI_CS = 0xFF
#define SR_SPIF             7
#define SR_WCOL             6
#define SR_WFFULL           3
#define SR_WFEMPTY          2
#define SR_RFFULL           1
#define SR_RFEMPTY          0
#define CR_SPIE             7
#define CR_SPE              6
#define CR_MSTR             4
#define CR_CPOL             3
#define CR_CPHA             2
#define CR_SPR_1            1
#define CR_SPR_0            0
#define ER_ICNT_1           7
#define ER_ICNT_0           6
#define ER_ESPR_1           1
#define ER_ESPR_0           0
#define DRAM_Space          (*(volatile unsigned char *)(0x09000000))

/*********************************************************************************************************************************
(( DO NOT initialise global variables here, do it main even if you want 0
(( it's a limitation of the compiler
(( YOU HAVE BEEN WARNED
*********************************************************************************************************************************/

unsigned int i, x, y, z, PortA_Count;
unsigned char Timer1Count, Timer2Count, Timer3Count, Timer4Count ;

/*******************************************************************************************
** Function Prototypes
*******************************************************************************************/
void Wait1ms(void);
void Wait3ms(void);
void Init_LCD(void) ;
void LCDOutchar(int c);
void LCDOutMess(char *theMessage);
void LCDClearln(void);
void LCDline1Message(char *theMessage);
void LCDline2Message(char *theMessage);
int sprintf(char *out, const char *format, ...) ;
int TestForSPITransmitDataComplete(void);
void SPI_Init(void);
void WaitForSPITransmitComplete(void);
int WriteSPIChar(int, int);
void WritePage(unsigned char *memory_address, int flash_address);
void WriteProgramToFlash(void);
void ReadPageVerify(unsigned char *memory_address, int flash_address, int);



/*****************************************************************************************
**	Interrupt service routine for Timers
**
**  Timers 1 - 4 share a common IRQ on the CPU  so this function uses polling to figure
**  out which timer is producing the interrupt
**
*****************************************************************************************/

void Timer_ISR()
{
   	if(Timer1Status == 1) {         // Did Timer 1 produce the Interrupt?
   	    Timer1Control = 3;      	// reset the timer to clear the interrupt, enable interrupts and allow counter to run
   	    PortA = Timer1Count++ ;     // increment an LED count on PortA with each tick of Timer 1
   	}

  	if(Timer2Status == 1) {         // Did Timer 2 produce the Interrupt?
   	    Timer2Control = 3;      	// reset the timer to clear the interrupt, enable interrupts and allow counter to run
   	    PortC = Timer2Count++ ;     // increment an LED count on PortC with each tick of Timer 2
   	}

   	if(Timer3Status == 1) {         // Did Timer 3 produce the Interrupt?
   	    Timer3Control = 3;      	// reset the timer to clear the interrupt, enable interrupts and allow counter to run
        HEX_A = Timer3Count++ ;     // increment a HEX count on Port HEX_A with each tick of Timer 3
   	}

   	if(Timer4Status == 1) {         // Did Timer 4 produce the Interrupt?
   	    Timer4Control = 3;      	// reset the timer to clear the interrupt, enable interrupts and allow counter to run
        HEX_B = Timer4Count++ ;     // increment a HEX count on HEX_B with each tick of Timer 4
   	}
}

/*****************************************************************************************
**	Interrupt service routine for ACIA. This device has it's own dedicate IRQ level
**  Add your code here to poll Status register and clear interrupt
*****************************************************************************************/

void ACIA_ISR()
{}

/***************************************************************************************
**	Interrupt service routine for PIAs 1 and 2. These devices share an IRQ level
**  Add your code here to poll Status register and clear interrupt
*****************************************************************************************/

void PIA_ISR()
{}

/***********************************************************************************
**	Interrupt service routine for Key 2 on DE1 board. Add your own response here
************************************************************************************/
void Key2PressISR()
{}

/***********************************************************************************
**	Interrupt service routine for Key 1 on DE1 board. Add your own response here
************************************************************************************/
void Key1PressISR()
{}

/************************************************************************************
**   Delay Subroutine to give the 68000 something useless to do to waste 1 mSec
************************************************************************************/
void Wait1ms(void)
{
    int  i ;
    for(i = 0; i < 1000; i ++)
        ;
}

/************************************************************************************
**  Subroutine to give the 68000 something useless to do to waste 3 mSec
**************************************************************************************/
void Wait3ms(void)
{
    int i ;
    for(i = 0; i < 3; i++)
        Wait1ms() ;
}

/*********************************************************************************************
**  Subroutine to initialise the LCD display by writing some commands to the LCD internal registers
**  Sets it for parallel port and 2 line display mode (if I recall correctly)
*********************************************************************************************/
void Init_LCD(void)
{
    LCDcommand = 0x0c ;
    Wait3ms() ;
    LCDcommand = 0x38 ;
    Wait3ms() ;
}

/*********************************************************************************************
**  Subroutine to initialise the RS232 Port by writing some commands to the internal registers
*********************************************************************************************/
void Init_RS232(void)
{
    RS232_Control = 0x15 ; //  %00010101 set up 6850 uses divide by 16 clock, set RTS low, 8 bits no parity, 1 stop bit, transmitter interrupt disabled
    RS232_Baud = 0x1 ;      // program baud rate generator 001 = 115k, 010 = 57.6k, 011 = 38.4k, 100 = 19.2, all others = 9600
}

/*********************************************************************************************************
**  Subroutine to provide a low level output function to 6850 ACIA
**  This routine provides the basic functionality to output a single character to the serial Port
**  to allow the board to communicate with HyperTerminal Program
**
**  NOTE you do not call this function directly, instead you call the normal putchar() function
**  which in turn calls _putch() below). Other functions like puts(), printf() call putchar() so will
**  call _putch() also
*********************************************************************************************************/

int _putch( int c)
{
    while((RS232_Status & (char)(0x02)) != (char)(0x02))    // wait for Tx bit in status register or 6850 serial comms chip to be '1'
        ;

    RS232_TxData = (c & (char)(0x7f));                      // write to the data register to output the character (mask off bit 8 to keep it 7 bit ASCII)
    return c ;                                              // putchar() expects the character to be returned
}

/*********************************************************************************************************
**  Subroutine to provide a low level input function to 6850 ACIA
**  This routine provides the basic functionality to input a single character from the serial Port
**  to allow the board to communicate with HyperTerminal Program Keyboard (your PC)
**
**  NOTE you do not call this function directly, instead you call the normal getchar() function
**  which in turn calls _getch() below). Other functions like gets(), scanf() call getchar() so will
**  call _getch() also
*********************************************************************************************************/
int _getch( void )
{
    char c ;
    while((RS232_Status & (char)(0x01)) != (char)(0x01))    // wait for Rx bit in 6850 serial comms chip status register to be '1'
        ;

    return (RS232_RxData & (char)(0x7f));                   // read received character, mask off top bit and return as 7 bit ASCII character
}

/******************************************************************************
**  Subroutine to output a single character to the 2 row LCD display
**  It is assumed the character is an ASCII code and it will be displayed at the
**  current cursor position
*******************************************************************************/
void LCDOutchar(int c)
{
    LCDdata = (char)(c);
    Wait1ms() ;
}

/**********************************************************************************
*subroutine to output a message at the current cursor position of the LCD display
************************************************************************************/
void LCDOutMessage(char *theMessage)
{
    char c ;
    while((c = *theMessage++) != 0)     // output characters from the string until NULL
        LCDOutchar(c) ;
}

/******************************************************************************
*subroutine to clear the line by issuing 24 space characters
*******************************************************************************/
void LCDClearln(void)
{
    int i ;
    for(i = 0; i < 24; i ++)
        LCDOutchar(' ') ;       // write a space char to the LCD display
}

/******************************************************************************
**  Subroutine to move the LCD cursor to the start of line 1 and clear that line
*******************************************************************************/
void LCDLine1Message(char *theMessage)
{
    LCDcommand = 0x80 ;
    Wait3ms();
    LCDClearln() ;
    LCDcommand = 0x80 ;
    Wait3ms() ;
    LCDOutMessage(theMessage) ;
}

/******************************************************************************
**  Subroutine to move the LCD cursor to the start of line 2 and clear that line
*******************************************************************************/
void LCDLine2Message(char *theMessage)
{
    LCDcommand = 0xC0 ;
    Wait3ms();
    LCDClearln() ;
    LCDcommand = 0xC0 ;
    Wait3ms() ;
    LCDOutMessage(theMessage) ;
}

/*********************************************************************************************************************************
**  IMPORTANT FUNCTION
**  This function install an exception handler so you can capture and deal with any 68000 exception in your program
**  You pass it the name of a function in your code that will get called in response to the exception (as the 1st parameter)
**  and in the 2nd parameter, you pass it the exception number that you want to take over (see 68000 exceptions for details)
**  Calling this function allows you to deal with Interrupts for example
***********************************************************************************************************************************/

void InstallExceptionHandler( void (*function_ptr)(), int level)
{
    volatile long int *RamVectorAddress = (volatile long int *)(StartOfExceptionVectorTable) ;   // pointer to the Ram based interrupt vector table created in Cstart in debug monitor

    RamVectorAddress[level] = (long int *)(function_ptr);                       // install the address of our function into the exception table
}

/******************************************************************************************************************************
* SPI Controller Functions
******************************************************************************************************************************/

int TestForSPITransmitDataComplete(void) {
    return (SPI_Status & (1 << SR_SPIF));                                                                           // Check SPIF bit, return true if it is se
}

void SPI_Init(void) {
    Disable_SPI_CS();
    //SPI_Control     |= (1 << CR_MSTR) | (1 << CR_SPR_1) | (1 << CR_SPR_0);                                  // Set bits
    //SPI_Control     &= ~((1 << CR_SPE) | (1 << CR_CPOL) | (1 << CR_CPHA) | (1 << CR_SPIE));                                                                  // Clear bits
    //SPI_Ext         &= ~((1 << ER_ICNT_1) | (1 << ER_ICNT_0) | (1 << ER_ESPR_1) | (1 << ER_ESPR_0));                        // Clear bits
    //SPI_Status      |= ((1 << SR_SPIF));     

    //SPI_Control     |= (1 << CR_SPE);
    //printf("\r\nFirst Status register: %i\n", SPI_Status);                                                                // Set bits
    //SPI_Status      &= ~((1 << SR_WFFULL) | (1 << SR_WFEMPTY) | (1 << SR_RFFULL) | (1 << SR_RFEMPTY));                      // Clear bits 
    //Disable_SPI_CS();
    SPI_Control = 0x53;
    SPI_Ext     = 0x00;
    SPI_Status  = 0xC0;
}

void WaitForSPITransmitComplete(void) {
    while(TestForSPITransmitDataComplete() == 0) {
        //printf("\r\nSPIF not set yet......\n");
        //SPI_Data = 0xDE; // write dummy data;
        //
        
    }          
    //dummy = SPI_Data;                                                                   // Wait for SPIF bit, looking for completion of transmission
    SPI_Status      |= ((1 << SR_WCOL) | (1 << SR_SPIF));                                                                  // Clear write collision bit and the interrupt bit, just in case they were set     
    
    
}

int WriteSPIChar(int c, int follow_up) {
    if (SPI_CS != 0xFE) {
        Enable_SPI_CS();        // only enable CS if it has not been enabled yet
    }
    
    Enable_SPI_CS();

    SPI_Data = c;

    WaitForSPITransmitComplete();

    if (!follow_up) {
        // If there is no follow-up byte to be written during whatever command was sent, then we can disable CS 
        // If there is a follow-up byte to be written during the current command, then we do not disable CS yet
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
    int read_byte, zeroth_byte, first_byte, second_byte, counter, i;
    volatile unsigned char * address;
    
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
            
        }
        //printf("\r\n %X: %i      %i\n", address, *address, read_byte);
        
        address++;
        counter++;
    }  
        
        
        
    read_byte = WriteSPIChar(0x00, 0);              // final dummy byte, to read byte 256
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
    // this is analogous to the ProgramFlashChip function in the debug monitor; it already knows that the chip has to be erased and that we are writing bytes starting at 0x08000000
    int read_byte, i, j, k, flash_address, page_increment;
    unsigned int start, end;
    char choice, pattern;
    volatile unsigned char * address_start;
    volatile unsigned char * address_end;
    volatile unsigned char * address;

    printf("\r\nErasing flash chip...\n");
    read_byte = WriteSPIChar(0x06, 0);      // write enable
    read_byte = WriteSPIChar(0xC7, 0);      // erase chip
    ReadStatusRegisterBUSY();               // wait for status register 'busy' bit to go low, indicating the erase operation has finished
    printf("\r\nFlash chip successfully erased.\n\n");
  
    printf("\r\nWriting program at 0x08000000 to flash memory...\n");
    address_start = (volatile unsigned char *) 0x08000000;
    address_end = (volatile unsigned char *) 0x0803FFFF;
    
    //address = address_start;
    flash_address = 0;
    page_increment = 256;
    i = 0;
    
    for (address=address_start; address<=address_end; address=address+256) {
        WritePage(address, flash_address);
        flash_address += 256;
    }
    
    
    /*
    while (i < 1000) {
        WritePage(address, flash_address);
        printf("\r\nPage %i written to flash memory...", i);

        i++;
        address += i * page_increment;
        flash_address += i * page_increment;
    }*/

    printf("\r\n256 kilobytes written to flash memory.\n");
    //WritePage(address, flash_address);
    //WritePage(address + page_increment, flash_address + page_increment);
}

/******************************************************************************************************************************
* Start of user program
******************************************************************************************************************************/

void main()
{
    volatile unsigned char * address;
    int read_byte, read_byte2, read_byte3, read_byte4, read_byte5, read_byte6, start, flash_address;
    int byte, zeroth_byte, first_byte, second_byte;
    
    i = x = y = z = PortA_Count = 0;
    Timer1Count = Timer2Count = Timer3Count = Timer4Count = 0;


    InstallExceptionHandler(PIA_ISR, 25) ;          // install interrupt handler for PIAs 1 and 2 on level 1 IRQ
    InstallExceptionHandler(ACIA_ISR, 26) ;		    // install interrupt handler for ACIA on level 2 IRQ
    InstallExceptionHandler(Timer_ISR, 27) ;		// install interrupt handler for Timers 1-4 on level 3 IRQ
    InstallExceptionHandler(Key2PressISR, 28) ;	    // install interrupt handler for Key Press 2 on DE1 board for level 4 IRQ
    InstallExceptionHandler(Key1PressISR, 29) ;	    // install interrupt handler for Key Press 1 on DE1 board for level 5 IRQ

    Timer1Data = 0x10;		// program time delay into timers 1-4
    Timer2Data = 0x20;
    Timer3Data = 0x15;
    Timer4Data = 0x25;

    Timer1Control = 3;		// write 3 to control register to Bit0 = 1 (enable interrupt from timers) 1 - 4 and allow them to count Bit 1 = 1
    Timer2Control = 3;
    Timer3Control = 3;
    Timer4Control = 3;

    Init_LCD();             // initialise the LCD display to use a parallel data interface and 2 lines of display
    Init_RS232() ;          // initialise the RS232 port for use with hyper terminal

/*************************************************************************************************
**  Test of scanf function
*************************************************************************************************/

    scanflush() ;                       // flush any text that may have been typed ahead

    SPI_Init();
    printf("\r\nPERFORMING FLASH MEMORY TEST\n");
    printf("\r\nErasing flash chip...");
    read_byte = WriteSPIChar(0x06, 0);      // write enable
    read_byte = WriteSPIChar(0xC7, 0);      // erase chip
    ReadStatusRegisterBUSY();               // wait for status register 'busy' bit to go low, indicating the erase operation has finished
    printf("\r\nChip erased.\n");

    printf("Writing 0xBA to flash memory location = 0...");
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

    printf("\r\nByte read from flash that was just written to flash: %08X\n", read_byte);

    while(1)
        ;

   // programs should NOT exit as there is nothing to Exit TO !!!!!!
   // There is no OS - just press the reset button to end program and call debug
}

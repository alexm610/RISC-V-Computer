#include "uart.h"
/*********************************************************************************************
*Subroutine to initialise the RS232 Port by writing some commands to the internal registers
*********************************************************************************************/
void Init_RS232(void)
{
    RS232_Control = (char)(0x15) ; //  %00010101    divide by 16 clock, set rts low, 8 bits no parity, 1 stop bit transmitter interrupt disabled
    RS232_Baud = (char)(0x1) ;      // program baud rate generator 000 = 230k, 001 = 115k, 010 = 57.6k, 011 = 38.4k, 100 = 19.2, all others = 9600
}

int kbhit(void)
{
    if(((RS232_Status) & (char)(0x01)) == (char)(0x01))    // wait for Rx bit in status register to be '1'
        return 1 ;
    else
        return 0 ;
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
    while(((RS232_Status) & (char)(0x02)) != (char)(0x02))    // wait for Tx bit in status register or 6850 serial comms chip to be '1'
        ;

    (RS232_TxData) = ((char)(c) & (char)(0x7f));                      // write to the data register to output the character (mask off bit 8 to keep it 7 bit ASCII)
    return c ;                                              // putchar() expects the character to be returned
}

/*********************************************************************************************************
**  Subroutine to provide a low level input function to 6850 ACIA
**  This routine provides the basic functionality to input a single character from the serial Port
**  to allow the board to communicate with HyperTerminal Program Keyboard (your PC)
**
**  NOTE you do not call this function directly, instead you call the normal _getch() function
**  which in turn calls _getch() below). Other functions like gets(), scanf() call _getch() so will
**  call _getch() also
*********************************************************************************************************/

// flush the input stream for any unread characters

void FlushKeyboard(void)
{
    char c ;

    while(1)    {
        if(((RS232_Status) & (char)(0x01)) == (char)(0x01))    // if Rx bit in status register is '1'
            c = ((RS232_RxData) & (char)(0x7f)) ;
        else
            return ;
     }
}

void _puts(const char *s)
{
    while (*s != '\0') {
        if (*s == '\n') {
            _putch('\r');   // send CR before LF for proper terminal newline
            _putch('\n');
            s++;
        } else {
            _putch(*s++);
        }
    }
}

int _getch(void)
{
    int c;
    while (((RS232_Status) & (char)(0x01)) != (char)(0x01))
        ;
    c = (RS232_RxData & 0x7f);
    return c;   // no echo here — let the caller decide
}

void _gets(char *buf, int max_len)
{
    int i = 0;
    FlushKeyboard();
    while (1) {
        char c = _getch();
        if (c == '\r' || c == '\n') {
            _puts("\n");
            buf[i] = '\0';
            return;
        } else if (c == 0x08 || c == 0x7F) {
            if (i > 0) {
                i--;
                _putch(0x08);
                _putch(' ');
                _putch(0x08);
            }
        } else if (i < max_len - 1) {
            buf[i++] = c;
            _putch(c);   // echo here, after storing
        }
    }
}

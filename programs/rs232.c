#include "instructions.h"

#define UART_TX_BUSY    0x02
#define UART_RX_READY   0x01

// blocking
void uart_putch(char c) {
    // wait until transmitter is not busy
    while ((RS232_Status & UART_TX_BUSY) == UART_TX_BUSY);
    RS232_Data = (char) c;
}

// blocking
char uart_getch(void) {
    // wait until a byte is ready
    while ((RS232_Status & UART_RX_READY) != UART_RX_READY);
    return (char)(RS232_Data & 0xFF);
}

// send string
void uart_puts(char *string) {
    while (*string) {
        uart_putch(*string++);
    }
}

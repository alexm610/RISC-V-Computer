#include "rs232.h"

volatile uint32_t Echo = 1;

void rs232_init(void)
{
    RS232_Control = (RS232_CTRL_TX_EN | RS232_CTRL_RX_EN |
                     RS232_CTRL_CLR_RX | RS232_CTRL_CLR_ERR);
}

int _putch(int c)
{
    // Wait for TX_READY (bit0 = 1)
    while ((RS232_Status & RS232_TX_READY) == 0u) {
        ;
    }

    // Send low 7-bit ASCII like your original (or use 0xFF if you want full 8-bit)
    RS232_TxData = (uint32_t)((uint8_t)c & 0x7Fu);
    return c;
}

int _getch(void)
{
    int c;

    // Wait for RX_READY (bit1 = 1)
    while ((RS232_Status & RS232_RX_READY) == 0u) {
        ;
    }

    // Reading DATA clears RX_VALID in your UART RTL
    c = (int)((uint8_t)(RS232_RxData & 0xFFu) & 0x7Fu);

    if (Echo) {
        _putch(c);
    }
    return c;
}

// Non-blocking version: returns -1 if no char available
int rs232_getch_nb(void)
{
    if ((RS232_Status & RS232_RX_READY) == 0u) {
        return -1;
    }

    int c = (int)((uint8_t)(RS232_RxData & 0xFFu) & 0x7Fu);

    if (Echo) {
        _putch(c);
    }
    return c;
}

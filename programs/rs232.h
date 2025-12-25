#pragma once
#include <stdint.h>
#include <stdbool.h>

#ifndef UART0_BASE
#define UART0_BASE 0x10000000u   // MUST match your address_decoder
#endif

// Word-spaced register offsets
#define RS232_DATA_OFF    0x00u   // R: RX byte in [7:0], W: TX byte in [7:0]
#define RS232_STATUS_OFF  0x04u   // R: status
#define RS232_CTRL_OFF    0x08u   // W: control (enable/clear)

// STATUS bits (match your UART RTL)
#define RS232_RX_READY    (1u << 1)   // RX_VALID
#define RS232_TX_READY    (1u << 0)   // TX_READY

// CTRL bits (match your UART RTL)
#define RS232_CTRL_TX_EN    (1u << 0)
#define RS232_CTRL_RX_EN    (1u << 1)
#define RS232_CTRL_LOOPBACK (1u << 2)
#define RS232_CTRL_CLR_RX   (1u << 3)
#define RS232_CTRL_CLR_ERR  (1u << 4)

// Memory-mapped registers
#define RS232_RxData   (*(volatile uint32_t *)(UART0_BASE + RS232_DATA_OFF))
#define RS232_TxData   (*(volatile uint32_t *)(UART0_BASE + RS232_DATA_OFF))
#define RS232_Status   (*(volatile uint32_t *)(UART0_BASE + RS232_STATUS_OFF))
#define RS232_Control  (*(volatile uint32_t *)(UART0_BASE + RS232_CTRL_OFF))

// Optional echo flag like your old code
extern volatile uint32_t Echo;

void rs232_init(void);

// Your requested API
int _putch(int c);
int _getch(void);

// Useful helper so main doesn’t block (prevents “HEX only updates on keypress”)
int rs232_getch_nb(void);   // returns -1 if no char available

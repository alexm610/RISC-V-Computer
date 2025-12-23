#include "rs232.h"

// 8-bit MMIO access helpers
static inline void mmio_write8(uint32_t addr, uint8_t value) {
    *(volatile uint8_t *)addr = value;
}
static inline uint8_t mmio_read8(uint32_t addr) {
    return *(volatile uint8_t *)addr;
}

// UART register accessors
static inline void uart_write_reg(uint32_t base, uint32_t off, uint8_t v) {
    mmio_write8(base + off, v);
}
static inline uint8_t uart_read_reg(uint32_t base, uint32_t off) {
    return mmio_read8(base + off);
}

// Compute divisor used by HW: BAUDDIV = (clk_hz / baud) - 1
static inline uint16_t uart_calc_divisor(uint32_t clk_hz, uint32_t baud) {
    if (baud == 0) return 0;
    uint32_t q = clk_hz / baud;
    if (q == 0) return 0;
    return (uint16_t)(q - 1u);
}

// Initialize UART: set baud divisor and enable TX/RX
static inline void uart_init(uint32_t base, uint32_t clk_hz, uint32_t baud) {
    uint16_t div = uart_calc_divisor(clk_hz, baud);

    // program divisor
    uart_write_reg(base, UART_REG_BAUD_L, (uint8_t)(div & 0xFFu));
    uart_write_reg(base, UART_REG_BAUD_H, (uint8_t)(div >> 8));

    // clear RX + errors, enable TX/RX
    uart_write_reg(base, UART_REG_CTRL,
                   (uint8_t)(UART_CTRL_TX_EN | UART_CTRL_RX_EN |
                             UART_CTRL_CLR_RX | UART_CTRL_CLR_ERR));
}

// Read STATUS
static inline uint8_t uart_status(uint32_t base) {
    return uart_read_reg(base, UART_REG_STATUS);
}

// Blocking transmit of one byte (polls TX_READY)
static inline void uart_putc(uint32_t base, uint8_t c) {
    while ((uart_status(base) & UART_STATUS_TX_READY) == 0) { }
    uart_write_reg(base, UART_REG_DATA, c);
}

// Non-blocking transmit: returns true if written, false if not ready
static inline bool uart_putc_nb(uint32_t base, uint8_t c) {
    if ((uart_status(base) & UART_STATUS_TX_READY) == 0) return false;
    uart_write_reg(base, UART_REG_DATA, c);
    return true;
}

// Blocking receive of one byte (polls RX_VALID)
// NOTE: reading DATA clears RX_VALID in hardware.
static inline uint8_t uart_getc(uint32_t base) {
    while ((uart_status(base) & UART_STATUS_RX_VALID) == 0) { }
    return uart_read_reg(base, UART_REG_DATA);
}

// Non-blocking receive: returns true if got a byte
static inline bool uart_getc_nb(uint32_t base, uint8_t *out) {
    if ((uart_status(base) & UART_STATUS_RX_VALID) == 0) return false;
    *out = uart_read_reg(base, UART_REG_DATA);
    return true;
}

// Write-1-to-clear sticky status bits (OVERRUN / FRAME_ERR)
static inline void uart_clear_errors(uint32_t base) {
    uart_write_reg(base, UART_REG_STATUS, (uint8_t)(UART_STATUS_OVERRUN | UART_STATUS_FRAME_ERR));
}

// Simple print helpers
static inline void uart_puts(uint32_t base, const char *s) {
    while (*s) uart_putc(base, (uint8_t)*s++);
}

// Optional: print newline as CRLF for terminals
static inline void uart_puts_crlf(uint32_t base, const char *s) {
    while (*s) {
        char c = *s++;
        if (c == '\n') uart_putc(base, '\r');
        uart_putc(base, (uint8_t)c);
    }
}
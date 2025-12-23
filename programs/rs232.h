#include <stdint.h>
#include <stdbool.h>
// Base address must match uart_mmio_8bit BASE_ADDR parameter.
#ifndef UART0_BASE
#define UART0_BASE 0x10000000u
#endif

// Register offsets
#define UART_REG_DATA    0x00u
#define UART_REG_STATUS  0x01u
#define UART_REG_BAUD_L  0x02u
#define UART_REG_BAUD_H  0x03u
#define UART_REG_CTRL    0x04u

// STATUS bits
#define UART_STATUS_TX_READY   (1u << 0)
#define UART_STATUS_RX_VALID   (1u << 1)
#define UART_STATUS_OVERRUN    (1u << 2)  // sticky
#define UART_STATUS_FRAME_ERR  (1u << 3)  // sticky

// CTRL bits
#define UART_CTRL_TX_EN        (1u << 0)
#define UART_CTRL_RX_EN        (1u << 1)
#define UART_CTRL_LOOPBACK     (1u << 2)
#define UART_CTRL_CLR_RX       (1u << 3)  // self-clearing command
#define UART_CTRL_CLR_ERR      (1u << 4)  // self-clearing command


// 8-bit MMIO access helpers
static inline void mmio_write8(uint32_t addr, uint8_t value);
static inline uint8_t mmio_read8(uint32_t addr);
static inline void uart_write_reg(uint32_t base, uint32_t off, uint8_t v);
static inline uint8_t uart_read_reg(uint32_t base, uint32_t off);
static inline uint16_t uart_calc_divisor(uint32_t clk_hz, uint32_t baud);
static inline void uart_init(uint32_t base, uint32_t clk_hz, uint32_t baud);
static inline uint8_t uart_status(uint32_t base);
static inline void uart_putc(uint32_t base, uint8_t c);
static inline bool uart_putc_nb(uint32_t base, uint8_t c);
static inline uint8_t uart_getc(uint32_t base);
static inline bool uart_getc_nb(uint32_t base, uint8_t *out);
static inline void uart_clear_errors(uint32_t base);
static inline void uart_puts(uint32_t base, const char *s);
static inline void uart_puts_crlf(uint32_t base, const char *s);
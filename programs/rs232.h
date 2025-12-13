#define UART_TX_BUSY    0x02
#define UART_RX_READY   0x01


void uart_putch(char);
char uart_getch(void);
void uart_puts(char *);

#define VGA                     *(volatile unsigned long *)(0x04010000)
#define SWITCHES                *(volatile unsigned long *)(0x00400000)
#define LEDR                    *(volatile unsigned long *)(0x00400004)
#define HEX                     *(volatile unsigned long *)(0x00400008)
#define LCD_Command_Register    *(volatile unsigned long *)(0x0040000C)
#define LCD_Data_Register       *(volatile unsigned long *)(0x00400010)
#define Timer0_Data_Register    *(volatile unsigned long *)(0x00400100)
#define Timer0_Control_Register *(volatile unsigned long *)(0x00400104)
#define RS232_Status            *(volatile unsigned long *)(0x05000014)
#define RS232_Data              *(volatile unsigned long *)(0x05000010)


void print_stripes(void);

void uart_putch(char);
char uart_getch(void);
void uart_puts(char *);

void Wait1ms(void);
void Wait3ms(void);
void Initialize_LCD(void);
void LCD_char(char);
void LCD_message(char *);
void LCD_clear(void);
void LCD_line0(char *);
void LCD_line1(char *);

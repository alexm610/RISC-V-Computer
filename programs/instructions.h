#define VGA                     *(volatile unsigned long *)(0x04010000)
#define SWITCHES                *(volatile unsigned long *)(0x00400000)
#define LEDR                    *(volatile unsigned long *)(0x00400004)
#define HEX                     *(volatile unsigned long *)(0x00400008)
#define LCD_Command_Register    *(volatile unsigned long *)(0x0040000C)
#define LCD_Data_Register       *(volatile unsigned long *)(0x00400010)
#define RS232_Control           *(volatile unsigned char *)(0x00400040)
#define RS232_Status            *(volatile unsigned char *)(0x00400040)
#define RS232_TxData            *(volatile unsigned char *)(0x00400042)
#define RS232_RxData            *(volatile unsigned char *)(0x00400042)
#define RS232_Baud              *(volatile unsigned char *)(0x00400044)

void Init_RS232(void);
int _putch(int);

void Wait1ms(void);
void Wait3ms(void);
void Initialize_LCD(void);
void LCD_char(int);
void LCD_message(char *);
void LCD_clear(void);
void LCD_line0(char *);
void LCD_line1(char *);

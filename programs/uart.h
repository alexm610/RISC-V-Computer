#define RS232_Control       *(volatile unsigned long *)(0x10000000)
#define RS232_Status        *(volatile unsigned long *)(0x10000000)
#define RS232_TxData        *(volatile unsigned long *)(0x10000004)
#define RS232_RxData        *(volatile unsigned long *)(0x10000004)
#define RS232_Baud          *(volatile unsigned long *)(0x10000008)

#define printf(...)         _printf(__VA_ARGS__)
#define fprintf(f, ...)     _printf(__VA_ARGS__)
#define scanf(...)          _scanf(__VA_ARGS__)

void Init_RS232(void);
int kbhit(void);
int _putch(int);
int _getch(void);
void FlushKeyboard(void);
void _puts(const char *s);
void _gets(char *buf, int max_len);
void _printf(const char *fmt, ...);
void _scanf(const char *fmt, ...);


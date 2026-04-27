#include "instructions.h"
#include "vga.h"
#include "lcd_display.h"
#include "uart.h"

#define BUFFER_MAX_LENGTH   32

extern volatile int timer_ticks;

int a[100][100], b[100][100], c[100][100];
int i, j, k, sum;

void performance_test(void) {
    _puts("\n\nStart.....");
    for(i=0; i <50; i ++)  {
        _puts("\r\ntick");
        //_puts("%d ", i);
        for(j=0; j < 50; j++)  {
            sum = 0 ;
            for(k=0; k <50; k++)   {
                sum = sum + b[i][k] * b[k][j] + a[i][k] * c[i][j];
                sum = sum + b[i][k] * b[k][j] + a[i][k] * c[i][j];
                sum = sum + b[i][k] * b[k][j] + a[i][k] * c[i][j];
                sum = sum + b[i][k] * b[k][j] + a[i][k] * c[i][j];
                sum = sum + b[i][k] * b[k][j] + a[i][k] * c[i][j];
                sum = sum + b[i][k] * b[k][j] + a[i][k] * c[i][j];
                sum = sum + b[i][k] * b[k][j] + a[i][k] * c[i][j];
                sum = sum + b[i][k] * b[k][j] + a[i][k] * c[i][j];
                sum = sum + b[i][k] * b[k][j] + a[i][k] * c[i][j];
                sum = sum + b[i][k] * b[k][j] + a[i][k] * c[i][j];
                sum = sum + b[i][k] * b[k][j] + a[i][k] * c[i][j];
                sum = sum + b[i][k] * b[k][j] + a[i][k] * c[i][j];
                sum = sum + b[i][k] * b[k][j] + a[i][k] * c[i][j];
                sum = sum + b[i][k] * b[k][j] + a[i][k] * c[i][j];
                sum = sum + b[i][k] * b[k][j] + a[i][k] * c[i][j];
                sum = sum + b[i][k] * b[k][j] + a[i][k] * c[i][j];
                sum = sum + b[i][k] * b[k][j] + a[i][k] * c[i][j];
                sum = sum + b[i][k] * b[k][j] + a[i][k] * c[i][j];
                sum = sum + b[i][k] * b[k][j] + a[i][k] * c[i][j];
                sum = sum + b[i][k] * b[k][j] + a[i][k] * c[i][j];
            }
            c[i][j] = sum ;
        }
    }
    _puts("\n\nDone.....");
}

int main(void) {
    char *message1 = "Rip and tear,";
    char *message2 = "until it is done.";
    char buf[32];

    Initialize_LCD();    
    FlushKeyboard();
    Init_RS232();
    
    LCD_line0(message1);
    LCD_line1(message2);

    timer_ticks = 0;
    Timer0_Control_Register = 0x0;
    Timer0_Data_Register = 50000000;
    Timer0_Control_Register = 0x00000003;

    //_puts("Enter your name: ");
    //FlushKeyboard();
    //_gets(buf, 32); 
    //_puts("Hello, ");
    //_puts(buf);
    //_puts("!\n");
    performance_test();
    print_stripes();
    while (1) {
        HEX = timer_ticks;
        LEDR = SWITCHES;
    }
}


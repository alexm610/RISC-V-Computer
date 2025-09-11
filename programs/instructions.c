#include "instructions.h"

#define BUFFER_SIZE     64
char buffer[BUFFER_SIZE];

void process_command(char *line) {
    uart_puts("You typed: ");
    uart_puts(line);
    uart_puts("\r\n");

    // Example command handling
    if (line[0] == 'x') {
        uart_puts("Executing command X!\r\n");
    }
}

int main (void) {
    int line_index = 0;
    char *message1 = "Hello Somya,";
    Initialize_LCD();

    LCD_line0(message1);
    LCD_line1("I love you!");
    
    uart_puts("avfasdfasdf\r\n");


    
    print_stripes();
    while (1) {
        LEDR = SWITCHES;
        HEX = SWITCHES;
        uart_puts("avfasdfasdf\r\n");
    }
}
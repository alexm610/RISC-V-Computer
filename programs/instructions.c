#include "instructions.h"

int main (void) {
    Init_RS232();
    _putch(104); // h
    _putch(101); // e
    _putch(108); // l
    _putch(108); // l
    _putch(111); // o
    _putch(32);  // <space>
    _putch(119); // w
    _putch(111); // o
    _putch(114); // r
    _putch(108); // l
    _putch(100); // d
    _putch(10);  // <new line, carriage return>

    while (1) {
        LEDR = SWITCHES;
        HEX = SWITCHES;
    }
}
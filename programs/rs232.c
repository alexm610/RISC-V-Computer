#include "instructions.h"

void Init_RS232(void) {
    RS232_Control = (char)(0x15);
    RS232_Baud = (char)(0x1);
}

int _putch(int c) {
    while (((char)(RS232_Status) & (char)(0x02)) != (char)(0x02));
    RS232_TxData = ((char)(c) & (char)(0x7F));
    return c;
}
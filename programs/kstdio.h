#pragma once
#include <stdint.h>

int kputch(int c);        // uses _putch()
int kgetch(void);         // uses _getch()

void kputs(const char *s);
void kprintf(const char *fmt, ...);

int kgetint(void);        // reads a signed decimal int from UART

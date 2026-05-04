#include <stdio.h>
#include <stdarg.h>
#include "uart.h"

void Init_RS232(void) {
    volatile int i;
    RS232_Control = (char)(0x03);        /* master reset */
    for (i = 0; i < 50; i++);           /* short delay — reset must settle */
    RS232_Control = (char)(0x15);        /* divide/16, 8N1, RTS low */
    RS232_Baud    = (char)(0x01);        /* 115200 baud */
}

int kbhit(void) {
    return ((RS232_Status & (char)(0x01)) == (char)(0x01)) ? 1 : 0;
}

int _putch(int c) {
    while ((RS232_Status & (char)(0x02)) != (char)(0x02))
        ;
    RS232_TxData = (char)(c) & (char)(0x7f);
    return c;
}

int _getch(void) {
    while ((RS232_Status & (char)(0x01)) != (char)(0x01))
        ;
    return (int)(RS232_RxData & 0x7f);
}

void FlushKeyboard(void) {
    while (RS232_Status & (char)(0x01)) {
        (void) (RS232_RxData & (char)(0x7f));
    }
}

void _puts(const char *s) {
    while (*s != '\0') {
        if (*s == '\n')
            _putch('\r');
        _putch(*s++);
    }
}

void _gets(char *buf, int max_len) {
    int i = 0;
    while (1) {
        char c = (char)_getch();
        if (c == '\r' || c == '\n') {
            _puts("\n");
            buf[i] = '\0';
            return;
        } else if (c == 0x08 || c == 0x7F) {
            if (i > 0) {
                i--;
                _putch(0x08);
                _putch(' ');
                _putch(0x08);
            }
        } else if (i < max_len - 1) {
            buf[i++] = c;
            _putch(c);
        }
    }
}

static void _print_uint(unsigned int n, int base) {
    char tmp[32];
    int i = 0;
    if (n == 0) { _putch('0'); return; }
    while (n > 0) {
        int d = n % base;
        tmp[i++] = (d < 10) ? '0' + d : 'a' + d - 10;
        n /= base;
    }
    while (i-- > 0) _putch(tmp[i]);
}

void _printf(const char *fmt, ...) {
    va_list args;
    va_start(args, fmt);
    while (*fmt) {
        if (*fmt == '%') {
            fmt++;
            switch (*fmt) {
                case 'd': case 'i': {
                    int n = va_arg(args, int);
                    if (n < 0) { _putch('-'); n = -n; }
                    _print_uint((unsigned int)n, 10);
                    break;
                }
                case 'u':
                    _print_uint(va_arg(args, unsigned int), 10);
                    break;
                case 'x': case 'X':
                    _print_uint(va_arg(args, unsigned int), 16);
                    break;
                case 's': {
                    const char *s = va_arg(args, const char *);
                    while (*s) {
                        if (*s == '\n') _putch('\r');
                        _putch(*s++);
                    }
                    break;
                }
                case 'c':
                    _putch(va_arg(args, int));
                    break;
                case '%':
                    _putch('%');
                    break;
                default:
                    _putch('%');
                    _putch(*fmt);
                    break;
            }
        } else {
            if (*fmt == '\n') _putch('\r');
            _putch(*fmt);
        }
        fmt++;
    }
    va_end(args);
}

void _scanf(const char *fmt, ...) {
    char buf[128];
    _gets(buf, sizeof(buf));   /* blocking line input with echo + backspace */

    va_list args;
    va_start(args, fmt);

    const char *p = buf;
    while (*fmt) {
        if (*fmt == '%') {
            fmt++;
            switch (*fmt) {
                case 'd': case 'i': {
                    int *n = va_arg(args, int *);
                    int neg = 0;
                    if (*p == '-') { neg = 1; p++; }
                    *n = 0;
                    while (*p >= '0' && *p <= '9')
                        *n = *n * 10 + (*p++ - '0');
                    if (neg) *n = -(*n);
                    break;
                }
                case 'u': {
                    unsigned int *n = va_arg(args, unsigned int *);
                    *n = 0;
                    while (*p >= '0' && *p <= '9')
                        *n = *n * 10 + (*p++ - '0');
                    break;
                }
                case 'x': case 'X': {
                    unsigned int *n = va_arg(args, unsigned int *);
                    *n = 0;
                    while ((*p >= '0' && *p <= '9') ||
                           (*p >= 'a' && *p <= 'f') ||
                           (*p >= 'A' && *p <= 'F')) {
                        int d;
                        if (*p >= '0' && *p <= '9')      d = *p - '0';
                        else if (*p >= 'a' && *p <= 'f') d = *p - 'a' + 10;
                        else                              d = *p - 'A' + 10;
                        *n = *n * 16 + d;
                        p++;
                    }
                    break;
                }
                case 's': {
                    char *s = va_arg(args, char *);
                    while (*p == ' ' || *p == '\t') p++;  /* skip whitespace */
                    while (*p && *p != ' ' && *p != '\t' && *p != '\n')
                        *s++ = *p++;
                    *s = '\0';
                    break;
                }
                case 'c': {
                    char *c = va_arg(args, char *);
                    *c = *p++;
                    break;
                }
            }
        } else if (*fmt == ' ') {
            while (*p == ' ' || *p == '\t') p++;  /* consume whitespace */
        }
        fmt++;
    }
    va_end(args);
}

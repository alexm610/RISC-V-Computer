#include "kstdio.h"
#include "rs232.h"
#include <stdarg.h>

int kputch(int c) { return _putch(c); }
int kgetch(void)  { return _getch(); }

void kputs(const char *s) {
    while (*s) kputch(*s++);
}

static void kput_u32_hex(uint32_t v) {
    static const char *hex = "0123456789abcdef";
    for (int i = 28; i >= 0; i -= 4) {
        kputch(hex[(v >> i) & 0xF]);
    }
}

static void kput_u32_dec(uint32_t v) {
    char buf[10];
    int n = 0;
    if (v == 0) { kputch('0'); return; }
    while (v && n < (int)sizeof(buf)) {
        buf[n++] = (char)('0' + (v % 10));
        v /= 10;
    }
    while (n--) kputch(buf[n]);
}

static void kput_i32_dec(int32_t v) {
    if (v < 0) { kputch('-'); kput_u32_dec((uint32_t)(-v)); }
    else kput_u32_dec((uint32_t)v);
}

void kprintf(const char *fmt, ...) {
    va_list ap;
    va_start(ap, fmt);

    for (; *fmt; fmt++) {
        if (*fmt != '%') { kputch(*fmt); continue; }
        fmt++;
        if (*fmt == 0) break;

        switch (*fmt) {
            case '%': kputch('%'); break;
            case 'c': kputch(va_arg(ap, int)); break;
            case 's': {
                const char *s = va_arg(ap, const char*);
                if (!s) s = "(null)";
                kputs(s);
            } break;
            case 'x': kput_u32_hex(va_arg(ap, uint32_t)); break;
            case 'u': kput_u32_dec(va_arg(ap, uint32_t)); break;
            case 'd': kput_i32_dec(va_arg(ap, int32_t)); break;
            default:
                kputch('?');
                break;
        }
    }

    va_end(ap);
}

// Tiny decimal integer input (blocking)
// Supports optional leading '-' and backspace.
// Ends on '\r' or '\n'.
int kgetint(void) {
    int sign = 1;
    int32_t val = 0;
    int started = 0;

    while (1) {
        int c = kgetch();

        if (c == '\r' || c == '\n') {
            kputch('\n');
            break;
        }

        if (c == '\b' || c == 127) { // backspace
            // super simple: ignore editing once started (keeps code tiny)
            continue;
        }

        if (!started && c == '-') {
            sign = -1;
            started = 1;
            continue;
        }

        if (c >= '0' && c <= '9') {
            started = 1;
            val = val * 10 + (c - '0');
        }
    }

    return (int)(sign * val);
}

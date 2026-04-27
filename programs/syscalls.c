#include <stdio.h>
#include <sys/stat.h>
#include "uart.h"

extern char _end;
static char *heap_ptr = &_end;

void *_sbrk(int incr) {
    char *prev = heap_ptr;
    heap_ptr += incr;
    return (void *)prev;
}

int _write(int fd, const void *buf, int len) {
    const char *p = (const char *)buf;
    for (int i = 0; i < len; i++) {
        if (p[i] == '\n')
            _putch('\r');
        _putch(p[i]);
    }
    return len;
}

int _read(int fd, void *buf, int len) {
    char *p = (char *)buf;
    int i = 0;
    while (i < len) {
        char c = (char)_getch();
        if (c == '\r' || c == '\n') {
            _putch('\r');
            _putch('\n');
            p[i++] = '\n';
            break;
        } else if (c == 0x08 || c == 0x7F) {
            if (i > 0) {
                i--;
                _putch(0x08);
                _putch(' ');
                _putch(0x08);
            }
        } else if (i < len - 1) {
            p[i++] = c;
            _putch(c);
        }
    }
    return i;
}

void _exit(int status)               { while (1); }
int  _close(int fd)                  { return -1; }
int  _fstat(int fd, struct stat *s)  { s->st_mode = S_IFCHR; return 0; }
int  _isatty(int fd)                 { return 1; }
int  _lseek(int fd, int o, int w)    { return 0; }
int  _kill(int pid, int sig)         { return -1; }
int  _getpid(void)                   { return 1; }
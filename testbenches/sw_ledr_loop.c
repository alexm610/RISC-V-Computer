#define SWITCHES    *(volatile unsigned char *)(0x300)
#define LEDR        *(volatile unsigned char *)(0x310)

void main (void) {
    while (1) {
        LEDR = SWITCHES;
    }
}
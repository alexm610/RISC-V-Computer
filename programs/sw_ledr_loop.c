#define SWITCHES    *(volatile unsigned long *)(0x300)
#define LEDR        *(volatile unsigned long *)(0x310)
#define HEX         *(volatile unsigned long *)(0x320)

int main (void) {
    while (1) {
        LEDR = SWITCHES;
    }
}
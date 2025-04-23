#define SWITCHES                *(volatile unsigned long *)(0x04000000)
#define LEDR                    *(volatile unsigned long *)(0x04000004)
#define HEX                     *(volatile unsigned long *)(0x04000008)

int main (void) {
    while (1) {
        LEDR = SWITCHES;
    }
}
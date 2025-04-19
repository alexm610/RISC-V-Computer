#define VGA         *(volatile unsigned long *)(0x330)
#define SWITCHES    *(volatile unsigned long *)(0x300)
#define LEDR        *(volatile unsigned long *)(0x310)



int main (void) {
    

    while (1) {
        LEDR = SWITCHES;
    }
}
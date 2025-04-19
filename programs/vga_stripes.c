#define VGA         *(volatile unsigned long *)(0x330)
#define SWITCHES    *(volatile unsigned long *)(0x300)
#define LEDR        *(volatile unsigned long *)(0x310)

int main (void) {
    int x, y, colour, vga_setting;

    colour = 0;
    for (y=0; y<120; y++) {
        for (x=0; x<160; x++) {
            VGA |= (y << 24) | (x << 16) | colour;
            colour++;
        }
    }

    while (1) {
        LEDR = SWITCHES;
    }
}
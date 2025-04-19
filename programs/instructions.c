#define VGA                     *(volatile unsigned long *)(0x04010000)
#define SWITCHES                *(volatile unsigned long *)(0x04000000)
#define LEDR                    *(volatile unsigned long *)(0x04000004)
#define HEX                     *(volatile unsigned long *)(0x04000008)
#define LCD_Command_Register    *(volatile unsigned long *)(0x0400000C)
#define LCD_Data_Register       *(volatile unsigned long *)(0x04000010)

int main (void) {
    int x, y, colour;

    colour = 0;
    for (y=0; y<120; y++) {
        for (x=0; x<160; x++) {
            VGA |= (y << 24) | (x << 16) | colour;
            colour++;
        }
    }

    while (1) {
        LEDR = SWITCHES;
        HEX = SWITCHES;
    }
}
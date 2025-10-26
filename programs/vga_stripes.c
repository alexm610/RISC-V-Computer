#include "instructions.h"

void print_stripes(void) {
    int x, y, colour;

    colour = 0;
    for (y=0; y<120; y++) {
        for (x=0; x<160; x++) {
            VGA |= (y << 24) | (x << 16) | colour;
            colour++;
        }
    }
}
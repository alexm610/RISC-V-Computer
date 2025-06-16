#define SWITCHES                *(volatile unsigned long *)(0x04000000)
#define LEDR                    *(volatile unsigned long *)(0x04000004)

int main (void) {
    int x; 

    x = 4;


    while (1) {
        LEDR = SWITCHES;
    }
}
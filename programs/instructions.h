#define VGA                     *(volatile unsigned long *)(0x04010000)
#define SWITCHES                *(volatile unsigned long *)(0x00400000)
#define LEDR                    *(volatile unsigned long *)(0x00400004)
#define HEX                     *(volatile unsigned long *)(0x00400008)
#define LCD_Command_Register    *(volatile unsigned long *)(0x0040000C)
#define LCD_Data_Register       *(volatile unsigned long *)(0x00400010)
#define Timer0_Data_Register    *(volatile unsigned long *)(0x00400100)
#define Timer0_Control_Register *(volatile unsigned long *)(0x00400104)
#define RS232_Status            *(volatile unsigned long *)(0x05000014)
#define RS232_Data              *(volatile unsigned long *)(0x05000010)






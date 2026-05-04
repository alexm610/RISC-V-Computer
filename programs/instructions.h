#define VGA                     *(volatile unsigned long *)(0x04010000)
#define SWITCHES                *(volatile unsigned long *)(0x00400000)
#define LEDR                    *(volatile unsigned long *)(0x00400004)
#define HEX                     *(volatile unsigned long *)(0x00400008)
#define LCD_Command_Register    *(volatile unsigned long *)(0x0040000C)
#define LCD_Data_Register       *(volatile unsigned long *)(0x00400010)
#define Timer0_Data_Register    *(volatile unsigned long *)(0x00400100)
#define Timer0_Control_Register *(volatile unsigned long *)(0x00400104)
#define SPI_Control         (*(volatile unsigned long *)(0x00408020))  // [4:2]=000
#define SPI_Status          (*(volatile unsigned long *)(0x00408024))  // [4:2]=001
#define SPI_Data            (*(volatile unsigned long *)(0x00408028))  // [4:2]=010
#define SPI_Ext             (*(volatile unsigned long *)(0x0040802C))  // [4:2]=011
#define SPI_CS              (*(volatile unsigned long *)(0x00408030))  // [4:2]=100
#define Enable_SPI_CS()     SPI_CS = 0xFE
#define Disable_SPI_CS()    SPI_CS = 0xFF
#define SR_SPIF             7
#define SR_WCOL             6

#define VGA                     *(volatile unsigned long *)(0x04010000)
#define SWITCHES                *(volatile unsigned long *)(0x00400000)
#define LEDR                    *(volatile unsigned long *)(0x00400004)
#define HEX                     *(volatile unsigned long *)(0x00400008)
#define LCD_Command_Register    *(volatile unsigned long *)(0x0040000C)
#define LCD_Data_Register       *(volatile unsigned long *)(0x00400010)
#define Timer0_Data_Register    *(volatile unsigned long *)(0x00400100)
#define Timer0_Control_Register *(volatile unsigned long *)(0x00400104)
#define SPI_Control             *(volatile unsigned long *)(0x00408020)  
#define SPI_Status              *(volatile unsigned long *)(0x00408024)  
#define SPI_Data                *(volatile unsigned long *)(0x00408028)  
#define SPI_Ext                 *(volatile unsigned long *)(0x0040802C)  
#define SPI_CS                  *(volatile unsigned long *)(0x00408030)  
#define AUDIO_I2S_CONTROL       *(volatile unsigned long *)(0x00409000)
#define AUDIO_I2S_STATUS        *(volatile unsigned long *)(0x00409004)
#define AUDIO_I2S_TXDATA        *(volatile unsigned long *)(0x00409008)
#define AUDIO_I2S_BCLK_DIV      *(volatile unsigned long *)(0x0040900C)
#define AUDIO_I2S_RXDATA        *(volatile unsigned long *)(0x00409010)
#define AUDIO_I2C_CONTROL       *(volatile unsigned long *)(0x00409100)
#define AUDIO_I2C_STATUS        *(volatile unsigned long *)(0x00409104)
#define AUDIO_I2C_DATA          *(volatile unsigned long *)(0x00409108)
#define AUDIO_I2C_RXDATA        *(volatile unsigned long *)(0x0040910C)
#define AUDIO_I2C_PRESCALE      *(volatile unsigned long *)(0x00409110)
#define AUDIO_I2C_COMMAND       *(volatile unsigned long *)(0x00409114)
#define Enable_SPI_CS()         SPI_CS = 0xFE
#define Disable_SPI_CS()        SPI_CS = 0xFF
#define SR_SPIF                 7
#define SR_WCOL                 6
#define AUDIO_I2S_ENABLE        0x00000001
#define AUDIO_I2S_CLEAR_FIFO    0x00000002
#define AUDIO_I2S_MUTE          0x00000004
#define AUDIO_I2S_CLEAR_UNDERRUN 0x00000008
#define AUDIO_I2S_TX_READY      0x00000001
#define AUDIO_I2S_TX_EMPTY      0x00000002
#define AUDIO_I2S_TX_FULL       0x00000004
#define AUDIO_I2S_UNDERRUN      0x00000008
#define AUDIO_I2C_ENABLE        0x00000001
#define AUDIO_I2C_TIP           0x00000002
#define AUDIO_I2C_BUSY          0x00000004
#define AUDIO_I2C_RX_ACK        0x00000008
#define AUDIO_I2C_DONE          0x00000010
#define AUDIO_I2C_START         0x00000001
#define AUDIO_I2C_STOP          0x00000002
#define AUDIO_I2C_READ          0x00000004
#define AUDIO_I2C_WRITE         0x00000008
#define AUDIO_I2C_NACK          0x00000010

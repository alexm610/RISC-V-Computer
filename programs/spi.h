void SPI_Init(void);
int  TestForSPITransmitDataComplete(void) ;
void ReadStatusRegisterBUSY(void);
void WaitForSPITransmitComplete(void);
int  WriteSPIChar(int, int);
void WritePage(volatile unsigned char *memory_address, int flash_address);
void WriteProgramToFlash(void);
void ReadPageVerify(volatile unsigned char *memory_address, int flash_address, int);

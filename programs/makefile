CC       = riscv32-unknown-elf-gcc
OBJCOPY  = riscv32-unknown-elf-objcopy
SREC     = srec_cat
HEXDUMP  = hexdump

CFLAGS   = -march=rv32i_zicsr -mabi=ilp32 -Wall -O2
LDFLAGS  = -T linker.ld --specs=nano.specs -nostartfiles
LIBS     = -lc -lm -lgcc

OFLAGS      = -O binary
SRECFLAGS1  = -Output -Memory_Initialization_File 32
SRECFLAGS2  = -Output_Block_Size 4 -DISable Execution_Start_Address
SRECFLAGS3  = -byte-swap 4
HEXDUMPFLAGS = -v -e '"%08x\n"'

OBJS = instructions.elf
BINS = instructions.bin
SRECS = instructions.srec
MIFS = instructions.mif

SRCS = start.s instructions.c uart.c lcd_display.c vga.c irq_handler.c syscalls.c spi.c framebuffer.c diskio.c ff.c sd_spi.c
HDRS = instructions.h vga.h uart.h lcd_display.h irq_handler.h spi.h framebuffer.h diskio.h ff.h ffconf.h sd_spi.h

all: instructions.mif

instructions.mif: $(SRECS)
	$(SREC) $(SRECFLAGS1) $(SRECS) $(SRECFLAGS2) > $(MIFS)
	@echo Compilation complete.

instructions.srec: $(BINS)
	$(HEXDUMP) $(HEXDUMPFLAGS) $(BINS) > instructions.hex
	$(SREC) $(BINS) -binary -o output1.srec
	$(SREC) output1.srec $(SRECFLAGS3) > output2.srec
	$(SREC) output2.srec -fill 0x00 -within output2.srec -range-padding 4 > $(SRECS)

instructions.bin: $(OBJS)
	$(OBJCOPY) $(OFLAGS) $(OBJS) $(BINS)

instructions.elf: $(SRCS) $(HDRS)
	$(CC) $(CFLAGS) $(LDFLAGS) -o $(OBJS) $(SRCS) $(LIBS)

clean:
	$(RM) -f *.bin *.elf *.mif *.srec *.hex output1.srec output2.srec

CC      = riscv32-unknown-elf-gcc
OBJCOPY = riscv32-unknown-elf-objcopy
SREC    = srec_cat
HEXDUMP = hexdump

CFLAGS  = -Os -Wall -Wextra -ffunction-sections -fdata-sections -march=rv32i -mabi=ilp32
LDFLAGS = -nostartfiles -T linker.ld -Wl,--gc-sections

OFLAGS  = -O binary

SRECFLAGS1 = -Output -Memory_Initialization_File 32
SRECFLAGS2 = -Output_Block_Size 4 -DISable Execution_Start_Address
SRECFLAGS3 = -byte-swap 4
HEXDUMPFLAGS = -v -e '"%08x\n"'

SRCS = instructions.c rs232.c lcd_display.c vga.c irq_handler.c kstdio.c
ASMS = start.s
OBJS = $(SRCS:.c=.o) $(ASMS:.s=.o)

all: instructions.mif

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

%.o: %.s
	$(CC) $(CFLAGS) -c $< -o $@

instructions.elf: $(OBJS) linker.ld
	$(CC) $(LDFLAGS) -o $@ $(OBJS)

instructions.bin: instructions.elf
	$(OBJCOPY) $(OFLAGS) $< $@

instructions.srec: instructions.bin
	$(HEXDUMP) $(HEXDUMPFLAGS) instructions.bin > instructions.hex
	$(SREC) instructions.bin -binary -o output1.srec
	$(SREC) output1.srec $(SRECFLAGS3) > output2.srec
	$(SREC) output2.srec -fill 0x00 -within output2.srec -range-padding 4 > instructions.srec

instructions.mif: instructions.srec
	$(SREC) $(SRECFLAGS1) instructions.srec $(SRECFLAGS2) > instructions.mif
	@echo Compilation complete.

clean:
	$(RM) -f *.o *.bin *.elf *.mif *.srec *.hex output1.srec output2.srec

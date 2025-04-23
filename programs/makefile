CC = riscv32-unknown-elf-gcc
OBJCOPY = riscv32-unknown-elf-objcopy
SREC = srec_cat
HEXDUMP = hexdump
CFLAGS = -o
LDFLAGS = -nostdlib -T
OFLAGS = -O binary
SRECFLAGS1 = -Output -Memory_Initialization_File 32
SRECFLAGS2 = -Output_Block_Size 4 -DISable Execution_Start_Address
SRECFLAGS3 = -byte-swap 4
HEXDUMPFLAGS = -e '"%08x\n"'
OBJS = instructions.elf
BINS = instructions.bin
SRECS = instructions.srec
MIFS = instructions.mif

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

instructions.elf: instructions.c
	$(CC) $(LDFLAGS) linker.ld $(CFLAGS) instructions.elf start.s instructions.c

clean: 
	$(RM) -f *.bin *.elf *.mif *.srec
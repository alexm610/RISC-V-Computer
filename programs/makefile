CC = riscv32-unknown-elf-gcc
OBJCOPY = riscv32-unknown-elf-objcopy
SREC = srec_cat
CFLAGS = -o
LDFLAGS = -nostdlib -T
OFLAGS = -O binary
SRECFLAGS1 = -Output -Memory_Initialization_File 32
SRECFLAGS2 = -Output_Block_Size 4 -DISable Execution_Start_Address
SRECFLAGS3 = -byte-swap 4
OBJS = instructions.elf
BINS = instructions.bin
SRECS = instructions.srec
MIFS = instructions.mif

instructions.mif: $(SRECS)
	$(SREC) $(SRECFLAGS1) $(SRECS) $(SRECFLAGS2) > $(MIFS)
	@echo Compilation complete. 

instructions.srec: $(BINS)
	$(SREC) $(BINS) -binary -o output.srec
	$(SREC) output.srec $(SRECFLAGS3) > $(SRECS)

instructions.bin: $(OBJS)
	$(OBJCOPY) $(OFLAGS) $(OBJS) $(BINS)

instructions.elf: instructions.c
	$(CC) $(LDFLAGS) linker.ld $(CFLAGS) instructions.elf start.s instructions.c

clean: 
	$(RM) -f *.bin *.elf *.mif *.srec
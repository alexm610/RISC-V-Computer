CC = riscv32-unknown-elf-as
OBJCPY = riscv32-unknown-elf-objcopy 
HEXDUMP = hexdump
SREC = srec_cat
HEXDUMPFLAGS = -e '"%08x\n"'
CFLAGS = -o 
OFLAGS = -O binary
SRECFLAGS1 = -Output -Memory_Initialization_File 32
SRECFLAGS2 = -Output_Block_Size 4 -DISable Execution_Start_Address
OBJS = instructions.o
BINS = instructions.bin
SRECS = output.srec

instructions.mif: $(SRECS)
	$(SREC) $(SRECFLAGS1) $(SRECS) $(SRECFLAGS2) > instructions.mif
	@echo MIF file built...
	@echo Compilation complete.


instructions.o: instructions.s
	$(CC) instructions.s $(CFLAGS) instructions.o
	@echo Object file built...

instructions.bin: $(OBJS)
	$(OBJCPY) $(OFLAGS) $(OBJS) instructions.bin 
	@echo Binary file built...

instructions.srec: $(BINS)
	$(HEXDUMP) $(HEXDUMPFLAGS) $(BINS) > instructions.hex
	@echo HEX file built...
	$(SREC) $(BINS) -binary -o instructions.srec
	@echo SRecord built...
	
output.srec: instructions.srec 
	$(SREC) instructions.srec -byte-swap 4 > output.srec
	@echo SRecord byte-swapped to little-endian...

clean:
	$(RM) -f *.o *.srec *.bin *.hex *.mif 2>NUL

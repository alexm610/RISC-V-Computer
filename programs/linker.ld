ENTRY(_start)

/* ROM is 4096 words of 32-bit => 4096*4 = 16384 bytes */
MEMORY
{
    ROM (rx)  : ORIGIN = 0x00000000, LENGTH = 16K
    RAM (rwx) : ORIGIN = 0x08000000, LENGTH = 4K
}

SECTIONS
{
  /* ---------------- ROM ---------------- */

  .text : {
    . = ALIGN(4);
    *(.text*)
    *(.text.*)
  } > ROM

  .rodata : {
    . = ALIGN(4);
    *(.rodata*)
    *(.srodata*)
  } > ROM

  /* Any initialized data lives in RAM at runtime but its *image* lives in ROM */
  .data : {
    . = ALIGN(4);
    _data_start = .;
    *(.data*)
    *(.sdata*)
    _data_end = .;
  } > RAM AT> ROM
  _data_lma = LOADADDR(.data);

  /* Provide global pointer for RISC-V small data accesses */
  PROVIDE(__global_pointer$ = _data_start + 0x800);

  /* ---------------- RAM ---------------- */

  .bss : {
    . = ALIGN(4);
    _bss_start = .;
    *(.bss*)
    *(.sbss*)
    *(COMMON)
    _bss_end = .;
  } > RAM

  /* end of statics; useful even if you don't use malloc */
  _end = .;

  .stack : {
    . = ORIGIN(RAM) + LENGTH(RAM);
    _stack_top = .;
  } > RAM

    /* ---- Sanity check: ROM image must fit ---- */
  PROVIDE(__rom_image_end = LOADADDR(.data) + SIZEOF(.data));
  ASSERT(__rom_image_end <= (ORIGIN(ROM) + LENGTH(ROM)), "ROM overflow: image exceeds 4096 words")
}
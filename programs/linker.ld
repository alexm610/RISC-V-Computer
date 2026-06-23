ENTRY(_start)
MEMORY
{
    ROM (rx)  : ORIGIN = 0x00000000, LENGTH = 128K
    /* RAM capped at 56M so it ends at 0x0B800000.  The top 8MB of the 64MB
       SDRAM (CPU 0x0B800000-0x0BFFFFFF, physical 0x03800000-0x03FFFFFF) is
       reserved for the framebuffer + double buffer and is intentionally
       OUTSIDE this region so stack/heap/data/bss never land in video memory. */
    RAM (rwx) : ORIGIN = 0x08000000, LENGTH = 56M
}
SECTIONS
{
  .text : {
    . = ALIGN(4);
    *(.text.startup)       /* _start must land at 0x00000000 */
    *(.text*)
    *(.text.*)
  } > ROM
  .rodata : {
    . = ALIGN(4);
    *(.rodata*)
    *(.srodata*)
  } > ROM
  .data : {
    . = ALIGN(4);
    _data_start = .;
    *(.data*)
    *(.sdata*)
    _data_end = .;
  } > RAM AT> ROM
  _data_lma = LOADADDR(.data);
  PROVIDE(__global_pointer$ = _data_start + 0x800);
  .bss : {
    . = ALIGN(4);
    _bss_start = .;
    *(.bss*)
    *(.sbss*)
    *(COMMON)
    _bss_end = .;
  } > RAM
  _end = .;
  .stack (NOLOAD) : {
    . = ORIGIN(RAM) + LENGTH(RAM);   /* = 0x0B800000, grows down, just below FB */
    _stack_top = .;
  } > RAM
  PROVIDE(__rom_image_end = LOADADDR(.data) + SIZEOF(.data));
  ASSERT(__rom_image_end <= (ORIGIN(ROM) + LENGTH(ROM)),
         "ROM overflow: image exceeds 128K")
}

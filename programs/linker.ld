ENTRY(_start)

MEMORY
{
    ROM (rx)  : ORIGIN = 0x00000000, LENGTH = 16K
    RAM (rwx) : ORIGIN = 0x08000000, LENGTH = 64M
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

  /* Must be after .data so _data_start is defined */
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
    . = ORIGIN(RAM) + LENGTH(RAM);
    _stack_top = .;
  } > RAM

  PROVIDE(__rom_image_end = LOADADDR(.data) + SIZEOF(.data));
  ASSERT(__rom_image_end <= (ORIGIN(ROM) + LENGTH(ROM)),
         "ROM overflow: image exceeds 16K")
}

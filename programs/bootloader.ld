ENTRY(_start)

MEMORY
{
    ROM     (rx)  : ORIGIN = 0x00000000, LENGTH = 128K

    /* Keep all live bootloader state away from the payload being copied to
       0x08000000.  This region is immediately below the video reservation. */
    BOOTRAM (rwx) : ORIGIN = 0x0B700000, LENGTH = 1M
}

SECTIONS
{
    .text : {
        . = ALIGN(4);
        *(.text.startup)
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
    } > BOOTRAM AT> ROM

    _data_lma = LOADADDR(.data);
    PROVIDE(__global_pointer$ = _data_start + 0x800);

    .bss (NOLOAD) : {
        . = ALIGN(4);
        _bss_start = .;
        *(.bss*)
        *(.sbss*)
        *(COMMON)
        _bss_end = .;
    } > BOOTRAM

    _end = .;

    .stack (NOLOAD) : {
        . = ORIGIN(BOOTRAM) + LENGTH(BOOTRAM);
        _stack_top = .;
    } > BOOTRAM

    PROVIDE(__rom_image_end = LOADADDR(.data) + SIZEOF(.data));

    ASSERT(__rom_image_end <= ORIGIN(ROM) + LENGTH(ROM),
           "Bootloader exceeds the 128 KiB ROM")
    ASSERT(_bss_end <= ORIGIN(BOOTRAM) + LENGTH(BOOTRAM),
           "Bootloader runtime data exceeds reserved RAM")
}

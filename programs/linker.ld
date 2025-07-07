ENTRY(_start)

MEMORY
{
    ROM (rx)  : ORIGIN = 0x00000000, LENGTH = 32K
    RAM (rwx) : ORIGIN = 0x08000000, LENGTH = 4K
}

SECTIONS
{
    .text : {
        . = ALIGN(4);
        *(.text*)
        *(.text.*)
    } > ROM

    .rodata : {
        . = ALIGN(4);
        *(.rodata*)
    } > ROM

    .data : AT(ADDR(.rodata) + SIZEOF(.rodata)) {
        . = ALIGN(4);
        _data_start = .;
        *(.data*)
        _data_end = .;
    } > RAM
    _data_lma = LOADADDR(.data);

    .bss : {
        _bss_start = .;
        *(.bss*)
        *(COMMON)
        _bss_end = .;
    } > RAM

    .stack : {
        . = ORIGIN(RAM) + LENGTH(RAM);
        _stack_top = .;
    } > RAM
}

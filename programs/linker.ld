ENTRY(_start)

MEMORY
{
    ROM (rx)    : ORIGIN = 0x00000000, LENGTH = 4K
    RAM (rwx)   : ORIGIN = 0x00000000, LENGTH = 64M
}

SECTIONS
{
    .text : {
        *(.text*)
    } > RAM

    .data : {
        *(.data*)
    } > RAM

    .bss : {
        *(.bss*)
        *(COMMON)
    } > RAM

    .stack : {
        . = ORIGIN(RAM) + LENGTH(RAM);
        _stack_top = .; 
    } > RAM
}
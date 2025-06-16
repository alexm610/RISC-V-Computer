.section .text
.global _start
_start:
    # Set up stack
    la sp, _stack_top
    call main
    j .

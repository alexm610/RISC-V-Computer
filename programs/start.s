.section .text
.global _start
_start:
    la sp, _stack_top       # set sp to the top of the RAM (stack grows down)
    call main
    j .
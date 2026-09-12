.section .text.startup
.global _start
.extern main

_start:
    la sp, _stack_top

    .option push
    .option norelax
    la gp, __global_pointer$
    .option pop

    /* Copy initialized data from its ROM load address to bootloader RAM. */
    la t0, _data_lma
    la t1, _data_start
    la t2, _data_end
1:
    beq t1, t2, 2f
    lw  t3, 0(t0)
    sw  t3, 0(t1)
    addi t0, t0, 4
    addi t1, t1, 4
    j 1b

    /* Clear the bootloader BSS. */
2:
    la t1, _bss_start
    la t2, _bss_end
3:
    beq t1, t2, 4f
    sw  zero, 0(t1)
    addi t1, t1, 4
    j 3b

4:
    call main
5:
    j 5b

.section .text.startup
.global _start
.extern main
.extern timer_irq_handler
.extern default_irq_handler

_start:
    /* set stack pointer first */
    la sp, _stack_top

    /* set global pointer — norelax guards are mandatory */
    .option push
    .option norelax
    la gp, __global_pointer$
    .option pop

    /* copy .data from ROM to RAM */
    la t0, _data_lma
    la t1, _data_start
    la t2, _data_end
1:
    beq  t1, t2, 2f
    lw   t3, 0(t0)
    sw   t3, 0(t1)
    addi t0, t0, 4
    addi t1, t1, 4
    j    1b

    /* zero .bss */
2:
    la t1, _bss_start
    la t2, _bss_end
3:
    beq  t1, t2, 4f
    sw   zero, 0(t1)
    addi t1, t1, 4
    j    3b

    /* set mtvec to vectored mode — table must be 64-byte aligned */
4:
    la   t0, __vector_table
    li   t1, 1               /* MODE=1 → vectored */
    or   t0, t0, t1
    csrw mtvec, t0

    /* enable global machine interrupts (MIE bit 3 of mstatus) */
    li   t0, (1 << 3)
    csrs mstatus, t0

    /* enable machine timer interrupt (MTIE bit 7 of mie) */
    li   t0, (1 << 7)
    csrs mie, t0

    call main
    j    .                   /* trap if main returns */

/*
 * Vector table for vectored mtvec mode.
 * Hardware jumps to (mtvec & ~3) + cause*4 for interrupts.
 * Must be aligned to at least 64 bytes (next power of 2 >= 16*4).
 */
.align 6                     /* 2^6 = 64 byte alignment */
__vector_table:
    j default_irq_handler    /* IRQ 0  — user software */
    j default_irq_handler    /* IRQ 1  — supervisor software */
    j default_irq_handler    /* IRQ 2  — reserved */
    j default_irq_handler    /* IRQ 3  — machine software */
    j default_irq_handler    /* IRQ 4  — user timer */
    j default_irq_handler    /* IRQ 5  — supervisor timer */
    j default_irq_handler    /* IRQ 6  — reserved */
    j timer_irq_handler      /* IRQ 7  — machine timer (MTIP) */
    j default_irq_handler    /* IRQ 8  — user external */
    j default_irq_handler    /* IRQ 9  — supervisor external */
    j default_irq_handler    /* IRQ 10 — reserved */
    j default_irq_handler    /* IRQ 11 — machine external */
    j default_irq_handler    /* IRQ 12 */
    j default_irq_handler    /* IRQ 13 */
    j default_irq_handler    /* IRQ 14 */
    j default_irq_handler    /* IRQ 15 */
    
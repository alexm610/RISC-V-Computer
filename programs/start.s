.section .text
.global _start
.extern main
.extern timer_irq_handler
.extern default_irq_handler

_start:
    # Init SP
    la sp, _stack_top
    la gp, __global_pointer$

    # ------------------------
    # Copy .data from ROM to RAM
    # ------------------------
    la t0, _data_lma
    la t1, _data_start
    la t2, _data_end
1:
    beq t1, t2, 2f
    lw t3, 0(t0)
    sw t3, 0(t1)
    addi t0, t0, 4
    addi t1, t1, 4
    j 1b
2:
    # ------------------------
    # Zero .bss
    # ------------------------
    la t1, _bss_start
    la t2, _bss_end
3:
    beq t1, t2, 4f
    sw zero, 0(t1)
    addi t1, t1, 4
    j 3b
4:
    # ------------------------
    # Trap vector base (vectored)
    # ------------------------
    la t0, __vector_table
    li t1, 1
    or t0, t0, t1
    csrw mtvec, t0

    # Enable global machine interrupts (MIE in mstatus)
    li t0, 8
    # csrs mstatus, t0

    # Enable timer interrupts in mie (MTIE = 1 << 7)
    li t0, (1 << 7)
    # csrs mie, t0

    call main
    j .

.align 2
__vector_table:
    j default_irq_handler      # IRQ 0
    j default_irq_handler      # IRQ 1
    j default_irq_handler      # IRQ 2
    j default_irq_handler      # IRQ 3
    j default_irq_handler      # IRQ 4
    j default_irq_handler      # IRQ 5
    j default_irq_handler      # IRQ 6
    j timer_irq_handler        # IRQ 7
    j default_irq_handler      # IRQ 8
    j default_irq_handler      # IRQ 9
    j default_irq_handler      # IRQ 10
    j default_irq_handler      # IRQ 11
    j default_irq_handler      # IRQ 12
    j default_irq_handler      # IRQ 13
    j default_irq_handler      # IRQ 14
    j default_irq_handler      # IRQ 15

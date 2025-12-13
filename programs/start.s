.section .text
.global _start
.extern timer_irq_handler
.extern default_irq_handler

# ------------------------
# Start of program
# ------------------------
_start:
    # Initialize stack pointer
    la sp, _stack_top

    # Set mtvec for vectored mode (base address | 0x1)
    la t0, __vector_table
    li t1, 1               # vector mode
    or t0, t0, t1
    csrrw x0, mtvec, t0 

    # Enable global machine interrupts (MIE in mstatus)
    li t0, 8
    csrrs x0, mstatus, t0

    # Enable external interrupts in MIE (MEIE = 1 << 11)
    li t0, (1 << 7)
    # csrrs x0, mie, t0
    # csrrsi x0, mie, 11   # external
    csrrs x0, mie, t0     # timer
    # csrrsi x0, mie, 3    # software


    # Call main
    call main
    j .

.align 2
__vector_table:
    j default_irq_handler      # IRQ 0
    j default_irq_handler      # IRQ 1
    j default_irq_handler      # IRQ 2
    j default_irq_handler     # IRQ 3
    j default_irq_handler      # IRQ 4
    j default_irq_handler      # IRQ 5
    j default_irq_handler      # IRQ 6
    j timer_irq_handler        # IRQ 7
    j default_irq_handler      # IRQ 0
    j default_irq_handler      # IRQ 1
    j default_irq_handler      # IRQ 2
    j default_irq_handler     # IRQ 3
    j default_irq_handler      # IRQ 4
    j default_irq_handler      # IRQ 5
    j default_irq_handler      # IRQ 6
    j timer_irq_handler        # IRQ 7

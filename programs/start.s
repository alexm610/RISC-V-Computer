.section .text
.global _start
.global _trap_entry
.extern trap_handler

# ------------------------
# Start of program
# ------------------------
_start:
    # Initialize stack pointer
    la sp, _stack_top

    # Set mtvec for vectored mode (base address | 0x1)
    la t0, _trap_entry
    li t1, 0               # direct mode
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

# ------------------------
# Trap entry stub (C callable)
# ------------------------
# Note: vectored interrupts jump to mtvec_base + 4*irq, so we
# can have separate entry points per interrupt if needed. Here
# we keep a single stub that C will dispatch.

_trap_entry:
    # Save caller-saved registers
    addi sp, sp, -64
    sw ra,   0(sp)
    sw t0,   4(sp)
    sw t1,   8(sp)
    sw t2,  12(sp)
    sw a0,  16(sp)
    sw a1,  20(sp)
    sw a2,  24(sp)
    sw a3,  28(sp)
    sw a4,  32(sp)
    sw a5,  36(sp)
    sw a6,  40(sp)
    sw a7,  44(sp)
    sw t3,  48(sp)
    sw t4,  52(sp)
    sw t5,  56(sp)
    sw t6,  60(sp)

    # Call C handler
    call trap_handler

    # Restore registers
    lw ra,   0(sp)
    lw t0,   4(sp)
    lw t1,   8(sp)
    lw t2,  12(sp)
    lw a0,  16(sp)
    lw a1,  20(sp)
    lw a2,  24(sp)
    lw a3,  28(sp)
    lw a4,  32(sp)
    lw a5,  36(sp)
    lw a6,  40(sp)
    lw a7,  44(sp)
    lw t3,  48(sp)
    lw t4,  52(sp)
    lw t5,  56(sp)
    lw t6,  60(sp)
    addi sp, sp, 64

    # Return from trap
    mret

/* ROM copies this payload into RAM before calling it. No preloaded RAM. */
.option norvc
.section .text
.global _start
_start:
    la t0, rom_irq
    csrw mtvec, t0
    li t0, 128
    csrw mie, t0
    li t0, 8
    csrw mstatus, t0
    li s0, 0x08000000
    la t0, __ram_load
    mv t1, s0
    la t2, __ram_end
copy:
    lw t3, 0(t0)
    sw t3, 0(t1)
    addi t0, t0, 4
    addi t1, t1, 4
    bne t1, t2, copy
    /* Link and base may be the same register; target bit zero is ignored. */
    mv ra, s0
    jalr ra, 1(ra)
    li t0, 0x00400000
    li t1, 0x600d
    sw t1, 0(t0)
    j .
fail:
    li t0, 0x00400000
    li t1, 0xbad
    sw t1, 0(t0)
    j .
.balign 4
rom_irq:
    addi s2, s2, 1
    mret

.section .ramtext, "ax"
.global ram_entry
ram_entry:
    li s1, 0x08001000
    li t0, 0x12345678
    sw t0, 0(s1)
    lw t1, 0(s1)
    bne t0, t1, ram_fail
    li t0, -128
    sb t0, 1(s1)
    lb t1, 1(s1)
    bne t0, t1, ram_fail
    lbu t1, 1(s1)
    li t2, 128
    bne t1, t2, ram_fail
    li t0, -32768
    sh t0, 2(s1)
    lh t1, 2(s1)
    bne t0, t1, ram_fail
    lhu t1, 2(s1)
    li t2, 32768
    bne t1, t2, ram_fail
    /* Read the same instruction as data, from both RAM and its ROM image. */
    lw t0, 0(s0)
    la t1, __ram_load
    lw t1, 0(t1)
    bne t0, t1, ram_fail
    /* The bench requests an IRQ when this MMIO marker is written. */
    li t0, 0x00400004
    li t1, 1
    sw t1, 0(t0)
wait_rom_irq:
    beq s2, zero, wait_rom_irq
    /* Now prove that the interrupt vector itself may live in RAM. */
    la t0, ram_irq
    csrw mtvec, t0
    li t0, 0x00400004
    li t1, 2
    sw t1, 0(t0)
wait_ram_irq:
    bne s2, t1, wait_ram_irq
    ret
ram_fail:
    la t0, fail
    jr t0
.balign 4
ram_irq:
    addi s2, s2, 1
    mret

.global _boot
.text

_boot:               
	addi x1, x0, 768
    addi x2, x0, 784
    
_loop:
    lw x6, 0(x1)
    sw x6, 0(x2)
    beq x0, x0, _loop


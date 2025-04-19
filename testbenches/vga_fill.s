.global _boot
.text

_boot:
	addi x21, x0, 160    
    addi x22, x0, 120   
    addi x24, x0, 8     
    addi x23, x0, 816
    addi x3, x0, 0      
    addi x1, x0, 0      
    addi x2, x0, 0      
    beq x0, x0, _fill


_fill:
    andi x7, x0, 0      
    slli x4, x1, 16     
    slli x5, x2, 24     
    or x7, x7, x3       
    or x7, x7, x4       
    or x7, x7, x5       
    sw x7, 0(x23)        
    bge x1, x21, _incY  
    addi x1, x1, 1      
    addi x3, x3, 1      
    blt x3, x24, _fill  
    addi x3, x0, 0      
    beq x0, x0, _fill

_incY:
    addi x2, x2, 1      
    bge x2, x22, _end   
    addi x1, x0, 0      
    beq x0, x0, _fill   
	
_end: 
    addi x1, x0, 128
    addi x2, x0, 144

_loop:
    lw x6, 0(x1)
    sw x6, 0(x2)
    beq x0, x0, _loop

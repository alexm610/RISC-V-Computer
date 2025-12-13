#include <stdint.h>
#include "instructions.h"
#include "irq_handler.h"

volatile uint32_t timer_ticks = 0;

void __attribute__((interrupt)) timer_irq_handler(void) {
    timer_ticks++;
    Timer0_Control_Register = 0x3;
}

void __attribute__((interrupt)) default_irq_handler(void) {
    ;;
}
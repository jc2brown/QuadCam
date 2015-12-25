
#include <stdint.h>




typedef void (*isr_fcn)(void);



void register_interrupt(uint32_t isr_id, isr_fcn isr);
void enable_interrupts();
void disable_interrupts();
void init_interrupts();

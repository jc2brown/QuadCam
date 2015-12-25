

#include "mb_interface.h"


#include "peripherals.h"

#include "interrupts.h"

void nop_isr() {}


isr_fcn irq_vectors[32] = { nop_isr };
uint32_t irq_enable = 0;


void master_isr(void) __attribute__ ((interrupt_handler ));
void master_isr() {

	uint32_t irq_status_w = IRQ_STATUS & irq_enable;
	uint8_t *irq_status_ba = (uint8_t*)&irq_status_w;
	uint32_t irq_mask;
	const isr_fcn* irq_vector_ptr;

	int b, i;

	for ( b = 0; irq_status_w && b < 4; ++b ) {

		irq_mask = 0x00000001 << (8*b);
		irq_vector_ptr = irq_vectors+(8*b);

		for ( i = 0; irq_status_ba[b] && i < 8; ++i ) {

			if ( irq_status_w & irq_mask ) {
				(*irq_vector_ptr)();
				irq_status_w &= ~irq_mask;
				IRQ_ACK |= irq_mask;
			}

			irq_mask <<= 1;
			irq_vector_ptr += 1;
		}
	}
}





void register_interrupt(uint32_t isr_id, isr_fcn isr) {
	irq_vectors[isr_id] = isr;
	irq_enable |= IRQ_FLAG(isr_id);
}

void enable_interrupts() {
	IRQ_ENABLE = irq_enable;
	microblaze_enable_interrupts();
}

void disable_interrupts() {
	microblaze_disable_interrupts();
	IRQ_ENABLE = 0;
}



void init_interrupts() {
	IRQ_ENABLE = 0;
	IRQ_ACK = IRQ_STATUS; // Reset all pending interrupts
	irq_enable = 0;
}

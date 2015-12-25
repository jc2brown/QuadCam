
#include <stdint.h>
#include "iobus.h"
#include "delay.h"


// Simple hardware timer
// Blocks for the specified number of microseconds
void delay_us(uint32_t us) {
	TIMER = us;
}


void delay_ms(uint32_t ms) {
	int i;
	for ( i = 0; i < ms; ++i ) {
		delay_us(1000);
	}
}

void delay_s(uint32_t s) {
	int i;
	for ( i = 0; i < s; ++i ) {
		delay_ms(1000);
	}
}

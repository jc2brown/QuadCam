
#include "peripherals.h"
#include "iobus.h"
#include "util.h"


// Transmit a character over UART TXD when the TX buffer is empty
void printc(const char c) {
	while ( UART_STATUS & IRQ_FLAG(IRQ_UART_TX_ID) );
	UART_TX = (uint32_t)c;
}

// Transmits a string over UART TXD
void prints(const char *str) {
	for ( ; *str != '\0'; ++str ) {
		printc(*str);
		delay_us(2);
	}
}

// Writes a string to a single memory address one character at a time
void printios(volatile uint32_t *addr, const char *str) {
	for ( ; *str != '\0'; ++str ) {
		*addr = (uint32_t)*str;
	}
}

void printio8(volatile uint32_t *addr, const uint8_t *str, uint32_t n) {
	uint32_t i;
	for ( i = 0; i < n; ++i ) {
		*addr = (uint32_t)str[i];
	}
}

void printio32(volatile uint32_t *addr, const uint32_t *str, uint32_t n) {
	uint32_t i;
	for ( i = 0; i < n; ++i ) {
		*addr = (uint32_t)str[i];
	}
}


#include <stdint.h>
#include <stdio.h>
#include "device.h"
#include "iobus.h"
#include "outbyte.h"
#include "quadcam.h"
#include "delay.h"

#include "uart.h"

static uint32_t uart_forced_baud_delay = 0;

const uint32_t valid_baudrates[N_BAUDRATES] = {
		9600, 19200, 38400, 57600,
		115200, 230400, 921600, 1000000,
		2000000, 3000000, 4000000, 6000000
};

void uart_outbyte(char c) {
	while ( FAST_UART_STATUS & FAST_UART_STATUS_FLAG_TX_FULL ); // Wait until not full
	FAST_UART_TX = c;
	//while ( ! (FAST_UART_STATUS & FAST_UART_STATUS_FLAG_TX_EMPTY) ); // Enable this line if UART TX is misbehaving
}


// UART TX fifo reports not empty for a long time -- why?
// If this flag is 0, the empty check is bypassed to eliminate a 20sec wait on startup
// UART may not work if checks are bypassed
#define WAIT_FOR_EMPTY 0

void set_uart_baudrate(uint32_t uart_baudrate) {
#if WAIT_FOR_EMPTY
	while ( ! (FAST_UART_STATUS & FAST_UART_STATUS_FLAG_TX_EMPTY) ); // Wait until FIFO is empty
#endif
	delay_us(uart_forced_baud_delay);
	set_clk_frequency(&UART_BAUD_DIV, 2*uart_baudrate);
	//UART_BAUD_DIV = MCU_CLK_FREQ / uart_baudrate;
	uart_forced_baud_delay = (1000000*10)/uart_baudrate;
}

uint32_t uart_reset(uint32_t subid) {
	int i;
	FAST_UART_RX_SRC = 0;
	FAST_UART_TX_SRC = FAST_UART_TX_SRC_UART_TX;

	store_outbytes();
	add_outbyte(uart_outbyte);
	for ( i = 0; i < N_BAUDRATES; ++i ) {
		set_uart_baudrate(valid_baudrates[i]);
		xil_printf("\n\nUse %d baud +/- 5%%\n\n", DEFAULT_UART_BAUDRATE);
	}
	recall_outbytes();

	set_uart_baudrate(DEFAULT_UART_BAUDRATE);

	FAST_UART_TX = '!';
	return 0;
}


uint32_t uart_init(uint32_t subid) {
	return 0;
}


uint32_t uart_probe(uint32_t subid) {
	uint32_t status = 0;
	int rx = FAST_UART_STATUS & FAST_UART_STATUS_FLAG_RX_PINSTATE;
	if ( ! rx ) {
		status |= IODEVICE_PROBE_FAIL;
	}
	if ( rx ) {
		status |= IODEVICE_PROBE_PASS;
	}
	return status;
}

uint32_t uart_check(uint32_t subid) {
	uint32_t status = 0;
	return status;
}

void uart_description(uint32_t subid) {
	xil_printf("Generic TTL UART\n");
}

IODevice uart = {
		.subid = 0,
		.name = "UART",
		.details = uart_description,
		.status = 0,
		.reset = uart_reset,
		.init = uart_init,
		.probe = uart_probe,
		.check = check_stub,
		.test = test_stub
};

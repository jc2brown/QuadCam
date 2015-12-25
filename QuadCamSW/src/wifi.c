
#include <stdint.h>
#include <stdio.h>

#include "device.h"
#include "iobus.h"
#include "quadcam.h"
#include "delay.h"

#include "wifi.h"

// The tx fifo seems to lose bytes, so
static uint32_t wifi_forced_baud_delay = 0;




void wifi_outbyte(char c) {
	while ( WIFI_STATUS & WIFI_STATUS_FLAG_TX_FULL ); // Wait until not full
	WIFI_TX = c;
	while ( ! (WIFI_STATUS & WIFI_STATUS_FLAG_TX_EMPTY) ); // TX EMPTY? // Enable this line if UART TX is misbehaving
	//delay_us(wifi_forced_baud_delay);
}

void set_wifi_baudrate(uint32_t wifi_baudrate) {
	while ( ! (WIFI_STATUS & WIFI_STATUS_FLAG_TX_EMPTY) ) { // Wait until FIFO is empty
		delay_us(wifi_forced_baud_delay);
	}
	delay_us(wifi_forced_baud_delay);
	set_clk_frequency(&WIFI_BAUD_DIV, 2*wifi_baudrate);
	//WIFI_BAUD_DIV = MCU_CLK_FREQ / wifi_baudrate;
	wifi_forced_baud_delay = (1000000*10)/wifi_baudrate;
}



void print_loop() {
	while(1) {
		while( ! (WIFI_STATUS & WIFI_STATUS_FLAG_RX_EMPTY) ) {
			uart_outbyte(WIFI_RX);
		}
	}
}



uint32_t wifi_reset(uint32_t subid) {
	return 0;
}



uint32_t wifi_init(uint32_t subid) {
	WIFI_ENABLE = 0;
	WIFI_RX_SRC = 0;
	WIFI_TX_SRC = WIFI_TX_SRC_WIFI_TX;

	WIFI_RXD = 1;
	WIFI_RXD_OUTPUT_ENABLE = 1;

	WIFI_GPIO = 0xFF;
	WIFI_GPIO_OUTPUT_ENABLE = 0xFF;

	WIFI_RX_SRC = 0;
	set_wifi_baudrate(DEFAULT_WIFI_BAUDRATE);


	WIFI_ENABLE = 3;
	delay_ms(100);

	WIFI_RXD_OUTPUT_ENABLE = 0;

}



uint32_t wifi_probe(uint32_t subid) {
	uint32_t status = 0;


	WIFI_ENABLE = 0;

//	WIFI_RX_SRC = WIFI_RX_SRC_RXD;
//	WIFI_TX_SRC = WIFI_TX_SRC_WIFI_RX;

	WIFI_RXD = 1;
	WIFI_RXD_OUTPUT_ENABLE = 1;

	WIFI_GPIO = 0xFF;
	WIFI_GPIO_OUTPUT_ENABLE = 0xFF;

	WIFI_ENABLE = 3;
	delay_ms(100);

	WIFI_GPIO_OUTPUT_ENABLE = 0x00;



	// The ESP should now be driving its TXD pin (our RXD pin) high
	// We apply a pulldown internally so if we detect a low instead of a high,
	// we will assume the module is not present


	WIFI_RXD_OUTPUT_ENABLE = 0;
	delay_us(1); // Allow pin to settle

	int rx = WIFI_STATUS & WIFI_STATUS_FLAG_RX_PINSTATE;


		if ( ! rx ) {
			status |= IODEVICE_PROBE_FAIL;
		}
		if ( rx ) {
			status |= IODEVICE_PROBE_PASS;
		}

	return status;

}

uint32_t wifi_check(uint32_t subid) {
	uint32_t status = 0;

	return status;
}


void wifi_description(uint32_t subid) {
	xil_printf("ESP8266 WiFi 2.4GHz Module\n");
}

IODevice wifi = {
		.subid = 0,
		.name = "WIFI",
		.details = wifi_description,
		.status = 0,
		.reset = wifi_reset,
		.init = init_stub,
		.probe = wifi_probe,
		.check = check_stub,
		.test = test_stub
};




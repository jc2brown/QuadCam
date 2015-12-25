
#include <stdint.h>
#include <stdio.h>

#include "delay.h"

#include "device.h"
#include "iobus.h"

#include "fpga.h"




void set_led_clk_frequency(uint32_t led_clk_freq) {
	LEDCLK_DIV = MCU_CLK_FREQ / (7*2*led_clk_freq);
}

void set_led_latch_frequency(uint32_t led_latch_freq) {
	LED_LATCH_DIV = (MCU_CLK_FREQ) / (2*led_latch_freq);
}

void set_flash_clk_frequency(uint32_t flash_clk_freq) {
	FLASH_CLK_DIV = MCU_CLK_FREQ / (2*flash_clk_freq);
}



/*
void heartbeat_fatal() {
	set_flash_clk_frequency(1000);
	FLASH_ON = 100;
	FLASH_MAX = 200;
	ERROR_LED_SRC = ERROR_LED_SRC_FLASH;
}

void heartbeat_alert() {
	set_flash_clk_frequency(1000);
	FLASH_ON = 400;
	FLASH_MAX = 500;
	ERROR_LED_SRC = ERROR_LED_SRC_FLASH;
}

void heartbeat_error() {
	set_flash_clk_frequency(1000);
	FLASH_ON = 1400;
	FLASH_MAX = 1500;
	ERROR_LED_SRC = ERROR_LED_SRC_FLASH;
}

void heartbeat_rapid() {
	set_flash_clk_frequency(1000);
	FLASH_ON = 100;
	FLASH_MAX = 500;
	ERROR_LED_SRC = ERROR_LED_SRC_FLASH;
}

void heartbeat_normal() {
	set_flash_clk_frequency(1000);
	FLASH_ON = 100;
	FLASH_MAX = 1500;
	ERROR_LED_SRC = ERROR_LED_SRC_FLASH;
}
*/




static uint32_t fpga_reset(uint32_t subid) {
	LEDS_SRC = 0xFFFFFFF0;
	ERROR_LED = 1;
	ERROR_LED_SRC = 1;
	return 0;
}

static uint32_t fpga_init(uint32_t subid) {
	int i;
	LEDS_SRC = 0x99999990;
	ERROR_LED_SRC = 1;
	FLASH_MAX = 1001;
	for ( i = 0; i < 1000; ++i ) {
		FLASH_ON = i;
		delay_ms(1);
	}
	LEDS_SRC = 0x000000F0;
	return 0;
}


static uint32_t fpga_probe(uint32_t subid) {
	uint32_t status = 0;
	status |= IODEVICE_PROBE_PASS;
	return status;
}



static void fpga_description(uint32_t subid) {
	xil_printf("Xilinx Spartan 6 XC6SLX16-2FTG256C\n");
}

IODevice fpga = {
		.subid = 0,
		.name = "FPGA",
		.details = fpga_description,
		.status = 0,
		.reset = fpga_reset,
		.init = fpga_init,
		.probe = fpga_probe,
		.check = check_stub,
		.test = test_stub
};

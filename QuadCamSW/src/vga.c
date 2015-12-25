#include <stdint.h>
#include <stdio.h>
#include "quadcam.h"
#include "device.h"
#include "vga.h"





int vga_page;

int get_vga_page() {
	return vga_page;
}



void set_vga_page(int page) {
	vga_page = page;
	if ( vga_page == vstripe_page ) {
		VGA_SRC = 0;
		VGA_TEST_MODE = 0;
	} else if ( vga_page == screensaver_page ) {
		VGA_SRC = 0;
		VGA_TEST_MODE = 1;
	} else {
		VGA_SRC = 1;
		VGA_FRAME_ADDR0 = page_addrs[page];
		VGA_FRAME_ADDR1 = page_addrs[page];
		VGA_FRAME_ADDR2 = page_addrs[page];
		VGA_FRAME_ADDR3 = page_addrs[page];
	}
}





void vga_description(){
	xil_printf("Display 12bit 1280x1024 @ 60Hz\n");
}

uint32_t vga_reset(uint32_t subid) {
	VGA_SRC = 0;
	VGA_TEST_ENABLE = 0;
	VGA_TEST_MODE = 0;
	VGA_ENABLE = 0;
	return 0;
}


uint32_t vga_init(uint32_t subid) {
	volatile int i;
	VGA_SRC = 1;
	VGA_ENABLE = 1;
	delay_us(689);
	for ( i = 0; i < 12; ++i );
	VGA_TEST_ENABLE = 1;
	VGA_TEST_MODE = 1;
	VGA_MID_LINE_OFFSET = 1024;
	VGA_MAGIC = 1;
	VGA_MAGIC_KEY = 0xFFFFFFFF;
	return 0;
}

uint32_t vga_probe(uint32_t subid) {
	return IODEVICE_PROBE_PASS;
}

uint32_t vga_check(uint32_t subid) {
	return 0;
}

uint32_t vga_test(uint32_t subid) {
	VGA_TEST_ENABLE = 1;
	return 0;
}


IODevice vga = {
	.subid = 0,
	.name = "VGA ",
	.details = vga_description,
	.status = 0,
	.reset = vga_reset,
	.init = vga_init,
	.probe = vga_probe,
	.check = vga_check,
	.test = vga_test
};

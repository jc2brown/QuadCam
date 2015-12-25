#include <stdint.h>
#include <stdio.h>
#include "delay.h"
#include "device.h"
#include "iobus.h"
#include "usb.h"



void usb_print(char c) {
	uint32_t count = COUNTER;
	while(1) {
		if ( COUNTER - count > (MCU_CLK_FREQ/1000000) * USB_PRINT_TIMEOUT ) {
			return;
		}
		if ( ! (USB_STATUS & USB_STATUS_FLAG_TX_FULL) ) {
			USB = c;
			return;
		}
	}
}



int usb_page;

int get_usb_page() {
	return usb_page;
}



void set_usb_page(int page) {
	usb_page = page;
	USB_FRAME_ADDR0 = page_addrs[page];
	USB_FRAME_ADDR1 = page_addrs[page];
	USB_FRAME_ADDR2 = page_addrs[page];
	USB_FRAME_ADDR3 = page_addrs[page];
}





void usb_description(){
	xil_printf("FT232H USB 2.0 HighSpeed\n");
}

uint32_t usb_reset(uint32_t subid) {
	USB_ENABLE = 0;
	USB_MODE = 0;
	return 0;
}


uint32_t usb_init(uint32_t subid) {
	USB_ENABLE = 0;
	USB_MODE = 0;
	set_usb_page(0);
	return 0;
}

uint32_t usb_probe(uint32_t subid) {

	uint32_t status = 0;

	status |= IODEVICE_PROBE_PASS;

	return status;
}

uint32_t usb_check(uint32_t subid) {

	uint32_t status = 0;

	if ( USB_STATUS & USB_STATUS_FLAG_TX_FULL ) {
		status |= IODEVICE_CHECK_FAIL;
	} else {
		status |= IODEVICE_CHECK_PASS;
	}


	return status;
}

uint32_t usb_test(uint32_t subid) {
	return 0;
}


IODevice usb = {
	.subid = 0,
	.name = "USB ",
	.details = usb_description,
	.status = 0,
	.reset = usb_reset,
	.init = usb_init,
	.probe = usb_probe,
	.check = usb_check,
	.test = usb_test
};

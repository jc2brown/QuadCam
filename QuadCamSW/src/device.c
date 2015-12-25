
#include <stdint.h>
#include <stdio.h>
#include "device.h"
#include "draw.h"


uint32_t reset_stub(uint32_t subid) {
	return 0;
}

uint32_t init_stub(uint32_t subid) {
	return 0;
}

uint32_t probe_stub(uint32_t subid) {
	return 0;
}

uint32_t check_stub(uint32_t subid) {
	return 0;
}

uint32_t test_stub(uint32_t subid) {
	return 0;
}


void reset_device(IODevice *iodevice) {
	iodevice->status = iodevice->reset(iodevice->subid);
	//xil_printf("\n%s  status:0x%02X\n", iodevice->name, iodevice->status);
}

void reset_devices(IODevice **iodevices, uint32_t n_iodids) {
	int i;
	uint32_t leds = 1;
	for ( i = 0; i < n_iodids; ++i ) {
		LEDS_SRC = 0x11111111;
		LEDS1 = i;
		reset_device(iodevices[i]);
	}
}

void init_device(IODevice *iodevice) {
	iodevice->init(iodevice->subid);
	//xil_printf("\n%s  status:0x%02X\n", iodevice->name, iodevice->status);
}

void init_devices(IODevice **iodevices, uint32_t n_iodids) {
	int i;
	for ( i = 0; i < n_iodids; ++i ) {
		init_device(iodevices[i]);
	}
}

void probe_device(IODevice *iodevice) {
	iodevice->status &= ~(IODEVICE_PROBE_FAIL | IODEVICE_PROBE_PASS);
	xil_printf("\n%s: ", iodevice->name);
	iodevice->status |= iodevice->probe(iodevice->subid);
	iodevice->details(iodevice->subid);
}

void probe_devices(IODevice **iodevices, uint32_t n_iodids) {
	int i;
	for ( i = 0; i < n_iodids; ++i ) {
		probe_device(iodevices[i]);
	}
}

void print_probe_results() {
	int i;
	uint32_t status;

	xil_printf("\nProbe Results\n\n");

	for ( i = 0; i < N_IODIDs; ++i ) {
		status = iodevices[i]->status;
		xil_printf("%s %s %s\n",
			iodevices[i]->name,
			(status & IODEVICE_PROBE_FAIL ? "FAIL" : "    "),
			(status & IODEVICE_PROBE_PASS ? "PASS" : "    "));
	}
}


void check_device(IODevice *iodevice) {
	iodevice->status &= ~(IODEVICE_CHECK_FAIL | IODEVICE_CHECK_PASS);
	iodevice->status |= iodevice->check(iodevice->subid);
	//xil_printf("\n%s  status:0x%02X\n", iodevice->name, iodevice->status);
	//iodevice->details(iodevice->subid);
}

void check_devices(IODevice **iodevices, uint32_t n_iodids) {
	int i;
	for ( i = 0; i < n_iodids; ++i ) {
		check_device(iodevices[i]);
	}
}

void print_check_results() {
	int i;
	uint32_t status;

	xil_printf("\nCheck Results\n\n");

	for ( i = 0; i < N_IODIDs; ++i ) {
		status = iodevices[i]->status;
		xil_printf("%s %s %s\n",
			iodevices[i]->name,
			(status & IODEVICE_CHECK_FAIL ? "FAIL" : "    "),
			(status & IODEVICE_CHECK_PASS ? "PASS" : "    "));
	}
}


void test_device(IODevice *iodevice) {
	iodevice->status &= ~(IODEVICE_TEST_FAIL | IODEVICE_TEST_PASS);
	iodevice->status |= iodevice->test(iodevice->subid);
	//xil_printf("\n%s  status:0x%02X\n", iodevice->name, iodevice->status);
	//iodevice->details(iodevice->subid);
}

void test_devices(IODevice **iodevices, uint32_t n_iodids) {
	int i;
	for ( i = 0; i < n_iodids; ++i ) {
		test_device(iodevices[i]);
	}
}


void print_test_results() {
	int i;
	uint32_t status;

	xil_printf("\nTest Results\n\n");

	for ( i = 0; i < N_IODIDs; ++i ) {
		status = iodevices[i]->status;
		xil_printf("%s %s %s\n",
			iodevices[i]->name,
			(status & IODEVICE_TEST_FAIL ? "FAIL" : "    "),
			(status & IODEVICE_TEST_PASS ? "PASS" : "    "));
	}
}

void print_results() {
	int i;
	uint32_t status;

	xil_printf("\nDevice    Probe  Check  Test");
	xil_printf("\n------    -----  -----  ----");

	for ( i = 0; i < N_IODIDs; ++i ) {
		status = iodevices[i]->status;

		xil_printf("\n%-8s  ", iodevices[i]->name);

		if ( (status & IODEVICE_PROBE_PASS) && (status & IODEVICE_PROBE_FAIL) ) {
			store_style();
			set_fg_colour(colour_yellow);
			xil_printf("%s   ", "P&F ");
			recall_style();
		} else if (status & IODEVICE_PROBE_PASS) {
			store_style();
			set_fg_colour(colour_green);
			xil_printf("%s   ", "PASS");
			recall_style();
		} else if (status & IODEVICE_PROBE_FAIL) {
			store_style();
			set_fg_colour(colour_red);
			xil_printf("%s   ", "FAIL");
			recall_style();
		} else {
			xil_printf("%s   ", " ?? ");
		}

		if ( (status & IODEVICE_CHECK_PASS) && (status & IODEVICE_CHECK_FAIL) ) {
			store_style();
			set_fg_colour(colour_yellow);
			xil_printf("%s   ", "P&F ");
			recall_style();
		} else if (status & IODEVICE_CHECK_PASS) {
			store_style();
			set_fg_colour(colour_green);
			xil_printf("%s   ", "PASS");
			recall_style();
		} else if (status & IODEVICE_CHECK_FAIL) {
			store_style();
			set_fg_colour(colour_red);
			xil_printf("%s   ", "FAIL");
			recall_style();
		} else {
			xil_printf("%s   ", " ?? ");
		}

		if ( (status & IODEVICE_TEST_PASS) && (status & IODEVICE_TEST_FAIL) ) {
			store_style();
			set_fg_colour(colour_yellow);
			xil_printf("%s   ", "P&F ");
			recall_style();
		} else if (status & IODEVICE_TEST_PASS) {
			store_style();
			set_fg_colour(colour_green);
			xil_printf("%s   ", "PASS");
			recall_style();
		} else if (status & IODEVICE_TEST_FAIL) {
			store_style();
			set_fg_colour(colour_red);
			xil_printf("%s   ", "FAIL");
			recall_style();
		} else {
			xil_printf("%s   ", " ?? ");
		}
	}
	xil_printf("\n\n");
}

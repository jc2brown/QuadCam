
#include <stdint.h>
#include <stdio.h>
#include "device.h"
#include "iobus.h"
#include "ram.h"

char *mport_dev[4] = {
		"Cams",
		"USB",
		"VGA",
		"MCU"
};

void print_ram_errors() {
	int i;
	uint32_t status = MCTL_STATUS;
	if ( status & 0x00FF ) {
		for ( i = 0; i < 4; ++i ) {
			if ( status & 1 ) {
				xil_printf("Port %d (%s): read error\n", i, mport_dev[i]);
			}
			if ( status & 2 ) {
				xil_printf("Port %d (%s): read overflow\n", i, mport_dev[i]);
			}
			if ( status & 4 ) {
				xil_printf("Port %d (%s): write error\n", i, mport_dev[i]);
			}
			if ( status & 8 ) {
				xil_printf("Port %d (%s): write underrun\n", i, mport_dev[i]);
			}
			status >>= 4;
		}
	} else {
		xil_printf("No errors\n");
	}
}


uint32_t ram_reset(uint32_t subid) {
	return 0;
}


uint32_t ram_probe(uint32_t subid) {
	uint32_t status = 0;

	uint32_t ram_error = RAM_STATUS & 0x01;
	uint32_t ram_calib_done = RAM_STATUS & 0x02;

	if ( !ram_error && !ram_calib_done ) {
		status |= IODEVICE_PROBE_FAIL;
	}
	if ( ram_error || ram_calib_done ) {
		status |= IODEVICE_PROBE_PASS;
	}
	return status;

}

uint32_t ram_check(uint32_t subid) {
	uint32_t status = 0;

	uint32_t ram_error = RAM_STATUS & 0x01;
	uint32_t ram_calib_done = RAM_STATUS & 0x02;

	if ( ram_error ) {
		status |= IODEVICE_CHECK_FAIL;
	}

	if ( ram_calib_done ) {
		status |= IODEVICE_CHECK_PASS;
	}
	return status;

}

#define START_DATA 0
#define START_ADDR 0x00800000
//#define N_WORDS 0x00800000
#define N_WORDS 0x00200000

// Writes N_WORDS to RAM, then reads n_words from RAM and compares
// the actual read data against the data that was written.
uint32_t ram_test(uint32_t subid) {

	uint32_t addrinc = 1;
	uint32_t datainc = 0x87654321;

	volatile uint32_t rddata = START_DATA;
	volatile uint32_t wrdata = START_DATA;

	uint32_t rdaddr = START_ADDR;
	uint32_t expected_rddata = 0;

	uint32_t wraddr = START_ADDR;

	uint32_t error_count = 0;
	uint32_t expected_error_count = 0;

	uint32_t i;

	xil_printf("\nTesting RAM address range 0x%08X - 0x%08X  (%d Mb)", START_ADDR*4, (START_ADDR+N_WORDS)*4, (N_WORDS*4*8)/(1024*1024));

	for ( i = 0; i < N_WORDS; ++i ) {
		RAM_BLOCK[wraddr] = wrdata;
		wraddr += addrinc;
		wrdata += datainc;
	}

	for ( i = 0; i < N_WORDS; ++i ) {
		rddata = RAM_BLOCK[rdaddr];
		if ( rddata != expected_rddata ) {
			++error_count;
		}
		rdaddr += addrinc;
		expected_rddata += datainc;
	}

	expected_error_count = 0;
	xil_printf("\nRAM ERRORS: %d detected\n", error_count, expected_error_count);

	if ( error_count != expected_error_count ) {
		return IODEVICE_TEST_FAIL;
	}
	return IODEVICE_TEST_PASS;
}


void ram_description(uint32_t subid) {
	xil_printf("Micron LPDDR 512Mb 144MHz\n");
}

IODevice ram = {
		.subid = 0,
		.name = "RAM ",
		.details = ram_description,
		.status = 0,
		.reset = ram_reset,
		.init = init_stub,
		.probe = ram_probe,
		.check = ram_check,
		.test = ram_test
};

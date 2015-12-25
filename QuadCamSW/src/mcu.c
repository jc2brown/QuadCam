
#include <stdint.h>
#include <stdio.h>

#include "device.h"
#include "quadcam.h"
//#include "xparameters.h"
//#include "iobus.h"
#include "mcu.h"


uint32_t mcu_probe(uint32_t subid) {
	uint32_t status = 0;
	status |= IODEVICE_PROBE_PASS;
	return status;
}

void mcu_description(uint32_t subid) {
	xil_printf("MicroBlaze Microcontroller  108 MHz  32 KB\n");
}

IODevice mcu = {
		.subid = 0,
		.name = "MCU ",
		.details = mcu_description,
		.status = 0,
		.reset = reset_stub,
		.init = init_stub,
		.probe = mcu_probe,
		.check = check_stub,
		.test = test_stub
};

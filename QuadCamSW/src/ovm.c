#include <stdio.h>
#include "quadcam.h"
#include "util.h"
#include "iobus.h"
#include "device.h"

#include "ovm.h"


volatile uint32_t *cams[4] = { CAM0, CAM1, CAM2, CAM3 };

uint32_t good_cams = 0x0F;



void set_ovm_xvclk_frequency(uint32_t xvclk_freq) {
	set_clk_frequency(&OVM_XVCLK_DIV, xvclk_freq);
}

void set_ovm_scl_clk_frequency(uint32_t scl_freq) {
	set_clk_frequency(&OVM_SCL_CLK_DIV, scl_freq);
}




void set_ovm_page(int page) {
	OVM_FRAME_ADDR0 = page_addrs[page];
	OVM_FRAME_ADDR1 = page_addrs[page];
	OVM_FRAME_ADDR2 = page_addrs[page];
	OVM_FRAME_ADDR3 = page_addrs[page];
}


/*
#define FPS_TIMEOUT 100000 	// microseconds

int measure_fps(int id) {
	int i;
	uint32_t mask = 1 << id;
	if ( ! (mask & good_cams) ) {
		return 0;
	}
	for ( i = 0; i < FPS_TIMEOUT; ++i ) {
		if ( (OVM_VSYNC & mask) ) {
			break;
		}
		delay_us(1);
	}
	if ( i == FPS_TIMEOUT) {
		return 0;
	}
	for ( i = 0; i < FPS_TIMEOUT; ++i ) {
		if ( ! (OVM_VSYNC & mask) ) {
			break;
		}
		delay_us(1);
	}
	if ( i == FPS_TIMEOUT) {
		return 0;
	}
	while ( (OVM_VSYNC & mask) );
	uint32_t count = COUNTER;
	while ( ! (OVM_VSYNC & mask) );
	while ( OVM_VSYNC & mask );
	return MCU_CLK_FREQ / (COUNTER - count);
}
*/


void ovm_config() {
	int i;
	OVM_ENABLE = 0x00;
	set_ovm_xvclk_frequency(2000000);
	delay_ms(50);
	OVM_ENABLE = good_cams;
	delay_ms(50);
	set_ovm_scl_clk_frequency(50000);
	delay_ms(100);


	for ( i = 0; i < 4; ++i ) {
		if ( (1<<i) & good_cams ) {
			cams[i][OV_REG_CLKRC] = 0x00; // div2
			cams[i][OV_REG_PLL] = 0x32; // mult4
			cams[i][OV_REG_PWC0] = 0x0C; // power
			cams[i][OV_REG_REG0C] = 0xC6; // vflip hflip outputenable
			cams[i][OV_REG_REG12] = 0x16; // RGB format
			cams[i][OV_REG_AECH] = 0x7F; // AutoExp
			cams[i][OV_REG_REG13] = 0xE7; // //AWB
			cams[i][OV_REG_REG14] = 0x50; // 64x AGC ceiling
			cams[i][OV_REG_REG15] = 0x9F; // AutoFPS:1/2, 4x gain
			cams[i][OV_REG_REG3F] = 0x04; // Href changes on rising edge
			cams[i][OV_REG_REG28] = 0x04; // Vsync changes on rising edge
			cams[i][OV_REG_REG80] = 0x7E;
			cams[i][OV_REG_REG81] = 0x61;
			//cams[i][OV_REG_REGB4] = 0x3F;
			cams[i][OV_REG_REGB4] = 0x2F;
			//cams[i][OV_REG_REGB4] = 0x06;

			cams[i][OV_REG_CLKRC] = 0x40; // 0x40
			delay_ms(10);
			cams[i][OV_REG_PLL] = 0x32; // 0x12
			delay_ms(10);
		}
	}

	set_ovm_scl_clk_frequency(100000);
	delay_ms(10);
	set_ovm_xvclk_frequency(4200000);
	delay_ms(10);


	OVM_ENABLE = 0x00;
	delay_ms(10);
	OVM_BRAM_ENABLE = 0x0F;
	delay_ms(10);
	OVM_MUX_ENABLE = 0x01;
	delay_ms(10);
	/*OVM_ENABLE = 0x01;
	delay_ms(10);
	OVM_ENABLE = 0x03;
	delay_ms(20);
	OVM_ENABLE = 0x07;
	delay_ms(30);*/

	/*
	int ovm_ref = 0;
	uint32_t ovm_enable = 0;

	for ( i = 0; i < 4; ++i ) {
		if ( ovm_ref != 0 ) {
			while ( ! (OVM_VSYNC & (1<<ovm_ref)) );
		}
		if ( (1 << i) & good_cams ) {
			ovm_enable |= ((1 << i) & good_cams);
			if ( ovm_ref == 0 ) {
				ovm_ref = i;
			}
			OVM_ENABLE = ovm_enable;
		}
	}
	*/

	OVM_ENABLE = good_cams;
	delay_ms(40);
}

uint32_t ovm_reset(uint32_t subid) {
	return 0;
}


uint32_t ovm_init(uint32_t subid) {

	OVM_ENABLE = 0x0F;
	delay_ms(200);
	/*
	if ( (1<<subid) & good_cams ) {
		cams[subid][OV_REG_CLKRC] = 0x00; // div2
		cams[subid][OV_REG_PLL] = 0x32; // mult4
		cams[subid][OV_REG_PWC0] = 0x0C; // power
		cams[subid][OV_REG_REG0C] = 0xC6; // vflip hflip outputenable
		cams[subid][OV_REG_REG12] = 0x06; // RGB format
		cams[subid][OV_REG_AECH] = 0x7F; // AutoExp
		cams[subid][OV_REG_REG13] = 0xE7; // //AWB
		cams[subid][OV_REG_REG14] = 0x50; // 64x AGC ceiling
		cams[subid][OV_REG_REG15] = 0x9F; // AutoFPS:1/2, 4x gain
		cams[subid][OV_REG_CLKRC] = 0x40; // 0x40
		delay_ms(10);
		cams[subid][OV_REG_PLL] = 0x32; // 0x12
		delay_ms(10);
	}*/
	return 0;
}



// Determines which cameras are present
// A camera is considered present if it has a toggling VSYNC
uint32_t ovm_probe(uint32_t subid) {
	uint32_t status = 0;
	//uint32_t old_ovm_enable = OVM_ENABLE;
	uint32_t submask = 1<<subid;
	//OVM_ENABLE = submask;
	if ( ovm_fps[subid] == 0 ) {
		status |= IODEVICE_PROBE_FAIL;
		good_cams &= ~submask;
	} else {
		status |= IODEVICE_PROBE_PASS;
		//good_cams |= submask;
	}
	//OVM_ENABLE = 0x00;
	//delay_ms(100);
	//OVM_ENABLE = old_ovm_enable;
	return status;
}

void ovm_description(uint32_t subid) {
	xil_printf("OVM7690 CameraCube 640x480 30FPS\n");
}


// Determines which cameras are healthy
// A camera is considered healthy if it returns correct manufacturer and product IDs
uint32_t ovm_check(uint32_t mask) {
	uint32_t response = 0x00;
	int i = mask;

	//uint32_t old_ovm_enable = OVM_ENABLE;

	mask = 1<<mask;
	if ( ! (mask & good_cams) ) {
		return 0;
	}

	//OVM_ENABLE = mask;
	//delay_ms(10);

	uint32_t pidh;
	uint32_t pidl;
	uint32_t midh;
	uint32_t midl;


	xil_printf("\nOVM%d:", i);

	pidh = cams[i][OV_REG_PIDH];
	pidl = cams[i][OV_REG_PIDL];
	xil_printf("\nProduct ID:      0x%02X%02X  (0x%02X%02X expected)", pidh, pidl, OVM_PIDH, OVM_PIDL);

	midh = cams[i][OV_REG_MIDH];
	midl = cams[i][OV_REG_MIDL];
	xil_printf("\nManufacturer ID: 0x%02X%02X  (0x%02X%02X expected)\n", midh, midl, OVM_MIDH, OVM_MIDL);

	if ( pidh == OVM_PIDH && pidl == OVM_PIDL && midh == OVM_MIDH && midl == OVM_MIDL ) {
		response |= IODEVICE_CHECK_PASS;
	} else {
		response |= IODEVICE_CHECK_FAIL;
	}


	//OVM_ENABLE = 0x00;
	//delay_ms(100);
	//OVM_ENABLE = old_ovm_enable;

	//OVM_ENABLE = old_ovm_enable;

	return response;
}
/*
void ovm_tests(int *n_tests, int *n_errors) {
	int i;
	uint32_t mask = 0x0F;
	uint32_t response;

	int reg;
	int mismatch;
	uint32_t ref;
	uint32_t value;


	for ( reg = 0; reg < 256; ++reg ) {
		mismatch = 0;

		//xil_printf("\n0x%02X", reg);

		ref = cams[0][reg];
		//xil_printf("  0x%02X", ref);

		for ( i = 1; i < 4; ++i ) {
			value = cams[i][reg];
			if ( value != ref ) {
				mismatch = 1;
			}
		//	xil_printf("  0x%02X", value);
		}
		if ( mismatch ) {
			xil_printf("  MISMATCH");
		}
	}

	for ( i = 0; i < 4; ++i ) {
		if ( mask & 1 ) {
			*n_tests += 1;
			if ( (response & 1) == 0 ) {
				*n_errors += 1;
				xil_printf("FAILURE: OVM %d\n", i);
			}
		}
		mask >>= 1;
		response >>= 1;
	}
}
*/




IODevice ovm[4] = {
	[0] {
		.subid = 0,
		.name = "OVM0",
		.details = ovm_description,
		.status = 0,
		.reset = ovm_reset,
		.init = init_stub,
		.probe = ovm_probe,
		.check = ovm_check,
		.test = test_stub },
	[1] {
		.subid = 1,
		.name = "OVM1",
		.details = ovm_description,
		.status = 0,
		.reset = ovm_reset,
		.init = init_stub,
		.probe = ovm_probe,
		.check = ovm_check,
		.test = test_stub },
	[2] {
		.subid = 2,
		.name = "OVM2",
		.details = ovm_description,
		.status = 0,
		.reset = ovm_reset,
		.init = init_stub,
		.probe = ovm_probe,
		.check = ovm_check,
		.test = test_stub },
	[3] {
		.subid = 3,
		.name = "OVM3",
		.details = ovm_description,
		.status = 0,
		.reset = ovm_reset,
		.init = init_stub,
		.probe = ovm_probe,
		.check = ovm_check,
		.test = test_stub }
};

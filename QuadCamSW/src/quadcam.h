
#include <stdint.h>

#ifndef QUADCAM_H
#define QUADCAM_H


#define MCU_CLK_FREQ 108000000

#define DEFAULT_LED_CLK_FREQ 72000
#define DEFAULT_LED_LATCH_FREQ 72000
#define DEFAULT_FLASH_CLK_FREQ 10000000

typedef enum IODeviceID_enum {
	IODID_FPGA,
	IODID_MCU,
	IODID_RAM,
	IODID_USB,
	IODID_VGA,
	IODID_OVM0,
	IODID_OVM1,
	IODID_OVM2,
	IODID_OVM3,
	IODID_UART,
	IODID_WIFI,
	N_IODIDs
} IODeviceId;





#define N_FRAMES 10
extern uint32_t page_addrs[N_FRAMES];


extern uint32_t ovm_fps[4];

extern int loading_page;
extern int probe_page;
extern int check_page;
extern int test_page;
extern int status_page;
extern int console_page;
extern int video_page;
extern int still_page;
extern int vstripe_page;
extern int screensaver_page;



void set_outbyte(void (*new_outbyte_fcn)(char));



#endif



#ifndef FPGA_H
#define FPGA_H

#include "device.h"

void set_led_clk_frequency(uint32_t led_clk_freq);
void set_led_latch_frequency(uint32_t led_latch_freq);
void set_flash_clk_frequency(uint32_t flash_clk_freq);

void heartbeat_fatal(void);
void heartbeat_alert(void);
void heartbeat_error(void);
void heartbeat_rapid(void);
void heartbeat_normal(void);


extern IODevice fpga;


#endif

// Microblaze memory map - external IObus peripherals
// Address range 0xC000000 to 0xFFFFFFF


#include <stdint.h>

#ifndef IOBUS_H
#define IOBUS_H


//////////////////////////////////
// Microblaze external IO Bus
// See DS865, esp. pg4
//////////////////////////////////

// IO Bus base address: 0xC0000000 (fixed in Microblaze implementation)
// All IO Bus peripheral addresses must be allocated between 0xC0000000 and 0xFFFFFFFF
#define IO_BUS			((volatile uint32_t*)0xC0000000)

// External RAM base address
// 512Mb = 64MB => 0x04000000 byte addresses
#define RAM_BLOCK		((volatile uint32_t*)0xC0000000)


#define TIMER			(*((volatile uint32_t*)0xD0000000))

#define COUNTER			(*((volatile uint32_t*)0xD4000000))

//
#define GPIO_BLOCK		((volatile uint32_t*)0xD8000000)



// These must match the constants in ..VHDL/src/mcu/pkg_mcu.vhd


#define GPIO_ERROR_LED 		0x00
#define ERROR_LED			GPIO_BLOCK[GPIO_ERROR_LED]

#define GPIO_LEDS1 			0x01
#define LEDS1				GPIO_BLOCK[GPIO_LEDS1]

#define GPIO_LEDS2 			0x02
#define LEDS2				GPIO_BLOCK[GPIO_LEDS2]


#define GPIO_SWITCH_STATUS 	0x08
#define SWITCH_STATUS		GPIO_BLOCK[GPIO_SWITCH_STATUS]

#define GPIO_SWITCH_SRC		0x0C
#define SWITCH_SRC			GPIO_BLOCK[GPIO_SWITCH_SRC]


// Error LED source selection
// There are 4 error LED signals to select from
// The source is selected by the 4 LSbs
#define ERROR_LED_SRC_MCU 			0x00
#define ERROR_LED_SRC_FLASH	 		0x01
#define ERROR_LED_SRC_RAM_ACTIVE 	0x02
#define ERROR_LED_SRC_RAM_BUSY	 	0x03

#define GPIO_ERROR_LED_SRC	0x10
#define ERROR_LED_SRC		GPIO_BLOCK[GPIO_ERROR_LED_SRC]


// LED source selection
// There are 16 LED vectors to select from
#define LEDS_SRC_LOW			0x00000000
#define LEDS_SRC_MCU1			0x11111110
#define LEDS_SRC_MCU2			0x22222220
#define LEDS_SRC_RAM_STATUS		0x33333330
#define LEDS_SRC_FLASH			0x99999990
#define LEDS_SRC_ERROR			0xEEEEEEE0


//  0:  fixed 0x00
//  1:  MCU LED1
//  2:  MCU LED2
//  3:  Misc. RAM
//  4:  MctlPort0 read data(7..1)
//  5:  MctlPort1 read data(7..1)
//  6:  MctlPort2 read data(7..1)
//  7:  MctlPort3 read data(7..1)
//  8:
//  9:  flash
//  10: OVM0 video(7..1)
//  11: OVM1 video(7..1)
//  12: OVM2 video(7..1)
//  13: OVM3 video(7..1)
//  14: error LED output
//  15: fixed 0xFF

// Each LED source is individually selectable
//  bits0-3: 	Unused
//  bits4-7: 	LED1 source
//  bits8-11: 	LED2 source
//  bits12-15: 	LED3 source
//  bits16-19: 	LED4 source
//  bits20-23: 	LED5 source
//  bits24-27: 	LED6 source
//  bits28-31: 	LED7 source
#define GPIO_LEDS_SRC		0x11
#define LEDS_SRC			GPIO_BLOCK[GPIO_LEDS_SRC]

#define GPIO_LEDCLK_DIV		0x12
#define LEDCLK_DIV			GPIO_BLOCK[GPIO_LEDCLK_DIV]

#define GPIO_LED_LATCH_DIV	0x13
#define LED_LATCH_DIV		GPIO_BLOCK[GPIO_LED_LATCH_DIV]


#define GPIO_FLASH_CLK_DIV	0x18
#define FLASH_CLK_DIV		GPIO_BLOCK[GPIO_FLASH_CLK_DIV]

#define GPIO_FLASH_ON		0x19
#define FLASH_ON			GPIO_BLOCK[GPIO_FLASH_ON]

#define GPIO_FLASH_MAX		0x1A
#define FLASH_MAX			GPIO_BLOCK[GPIO_FLASH_MAX]



// TODO move these to iobus.h and use them

#define DEBUG_SRC_OVM0	0x0A
#define DEBUG_SRC_OVM1	0x0B
#define DEBUG_SRC_OVM2	0x0C
#define DEBUG_SRC_OVM3	0x0D


#define PROBE_SRC_OVM_DATA0 0
#define PROBE_SRC_OVM_DATA1 1
#define PROBE_SRC_OVM_DATA2 2
#define PROBE_SRC_OVM_DATA3 3
#define PROBE_SRC_OVM_DATA4 4
#define PROBE_SRC_OVM_DATA5 5
#define PROBE_SRC_OVM_DATA6 6
#define PROBE_SRC_OVM_DATA7 7
#define PROBE_SRC_OVM_PCLK 8
#define PROBE_SRC_OVM_HREF 9
#define PROBE_SRC_OVM_VSYNC 10


// Debug register (mapped to debug source 0)
#define GPIO_DEBUG0			0x20
#define DEBUG0				GPIO_BLOCK[GPIO_DEBUG0]

// Read-only
#define GPIO_DEBUG			0x21
#define DEBUG				GPIO_BLOCK[GPIO_DEBUG]

// Debug port source selection
//  0: MCU DEBUG register
//  4: UART/Wifi
//  7: VGA red/green
//  8: VGA green/blue
//  9: VGA red/blue
//	A: OVM0
//	B: OVM1
//	C: OVM2
//	D: OVM3
#define GPIO_DEBUG_SRC		0x22
#define DEBUG_SRC			GPIO_BLOCK[GPIO_DEBUG_SRC]



#define GPIO_MCTL_STATUS	0x28
#define MCTL_STATUS			GPIO_BLOCK[GPIO_MCTL_STATUS]



// Enables the debug probe level/edge counter
//
#define GPIO_PROBE_ENABLE	0x30
#define PROBE_ENABLE		GPIO_BLOCK[GPIO_PROBE_ENABLE]

#define GPIO_PROBE_CLEAR	0x31
#define PROBE_CLEAR			GPIO_BLOCK[GPIO_PROBE_CLEAR]

// Debug probe bit selection (0 to 31)
#define GPIO_PROBE_SRC		0x32
#define PROBE_SRC			GPIO_BLOCK[GPIO_PROBE_SRC]

#define GPIO_PROBE_LATCH_DIV 0x33
#define PROBE_LATCH_DIV		 GPIO_BLOCK[GPIO_PROBE_LATCH_DIV]


// Read-only
#define GPIO_PROBE_LOW		0x34
#define PROBE_LOW			GPIO_BLOCK[GPIO_PROBE_LOW]

// Read-only
#define GPIO_PROBE_HIGH		0x35
#define PROBE_HIGH			GPIO_BLOCK[GPIO_PROBE_HIGH]

// Read-only
#define GPIO_PROBE_FALL		0x36
#define PROBE_FALL			GPIO_BLOCK[GPIO_PROBE_FALL]

// Read-only
#define GPIO_PROBE_RISE		0x37
#define PROBE_RISE			GPIO_BLOCK[GPIO_PROBE_RISE]



#define GPIO_OVM_BRAM_ENABLE	0x40
#define OVM_BRAM_ENABLE			GPIO_BLOCK[GPIO_OVM_BRAM_ENABLE]

#define GPIO_OVM_MUX_ENABLE		0x41
#define OVM_MUX_ENABLE			GPIO_BLOCK[GPIO_OVM_MUX_ENABLE]


#define GPIO_OVM0_LINE_OFFSET	0x44
#define OVM0_LINE_OFFSET		GPIO_BLOCK[GPIO_OVM0_LINE_OFFSET]

#define GPIO_OVM1_LINE_OFFSET	0x45
#define OVM1_LINE_OFFSET		GPIO_BLOCK[GPIO_OVM1_LINE_OFFSET]

#define GPIO_OVM2_LINE_OFFSET	0x46
#define OVM2_LINE_OFFSET		GPIO_BLOCK[GPIO_OVM2_LINE_OFFSET]

#define GPIO_OVM3_LINE_OFFSET	0x47
#define OVM3_LINE_OFFSET		GPIO_BLOCK[GPIO_OVM3_LINE_OFFSET]


#define GPIO_OVM_FRAME_ADDR0	0x48
#define OVM_FRAME_ADDR0			GPIO_BLOCK[GPIO_OVM_FRAME_ADDR0]

#define GPIO_OVM_FRAME_ADDR1	0x49
#define OVM_FRAME_ADDR1			GPIO_BLOCK[GPIO_OVM_FRAME_ADDR1]

#define GPIO_OVM_FRAME_ADDR2	0x4A
#define OVM_FRAME_ADDR2			GPIO_BLOCK[GPIO_OVM_FRAME_ADDR2]

#define GPIO_OVM_FRAME_ADDR3	0x4B
#define OVM_FRAME_ADDR3			GPIO_BLOCK[GPIO_OVM_FRAME_ADDR3]



#define GPIO_OVM_PCLK 		0x4C
#define OVM_PCLK			GPIO_BLOCK[GPIO_OVM_PCLK]

#define GPIO_OVM_HREF 		0x4D
#define OVM_HREF			GPIO_BLOCK[GPIO_OVM_HREF]

#define GPIO_OVM_VSYNC 		0x4E
#define OVM_VSYNC			GPIO_BLOCK[GPIO_OVM_VSYNC]


#define GPIO_RAM_ERROR_STATUS0 	0x50
#define RAM_ERROR_STATUS0		GPIO_BLOCK[GPIO_RAM_ERROR_STATUS0]

#define GPIO_RAM_ERROR_STATUS1 	0x51
#define RAM_ERROR_STATUS1		GPIO_BLOCK[GPIO_RAM_ERROR_STATUS1]

#define GPIO_RAM_ERROR_STATUS2 	0x52
#define RAM_ERROR_STATUS2		GPIO_BLOCK[GPIO_RAM_ERROR_STATUS2]

#define GPIO_RAM_ERROR_STATUS3 	0x53
#define RAM_ERROR_STATUS3		GPIO_BLOCK[GPIO_RAM_ERROR_STATUS3]


// bit0: error
// bit1: calibration done
#define GPIO_RAM_STATUS 		0x54
#define RAM_STATUS				GPIO_BLOCK[GPIO_RAM_STATUS]



#define GPIO_VGA_ENABLE			0x60
#define VGA_ENABLE				GPIO_BLOCK[GPIO_VGA_ENABLE]

#define GPIO_VGA_SRC			0x61
#define VGA_SRC					GPIO_BLOCK[GPIO_VGA_SRC]

#define GPIO_VGA_TEST_ENABLE	0x62
#define VGA_TEST_ENABLE			GPIO_BLOCK[GPIO_VGA_TEST_ENABLE]

#define GPIO_VGA_TEST_MODE		0x63
#define VGA_TEST_MODE			GPIO_BLOCK[GPIO_VGA_TEST_MODE]




#define GPIO_VGA_FRAME_ADDR0	0x64
#define VGA_FRAME_ADDR0			GPIO_BLOCK[GPIO_VGA_FRAME_ADDR0]

#define GPIO_VGA_FRAME_ADDR1	0x65
#define VGA_FRAME_ADDR1			GPIO_BLOCK[GPIO_VGA_FRAME_ADDR1]

#define GPIO_VGA_FRAME_ADDR2	0x66
#define VGA_FRAME_ADDR2			GPIO_BLOCK[GPIO_VGA_FRAME_ADDR2]

#define GPIO_VGA_FRAME_ADDR3	0x67
#define VGA_FRAME_ADDR3			GPIO_BLOCK[GPIO_VGA_FRAME_ADDR3]



#define GPIO_VGA_MID_LINE_OFFSET	0x68
#define VGA_MID_LINE_OFFSET			GPIO_BLOCK[GPIO_VGA_MID_LINE_OFFSET]


#define GPIO_VGA_MAGIC				0x69
#define VGA_MAGIC					GPIO_BLOCK[GPIO_VGA_MAGIC]

#define GPIO_VGA_MAGIC_KEY			0x6A
#define VGA_MAGIC_KEY				GPIO_BLOCK[GPIO_VGA_MAGIC_KEY]




#define GPIO_USB_ENABLE			0x70
#define USB_ENABLE				GPIO_BLOCK[GPIO_USB_ENABLE]

#define GPIO_USB_MODE			0x71
#define USB_MODE				GPIO_BLOCK[GPIO_USB_MODE]




#define GPIO_USB_FRAME_ADDR0	0x74
#define USB_FRAME_ADDR0			GPIO_BLOCK[GPIO_USB_FRAME_ADDR0]

#define GPIO_USB_FRAME_ADDR1	0x75
#define USB_FRAME_ADDR1			GPIO_BLOCK[GPIO_USB_FRAME_ADDR1]

#define GPIO_USB_FRAME_ADDR2	0x76
#define USB_FRAME_ADDR2			GPIO_BLOCK[GPIO_USB_FRAME_ADDR2]

#define GPIO_USB_FRAME_ADDR3	0x77
#define USB_FRAME_ADDR3			GPIO_BLOCK[GPIO_USB_FRAME_ADDR3]



#define GPIO_RESET				0x7F
#define RESET					GPIO_BLOCK[GPIO_RESET]



#define GPIO_OVM_ENABLE 	0x80
#define OVM_ENABLE			GPIO_BLOCK[GPIO_OVM_ENABLE]

#define GPIO_OVM_XVCLK_DIV 	0x81
#define OVM_XVCLK_DIV		GPIO_BLOCK[GPIO_OVM_XVCLK_DIV]

#define GPIO_OVM_SCL_CLK_DIV 0x82
#define OVM_SCL_CLK_DIV		 GPIO_BLOCK[GPIO_OVM_SCL_CLK_DIV]

#define GPIO_OVM_DEV_ADDR 	0x83
#define OVM_DEV_ADDR		GPIO_BLOCK[GPIO_OVM_DEV_ADDR]



#define GPIO_UART_BAUD_DIV 	0x90
#define UART_BAUD_DIV		GPIO_BLOCK[GPIO_UART_BAUD_DIV]



// Uart RXD source selection
#define FAST_UART_RX_SRC_RXD		0
#define FAST_UART_RX_SRC_LOOPBACK	1
//	bit0:
// 		0: external RXD input
// 		1: internal loopback from TXD
#define GPIO_FAST_UART_RX_SRC 	0x91
#define FAST_UART_RX_SRC		GPIO_BLOCK[GPIO_FAST_UART_RX_SRC]


#define FAST_UART_TX_SRC_UART_TX 0
#define FAST_UART_TX_SRC_WIFI_RX 1

#define GPIO_FAST_UART_TX_SRC 	0x92
#define FAST_UART_TX_SRC			GPIO_BLOCK[GPIO_FAST_UART_TX_SRC]


// UART Rx/TX status
#define FAST_UART_STATUS_BIT_RX_EMPTY 	0
#define FAST_UART_STATUS_BIT_RX_FULL 	1
#define FAST_UART_STATUS_BIT_RX_PINSTATE 2
#define FAST_UART_STATUS_BIT_TX_EMTPY 	4
#define FAST_UART_STATUS_BIT_TX_FULL 	5

#define FAST_UART_STATUS_FLAG_RX_EMPTY		(1<<FAST_UART_STATUS_BIT_RX_EMPTY)
#define FAST_UART_STATUS_FLAG_RX_FULL		(1<<FAST_UART_STATUS_BIT_RX_FULL)
#define FAST_UART_STATUS_FLAG_RX_PINSTATE	(1<<FAST_UART_STATUS_BIT_RX_PINSTATE)
#define FAST_UART_STATUS_FLAG_TX_EMPTY		(1<<FAST_UART_STATUS_BIT_TX_EMTPY)
#define FAST_UART_STATUS_FLAG_TX_FULL		(1<<FAST_UART_STATUS_BIT_TX_FULL)

// 	bit0: RX empty
// 	bit1: RX full
//  bit2: RX pin state
//  bit4: TX empty
// 	bit5: TX full
#define GPIO_FAST_UART_STATUS 	0x93
#define FAST_UART_STATUS		GPIO_BLOCK[GPIO_FAST_UART_STATUS]



#define GPIO_WIFI_BAUD_DIV 	0xA0
#define WIFI_BAUD_DIV		GPIO_BLOCK[GPIO_WIFI_BAUD_DIV]



// WIFI RXD source selection
#define WIFI_RX_SRC_RXD			0
#define WIFI_RX_SRC_LOOPBACK	1
//	bit0:
// 		0: external RXD input
// 		1: internal loopback from TXD
#define GPIO_WIFI_RX_SRC 	0xA1
#define WIFI_RX_SRC			GPIO_BLOCK[GPIO_WIFI_RX_SRC]

#define WIFI_TX_SRC_WIFI_TX 0
#define WIFI_TX_SRC_UART_RX 1

#define GPIO_WIFI_TX_SRC 	0xA2
#define WIFI_TX_SRC			GPIO_BLOCK[GPIO_WIFI_TX_SRC]


// Wifi Rx/TX status
#define WIFI_STATUS_BIT_RX_EMPTY 	0
#define WIFI_STATUS_BIT_RX_FULL 	1
#define WIFI_STATUS_BIT_RX_PINSTATE 2
#define WIFI_STATUS_BIT_TX_EMTPY 	4
#define WIFI_STATUS_BIT_TX_FULL 	5

#define WIFI_STATUS_FLAG_RX_EMPTY		(1<<WIFI_STATUS_BIT_RX_EMPTY)
#define WIFI_STATUS_FLAG_RX_FULL		(1<<WIFI_STATUS_BIT_RX_FULL)
#define WIFI_STATUS_FLAG_RX_PINSTATE	(1<<WIFI_STATUS_BIT_RX_PINSTATE) // may not work?
#define WIFI_STATUS_FLAG_TX_EMPTY		(1<<WIFI_STATUS_BIT_TX_EMTPY)
#define WIFI_STATUS_FLAG_TX_FULL		(1<<WIFI_STATUS_BIT_TX_FULL)


// 	bit0: RX empty
// 	bit1: RX full
//  bit2: RX pin state
//  bit4: TX empty
// 	bit5: TX full
#define GPIO_WIFI_STATUS 	0xA3
#define WIFI_STATUS			GPIO_BLOCK[GPIO_WIFI_STATUS]

#define GPIO_WIFI_ENABLE 	0xA4
#define WIFI_ENABLE			GPIO_BLOCK[GPIO_WIFI_ENABLE]

#define GPIO_WIFI_RXD 		0xA5
#define WIFI_RXD			GPIO_BLOCK[GPIO_WIFI_RXD]

#define GPIO_WIFI_RXD_OUTPUT_ENABLE 	0xA6
#define WIFI_RXD_OUTPUT_ENABLE			GPIO_BLOCK[GPIO_WIFI_RXD_OUTPUT_ENABLE]

#define GPIO_WIFI_GPIO 		0xA7
#define WIFI_GPIO			GPIO_BLOCK[GPIO_WIFI_GPIO]

#define GPIO_WIFI_GPIO_OUTPUT_ENABLE 	0xA8
#define WIFI_GPIO_OUTPUT_ENABLE			GPIO_BLOCK[GPIO_WIFI_GPIO_OUTPUT_ENABLE]


// USB RX/TX status
#define USB_STATUS_BIT_RX_EMPTY 	0
#define USB_STATUS_BIT_TX_FULL 		1

#define USB_STATUS_FLAG_RX_EMPTY	(1<<USB_STATUS_BIT_RX_EMPTY)
#define USB_STATUS_FLAG_TX_FULL		(1<<USB_STATUS_BIT_TX_FULL)


#define GPIO_USB_STATUS			0xB0
#define USB_STATUS				GPIO_BLOCK[GPIO_USB_STATUS]

#define GPIO_DEBUG_OUTPUT_ENABLE		0xB4
#define DEBUG_OUTPUT_ENABLE				GPIO_BLOCK[GPIO_DEBUG_OUTPUT_ENABLE]


#define USB				(*((volatile uint32_t*)0xDC000000))


#define CAM_BLOCK		((volatile uint32_t*)0xE0000000)
#define CAM0			((volatile uint32_t*)0xE0000000)
#define CAM1			((volatile uint32_t*)0xE4000000)
#define CAM2			((volatile uint32_t*)0xE8000000)
#define CAM3			((volatile uint32_t*)0xEC000000)



extern volatile uint32_t *cams[4];


#define FAST_UART_TX	(*((volatile uint32_t*)0xF0000000))
#define FAST_UART_RX	(*((volatile uint32_t*)0xF4000000))

#define WIFI_TX			(*((volatile uint32_t*)0xF8000000))
#define WIFI_RX			(*((volatile uint32_t*)0xFC000000))



/*
#define CAM01			((volatile uint32_t*)(((uint32_t)(cam0))|((uint32_t)(cam1))))
#define CAM02			((volatile uint32_t*)(((uint32_t)(cam0))|((uint32_t)(cam2))))
#define CAM03			((volatile uint32_t*)(((uint32_t)(cam0))|((uint32_t)(cam3))))
#define CAM12			((volatile uint32_t*)(((uint32_t)(cam1))|((uint32_t)(cam2))))
#define CAM13			((volatile uint32_t*)(((uint32_t)(cam1))|((uint32_t)(cam3))))
#define CAM23			((volatile uint32_t*)(((uint32_t)(cam2))|((uint32_t)(cam3))))

#define CAM012			((volatile uint32_t*)(((uint32_t)(cam0))|((uint32_t)(cam1))|((uint32_t)(cam2))))
#define CAM013			((volatile uint32_t*)(((uint32_t)(cam0))|((uint32_t)(cam1))|((uint32_t)(cam3))))
#define CAM123			((volatile uint32_t*)(((uint32_t)(cam1))|((uint32_t)(cam2))|((uint32_t)(cam3))))

#define CAM0123			((volatile uint32_t*)(((uint32_t)(cam0))|((uint32_t)(cam1))|((uint32_t)(cam2))|((uint32_t)(cam3))))
*/

void set_clk_frequency(volatile uint32_t *reg, uint32_t clk_freq);

#endif

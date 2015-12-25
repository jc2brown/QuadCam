//
// quadcam.c
//
//

#include <stdio.h>
#include <stdint.h>

#include "xparameters.h"

#include "device.h"
#include "draw.h"
#include "fpga.h"
#include "interrupts.h"
#include "iobus.h"
#include "mcu.h"
#include "outbyte.h"
#include "ovm.h"
#include "peripherals.h"
#include "ram.h"
#include "uart.h"
#include "usb.h"
#include "util.h"
#include "vga.h"
#include "wifi.h"

#include "quadcam.h"


// Welcome message to display on startup
#define PRODUCT_NAME 	"QuadCam"
#define COMPANY_NAME	"ESE Capstone 2015"
#define WELCOME_MSG 	"\n" PRODUCT_NAME "\n" COMPANY_NAME "\n"



IODevice *iodevices[N_IODIDs] = {
	[IODID_FPGA] &fpga,
	[IODID_MCU] &mcu,
	[IODID_RAM] &ram,
	[IODID_USB] &usb,
	[IODID_VGA] &vga,
	[IODID_OVM0] ovm+0,
	[IODID_OVM1] ovm+1,
	[IODID_OVM2] ovm+2,
	[IODID_OVM3] ovm+3,
	[IODID_UART] &uart,
	[IODID_WIFI] &wifi
};


void set_clk_frequency(volatile uint32_t *reg, uint32_t clk_freq) {
	*reg = MCU_CLK_FREQ / (2*clk_freq);
}


//typedef uint16_t Screen[480][640];

//#define PAGE(n) ((Screen*)RAM_BLOCK[]

uint32_t page_addrs[N_FRAMES] = {
	(0<<23),
	(1<<23),
	(2<<23),
	(3<<23),
	(4<<23),
	(5<<23),
	(6<<23),
	(7<<23),
	(8<<23),
	(9<<23)
};



void mb_reset()
{
    microblaze_disable_interrupts();
    (*((int (*)())(0x00)))(); // restart
}


#define DEFAULT_TEST_MODE 1

int test_mode_enabled = 0;
int test_mode_armed = 0;


int loading_page;
int probe_page;
int check_page;
int test_page;
int status_page;
int console_page;
int video_page;
int still_page;
int vstripe_page = -1;
int screensaver_page = -1;

int stream_frames;
int do_cls;
int frame_sync;
int auto_page;
int enable_transfer;
int delay_capture;
int do_capture;
int n_pages;
int vga_test_mode;
uint32_t last_isr_count;


void sw1() {
	int vga_frame = get_vga_page();
	if ( test_mode_armed ) {
		LEDS_SRC = 0xF00F00F0;
		test_mode_enabled = !DEFAULT_TEST_MODE;
	} else {
		if ( !(usb.status & IODEVICE_PROBE_FAIL) && (vga_frame == video_page) && (do_capture == 0) ) {
			do_capture = 1;
		} else {
			vga_frame = (vga_frame + 1) % n_pages;
			do_capture = 0;
		}
		set_vga_page(vga_frame);

		//delay_ms(400);
	}
}

void sw2() {
	mb_reset();
}

void intc0_isr() {
	if ( COUNTER - last_isr_count < (MCU_CLK_FREQ*2) / 5 ) {
		return;
	}
	last_isr_count = COUNTER;
	uint32_t switch_status = SWITCH_STATUS;
	if ( switch_status & 0x01 ) {
		sw1();
	}
	if ( switch_status & 0x02 ) {
		sw2();
	}
}

void uart_rx_isr() {
	char c = FAST_UART_RX;
	xil_printf("\nUART RX: %c [0x%02X]\n", c, c);
}

char wifi_c;
void wifi_rx_isr() {
	//wifi_c = WIFI_RX;
	outbyte(WIFI_RX);
	//xil_printf("\nWiFi RX: %c [0x%02X]\n", c, c);
}


char *mode_keys[2] = { "async mode \n", "SYNC MODE \n" };
int usb_mode;

void set_usb_mode(int mode) {
	char *s = mode_keys[mode];
	if ( mode == usb_mode ) {
		return;
	}
	while ( *s ) {
		usb_print(*s);
		s++;
	}
	usb_mode = mode;
	USB_MODE = usb_mode;
}

//static uint32_t usb_delay_count = 0;



void usb_rx_isr() {

	uint32_t status;
	int got_cmd = 0;
	int i;
	set_usb_mode(0);
	char c = (char)(USB & 0x000000FF);
	store_draw_page();
	set_draw_page(console_page);
	draw_char(c);
	set_usb_mode(usb_mode);
	store_outbyte(usb_print);
	add_outbyte(usb_print);

	usb.status &= ~IODEVICE_PROBE_FAIL;
	usb.status |= IODEVICE_PROBE_PASS;


	if ( c == '\t' ) {
		got_cmd = 1;
	}

	if ( c == '\r' ) {
		got_cmd = 1;
	}

	if ( c == '\n' ) {
		usb_print('>');
		usb_print(' ');
		got_cmd = 1;
	}

	if ( c == '^' ) {
		//RESET = 1; // Need to fix hard reset VHDL
		mb_reset();
	}

	if ( c >= '0' && c < '0' + n_pages ) {
		set_vga_page(c - '0');
		got_cmd = 1;
	}

	if ( c >= 'a' && c <= 'd' ) {
		good_cams &= ~(1<<(c-'a'));
		got_cmd = 1;
	}

	if ( ! got_cmd ) {
		got_cmd = 1; // Assume good cmd, undone in default

		switch ( c ) {

		case '+':
			do_capture = ! do_capture;
			break;
		case '/':
			delay_capture = 1;
			break;
		case '*':
			delay_capture = 0;
			break;
		case '>':
			enable_transfer = 1;
			break;
		case '.':
			enable_transfer = 0;
			break;
		case ']':
			auto_page = 1;
			break;
		case '[':
			auto_page = 0;
			break;
		case '}':
			frame_sync = 1;
			break;
		case '{':
			frame_sync = 0;
			break;
		case '"':
			stream_frames = 1;
			break;
		case '\'':
			stream_frames = 0;
			break;
		case '!':
			for ( i = 0; i < 4; ++i ) {
				if ( (1<<i) & good_cams ) {
					cams[i][OV_REG_REG15] = 0x03; // AutoFPS:None, 4x gain
				}
			}
			break;
		case '~':
			for ( i = 0; i < 4; ++i ) {
				if ( (1<<i) & good_cams ) {
					cams[i][OV_REG_REG15] = 0x9F; // AutoFPS:1/2, 4x gain
				}
			}
			break;
		case '#':
			do_cls = 1;
			break;
		case '?':
			draw_char('\n');
			print_ram_errors();
			break;
		default:
			got_cmd = 0;
			break;
		}
	}

	if ( ! got_cmd ) {
		usb_print('?');
		usb_print('?');
		usb_print('?');
		usb_print('\n');
	}

	recall_outbyte(usb_print);
	recall_draw_page();

}


#define FPS_MAX_COUNT 3

uint32_t ovm_vsync_time[4] = { 0 };
uint32_t last_ovm_vsync_time[4] = { 0 };
uint32_t ovm_fps[4] = { 0 };
uint32_t new_fps[4] = { 0 };
uint32_t new_fps_count[4] = { 0 };

void ovm_vsync_isr(int n) {
	uint32_t fps;
	if ( OVM_VSYNC & (1<<n) ) {
		last_ovm_vsync_time[n] = ovm_vsync_time[n];
		ovm_vsync_time[n] = COUNTER;
		fps = MCU_CLK_FREQ / (ovm_vsync_time[n] - last_ovm_vsync_time[n]);
		if ( fps == new_fps[n] ) {
			if ( ++new_fps_count[n] == FPS_MAX_COUNT ) {
				ovm_fps[n] = new_fps[n];
			}
		} else {
			new_fps[n] = fps;
			new_fps_count[n] = 0;
		}
	}
}

void ovm0_vsync_isr() { ovm_vsync_isr(0); }
void ovm1_vsync_isr() { ovm_vsync_isr(1); }
void ovm2_vsync_isr() { ovm_vsync_isr(2); }
void ovm3_vsync_isr() { ovm_vsync_isr(3); }


void reset() {
	disable_interrupts();

	stream_frames = 0;
	do_cls = 0;
	frame_sync = 1;
	auto_page = 1;
	enable_transfer = 1;
	delay_capture = 1;
	do_capture = 0;
	n_pages = 0;
	vga_test_mode = 0;
	last_isr_count = 0;

	SWITCH_SRC = 0x01;

	ERROR_LED_SRC = 0;
	ERROR_LED = 1;
	set_led_clk_frequency(DEFAULT_LED_CLK_FREQ);
	set_led_latch_frequency(DEFAULT_LED_LATCH_FREQ);

	FLASH_ON = 0;
	FLASH_MAX = 1000;
	set_flash_clk_frequency(DEFAULT_FLASH_CLK_FREQ);

	good_cams = 0x0F;
	OVM_ENABLE = 0x00;

	OVM_BRAM_ENABLE = 0x00;
	OVM_MUX_ENABLE = 0x00;

	VGA_TEST_ENABLE = 0;
	VGA_ENABLE = 0;

	//DEBUG_OUTPUT_ENABLE = 0;
	//DEBUG_SRC = 0x00;

	FAST_UART_RX_SRC = 0;
	set_uart_baudrate(DEFAULT_UART_BAUDRATE);

	WIFI_ENABLE = 0;
	WIFI_RX_SRC = 0;
	set_wifi_baudrate(DEFAULT_WIFI_BAUDRATE);

	LEDS_SRC = 0xFFFFFFFF;
	LEDS1 = 0x00;
	LEDS2 = 0x00;

	reset_devices(iodevices, N_IODIDs);
}


void init() {

	init_interrupts();
	register_interrupt(IRQ_INTC0_ID, intc0_isr);
	//register_interrupt(IRQ_INTC1_ID, uart_rx_isr);
	//register_interrupt(IRQ_INTC2_ID, wifi_rx_isr);
	register_interrupt(IRQ_INTC3_ID, usb_rx_isr);
	register_interrupt(IRQ_INTC4_ID, ovm0_vsync_isr);
	register_interrupt(IRQ_INTC5_ID, ovm1_vsync_isr);
	register_interrupt(IRQ_INTC6_ID, ovm2_vsync_isr);
	register_interrupt(IRQ_INTC7_ID, ovm3_vsync_isr);

	// Test mode is activated by holding SW1 on startup,
	// then releasing it when 1001001 is shown on the LEDs
	test_mode_enabled = DEFAULT_TEST_MODE;
	test_mode_armed = 1;

	enable_interrupts();

	test_mode_armed = 0;


	draw_init(page_addrs);
	set_draw_page(0);
	cls();

	OVM1_LINE_OFFSET = 0;
	OVM0_LINE_OFFSET = 1024;
	OVM3_LINE_OFFSET = 1504;
	OVM2_LINE_OFFSET = 480;

	ovm_init(0);

	init_devices(iodevices, N_IODIDs);
}


int test() {
	test_devices(iodevices, N_IODIDs);
	return 0;
}




void draw_switch_labels() {

	store_style();
	set_bg_colour(colour_beige);
	set_fg_colour(colour_black);
	set_cursor((1280/COL_WIDTH)/4-5, 4);
	xil_printf(" SW2 ");
	set_bg_colour(colour_black);
	set_fg_colour(colour_white);
	xil_printf(" Reset");

	set_bg_colour(colour_beige);
	set_fg_colour(colour_black);
	set_cursor((1280/COL_WIDTH)/4+10, 4);
	xil_printf(" SW1 ");
	set_bg_colour(colour_black);
	set_fg_colour(colour_white);
	if ( !(usb.status & IODEVICE_PROBE_FAIL) && (get_vga_page() == video_page) && ! do_capture ) {
		xil_printf(" Shoot");
	} else {
		xil_printf(" Page ");
	}

	recall_style();
}


void draw_cam_info(int id, int fps) {

	char y = 0;
	char r = 0;
	char g = 0;
	char b = 0;

	if ( (1<<id) & good_cams ) {
		y = 0x80|(cams[id][OV_REG_YAVG]/16);
		r = 0x80|(cams[id][OV_REG_RAVG]/16);
		g = 0x80|(cams[id][OV_REG_GAVG]/16);
		b = 0x80|(cams[id][OV_REG_BAVG]/16);
	}

	store_style();

	set_bg_colour(colour_black);

	set_fg_colour(colour_ltgrey);
	xil_printf("CC%d ", id+1);

	set_fg_colour(colour_white);
	xil_printf("%c ", y);

	set_fg_colour(colour_red);
	xil_printf("%c ", r);

	set_fg_colour(colour_green);
	xil_printf("%c ", g);

	set_fg_colour(colour_paleblue);
	xil_printf("%c ", b);

	set_fg_colour(colour_ltgrey);
	xil_printf("%-2d Hz ", fps);

	recall_style();

}


Style default_text_style = {
	.bg_mode = DRAW_OVER,
	.bg_colour = colour_black,
	.fg_mode = DRAW_OVER,
	.fg_colour = colour_white,
};

Style red_text_style = {
	.bg_mode = DRAW_OVER,
	.bg_colour = colour_black,
	.fg_mode = DRAW_OVER,
	.fg_colour = colour_richred,
};

Style default_header_style = {
	.bg_mode = DRAW_OVER,
	.bg_colour = colour_richblue,
	.fg_mode = DRAW_OVER,
	.fg_colour = colour_white,
};

Style test_mode_header_style = {
	.bg_mode = DRAW_OVER,
	.bg_colour = colour_richred,
	.fg_mode = DRAW_OVER,
	.fg_colour = colour_white,
};




int flash() {
	volatile int i;
	while (1) {
		LEDS_SRC = 0xF0000000;
		//(*((volatile uint32_t*)0x80000010)) = 0x11;
		for ( i = 0; i < 100000; ++i );
		LEDS_SRC = 0x000000F0;
		//(*((volatile uint32_t*)0x80000010)) = 0xFF;
		for ( i = 0; i < 100000; ++i );
	}
	return 1;
}




int main() {



	volatile uint32_t i, j;
	uint32_t leds = 0x0000000F;
	Style header_style = default_header_style;
	Style text_style = default_text_style;






	//enable_usb_print = 0;

	reset();
	init();


	VGA_MAGIC_KEY = test_mode_header_style.bg_colour;
	VGA_MAGIC_KEY = (0x01 << 12) | (0x01 << 7) | (0x01 << 1);
	VGA_MAGIC_KEY = colour_transparent;


	add_outbyte(draw_char);
	add_outbyte(usb_print);




	// -------------------------------------------------------
	// Loading Page
	// -------------------------------------------------------

	//enable_usb_print = 1;

	loading_page = n_pages;
	++n_pages;

	set_draw_page(loading_page);
	cls();

	leds <<= 4;
	LEDS_SRC = leds;

	set_vga_page(loading_page);
	set_style(text_style);
	store_style();
	if ( test_mode_enabled ) {
		header_style = test_mode_header_style;
	}
	set_style(header_style);
	xil_printf("\nLoading QuadCam...\n");
	recall_style();


	set_cursor(0x10, 3);
	for (i = 0x10 ; i < CHAR_ROM_SIZE; ++i) {
		draw_char((char)i);
	}
	xil_printf("\nTHE QUICK BROWN FOX JUMPS OVER THE LAZY DOG.");
	xil_printf("\nthe quick brown fox jumps over the lazy dog.");


	set_led_clk_frequency(DEFAULT_LED_CLK_FREQ);
	set_led_latch_frequency(DEFAULT_LED_LATCH_FREQ);


	// The datasheet uses 8bit addressing Read:0x42, Write:0x43
	// We (and the logic analyzer) use 7bit addressing with the 8th bit denoting read/write
	// The cameras' 7bit address is 0x21
	OVM_DEV_ADDR = 0x42 >> 1;

	set_ovm_xvclk_frequency(6000000);
	set_ovm_scl_clk_frequency(10000);

	xil_printf("\n\nHello!\n");
	xil_printf(WELCOME_MSG);

	if ( test_mode_enabled ) {
		set_style(red_text_style);
		xil_printf("\nTEST MODE\n");
		set_style(text_style);
	}

	delay_s(1);

	// -------------------------------------------------------
	// Probe Page
	// -------------------------------------------------------

	probe_page = n_pages;
	++n_pages;

	set_draw_page(probe_page);
	cls();

	leds <<= 4;
	LEDS_SRC = leds;

	set_vga_page(probe_page);
	set_style(header_style);
	xil_printf("\nProbing devices\n");
	set_style(text_style);

	probe_devices(iodevices, N_IODIDs);
	print_probe_results();



	// -------------------------------------------------------
	// Check Page
	// -------------------------------------------------------

	check_page = n_pages;
	++n_pages;

	set_draw_page(check_page);
	cls();

	leds <<= 4;
	LEDS_SRC = leds;

	set_vga_page(check_page);
	set_style(header_style);
	xil_printf("\nChecking devices\n");
	set_style(text_style);

	check_devices(iodevices, N_IODIDs);
	print_check_results();



	// -------------------------------------------------------
	// Test Page
	// -------------------------------------------------------

	if ( test_mode_enabled ) {

		test_page = n_pages;
		++n_pages;

		set_draw_page(test_page);
		cls();

		leds <<= 4;
		LEDS_SRC = leds;

		set_vga_page(test_page);
		set_style(header_style);
		xil_printf("\nTesting devices\n");
		set_style(text_style);

		test();
		print_test_results();
	}






	// -------------------------------------------------------
	// Status Page
	// -------------------------------------------------------


	status_page = n_pages;
	++n_pages;

	set_draw_page(status_page);
	cls();

	leds <<= 4;
	LEDS_SRC = leds;

	set_vga_page(status_page);
	set_style(header_style);
	xil_printf("\nHardware Status\n");
	set_style(text_style);
	print_results();


	remove_outbyte(usb_print);


	// -------------------------------------------------------
	// Console page
	// -------------------------------------------------------

	console_page = n_pages;
	++n_pages;

	set_draw_page(console_page);
	cls();

	leds <<= 4;
	LEDS_SRC = leds;

	set_vga_page(console_page);
	set_style(header_style);
	xil_printf("\nConsole\n");
	set_style(text_style);


	// -------------------------------------------------------
	// Still Page
	// -------------------------------------------------------

	still_page = n_pages;
	++n_pages;

	set_draw_page(still_page);
	cls();

	set_vga_page(still_page);

	if ( usb.status & IODEVICE_PROBE_FAIL ) {
		xil_printf("\nUSB link not detected, page will remain blank");
	} else {
		xil_printf("\nStill images will appear here");
	}

	set_origin(0,(960/ROW_HEIGHT));


	// -------------------------------------------------------
	// Video Page
	// -------------------------------------------------------

	video_page = n_pages;
	++n_pages;

	set_draw_page(video_page);
	set_origin(0,(960/ROW_HEIGHT));
	cls();

	leds <<= 4;
	LEDS_SRC = leds;

	set_vga_page(video_page);
	set_ovm_page(video_page);




	// -------------------------------------------------------
	// Vertical Stripe Page
	// -------------------------------------------------------

	vstripe_page = n_pages;
	++n_pages;


	// -------------------------------------------------------
	// Screensaver Page
	// -------------------------------------------------------

	screensaver_page = n_pages;
	++n_pages;




	//leds <<= 4;
	//LEDS_SRC = leds;

	ovm_config();

	uint32_t cur_counter = 0;
	uint32_t last_counter;

	//int count = 0;
	//int frame = 0;
	int cur_fps = 0, last_fps = 0;


	//int ovm_fps[4];


	set_flash_clk_frequency(7200);
	ERROR_LED = 0;
	ERROR_LED_SRC = ERROR_LED_SRC_RAM_BUSY;
	FLASH_MAX = 100;
	LEDS_SRC = 0x90000000;



	set_draw_page(video_page);
	set_vga_page(video_page);
	set_usb_page(video_page);


	uint32_t a, word;
	int x, y;


	//USB_ENABLE = 1;
	USB_MODE = 0;
	//set_usb_mode(1);

	add_outbyte(usb_print);
	xil_printf("\n> ");
	remove_outbyte(usb_print);

	do_capture = 0;

	uint32_t last_good_cams = 0;

	set_vga_page(screensaver_page);

	while(1) {

		if ( do_cls ) {
			cls();
			do_cls = 0;
		}

		store_style();
		set_bg_colour(colour_transparent);
		draw_rect(0, 960, 1279, 963, 0);
		recall_style();

		set_origin((1280/COL_WIDTH)/2-10, (960/ROW_HEIGHT));
		set_cursor(0, 1);
		xil_printf("QuadCam Monitor\n");
		xil_printf("ESE Capstone 2015\n");
		xil_printf("Display 60 Hz\n");
		set_origin(0,(960/ROW_HEIGHT));

		for (j = 0; j < 4; ++j ) {
			//ovm_fps[j] = measure_fps(j);

			draw_switch_labels();

			for ( i = 10; i > 0; --i ) {

				if ( last_good_cams != good_cams ) {
					OVM_ENABLE = good_cams;
					last_good_cams = good_cams;
				}



				FLASH_ON = i;

				set_cursor(5, 1);
				draw_cam_info(1, ovm_fps[1]);

				set_cursor((1280/COL_WIDTH)-25, 1);
				draw_cam_info(0, ovm_fps[0]);

				set_cursor(5, 4);
				draw_cam_info(2, ovm_fps[2]);

				set_cursor((1280/COL_WIDTH)-25, 4);
				draw_cam_info(3, ovm_fps[3]);


				last_counter = cur_counter;
				cur_counter = COUNTER;
				last_fps = cur_fps;
				cur_fps = MCU_CLK_FREQ / (cur_counter - last_counter);
				if ( cur_fps == last_fps ) {
					set_cursor((1280/COL_WIDTH)/2-10, 4);
					xil_printf("Info panel %d Hz    ", cur_fps);
				}


				if ( do_capture ) {

					if ( delay_capture ) {
						leds = 0xFE;
						LEDS_SRC = 0x22222220;

						for ( i = 7; i > 0; --i ) {
							LEDS2 = leds;
							leds <<= 1;
							draw_switch_labels();
							set_cursor(120, 4);
							xil_printf("-- Capture in %d... --", i/2);
							set_cursor(120, 4);
							delay_ms(250);
							xil_printf("   Capture in %d...   ", i/2);
							delay_ms(250);
							if ( do_capture == 0 ) {
								break;
							}
						}
						set_cursor(120, 4);
						xil_printf("                      ");

						LEDS_SRC = 0x90000000;
					}

					if ( do_capture ) {
						do_capture = 0;

						//delay_ms(100);

						while ( (frame_sync == 1) && ((OVM_VSYNC & good_cams) != good_cams) );
						set_ovm_page(still_page);
						ERROR_LED = 1;
						ERROR_LED_SRC = ERROR_LED_SRC_MCU;
						delay_ms(100);
						if ( auto_page && get_vga_page() == video_page ) {
							set_vga_page(still_page);
							set_usb_page(video_page);
						}
						set_draw_page(still_page);
						//cls();
						ERROR_LED_SRC = ERROR_LED_SRC_RAM_BUSY;
						while ( (frame_sync == 1) && ((OVM_VSYNC & good_cams) != good_cams) );

						if ( enable_transfer && !(usb.status & IODEVICE_PROBE_FAIL) ) {

							// Clean up old text
							set_cursor((1280/COL_WIDTH)/2-15, 2);
							xil_printf("                             ");
							set_cursor((1280/COL_WIDTH)/2-15, 3);
							xil_printf("                             ");


							set_cursor((1280/COL_WIDTH)/2-15, 2);
							xil_printf("Sending frame, please wait...");

							USB_MODE = 1;

							for ( i = 0; i < 100; ++i ) {
								USB = 0;
							}

							// Send magic start words
							word = 0xEFCDAB89;
							for ( i = 0; i < 4; ++i ) {
								USB = ((uint8_t*)&word)[i];
							}
							word = 0x67452301;
							for ( i = 0; i < 4; ++i ) {
								USB = ((uint8_t*)&word)[i];
							}

							// Draw magic end words to be sent at end of frame
							a = page_addrs[get_usb_page()]/4 + 512*2047 + 318;
							RAM_BLOCK[a] = 0x67452301;

							a = page_addrs[get_usb_page()]/4 + 512*2047 + 319;
							RAM_BLOCK[a] = 0xEFCDAB89;



							for ( y = 0; y < 2048; ++y ) {

								set_cursor((1280/COL_WIDTH)/2-15, 3);
								xil_printf("%d%%", (100*y)/2048);
								//xil_printf("   ");

								for ( x = 0; x < 320; ++x ) {

									a = page_addrs[get_usb_page()]/4 + 512*y + x;

									word = RAM_BLOCK[a];

									for ( i = 0; i < 4; ++i ) {
										USB = ((uint8_t*)&word)[i];
									}
								}
							}



							set_cursor((1280/COL_WIDTH)/2-15, 2);
							xil_printf("         Frame sent.         ");
							set_cursor((1280/COL_WIDTH)/2-15, 3);
							xil_printf("            100%%             ");
						}


						set_ovm_page(video_page);
						delay_ms(300);
						if ( auto_page && get_vga_page() == still_page ) {
							set_vga_page(video_page);
						}
						set_draw_page(video_page);

						//delay_ms(200);

						add_outbyte(usb_print);
						xil_printf("\n");
						if ( stream_frames ) {
							xil_printf("-");
						} else {
							xil_printf("> ");
						}
						remove_outbyte(usb_print);

					}
				}

			}
		}
	}
	return 0;
}

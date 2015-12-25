#include <stdint.h>
#include <stdio.h>
#include "device.h"
#include "draw.h"



const uint64_t char_rom[CHAR_ROM_SIZE] = {

	['\x01'] 0x006F7B0023F70000,

	['a'] 0x00019213A5268000,
	['b'] 0x0842D98C63170000,
	['c'] 0x0000C98420930000,
	['d'] 0x0085B38C63170000,
	['e'] 0x0001D1FC21170000,
	['f'] 0x0191C42108470000,
	['g'] 0x0001D18C6336842E,
	['h'] 0x0842D98C63188000,
	['i'] 0x0201842108470000,
	['j'] 0x0100C21084210A4C,
	['k'] 0x084254C629288000,
	['l'] 0x0610842108470000,
	['m'] 0x00025FAD63188000,
	['n'] 0x0002D98C63188000,
	['o'] 0x0001D18C63170000,
	['p'] 0x0001D18C639B4210,
	['q'] 0x0001D18C63368421,
	['r'] 0x0002C942108E0000,
	['s'] 0x0001D18383170000,
	['t'] 0x0423E84210930000,
	['u'] 0x0002318C63368000,
	['v'] 0x0002318A94A20000,
	['w'] 0x0002318D6B550000,
	['x'] 0x00036A2108AD8000,
	['y'] 0x0002318A94422110,
	['z'] 0x0003F111111F8000,

	['A'] 0x0229518FE3188000,
	['B'] 0x0F252972529F0000,
	['C'] 0x0326308422930000,
	['D'] 0x0F25294A529F0000,
	['E'] 0x0FA50872109F8000,
	['F'] 0x0FA50A72908E0000,
	['G'] 0x074610BC63170000,
	['H'] 0x08C631FC63188000,
	['I'] 0x0F908421084F8000,
	['J'] 0x0388421085260000,
	['K'] 0x08CA988629288000,
	['L'] 0x0E210842109F8000,
	['M'] 0x08C775AC63188000,
	['N'] 0x08C735AD67188000,
	['O'] 0x0746318C63170000,
	['P'] 0x0F252972108E0000,
	['Q'] 0x0746318C63171060,
	['R'] 0x0F252972949C8000,
	['S'] 0x0746107043170000,
	['T'] 0x0FD4842108470000,
	['U'] 0x08C6318C63170000,
	['V'] 0x08C6315294420000,
	['W'] 0x08C631AD6B550000,
	['X'] 0x08C5442115188000,
	['Y'] 0x08C54A2108470000,
	['Z'] 0x0FC44222111F8000,

	['0'] 0x074673AE73170000,
	['1'] 0x02708421084F8000,
	['2'] 0x07442111110F8000,
	['3'] 0x0744213043170000,
	['4'] 0x011952F884238000,
	['5'] 0x0FC216C843170000,
	['6'] 0x032210F463170000,
	['7'] 0x0FC4422110880000,
	['8'] 0x0746317463170000,
	['9'] 0x0746317842260000,

	['-'] 0x000000F800000000,
	['+'] 0x000084F908000000,
	['='] 0x00001F003E000000,
	['/'] 0x0084422110880000,
	['\\'] 0x0821042084108000,
	['.'] 0x0000000000C60000,
	[','] 0x0000000000C62200,
	[':'] 0x0000C60000630000,
	['('] 0x0111084210410000,
	[')'] 0x0410421084440000,
	['['] 0x0721084210870000,
	[']'] 0x0708421084270000,
	['@'] 0x032675AD66838000,
	['#'] 0x052BEA52BEA50000,
	['%'] 0x0451222224510000,
	['*'] 0x0012AEA900000000,


	// Vertical bar graph range 0 to 15
	[0x80] 0x0000000000000000, // scale0
	[0x81] 0x000000000000000F, // scale1
	[0x82] 0x000000000000007F, // scale2
	[0x83] 0x00000000000007FF, // scale3
	[0x84] 0x0000000000007FFF, // scale4
	[0x85] 0x00000000000FFFFF, // scale5
	[0x86] 0x00000000007FFFFF, // scale6
	[0x87] 0x0000000003FFFFFF, // scale7
	[0x88] 0x000000003FFFFFFF, // scale8
	[0x89] 0x00000003FFFFFFFF, // scale9
	[0x8A] 0x0000003FFFFFFFFF, // scale10
	[0x8B] 0x000001FFFFFFFFFF, // scale11
	[0x8C] 0x00001FFFFFFFFFFF, // scale12
	[0x8D] 0x0001FFFFFFFFFFFF, // scale13
	[0x8E] 0x001FFFFFFFFFFFFF, // scale14
	[0x8F] 0x00FFFFFFFFFFFFFF, // scale15

	[0x90] 0x0FFFFFFFFFFFFFFF, // AllOn
	[0x91] 0x0AD6B5AD6B5AD6B5, // vstripe

};







typedef struct rc_struct {
	uint32_t row;
	uint32_t col;
} RC;


typedef struct page_struct {
	uint32_t frame_addr;
	RC origin;
	RC cursor;
	RC stored_origin;
	RC stored_cursor;
	Style style;
	Style stored_style;
} Page;






void set_style(Style style);

void init_page(uint32_t frame_addr);

/*
uint32_t draw_frame_addr;

void set_draw_frame(int frame) {
	draw_frame_addr = frame_addrs[frame];
}
*/



#define N_PAGES 16
Page pages[N_PAGES];
static Page *active_page;
int active_page_id;
int stored_page_id;


void set_draw_page(int n) {
	active_page_id = n;
	active_page = &(pages[n]);
}

int get_draw_page() {
	return active_page_id;
}

void store_draw_page() {
	stored_page_id = get_draw_page();
}

void recall_draw_page() {
	set_draw_page(stored_page_id);
}


Style default_style = {
	.bg_mode = DRAW_OVER,
	.bg_colour = colour_black,
	.fg_mode = DRAW_OVER,
	.fg_colour = colour_white,
};

void init_page(uint32_t frame_addr) {

	active_page->frame_addr = frame_addr;

	set_style(default_style);

	set_origin(1,1);
	set_cursor(0,0);
}



RGB565 colour_transparent;

void draw_init(uint32_t *frame_addrs) {

	int i;


	colour_transparent = colour_magenta;
	//colour_transparent = colour_black;

	for ( i = 0; i < N_FRAMES; ++i ) {
		set_draw_page(i);
		init_page(frame_addrs[i]);
	}


}



void set_cursor(int col, int row) {
	active_page->cursor.row = row;
	active_page->cursor.col = col;
}

void set_origin(int col, int row) {
	active_page->origin.row = row;
	active_page->origin.col = col;
}


void cls() {
	set_bg_colour(colour_transparent);
	set_bg_colour(colour_black);
	draw_rect(0,0,1279,1023,0);
	active_page->cursor.col = 0;
	active_page->cursor.row = 0;
}




// Draws one pixels to the RAM video buffer
void draw_pixel(uint32_t x, uint32_t y, int active) {
	uint32_t fg_mask, bg_mask;
	if ( x % 2 == 1 ) {
		fg_mask = 0xFFFF0000;
		bg_mask = 0xFFFF0000;
	} else {
		fg_mask = 0x0000FFFF;
		bg_mask = 0x0000FFFF;
	}
	if ( ! active ) {
		fg_mask = 0x00000000;
	}
	draw_pixels(x, y, fg_mask, bg_mask);
}

// Draws two pixels to the RAM video buffer
// Pixels are stored in 16-bit RGB565 format
// The microblaze uses 32-bit transactions so we operate on two pixels at once
void draw_pixels(uint32_t x, uint32_t y, uint32_t fg_mask, uint32_t bg_mask) {
	x /= 2;
	if ( x >= 320 ) {
		x = (x - 320) + 1024 * 512;
	}
	uint32_t a = active_page->frame_addr/4 + y*512 + x;
	RGB565 pixels = 0x00000000;

	// Don't fetch pixels from RAM if we overwrite both
	if ( bg_mask != 0xFFFFFFFF || active_page->style.bg_mode != DRAW_OVER ) {
		pixels = RAM_BLOCK[a];
	}
	switch ( active_page->style.bg_mode ) {
	case DRAW_OVER:
		pixels = (active_page->style.bg_colour & bg_mask) | (pixels & ~bg_mask);
		break;
	case DRAW_XOR:
		pixels = ((pixels ^ active_page->style.bg_colour) & bg_mask) | (pixels & ~bg_mask);
		break;
	}
	switch ( active_page->style.fg_mode ) {
	case DRAW_OVER:
		pixels = (active_page->style.fg_colour & fg_mask) | (pixels & ~fg_mask);
		break;
	case DRAW_XOR:
		pixels = ((pixels ^ active_page->style.fg_colour) & fg_mask) | (pixels & ~fg_mask);
		break;
	}
	RAM_BLOCK[a] = pixels;
}


void draw_rect(uint32_t x0, uint32_t y0, uint32_t x1, uint32_t y1, int active) {
	uint32_t x, y;
	for ( y = y0; y <= y1; ++y ) {
		x = x0;
		if ( x % 2 == 1 ) {
			draw_pixel(x, y, active);
			++x;
		}
		for ( ; x < x1; x += 2 ) {
			draw_pixels(x, y, (active ? 0xFFFFFFFF : 0x0), 0xFFFFFFFF);
		}
		if ( x == x1 ) {
			draw_pixel(x, y, active);
		}
	}
}


//RGB565 to_RGB565(uint8_t r, uint8_t g, uint8_t b) {
//	uint8_t _r = r >> 3;
//	uint8_t _g = g >> 2;
//	uint8_t _b = b >> 3;
//	RGB565 rgb = (((RGB565)_r) << (5+6)) | (((RGB565)_g) << 5) | ((RGB565)_b);
//	return ((RGB565)(rgb) << 16) | ((RGB565)rgb);
//}


void draw_char(char c) {

	int i, j;
	uint32_t x, y;
	uint64_t cdef = char_rom[((uint8_t)c) % 256];

	while ( active_page->cursor.col >= (1280/COL_WIDTH) ) {
		active_page->cursor.col -= (1280/COL_WIDTH);
		++active_page->cursor.row;
	}
	active_page->cursor.row %= (1024/ROW_HEIGHT);

	switch ( c ) {
	case '\n':
		active_page->cursor.row += 1;
		active_page->cursor.col = 0;
		return;
	case '\r':
		active_page->cursor.col = 0;
		return;
	case '\f':
		active_page->cursor.row = 0;
		active_page->cursor.col = 0;
		return;
	}

	uint32_t row = active_page->cursor.row + active_page->origin.row;
	uint32_t col = active_page->cursor.col + active_page->origin.col;


	uint32_t cmask;
	int k;

	for ( j = ROW_HEIGHT-1; j >= 0; --j ) {

		y = row * ROW_HEIGHT + j;


		i = COL_WIDTH;
		x = col * COL_WIDTH + i;

		if ( x % 2 == 0 ) {
			if ( j >= CHAR_TPAD && j < ROW_HEIGHT-CHAR_BPAD && i >= CHAR_LPAD && i < COL_WIDTH-CHAR_RPAD ) {
				draw_pixel(x, y, (cdef & 1));
				cdef >>= 1;
			} else {
				draw_pixel(x, y, 0);
			}
			++i;
		}


		for ( ; i > 0; i -= 2 ) {
			x = col * COL_WIDTH + i;
			cmask = 0;
			for ( k = 0; k < 2; ++k ) {
				cmask <<= 16;
				if ( j >= CHAR_TPAD && j < ROW_HEIGHT-CHAR_BPAD && i-k >= CHAR_LPAD && i-k < COL_WIDTH-CHAR_RPAD ) {
					if ( cdef & 1 ) {
						cmask |= 0x0000FFFF;
					}
					cdef >>= 1;
				}
			}
			draw_pixels(x, y, cmask, 0xFFFFFFFF);
		}

		if ( i == 0 ) {
			x = col * COL_WIDTH + i;
			if ( j >= CHAR_TPAD && j < ROW_HEIGHT-CHAR_BPAD && i >= CHAR_LPAD && i < COL_WIDTH-CHAR_RPAD ) {
				draw_pixel(x, y, (cdef & 1));
				cdef >>= 1;
			} else {
				draw_pixel(x, y, 0);
			}
		}
	}
	++active_page->cursor.col;
}



void set_fg_mode(DrawMode mode) {
	active_page->style.fg_mode = mode;
}
void set_bg_mode(DrawMode mode) {
	active_page->style.bg_mode = mode;
}

void set_fg_colour(RGB565 colour) {
	active_page->style.fg_colour = colour;
}
void set_bg_colour(RGB565 colour) {
	active_page->style.bg_colour = colour;
}

void set_style(Style style) {
	active_page->style = style;
}
Style get_style() {
	return active_page->style;
}

void store_style() {
	active_page->stored_style = active_page->style;
}

void recall_style() {
	active_page->style = active_page->stored_style;
}

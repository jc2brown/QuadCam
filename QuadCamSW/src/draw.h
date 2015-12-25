
#ifndef DRAW_H
#define DRAW_H

#include <stdint.h>
#include "iobus.h"




typedef uint32_t RGB565;


typedef enum DrawMode_enum {
	DRAW_OVER,
	DRAW_XOR
} DrawMode;


typedef struct style_struct {
	DrawMode fg_mode;
	DrawMode bg_mode;
	RGB565 fg_colour;
	RGB565 bg_colour;
} Style;



#define MERGE565(r,g,b)	((((RGB565)((r)>>3)) << (5+6)) | (((RGB565)((g)>>2)) << 5) | ((RGB565)((b)>>3)))
#define LCOPY(rgb) 		(((RGB565)(rgb)) << 16) | ((RGB565)(rgb))

#define to_RGB565(r,g,b) (LCOPY(MERGE565((r),(g),(b))))


#define colour_black 		to_RGB565(0x00, 0x00, 0x00)
#define colour_dkgrey 		to_RGB565(0x40, 0x40, 0x40)
#define colour_blackgrey	to_RGB565(0x10, 0x10, 0x10)
#define colour_grey 		to_RGB565(0x80, 0x80, 0x80)
#define colour_ltgrey 		to_RGB565(0xEF, 0xEF, 0xEF)
#define colour_white 		to_RGB565(0xFF, 0xFF, 0xFF)

#define colour_red 			to_RGB565(0xFF, 0x00, 0x00)
#define colour_green 		to_RGB565(0x00, 0xFF, 0x00)
#define colour_blue 		to_RGB565(0x00, 0x00, 0xFF)
#define colour_yellow 		to_RGB565(0xFF, 0xFF, 0x00)
#define colour_cyan 		to_RGB565(0x00, 0xFF, 0xFF)
#define colour_magenta 		to_RGB565(0xFF, 0x00, 0xFF)

#define colour_paleblue		to_RGB565(0x00, 0xC0, 0xFF)
#define colour_richblue		to_RGB565(0x30, 0x80, 0xE0)
#define colour_richred  	to_RGB565(0xE0, 0x40, 0x20)
#define colour_darkgreen  	to_RGB565(0x20, 0x80, 0x40)
#define colour_beige		to_RGB565(0xFF, 0xFF, 0xC0)

extern RGB565 colour_transparent;

// Printed character padding
#define CHAR_BPAD 0
#define CHAR_TPAD 2
#define CHAR_LPAD 1
#define CHAR_RPAD 1



// Pixel dimensions of characters printed to screen
// Must match char_rom data format (see CharROM.xlsx)
#define CHAR_WIDTH 5
#define CHAR_HEIGHT 12


// Pixel width allocated to each character
// Sets character spacing
//#define COL_WIDTH 6
#define COL_WIDTH (CHAR_WIDTH + CHAR_LPAD + CHAR_RPAD)
#if COL_WIDTH < CHAR_WIDTH
#error COL_WIDTH must not be less than CHAR_WIDTH
#endif


// Pixel height allocated to each character
// Sets row spacing
//#define ROW_HEIGHT 15
#define ROW_HEIGHT (CHAR_HEIGHT + CHAR_BPAD + CHAR_TPAD)
#if ROW_HEIGHT < CHAR_HEIGHT
#error ROW_HEIGHT must not be less than CHAR_HEIGHT
#endif


// Printed character bitmaps
// Each bit corresponds to one pixel in a 5-wide 12-high grid (per CHAR_WIDTH & CHAR_HEIGHT)
// 60 pixels stored in one 64-bit datatype. Data format MSb to LSb:
//   - Uppermost 4 bits are unused
//   - Next 5 bits: top line of character, left to right MSb to LSb
//   - Repeat for remaining 11 lines //
// See CharROM.xlsx for automatic bitmap generation

#define CHAR_ROM_SIZE 0xA0

extern const uint64_t char_rom[CHAR_ROM_SIZE];










/*
int get_vga_frame(void);
void set_vga_frame(int frame);
void set_draw_frame(int frame);
*/

//uint32_t to_RGB565(uint8_t r, uint8_t g, uint8_t b);


void draw_init(uint32_t *frame_addrs);

void set_draw_page(int n);
int get_draw_page(void);
void store_draw_page(void);
void recall_draw_page(void);

void cls(void);


void draw_char(char c);
void draw_pixel(uint32_t x, uint32_t y, int active);
void draw_pixels(uint32_t x, uint32_t y, uint32_t fg_mask, uint32_t bg_mask);
void draw_rect(uint32_t x0, uint32_t y0, uint32_t x1, uint32_t y1, int active);


void set_cursor(int col, int row);
void set_origin(int col, int row);


void set_fg_mode(DrawMode draw_mode);
void set_bg_mode(DrawMode draw_mode);

void set_fg_colour(RGB565 colour);
void set_bg_colour(RGB565 colour);

void set_style(Style style);
Style get_style(void);

void store_style(void);
void recall_style(void);








#endif


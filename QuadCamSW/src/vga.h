#ifndef VGA_H
#define VGA_H

#include <stdint.h>

#include "iobus.h"



int get_vga_page(void);
void set_vga_page(int page);



extern IODevice vga;





#endif


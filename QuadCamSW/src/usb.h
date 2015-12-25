#ifndef USB_H
#define USB_H

#include <stdint.h>

#include "iobus.h"


#define USB_PRINT_TIMEOUT 100 // microseconds

void usb_print(char c);

int get_usb_page(void);
void set_usb_page(int page);



extern IODevice usb;





#endif


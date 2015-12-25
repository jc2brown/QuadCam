
#include <stdint.h>

#ifndef WIFI_H
#define WIFI_H


#define DEFAULT_WIFI_BAUDRATE 115200


void wifi_outbyte(char c);
void set_wifi_baudrate(uint32_t wifi_baudrate);




extern IODevice wifi;


#endif

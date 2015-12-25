
#include <stdint.h>

#ifndef UART_H
#define UART_H


#define DEFAULT_UART_BAUDRATE 115200
#define N_BAUDRATES 12

const extern uint32_t valid_baudrates[N_BAUDRATES];


void uart_outbyte(char c);
void set_uart_baudrate(uint32_t uart_baudrate);


extern IODevice uart;


#endif

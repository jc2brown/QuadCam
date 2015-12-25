
#ifndef UTIL_H
#define UTIL_H

#include <stdint.h>


void delay_us(uint32_t us);
void delay_ms(uint32_t ms);
void delay_s(uint32_t s);

void printc(const char c);
void prints(const char *str);

void printios(volatile uint32_t *addr, const char *str);
//void printios32(volatile uint32_t *addr, const uint32_t *str);

void printio8(volatile uint32_t *addr, const uint8_t *str, uint32_t n);
void printio32(volatile uint32_t *addr, const uint32_t *str, uint32_t n);


#endif

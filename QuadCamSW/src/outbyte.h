#ifndef OUTBYTE_H
#define OUTBYTE_H

#define N_OUTBYTE_FCNS 4

void outbyte(char c);
void add_outbyte(void (*new_outbyte_fcn)(char));
void remove_outbyte(void (*old_outbyte_fcn)(char));
void store_outbyte(void (*old_outbyte_fcn)(char));
void recall_outbyte(void (*new_outbyte_fcn)(char));
void store_outbytes();
void recall_outbytes();

#endif

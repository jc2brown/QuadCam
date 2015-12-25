#include <stdlib.h>
#include "outbyte.h"

#define N_OUTBYTE_FCNS 4


void outbyte_stub(char c) {}

void (*outbyte_fcn[N_OUTBYTE_FCNS])(char) = {
		outbyte_stub, outbyte_stub, outbyte_stub, outbyte_stub
};

void (*stored_outbyte_fcn[N_OUTBYTE_FCNS])(char) = {
		outbyte_stub, outbyte_stub, outbyte_stub, outbyte_stub
};

void outbyte(char c) {
	int i;
	for ( i = 0; i < N_OUTBYTE_FCNS; ++i ) {
		if ( outbyte_fcn[i] != NULL ) {
			outbyte_fcn[i](c);
		}
	}
}

void add_outbyte(void (*new_outbyte_fcn)(char)) {
	int i;
	for ( i = 0; i < N_OUTBYTE_FCNS; ++i ) {
		if ( outbyte_fcn[i] == new_outbyte_fcn ) {
			return;
		}
	}
	for ( i = 0; i < N_OUTBYTE_FCNS; ++i ) {
		if ( outbyte_fcn[i] == NULL || outbyte_fcn[i] == outbyte_stub ) {
			outbyte_fcn[i] = new_outbyte_fcn;
			return;
		}
	}
}

void remove_outbyte(void (*old_outbyte_fcn)(char)) {
	int i;
	for ( i = 0; i < N_OUTBYTE_FCNS; ++i ) {
		if ( outbyte_fcn[i] == old_outbyte_fcn ) {
			outbyte_fcn[i] = outbyte_stub;
			return;
		}
	}
}

void store_outbyte(void (*old_outbyte_fcn)(char)) {
	int i;
	for ( i = 0; i < N_OUTBYTE_FCNS; ++i ) {
		if ( outbyte_fcn[i] == old_outbyte_fcn ) {
			stored_outbyte_fcn[i] = outbyte_fcn[i];
			outbyte_fcn[i] = outbyte_stub;
			return;
		}
	}
}

void recall_outbyte(void (*new_outbyte_fcn)(char)) {
	int i;
	remove_outbyte(new_outbyte_fcn);
	for ( i = 0; i < N_OUTBYTE_FCNS; ++i ) {
		if ( stored_outbyte_fcn[i] == new_outbyte_fcn ) {
			outbyte_fcn[i] = stored_outbyte_fcn[i];
			stored_outbyte_fcn[i] = outbyte_stub;
			return;
		}
	}
}

void store_outbytes() {
	int i;
	for ( i = 0; i < N_OUTBYTE_FCNS; ++i ) {
		stored_outbyte_fcn[i] = outbyte_fcn[i];
		outbyte_fcn[i] = outbyte_stub;
	}
}

void recall_outbytes() {
	int i;
	for ( i = 0; i < N_OUTBYTE_FCNS; ++i ) {
		outbyte_fcn[i] = stored_outbyte_fcn[i];
	}
}

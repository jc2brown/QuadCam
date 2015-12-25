#ifndef DEVICE_H
#define DEVICE_H

#include "quadcam.h"

// Probe flags
#define IODEVICE_PROBE_FAIL		(1<<0)	// Device not on board
#define IODEVICE_PROBE_PASS		(1<<1)  // Device on board
// Check flags
#define IODEVICE_CHECK_FAIL		(1<<2)	// Device does not respond to stimulus
#define IODEVICE_CHECK_PASS		(1<<3)  // Device responds to all stimulus
// Test flags
#define IODEVICE_TEST_FAIL		(1<<4)  // Device appears to be damaged
#define IODEVICE_TEST_PASS		(1<<5)	// Device appears to be working correctly


typedef void (*details_fcn)(uint32_t);

typedef uint32_t (*reset_fcn)(uint32_t);
typedef uint32_t (*init_fcn)(uint32_t);
typedef uint32_t (*probe_fcn)(uint32_t);
typedef uint32_t (*check_fcn)(uint32_t);
typedef uint32_t (*test_fcn)(uint32_t);


uint32_t reset_stub(uint32_t subid);
uint32_t init_stub(uint32_t subid);
uint32_t probe_stub(uint32_t subid);
uint32_t check_stub(uint32_t subid);
uint32_t test_stub(uint32_t subid);


typedef struct IODevice_struct {
	int subid;
	char *name;
	details_fcn details;
	int status;
	reset_fcn reset;
	init_fcn init;
	probe_fcn probe;
	check_fcn check;
	test_fcn test;
} IODevice;


void reset_device(IODevice *iodevice);
void reset_devices(IODevice **iodevices, uint32_t n_iodids);

void reset_device(IODevice *iodevice);
void init_devices(IODevice **iodevices, uint32_t n_iodids);

void probe_device(IODevice *iodevice);
void probe_devices(IODevice **iodevices, uint32_t n_iodids);
void print_probe_results();

void check_device(IODevice *iodevice);
void check_devices(IODevice **iodevices, uint32_t n_iodids);
void print_check_results();

void test_device(IODevice *iodevice);
void test_devices(IODevice **iodevices, uint32_t n_iodids);
void print_test_results();

void print_results();


extern IODevice *iodevices[N_IODIDs];

#endif

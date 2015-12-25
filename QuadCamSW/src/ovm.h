
#ifndef OVM_H
#define OVM_H

#include "device.h"




#define OV_REG_GAIN 	(uint32_t)0x00
#define OV_REG_BGAIN 	(uint32_t)0x01
#define OV_REG_RGAIN 	(uint32_t)0x02
#define OV_REG_GGAIN 	(uint32_t)0x03
#define OV_REG_YAVG 	(uint32_t)0x04
#define OV_REG_BAVG 	(uint32_t)0x05
#define OV_REG_RAVG 	(uint32_t)0x06
#define OV_REG_GAVG 	(uint32_t)0x07
//#define OV_REG_RSVD 	(uint32_t)0x08		// Reserved
//#define OV_REG_RSVD 	(uint32_t)0x09		// Reserved
#define OV_REG_PIDH 	(uint32_t)0x0A		// Read-only Default:0x76
#define OV_REG_PIDL 	(uint32_t)0x0B		// Read-only Default:0x91
#define OV_REG_REG0C 	(uint32_t)0x0C
#define OV_REG_REG0D 	(uint32_t)0x0D
#define OV_REG_REG0E 	(uint32_t)0x0E
#define OV_REG_AECH 	(uint32_t)0x0F
#define OV_REG_AECL 	(uint32_t)0x10
#define OV_REG_CLKRC 	(uint32_t)0x11
#define OV_REG_REG12 	(uint32_t)0x12
#define OV_REG_REG13 	(uint32_t)0x13
#define OV_REG_REG14 	(uint32_t)0x14
#define OV_REG_REG15 	(uint32_t)0x15
#define OV_REG_REG16 	(uint32_t)0x16
#define OV_REG_HSTART 	(uint32_t)0x17
#define OV_REG_HSIZE 	(uint32_t)0x18
#define OV_REG_VSTART 	(uint32_t)0x19
#define OV_REG_VSIZE 	(uint32_t)0x1A
#define OV_REG_SHFT 	(uint32_t)0x1B
#define OV_REG_MIDH 	(uint32_t)0x1C
#define OV_REG_MIDL 	(uint32_t)0x1D
//#define OV_REG_RSVD 	(uint32_t)0x1E		// Reserved
//#define OV_REG_RSVD 	(uint32_t)0x1F		// Reserved
#define OV_REG_REG20 	(uint32_t)0x20
#define OV_REG_AECGM 	(uint32_t)0x21
#define OV_REG_REG22 	(uint32_t)0x22
//#define OV_REG_RSVD 	(uint32_t)0x23		// Reserved
#define OV_REG_WPT	 	(uint32_t)0x24
#define OV_REG_BPT		(uint32_t)0x25
#define OV_REG_VPT	 	(uint32_t)0x26
#define OV_REG_REG27 	(uint32_t)0x27
#define OV_REG_REG28 	(uint32_t)0x28
#define OV_REG_PLL	 	(uint32_t)0x29
#define OV_REG_EXHCL 	(uint32_t)0x2A
#define OV_REG_EXHCH 	(uint32_t)0x2B
#define OV_REG_DM_LN 	(uint32_t)0x2C
#define OV_REG_ADVFL 	(uint32_t)0x2D
#define OV_REG_ADVFH 	(uint32_t)0x2E
//#define OV_REG_RSVD 	(uint32_t)0x2F		// Reserved
//#define OV_REG_RSVD 	(uint32_t)0x30		// Reserved
//#define OV_REG_RSVD 	(uint32_t)0x31		// Reserved
//#define OV_REG_RSVD 	(uint32_t)0x32		// Reserved
//#define OV_REG_RSVD 	(uint32_t)0x33		// Reserved
//#define OV_REG_RSVD 	(uint32_t)0x34		// Reserved
//#define OV_REG_RSVD 	(uint32_t)0x35		// Reserved
//#define OV_REG_RSVD 	(uint32_t)0x36		// Reserved
//#define OV_REG_RSVD 	(uint32_t)0x37		// Reserved
#define OV_REG_STROBE 	(uint32_t)0x38
//#define OV_REG_RSVD 	(uint32_t)0x39		// Reserved
//#define OV_REG_RSVD 	(uint32_t)0x3A		// Reserved
//#define OV_REG_RSVD 	(uint32_t)0x3B		// Reserved
//#define OV_REG_RSVD 	(uint32_t)0x3C		// Reserved
//#define OV_REG_RSVD 	(uint32_t)0x3D		// Reserved
#define OV_REG_REG3E 	(uint32_t)0x3E
#define OV_REG_REG3F 	(uint32_t)0x3F
//#define OV_REG_RSVD 	(uint32_t)0x40		// Reserved
//#define OV_REG_RSVD 	(uint32_t)0x41		// Reserved
//#define OV_REG_RSVD 	(uint32_t)0x42		// Reserved
//#define OV_REG_RSVD 	(uint32_t)0x43		// Reserved
//#define OV_REG_RSVD 	(uint32_t)0x44		// Reserved
//#define OV_REG_RSVD 	(uint32_t)0x45		// Reserved
//#define OV_REG_RSVD 	(uint32_t)0x46		// Reserved
//#define OV_REG_RSVD 	(uint32_t)0x47		// Reserved
#define OV_REG_ANA1		(uint32_t)0x48
#define OV_REG_PWC0 	(uint32_t)0x49
//#define OV_REG_RSVD 	(uint32_t)0x4A		// Reserved
//#define OV_REG_RSVD 	(uint32_t)0x4B		// Reserved
//#define OV_REG_RSVD 	(uint32_t)0x4C		// Reserved
//#define OV_REG_RSVD 	(uint32_t)0x4D		// Reserved
//#define OV_REG_RSVD 	(uint32_t)0x4E		// Reserved
//#define OV_REG_RSVD 	(uint32_t)0x4F		// Reserved
#define OV_REG_BD50ST	(uint32_t)0x50
#define OV_REG_BD60ST	(uint32_t)0x51
//#define OV_REG_RSVD 	(uint32_t)0x52		// Reserved
//#define OV_REG_RSVD 	(uint32_t)0x53		// Reserved
//#define OV_REG_RSVD 	(uint32_t)0x54		// Reserved
//#define OV_REG_RSVD 	(uint32_t)0x55		// Reserved
//#define OV_REG_RSVD 	(uint32_t)0x56		// Reserved
//#define OV_REG_RSVD 	(uint32_t)0x57		// Reserved
//#define OV_REG_RSVD 	(uint32_t)0x58		// Reserved
//#define OV_REG_RSVD 	(uint32_t)0x59		// Reserved
#define OV_REG_UV_CTR0	(uint32_t)0x5A
#define OV_REG_UV_CTR1	(uint32_t)0x5B
#define OV_REG_UV_CTR2	(uint32_t)0x5C
#define OV_REG_UV_CTR4	(uint32_t)0x5D
//#define OV_REG_RSVD 	(uint32_t)0x5E		// Reserved
//#define OV_REG_RSVD 	(uint32_t)0x5F		// Reserved
//#define OV_REG_RSVD 	(uint32_t)0x60		// Reserved
//#define OV_REG_RSVD 	(uint32_t)0x61		// Reserved
#define OV_REG_REG62	(uint32_t)0x62
//#define OV_REG_RSVD 	(uint32_t)0x63		// Reserved
//#define OV_REG_RSVD 	(uint32_t)0x64		// Reserved
//#define OV_REG_RSVD 	(uint32_t)0x65		// Reserved
//#define OV_REG_RSVD 	(uint32_t)0x66		// Reserved
//#define OV_REG_RSVD 	(uint32_t)0x67		// Reserved
#define OV_REG_BLC8		(uint32_t)0x68
//#define OV_REG_RSVD 	(uint32_t)0x69		// Reserved
//#define OV_REG_RSVD 	(uint32_t)0x6A		// Reserved
#define OV_REG_BLCOUT	(uint32_t)0x6B
//#define OV_REG_RSVD 	(uint32_t)0x6C		// Reserved
//#define OV_REG_RSVD 	(uint32_t)0x6D		// Reserved
//#define OV_REG_RSVD 	(uint32_t)0x6E		// Reserved
#define OV_REG_REG6F	(uint32_t)0x6F
//#define OV_REG_RSVD 	(uint32_t)0x70		// Reserved
//#define OV_REG_RSVD 	(uint32_t)0x71		// Reserved
//#define OV_REG_RSVD 	(uint32_t)0x72		// Reserved
//#define OV_REG_RSVD 	(uint32_t)0x73		// Reserved
//#define OV_REG_RSVD 	(uint32_t)0x74		// Reserved
//#define OV_REG_RSVD 	(uint32_t)0x75		// Reserved
//#define OV_REG_RSVD 	(uint32_t)0x76		// Reserved
//#define OV_REG_RSVD 	(uint32_t)0x77		// Reserved
//#define OV_REG_RSVD 	(uint32_t)0x78		// Reserved
//#define OV_REG_RSVD 	(uint32_t)0x79		// Reserved
//#define OV_REG_RSVD 	(uint32_t)0x7A		// Reserved
//#define OV_REG_RSVD 	(uint32_t)0x7B		// Reserved
//#define OV_REG_RSVD 	(uint32_t)0x7C		// Reserved
//#define OV_REG_RSVD 	(uint32_t)0x7D		// Reserved
//#define OV_REG_RSVD 	(uint32_t)0x7E		// Reserved
//#define OV_REG_RSVD 	(uint32_t)0x7F		// Reserved
#define OV_REG_REG80	(uint32_t)0x80
#define OV_REG_REG81	(uint32_t)0x81
#define OV_REG_REG82	(uint32_t)0x82
//#define OV_REG_RSVD 	(uint32_t)0x83		// Reserved
//#define OV_REG_RSVD 	(uint32_t)0x84		// Reserved
#define OV_REG_LCC0		(uint32_t)0x85
#define OV_REG_LCC1		(uint32_t)0x86
#define OV_REG_LCC2		(uint32_t)0x87
#define OV_REG_LCC3		(uint32_t)0x88
#define OV_REG_LCC4		(uint32_t)0x89
#define OV_REG_LCC5		(uint32_t)0x8A
#define OV_REG_LCC6		(uint32_t)0x8B
#define OV_REG_AWB_CTRL	(uint32_t)0x8C // to 0xA2
#define OV_REG_GAM1		(uint32_t)0xA3
#define OV_REG_GAM2		(uint32_t)0xA4
#define OV_REG_GAM3		(uint32_t)0xA5
#define OV_REG_GAM4		(uint32_t)0xA6
#define OV_REG_GAM5		(uint32_t)0xA7
#define OV_REG_GAM6		(uint32_t)0xA8
#define OV_REG_GAM7		(uint32_t)0xA9
#define OV_REG_GAM8		(uint32_t)0xAA
#define OV_REG_GAM9		(uint32_t)0xAB
#define OV_REG_GAM10	(uint32_t)0xAC
#define OV_REG_GAM11	(uint32_t)0xAD
#define OV_REG_GAM12	(uint32_t)0xAE
#define OV_REG_GAM13	(uint32_t)0xAF
#define OV_REG_GAM14	(uint32_t)0xB0
#define OV_REG_GAM15	(uint32_t)0xB1
#define OV_REG_SLOPE	(uint32_t)0xB2
//#define OV_REG_RSVD 	(uint32_t)0xB3		// Reserved
#define OV_REG_REGB4	(uint32_t)0xB4
#define OV_REG_REGB5	(uint32_t)0xB5
#define OV_REG_REGB6	(uint32_t)0xB6
#define OV_REG_REGB7	(uint32_t)0xB7
#define OV_REG_REGB8	(uint32_t)0xB8
#define OV_REG_REGB9	(uint32_t)0xB9
#define OV_REG_REGBA	(uint32_t)0xBA
#define OV_REG_REGBB	(uint32_t)0xBB
#define OV_REG_REGBC	(uint32_t)0xBC
#define OV_REG_REGBD	(uint32_t)0xBD
#define OV_REG_REGBE	(uint32_t)0xBE
#define OV_REG_REGBF	(uint32_t)0xBF
#define OV_REG_REGC0	(uint32_t)0xC0
#define OV_REG_REGC1	(uint32_t)0xC1
#define OV_REG_REGC2	(uint32_t)0xC2
#define OV_REG_REGC3	(uint32_t)0xC3
#define OV_REG_REGC4	(uint32_t)0xC4
#define OV_REG_REGC5	(uint32_t)0xC5
#define OV_REG_REGC6	(uint32_t)0xC6
#define OV_REG_REGC7	(uint32_t)0xC7
#define OV_REG_REGC8	(uint32_t)0xC8
#define OV_REG_REGC9	(uint32_t)0xC9
#define OV_REG_REGCA	(uint32_t)0xCA
#define OV_REG_REGCB	(uint32_t)0xCB
#define OV_REG_REGCC	(uint32_t)0xCC
#define OV_REG_REGCD	(uint32_t)0xCD
#define OV_REG_REGCE	(uint32_t)0xCE
#define OV_REG_REGCF	(uint32_t)0xCF
#define OV_REG_REGD0	(uint32_t)0xD0
//#define OV_REG_RSVD 	(uint32_t)0xD1		// Reserved
#define OV_REG_REGD2	(uint32_t)0xD2
#define OV_REG_REGD3	(uint32_t)0xD3
#define OV_REG_REGD4	(uint32_t)0xD4
#define OV_REG_REGD5	(uint32_t)0xD5
#define OV_REG_REGD6	(uint32_t)0xD6
#define OV_REG_REGD7	(uint32_t)0xD7
#define OV_REG_REGD8	(uint32_t)0xD8
#define OV_REG_REGD9	(uint32_t)0xD9
#define OV_REG_REGDA	(uint32_t)0xDA
#define OV_REG_REGDB	(uint32_t)0xDB
#define OV_REG_REGDC	(uint32_t)0xDC
#define OV_REG_REGDD	(uint32_t)0xDD
#define OV_REG_REGDE	(uint32_t)0xDE
#define OV_REG_REGDF	(uint32_t)0xDF
#define OV_REG_REGE0	(uint32_t)0xE0
#define OV_REG_REGE1	(uint32_t)0xE1


#define OVM_PIDH 0x76
#define OVM_PIDL 0x91

#define OVM_MIDH 0x7F
#define OVM_MIDL 0xA2


void set_ovm_xvclk_frequency(uint32_t xvclk_freq);
void set_ovm_scl_clk_frequency(uint32_t scl_freq);

void ovm_config(void);
int measure_fps(int id);

void set_ovm_page(int page);

uint32_t ovm_probe(uint32_t mask);
void ovm_tests(int *n_tests, int *n_errors);

extern uint32_t good_cams;

extern IODevice ovm[4];

#endif

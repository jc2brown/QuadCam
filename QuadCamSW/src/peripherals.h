// Microblaze memory map - internal peripherals
// Address range 0x8000000 to 0xBFFFFFF
// See DS865, esp. pg24


#include <stdint.h>

#include "interrupts.h"

#ifndef PERIPHERALS_H
#define PERIPHERALS_H


#define UART_RX 		(*((volatile uint32_t*)0x80000000))
#define UART_TX 		(*((volatile uint32_t*)0x80000004))
#define UART_STATUS		(*((volatile uint32_t*)0x80000008))

//#define GP1O			(*((volatile uint32_t*)0x80000010))
//#define GP2O			(*((volatile uint32_t*)0x80000014))
//#define GP3O			(*((volatile uint32_t*)0x80000018))
//#define GP4O			(*((volatile uint32_t*)0x8000001C))
//
//#define GP1I			(*((volatile uint32_t*)0x80000020))
//#define GP2I			(*((volatile uint32_t*)0x80000024))
//#define GP3I			(*((volatile uint32_t*)0x80000028))
//#define GP4I			(*((volatile uint32_t*)0x8000002C))

#define IRQ_STATUS 		(*((volatile uint32_t*)0x80000030))
#define IRQ_PENDING		(*((volatile uint32_t*)0x80000034))
#define IRQ_ENABLE		(*((volatile uint32_t*)0x80000038))
#define IRQ_ACK			(*((volatile uint32_t*)0x8000003C))


// Could not make these work properly. They will fire once but then execution halts.
// They appear to compile with a return-from-subroutine instruction rather than return-from-interrupt.
// Not sure if this is accounted for in hardware, may be the cause of the problem.
// The assembler fails if __attribute__ ((interrupt_handler)) is applied to more than one function.
// As a workaround, similar functionality is provided by interrupts.h
//
//#define IRQ_VECTOR_0	(*((isr_fcn*)0x80000080))
//#define IRQ_VECTOR_1	(*((isr_fcn*)0x80000084))
//#define IRQ_VECTOR_2	(*((isr_fcn*)0x80000088))
//#define IRQ_VECTOR_3	(*((isr_fcn*)0x8000008C))
//#define IRQ_VECTOR_4	(*((isr_fcn*)0x80000090))
//#define IRQ_VECTOR_5	(*((isr_fcn*)0x80000094))
//#define IRQ_VECTOR_6	(*((isr_fcn*)0x80000098))
//#define IRQ_VECTOR_7	(*((isr_fcn*)0x8000009C))
//#define IRQ_VECTOR_8	(*((isr_fcn*)0x800000A0))
//#define IRQ_VECTOR_9	(*((isr_fcn*)0x800000A4))
//#define IRQ_VECTOR_10	(*((isr_fcn*)0x800000A8))
//#define IRQ_VECTOR_11	(*((isr_fcn*)0x800000AC))
//#define IRQ_VECTOR_12	(*((isr_fcn*)0x800000B0))
//#define IRQ_VECTOR_13	(*((isr_fcn*)0x800000B4))
//#define IRQ_VECTOR_14	(*((isr_fcn*)0x800000B8))
//#define IRQ_VECTOR_15	(*((isr_fcn*)0x800000BC))
//#define IRQ_VECTOR_16	(*((isr_fcn*)0x800000C0))
//#define IRQ_VECTOR_17	(*((isr_fcn*)0x800000C4))
//#define IRQ_VECTOR_18	(*((isr_fcn*)0x800000C8))
//#define IRQ_VECTOR_19	(*((isr_fcn*)0x800000CC))
//#define IRQ_VECTOR_20	(*((isr_fcn*)0x800000D0))
//#define IRQ_VECTOR_21	(*((isr_fcn*)0x800000D4))
//#define IRQ_VECTOR_22	(*((isr_fcn*)0x800000D8))
//#define IRQ_VECTOR_23	(*((isr_fcn*)0x800000DC))
//#define IRQ_VECTOR_24	(*((isr_fcn*)0x800000E0))
//#define IRQ_VECTOR_25	(*((isr_fcn*)0x800000E4))
//#define IRQ_VECTOR_26	(*((isr_fcn*)0x800000E8))
//#define IRQ_VECTOR_27	(*((isr_fcn*)0x800000EC))
//#define IRQ_VECTOR_28	(*((isr_fcn*)0x800000F0))
//#define IRQ_VECTOR_29	(*((isr_fcn*)0x800000F4))
//#define IRQ_VECTOR_30	(*((isr_fcn*)0x800000F8))
//#define IRQ_VECTOR_31	(*((isr_fcn*)0x800000FC))


// Interrupt source IDs (range 0 to 31)
// Each interrupt ID corresponds to its bit position in the IRQ registers (IRQ_ENABLE, IRQ_STATUS, IRQ_ACK)
#define IRQ_UART_ERR_ID		((uint32_t)0)
#define IRQ_UART_TX_ID		((uint32_t)1)
#define IRQ_UART_RX_ID		((uint32_t)2)

#define IRQ_INTC0_ID		((uint32_t)16)
#define IRQ_INTC1_ID		((uint32_t)17)
#define IRQ_INTC2_ID		((uint32_t)18)
#define IRQ_INTC3_ID		((uint32_t)19)
#define IRQ_INTC4_ID		((uint32_t)20)
#define IRQ_INTC5_ID		((uint32_t)21)
#define IRQ_INTC6_ID		((uint32_t)22)
#define IRQ_INTC7_ID		((uint32_t)23)

// Converts an IRQ ID to a 32-bit mask for IRQ register operations
#define IRQ_FLAG(irq_id)	((uint32_t)(1 << irq_id))

//#define IRQ_UART_ERR_FLAG 	IRQ_FLAG(IRQ_UART_ERR_ID)
//#define IRQ_UART_TX_FLAG 	IRQ_FLAG(IRQ_UART_TX_ID)
//#define IRQ_UART_RX_FLAG 	IRQ_FLAG(IRQ_UART_RX_ID)
//
//#define IRQ_INTC0_FLAG 		IRQ_FLAG(IRQ_INTC0_ID)
//#define IRQ_INTC1_FLAG 		IRQ_FLAG(IRQ_INTC1_ID)
//#define IRQ_INTC2_FLAG 		IRQ_FLAG(IRQ_INTC2_ID)
//#define IRQ_INTC3_FLAG 		IRQ_FLAG(IRQ_INTC3_ID)

#endif

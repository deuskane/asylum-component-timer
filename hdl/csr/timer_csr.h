#ifndef TIMER_REGISTERS_H
#define TIMER_REGISTERS_H

#include <stdint.h>

// Module      : timer
// Description : CSR for Timer
// Width       : 8

//==================================
// Register    : isr
// Description : Interruption Status Register
// Address     : 0x0
//==================================
#define TIMER_ISR 0x0

// Field       : isr.value
// Description : 0: interrupt is inactive, 1: interrupt is active
// Range       : [0]
#define TIMER_ISR_VALUE      0
#define TIMER_ISR_VALUE_MASK 1

//==================================
// Register    : imr
// Description : Interruption Mask Register
// Address     : 0x1
//==================================
#define TIMER_IMR 0x1

// Field       : imr.enable
// Description : 0: interrupt is disable, 1: interrupt is enable
// Range       : [0]
#define TIMER_IMR_ENABLE      0
#define TIMER_IMR_ENABLE_MASK 1

//==================================
// Register    : control
// Description : Control Timer
// Address     : 0x2
//==================================
#define TIMER_CONTROL 0x2

// Field       : control.clear
// Description : Reset Timer : 0 disable, 1 enable
// Range       : [0]
#define TIMER_CONTROL_CLEAR      0
#define TIMER_CONTROL_CLEAR_MASK 1

// Field       : control.enable
// Description : Time Enable : 0 disable, 1 enable
// Range       : [1]
#define TIMER_CONTROL_ENABLE      1
#define TIMER_CONTROL_ENABLE_MASK 1

// Field       : control.autostart
// Description : Time autostart after evant : 0 disable, 1 enable
// Range       : [2]
#define TIMER_CONTROL_AUTOSTART      2
#define TIMER_CONTROL_AUTOSTART_MASK 1

//==================================
// Register    : timer_byte0
// Description : Timer Init Value byte 0
// Address     : 0x4
//==================================
#define TIMER_TIMER_BYTE0 0x4

// Field       : timer_byte0.value
// Description : Timer Init Value byte 0
// Range       : [7:0]
#define TIMER_TIMER_BYTE0_VALUE      0
#define TIMER_TIMER_BYTE0_VALUE_MASK 255

//==================================
// Register    : timer_byte1
// Description : Timer Init Value byte 1
// Address     : 0x5
//==================================
#define TIMER_TIMER_BYTE1 0x5

// Field       : timer_byte1.value
// Description : Timer Init Value byte 1
// Range       : [7:0]
#define TIMER_TIMER_BYTE1_VALUE      0
#define TIMER_TIMER_BYTE1_VALUE_MASK 255

//==================================
// Register    : timer_byte2
// Description : Timer Init Value byte 2
// Address     : 0x6
//==================================
#define TIMER_TIMER_BYTE2 0x6

// Field       : timer_byte2.value
// Description : Timer Init Value byte 2
// Range       : [7:0]
#define TIMER_TIMER_BYTE2_VALUE      0
#define TIMER_TIMER_BYTE2_VALUE_MASK 255

//==================================
// Register    : timer_byte3
// Description : Timer Init Value byte 3
// Address     : 0x7
//==================================
#define TIMER_TIMER_BYTE3 0x7

// Field       : timer_byte3.value
// Description : Timer Init Value byte 3
// Range       : [7:0]
#define TIMER_TIMER_BYTE3_VALUE      0
#define TIMER_TIMER_BYTE3_VALUE_MASK 255

//----------------------------------
// Structure {module}_t
//----------------------------------
typedef struct {
  uint8_t isr; // 0x0
  uint8_t imr; // 0x1
  uint8_t control; // 0x2
  uint8_t __dummy_0x3__
  uint8_t timer_byte0; // 0x4
  uint8_t timer_byte1; // 0x5
  uint8_t timer_byte2; // 0x6
  uint8_t timer_byte3; // 0x7
} timer_t;

#endif // TIMER_REGISTERS_H

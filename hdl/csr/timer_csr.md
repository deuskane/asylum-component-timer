# timer
CSR for Timer

| Address | Registers |
|---------|-----------|
|0x0|isr|
|0x1|imr|
|0x2|control|
|0x4|timer_byte0|
|0x5|timer_byte1|
|0x6|timer_byte2|
|0x7|timer_byte3|

## 0x0 isr
Interruption Status Register

### [0:0] value
0: interrupt is inactive, 1: interrupt is active

## 0x1 imr
Interruption Mask Register

### [0:0] enable
0: interrupt is disable, 1: interrupt is enable

## 0x2 control
Control Timer

### [0:0] clear
Reset Timer : 0 disable, 1 enable

### [1:1] enable
Time Enable : 0 disable, 1 enable

### [2:2] autostart
Time autostart after evant : 0 disable, 1 enable

## 0x4 timer_byte0
Timer Init Value byte 0

### [7:0] value
Timer Init Value byte 0

## 0x5 timer_byte1
Timer Init Value byte 1

### [7:0] value
Timer Init Value byte 1

## 0x6 timer_byte2
Timer Init Value byte 2

### [7:0] value
Timer Init Value byte 2

## 0x7 timer_byte3
Timer Init Value byte 3

### [7:0] value
Timer Init Value byte 3


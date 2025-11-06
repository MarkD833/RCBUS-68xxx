/******************************************************************************
* RCBus-68000 V9958 graphics subroutines
*******************************************************************************
* Based on the original Z80 code by Dean Netherton.
* https://github.com/dinoboards/yellow-msx-series-for-rc2014/tree/main/apps-rc2014
*
******************************************************************************/

#ifndef V9958_H
#define V9958_H

#include <stdbool.h>
#include <stdint.h>

#define PAL  1
#define NTSC 2

typedef struct {
  uint8_t red;
  uint8_t blue;
  uint8_t green;
} RGB;

extern void outCmd(uint8_t b);
extern void outDat(uint8_t b);
extern void outPal(uint8_t b);

extern void clearScreenBank0(uint8_t color);
extern void setMode6(uint8_t lines, uint8_t mode);
extern void setPalette(RGB *);

extern void _commandDrawLine(void);
extern void _drawLine(void);
extern void _writeRegister(uint16_t rd);

extern uint16_t _fromX;
extern uint16_t _fromY;
extern uint8_t  _color;
extern uint8_t  _operation;
extern uint16_t _toX;
extern uint16_t _toY;

#define REGISTER_COUNT 12

#define writeRegister(a, b) _writeRegister(a * 256 + b)

#define CMD_VDP_TO_VRAM 0xC0
#define CMD_LINE(op)    (0x70 | op)
#define CMD_PSET(op)    (0x50 | op)
#define CMD_LOGIC_IMP   0x00
#define CMD_LOGIC_AND   0x01

#define drawLine(fromX, fromY, toX, toY, color, operation)  \
  _fromX     = (fromX);                                     \
  _fromY     = (fromY);                                     \
  _color     = (color);                                     \
  _operation = CMD_LINE((operation));                       \
  _toX       = (toX);                                       \
  _toY       = (toY);                                       \
  _drawLine()

#define pointSet(x, y, color, operation)                    \
  _fromX     = (x);                                         \
  _fromY     = (y);                                         \
  _color     = (color);                                     \
  _operation = CMD_PSET((operation));                       \
  _commandDrawLine()  
#endif


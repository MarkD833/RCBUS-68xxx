/******************************************************************************
* RCBus-68000 V9958 graphics subroutines
*******************************************************************************
* Based on the original Z80 code by Dean Netherton.
* https://github.com/dinoboards/yellow-msx-series-for-rc2014/tree/main/apps-rc2014
*
******************************************************************************/
#include <stdlib.h>
#include <stdbool.h>
#include "v9958.h"

uint8_t mode6Reg[REGISTER_COUNT] = {
    0x0A, // R0 - M5 = 1, M4 = 0, M3 = 1 => GRAPHIC MODE #6
    0x40, // R1 - ENABLE SCREEN, DISABLE INTERRUPTS, M1 = 0, M2 = 0
    0x1F, // R2 - PATTERN NAME TABLE := 0, A16 = 0
    0x00, // R3 - NO COLOR TABLE
    0x00, // R4 - N/A???
    0xF7, // R5 - SPRITE ATTRIBUTE TABLE -> FA00
    0x1E, // R6 - SPRITE PATTERN => F000
    0x00, // R7 - a background colour?
    0x8A, // R8 - COLOUR BUS INPUT, DRAM 64K, DISABLE SPRITE
    0x00, // R9 - LN = 1(212 lines), S1, S0 = 0, IL = 0, EO = 0, NT = 1 (PAL),
          // DC = 0
    0x00, // R10 - color table - n/a
    0x01  // R11 - SPRITE ATTRIBUTE TABLE -> FA00
};

void setBaseRegisters(uint8_t *pReg) {
  for (uint8_t i = 0; i < REGISTER_COUNT; i++)
    writeRegister(i, *pReg++);
}

void setVideoSignal(uint8_t *pReg, uint8_t lines, uint8_t mode) {
  if (lines == 212)
    pReg[9] |= 0x80;

  if (mode == PAL)
    pReg[9] |= 0x02;
}

void setMode6(uint8_t lines, uint8_t mode) {
  setVideoSignal(mode6Reg, lines, mode);
  setBaseRegisters(mode6Reg);
}

void setPalette(RGB *pPalette) {
  // start with palette entry #0
  writeRegister(16, 0);

  // then write out all 16 palette entries
  for (uint8_t c = 0; c < 16; c++) {
    outPal(pPalette->red * 16 + pPalette->blue);
    outPal(pPalette->green);
    pPalette++;
  }
}

# RCBUS MC68000 Software

This folder contains the C software that I've either developed myself or ported to my RCBus 68000 board(s).
The source code was built using GCC68K v13.1.0 using Tom Storey's bare metal 68K suite.

The development environment I setup is documented in the Win10-gcc-setup.md file in the root of the repository. 

I'm still learning about the GCC compiler & assembler so there's likely to be some issues with this code that I'm not aware of yet.

| Code | Description |
| :---- | :---- |
| [SC611](#SC611) | SC611 MicroSD module. |
| [SC704](#SC704) | SC704 I2C Bus Master module. |
| [TMS9918A](#TMS9918A) | Shiela Dixon's TMSEMU TMS9918A module. |
---

## SC611
### SPI Read
The code in the SC611_SPI_Read folder provides a more user friendly version of the SC611 assembler code. This is the first RCBus module I attempted to write high level code for and it includes some assembly language in the sc611.S file that handles the bit bang 8-bit and 16-bit transfers.

This code also introduced the code to support the 4 serial ports on the MC68681 as well as some simple printing routines to avoid bringing in printf().

---

## SC704
### I2C Scan
The code in the SC704_I2C_Scan folder implements a simple program to scan each I2C address from 0x08 to 0x7F to see if a device is present at that address and prints out the device addresses found to be active.

### I2C Read
The code in the SC704_I2C_Read folder demonstrates how to read some data from the preprogrammed 25LC256 EEPROM on the SC704 board.

---

## TMS9918A
The demonstrations below are based on the demonstration code of the same name by JB Langston for his Z80 system but ported over to my 68000 nased system.

### ASCII Character Set Demonstration
The code in the TMS9918A-ASCII-Chars folder is a C implementation of the same assembler demo. The TMS9918A assembler library has been modified so that the functions can be called directly from C.

### Sprite Demonstration
The code in the TMS9918A-Sprites folder is a C implementation of the same assembler demo - spinning globe - and the TMS9918A assembler library has been further modified to support the additional functions needed by the sprites demo.

### Nyan Cat Animation
The code in the TMS9918A-Nyan folder is a C implementation of the same assembler demo and demonstrates cycling through a sequence of frames of an animation.

### Fern (Pixel Plotting) Demonstration
The code in the TMS9918A-Fern folder is a 68K version of the fern demonstration and does 2048 plots before exiting.

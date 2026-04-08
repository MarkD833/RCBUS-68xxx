# RCBUS MC68000 Software

This folder contains the C software that I've either developed myself or ported to my RCBus 68000 board(s).
The source code was built using GCC68K v13.1.0.

I'm using Windows 11 and all my builds are done from the Windows CMD prompt. I use Notepad++ as my editor.

I'm still learning about the GCC compiler & assembler so there's likely to be some issues with this code that I'm not aware of yet.

The development environment I setup is documented in the Win-gcc-setup.md file in the root of the repository. You should have a read of this as it details how to create the crt0 runtime file as well as a simple library of C functions (libc) and a library of mathematical functions (libm).

**NOTE:** The crt0 and libc files are required for all example programs.

| Code | Description |
| :---- | :---- |
| [SC611](#SC611) | SC611 MicroSD module. |
| [SC704](#SC704) | SC704 I2C Bus Master module. |
| [TMS9918A](#TMS9918A) | Shiela Dixon's TMSEMU TMS9918A module. |
| [V9958A](#V9958A) | Dean Netherton's HDMI for RC module. |

---

## SC611
### SPI Read & Write
The code in the SC611_SPI_Read_Write folder provides a more user friendly version of the SC611 assembler code. The code attempts to write a text string to an external EEPROM connected to the SC611 SPI connector. It has been tested with a Microchip 25LC256 SPI EEPROM.

This is the first RCBus module I attempted to write high level code for and it includes some assembly language in the sc611.S file that handles the bit bang 8-bit and 16-bit transfers.

---

## SC704
### I2C Scan
The code in the SC704_I2C_Scan folder implements a simple program to scan each I2C address from 0x08 to 0x7F to see if a device is present at that address and prints out the device addresses found to be active.

### I2C Read
The code in the SC704_I2C_Read folder demonstrates how to read some data from the preprogrammed 25LC256 EEPROM on the SC704 board.

---

## TMS9918A
The demonstrations below are based on the demonstration code of the same name by JB Langston for his Z80 system but ported over to my 68000 based system.

### ASCII Character Set Demonstration
The code in the TMS9918A-ASCII-Chars folder is a C implementation of the same assembler demo. The TMS9918A assembler library has been modified so that the functions can be called directly from C.

### Sprite Demonstration
The code in the TMS9918A-Sprites folder is a C implementation of the same assembler demo - spinning globe - and the TMS9918A assembler library has been further modified to support the additional functions needed by the sprites demo.

### Nyan Cat Animation
The code in the TMS9918A-Nyan folder is a C implementation of the same assembler demo and demonstrates cycling through a sequence of frames of an animation.

### Fern (Pixel Plotting) Demonstration
The code in the TMS9918A-Fern folder is a 68K version of the fern demonstration and does 2048 plots before exiting.

---

## V9958A
The demonstrations below are based on the demonstration code of the same name by Dean Netherton for his [HDMI for RC](https://www.dinoboards.com.au/hdmi-for-rc) board based around a Tang Nano 20K FPGA module.

### Dots
The code in the V9958-Dots folder demonstrates plotting pixels. It's not quite the same as Deans original demo code as I have yet to implement a function to return pseudo-random numbers but it serves to demonstrate the plotting functionality.

### Lines
The code in the V9958-Lines folder demonstrates drawing lines. It's not quite the same as Deans original demo code as I have yet to implement a function to return pseudo-random numbers so it simply draws a rectangular box on the screen instead.

### Mbrot
The code in the V9958-Mbrot folder demonstrates the plotting of a mandelbrot set. I had to implement my own fabs() function as I don't have a libm (maths) library.


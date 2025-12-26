# SC129

The code in this folder provides 2 simple demonstrations to exercise the [SC129](https://smallcomputercentral.com/rcbus/sc100-series/sc129-digital-i-o-rc2014/) digital I/O module.

The first program is count.x68 and it simply counts up in binary on the 8 LEDs on the output port of the SC129 board.

The second prgram is echo.x68 and it simply reads the 8 bits on the input port and then echoes them back out on the 8 bits of the output port of the SC129 board.

Both programs assume that the SC129 has been configured for the default address of 0x00 and can be assembled using EASy68K. 



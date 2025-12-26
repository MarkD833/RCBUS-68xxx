# RCBUS MC68000 Software

This folder contains the assembler software that I've either developed myself or ported to my RCBus 68000 board(s).
It can be assembled using EASy68K.

The file MON68K+CCP+BIOS+BASIC.s68 is an S-record file for the 68000 board only. This file is not compatible with the 68302 board. It contains rcMON68K v1.3, CP/M-68K v1.3, CP/M-68K BIOS and EhBASIC v3.54. In order to use this file, you can either load it into your prom programmer and program the odd and even bytes into separate ROMs or you can load it into EASyBIN and generate a pair of binary files that your prom programmer can then program into separate ROMs.

| Code | Description |
| :---- | :---- |
| MON68K | My simple monitor program for the RCBus 68000. |
| MON302 | My simple monitor program for the RCBus 68302. |
| SC129 | SC129 digital i/o module. |
| SC611 | SC611 MicroSD module. |
| SC704 | SC704 I2C bus master module + SC406 temperature sensor module. |
| SC705 | SC705 serial ACIA module. |
| CP/M-68K v1.3 | Digital Research CP/M-68K v1.3 |
| EhBASIC v3.54 | Lee Davison’s EhBASIC for MC68000 |
| TMS9918A | Shiela Dixon's TMSEMU video module |
| MC68901) | MC68901 multi-function peripheral board |

Please see the individual folders for more details.


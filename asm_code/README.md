# RCBUS MC68000 Software

This folder contains the assembler software that I've either developed myself or ported to my RCBus 68000 board(s).
The software can be assembled using EASy68K under Windows or EASy68K-asm under Linux (see my EASy68K-asm repository).

There are also two s-record files containing MON68K v1.5, CP/M-68K v1.3 & EhBASIC v3.54. Note that these files are not compatible with the 68302 board.

The file MON68Kv1.5+CCP+BIOS+BASIC-38400.s68 uses a 38400 baud serial port and should be compatible with all MC68681 DUART variants.

The file MON68Kv1.5+CCP+BIOS+BASIC-115200.s68 uses a 115200 baud serial port and can be used with one of the Philips high speed DUART chips configured to run in the test mode.

**NOTE:** The MON68K monitor now uses the CTS signal to control the flow of data from the host PC. In order to use hardware flow control, the solder jumper JP2 on the rear of the SIO board needs to be bridged to allow the DUART OP0 signal to control the CTS signal. The serial receive routines are now interrupt driven and require the IRQ2 jumper to be fitted on the SIO board.

In order to use these files, you can either load one into your prom programmer and program the odd and even bytes into separate ROMs or you can load it into EASyBIN and generate a pair of binary files that your prom programmer can then program into separate ROMs.

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
| MC68901 | MC68901 multi-function peripheral board |

Please see the individual folders for more details.


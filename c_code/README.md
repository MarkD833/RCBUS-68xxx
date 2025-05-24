# RCBUS MC68000 Software

This folder contains the C software that I've either developed myself or ported to my RCBus 68000 board(s).
The source code was built using GCC68K v13.1.0 using Tom Storey's bare metal 68K suite.

The development environment I setup is documented in the Win10-gcc-setup.md file in the root of the repository. 

| Code | Description |
| :---- | :---- |
| [SC611](#sc611) | SC611 MicroSD module. |
---

## SC611

The code in this folder provides a more user friendly version of the SC611 assembler code. This is the first RCBus module I attempted to write high level code for and it includes some assembly language in the sc611.S file that handles the bit bang 8-bit and 16-bit transfers.

It also introduced the code to support the 4 serial ports on the MC68681 as well as some simple printing routines to avoid bringing in printf().

---

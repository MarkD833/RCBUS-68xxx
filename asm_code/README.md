# RCBUS MC68000 Software

This folder contains the assembler software that I've either developed myself or ported to my RCBus 68000 board(s).
It can be assembled using EASy68K.

The file MON68K+CCP+BIOS+BASIC.s68 is an S-record file for the 68000 board only. This file is not compatible with the 68302 board. It contains rcMON68K v1.3, CP/M-68K v1.3, CP/M-68K BIOS and EhBASIC v3.54. In order to use this file, you can either load it into your prom programmer and program the odd and even bytes into separate ROMs or you can load it into EASyBIN and generate a pair of binary files that your prom programmer can then program into separate ROMs.

| Code | Description |
| :---- | :---- |
| [MON68K](#68000-68302-monitor) | My simple monitor program for the RCBus 68000. |
| [MON302](#68000-68302-monitor) | My simple monitor program for the RCBus 68302. |
| [SC129](#sc129) | SC129 digital i/o module. |
| [SC611](#sc611) | SC611 MicroSD module. |
| [SC704](#sc704) | SC704 I2C bus master module + SC406 temperature sensor module. |
| [SC705](#sc705) | SC705 serial ACIA module. |
| [CP/M-68K v1.3](#cpm-68k) | Digital Research CP/M-68K v1.3 |
| [EhBASIC v3.54](#EhBASIC) | Lee Davison’s EhBASIC for MC68000 |
| [TMS9918A](#TMS9918A) | Shiela Dixon's TMSEMU video module |
| [MC68901](#MC68901) | MC68901 multi-function peripheral board |

---

# 68000 68302 monitor

I wanted a simple monitor that supported a few basic commands. This monitor was originally written for my 68008 board and then modified for my 68302 board before being modified again to support my RCBus 68000 and 68302 boards.

Please note that the monitor programs for my 68000 and 68302 are different although the keyboard commands are the same.

None of the commands support any use of cursor keys or the backspace/delete keys.

The monitor operates at 38400 baud without any handshaking.

There a few basic commands that the monitor understands as follows:

## B

Boots the embedded EhBASIC v3.54 from the ROM. It will check that EhBASIC is programmed into the ROM first. I need to provide a write-up on how to include EhBASIC and/or a ROM image that already includes it.

## C

Boots the embedded CP/M-68K v1.3 from the ROM. It will check that CP/M and the BIOS are programmed into the ROM first. I need to provide a write-up on how to include CP/M-68K and/or a ROM image that already includes it.

The CP/M68K v1.3 BIOS uses Steve Cousin's SC145 (or SC729) CompactFlash module to provide disk drives for CP/M. Please see the readme in the CP/M-68K code folder for more details.
 
## Dnnnn

Displays a block of 256 bytes starting at address nnnn. The address is in hexaddecimal and can be any address from 0x00000000 to 0xFFFFFFFF. Any printable ASCII characters are also displayed to aid in showing text strings etc.

The command doesn't support going forwards or backwards in 256 byte pages or any other variations. To display the next 256 bytes, issue another D command.

## Gnnnn

Executes the code starting at address nnnn. The address is in hexaddecimal and can be any address from 0x00000000 to 0xFFFFFFFF.

Once the code is executing, there isn't a way back into the monitor, except by pressing the reset button on the RCBus backplane.

## Iaa

Displays the 8-bit value at address aa in IO space. Address aa is an address between 0x00 and 0xFF. This command will activate the /IORQ signal on the RCBus. Similar to the Z80 IN instruction.

The monitor takes care of the mapping of the requested address into 68000 memory space.

## Mnnnn

Modifies a byte of memory starting at address nnnn. The address is in hexaddecimal and can be any address from 0x00000000 to 0xFFFFFFFF.

Once the byte has been entered, the next address is displayed to enable alteration of that address.

The command doesn't support going forwards or backwards or editing memory as 16-bit words or 32-bit long words.

## Oaabb

Writes the 8-bit value bb to address aa in IO space. Both the address and the value are 8-bit hexadecimal numbers between 0x00 and 0xFF. This command will activate the /IORQ signal on the RCBus. Similar to the Z80 OUT instruction.

The monitor takes care of the mapping of the requested address into 68000 memory space.

## S1 / S2

These commands are not entered directly by the user. They are detected by the monitor when Motorola S-records are transferred via a serial terminal program such as RealTerm. Each S-record is treated individually and is written to memory as it is received.

There is no need to initiate a download from the monitor by entering a command as the monitor will detect any lines beginning with an S and try and interpret them as Motorola S-records.
 
As user memory starts at address 0x100000 on my RCBus 68000, all S-records will be S2 records.

## ?

Simply displays the list of available commands that the monitor supports.

---

# RCBus / RC2014 boards
The folders hold 1 or 2 simple example assembly source files that demonstrate basic functionality of that particular board.

## SC129

The code in this folder provides 2 simple demonstrations to exercise the [SC129](https://smallcomputercentral.com/rcbus/sc100-series/sc129-digital-i-o-rc2014/) digital I/O module.

The first program is count.x68 and it simply counts up in binary on the 8 LEDs on the output port of the SC129 board.

The second prgram is echo.x68 and it simply reads the 8 bits on the input port and then echoes them back out on the 8 bits of the output port of the SC129 board.

Both programs assume that the SC129 has been configured for the default address of 0x00. 

---

## SC611

The code in this folder provides a simple demonstration of sending bit banged SPI data out using an [SC611](https://smallcomputercentral.com/rcbus/sc600-series/sc611-rcbus-micro-sd/) MicroSD module to read some information from a Microchip 25LC256 SPI EEPROM.

The program reads a 16-bit address from location $0000 in the EEPROM. It then reads and prints characters starting at that 16-bit address until a NULL is read. The PNG images shows an LA trace of the reading of location $000 and the reading of the null terminated string. I've included the hex file of the data in the EEPROM. It's the vocabulary from my Arduino SP0256 module.

---

## SC704

The code in this folder provides 2 simple demonstrations to exercise the [SC704](https://smallcomputercentral.com/rcbus/sc700-series/sc704-rcbus-i2c-bus-master/) I2C bus master module.

The first program is i2c_scan.x68 and it scans the I2C bus reporting back the addresses of any devices it finds. With no external devices connected, it should report back a device at address $50 (if the on-board 24LC256 EEPROM is fitted).

The second program works in conjunction with the [SC406](https://smallcomputercentral.com/i2c-bus-modules/sc406-i2c-temperature-sensor-module/) I2C temperature sensor module. It simply interrogates the TC74 temperature sensor and reports back the temperature in deg C.

---

## SC705

The code in this folder provides 2 simple demonstrations to exercise the [SC705](https://smallcomputercentral.com/rcbus/sc700-series/sc705-rcbus-serial-acia/) serial ACIA module.

Note that the ACIA serial port is configured for 57600,8,N,1 as my SC705 has a 3.6864MHz crystal fitted instead of a 7.3728MHz crystal. If your board uses a 7.3728MHz crystal, then the baud rate doubles to 115200.

The first program is hello.x68 and it simply outputs the message "Hello World!" + CR & LF to the ACIA serial port.

The second program is echo.x68 and it simply echoes back any characters recevied by the ACIA.

---

# CPM-68K

The code in this folder contains a modified version of CP/M-68K v1.3. This version of CP/M-68K runs direct from ROM (no copying into RAM etc) at address $0400 but has been retargeted so that the RAM storage it uses for its internal variables has been moved up to address $1FE000 (in RAM).

Also in this folder is my BIOS to support CP/M-68K on the RCBus 68000 hardware.

---

# EhBASIC

The code in this folder is for EhBASIC by Lee Davison. This code is based on version 3.54 which I believe was generated by Jeff Tranter and the source I used as the base for my system can be found here: https://github.com/jefftranter/68000/tree/master/ehbasic.

---

# TMS9918A

The code in this folder is my port of J B Langston's code (for the original TMS9918A chip) to run on my RCBus-68000 with [Shiela Dixon's TMSEMU](https://peacockmedia.software/RC2014/TMSEMU/) graphics module.

The ASCII font demo is the simplest. It needed quite a few of the TMS library routines to be ported to 68K assembler in order to get it to work correctly. It demonstrates the loading of a font and then displaying all 256 characters of that font.

The Nyan Cat demo was quite straightforward to port as almost all the TMS library routines had already been ported as part of the ASCII font demo. This demonstrates repeated cycling through a set of bitmaps on order to produce an animation of sorts.

The sprites demo adds more functionality to the TMS library and should show a spinning globe bouncing off the screen edges.

---

# MC68901

The code in this folder has some basic examples of using the MC6901 multi-function peripheral chip.

Toggle simple toggles an i/o pin using a crude software delay loop.

Ser_echo simply waits for a char on the MPF serial port (9600 baud) and echoes it back.

Timer uses the MFP timer C to generate interrupts that are counted and used to toggle an LED on an SC129 digital I/O board at around 1Hz.


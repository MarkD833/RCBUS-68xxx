# RCBUS 68000 Board
This is my 68000 design for the RCBus. My design uses a 68000 microprocessor - not a 68008 - and is currently being tested on Steve Cousins [SC701](https://smallcomputercentral.com/rcbus/sc700-series/sc701-rcbus-backplane/) 6-slot RCBus backplane.

Release 1.0 was my proof of concept that relied on an additional connector between the CPU and ROM/RAM boards as well as partial use of the second row of bus pins.

This is now a work in progress building up to release 2.0 which has removed the additional connector between the CPU and ROM/RAM boards and relies entirely on the RCBus-80 pin connector for inter-board communication.

![](./images/Board_Set_1.JPG)

There are no programable logic devices (PALs, GALs, CPLDs etc) in my design. The only programmable devices are the 2 EEPROMs containing the monitor, CP/M-68K and EhBASIC.

## Zilog compatability
There is no intention to support any Zilog specific chips such as the PIO, SIO, CTC or KIO as their signals and timing are just too different. The PIO and SIO have equivalents in the 68230 and 68681 chips. The KIO has a sort-of equivalent in the 68901. A  CTC type chip may not be needed as the 68230 and 68681 have their own timers and the 68901 has 4 simple timers.

## 68000 memory space
The current address map is as follows:

| Address Range | Signal | Notes |
| :---- | :---- | :---- |
| 0x000000..0x01FFFF | EEPROM | Fixed address |
| 0x100000..0x1FFFFF | SRAM | Fixed address |
| 0xD00000..0xD03FFF | DUARTs | Jumper selectable options |
| 0xD08000..0xD0BFFF | PI/Ts | Jumper selectable options |
| 0xD10000..0xD13FFF | MFPs | Jumper selectable options |
| 0xF00000..0xF7FFFF | /MREQ | Fixed address |
| 0xF80000..0xFFFFFF | /IORQ | Fixed address |

## What works so far
Currently the following boards are assembled and are working as intended:
* 68000 procesor board
* ROM / RAM board - 128K ROM & 1M RAM
* Quad serial I/O board - with 2 68681 DUARTs

## To do
These boards are waiting to be tested:
* Digital I/O board - with 2 68230 PI/Ts
* Mutifunction board - with 2 68901 MFPs
 
## Progress
Currently the 68000 board, the ROM/RAM board and the serial I/O board are working and a small monitor program is running that allows me to download Motorola S-records. Both S2 & S3 record types are handled.

The monitor currently supports a few of the EASy68K TRAP #15 text I/O functions - currently just tasks 0, 1, 5, 6, 13 & 14 - which are all related to text input/output. Further tasks may be added as I need them.

I have a number of Steve Cousin's RC2014 / RCBus boards that I have been able to use successfully in the 68000 system. The code folder holds some example code for these boards as well as CP/M-68K v1.3 using the CompactFlash boards.
| Name | Description |
| :---- | :---- |
| [SC129](https://smallcomputercentral.com/rcbus/sc100-series/sc129-digital-i-o-rc2014/) | digital I/O module |
| [SC145](https://smallcomputercentral.com/rcbus/sc100-series/sc145-compact-flash-rc2014/) | CompactFlash module |
| [SC611](https://smallcomputercentral.com/rcbus/sc600-series/sc611-rcbus-micro-sd/) | MicroSD module |
| [SC704](https://smallcomputercentral.com/rcbus/sc700-series/sc704-rcbus-i2c-bus-master/) | I2C bus master module |
| [SC406](https://smallcomputercentral.com/i2c-bus-modules/sc406-i2c-temperature-sensor-module/) | I2C temperature sensor module |
| [SC705](https://smallcomputercentral.com/rcbus/sc700-series/sc705-rcbus-serial-acia/) | serial ACIA module |
| [SC729](https://smallcomputercentral.com/rcbus/sc700-series/sc729-rcbus-compact-flash-module/) | CompactFlash module |

The SC145 & SC729 CompactFlash modules have both been tested with CP/M-68K v1.3 and appear to operate correctly.

I've ported part of J B Langston's TMS9918A code to work with Shiela Dixon's [TMSEMU RCBus video card](https://peacockmedia.software/RC2014/TMSEMU/). There are now several demos working as I've slowly added more functionality to the TMS library. Some demos have also been ported from assembler to C.

# Still to do
* Test the 68230 digital I/O board
* Test the 68901 MFP board

# Conclusion
The previous version 1 suite of boards have proven that it is possible to run a 68000 based processor system on a standard RCBus backplane that is also compatible with a selection of RCBus / RC2014 boards. The new version 2 suite of boards should present a bit more of a polished solution to my RCBus 68000 design.

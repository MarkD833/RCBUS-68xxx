# RCBUS 68000 Board
This is my 68000 design for the RCBus. My design uses a 68000 microprocessor - not a 68008 - and is currently being tested on Steve Cousins [SC701](https://smallcomputercentral.com/rcbus/sc700-series/sc701-rcbus-backplane/) 6-slot RCBus backplane.

![](./images/RCBus68000.JPG)

There are no programable logic devices (PALs, GALs, CPLDs etc) in my design. The only programmable devices are the 2 EEPROMs containing the monitor, CP/M-68K and EhBASIC.

The initial design uses only the RCBus-40 pin connection and has a "private" connector between the 68000 board and the ROM/RAM board. This connector carries D8..D15, A17..A23, /AS, /UDS, /LDS, R/W, /DTACK & /RCBUS_DTACK as well as bunch of unassigned pins for use if needed during testing. However, I should have used a connector with longer pins. When the 2 boards are mated together, they are about 5mm closer together than the spacing of the SC701 backplane connectors which causes them to lean towards eachother.

The RCBus specification doesn't specifically mention the 68000 in the backplane signal assignments table so there may be a bit of wiggle room on the pins used. I will detail the RCBus 80-pin signal assignments once I have something more concrete - most likely once the next iteration of the boards gets produced as I will remove the private connector between the 68000 and the ROM/RAM board.

## Zilog compatability
There is no intention to support any Zilog specific chips such as the PIO, SIO, CTC or KIO as their signals and timing are just too different. The PIO and SIO have equivalents in the 68230 and 68681 chips. The KIO has a sort-of equivalent in the 68901. A  CTC type chip may not be needed as the 68230 and 68681 have their own timers and the 68901 has 4 simple timers.

## RCBus memory space
My 68000 design partially decodes blocks of memory within the 68000 address range as follows:
| Address Range | Signal |
| :---- | :---- |
| 0xE00000..0xEFFFFF | /MREQ goes low |
| 0xF00000..0xFFFFFF | /IORQ goes low |

The partial decoding of the 16-bit RCBus memory space results in 16 sequential blocks of M68K memory accessing the same RCBus memory space.
  
The partial decoding of the 8-bit RCBus I/O space results in 4096 sequential blocks of M68K memory accessing the same RCBus I/O space.

The current design places the SIO, PIO and MFP boards in RCBus I/O space and uses the fixed /DTACK generator on the processor card to signal completion of the cycle. The next iteration of boards will likely move these boards into a third memory space in the range 0xD00000..0xDFFFFF where the 68681, 68230 and 68901 will signal completion of a bus cycle using their own /DTACK signals.

## What works so far
Currently the following boards are completed and are under test:
* 68000 procesor card
* ROM / RAM card - 128K ROM & 1M RAM
* Quad serial I/O card - with 2 68681 DUARTs
* Multifunction card - with 2 68901s (not shown)

![](./images/RCBusBoards.JPG)

## To do
These boards are waiting to be populated and tested:
* Digital I/O card - with 2 68230 PI/Ts

## Progress
Currently the 68000 card, the ROM/RAM card and the serial I/O card are working and a small monitor program is running that allows me to download Motorola S-records. Both S2 & S3 record types are handled.

The monitor currently supports a few of the EASy68K TRAP #15 text I/O functions - currently just tasks 0, 1, 5, 6, 13 & 14 - which are all related to text input/output. Further tasks may be added as I need them.

The following RCBus cards have also been tested:
| Name | Description |
| :---- | :---- |
| [SC129](https://smallcomputercentral.com/rcbus/sc100-series/sc129-digital-i-o-rc2014/) | digital I/O module |
| [SC145](https://smallcomputercentral.com/rcbus/sc100-series/sc145-compact-flash-rc2014/) | CompactFlash module |
| [SC704](https://smallcomputercentral.com/rcbus/sc700-series/sc704-rcbus-i2c-bus-master/) | I2C bus master module |
| [SC406](https://smallcomputercentral.com/i2c-bus-modules/sc406-i2c-temperature-sensor-module/) | I2C temperature sensor module |
| [SC705](https://smallcomputercentral.com/rcbus/sc700-series/sc705-rcbus-serial-acia/) | serial ACIA module |
| [SC729](https://smallcomputercentral.com/rcbus/sc700-series/sc729-rcbus-compact-flash-module/) | CompactFlash module |

The SC145 & SC729 CompactFlash modules have both been tested with CP/M-68K v1.3 and appear to operate correctly.

Further details available shortly once sufficient testing is done.

# Still to do
* Build and test the 68230 digital I/O card
* Further testing with various RCBus boards I have

# Conclusion

I'm happy with the current state of the prototype system as it has proven that it is possible to run a 68000 based processor system on a standard RCBus backplane that is also compatible with a selection of RCBus / RC2014 boards.

The next step is to utilise the full RCBus-80 signals. There are new board designs in progress for the 68000 board and ROM/RAM memory board that utilise the RCBus-80 signals and do away with the private connector. There are also new designs for the serial i/o, parallel i/o and multifunction cards that place them in 68000 memory space so that they don't take up any space in the /IORQ memory space.

I've also recently acquired an [SC611 micro SD card storage module](https://smallcomputercentral.com/rcbus/sc600-series/sc611-rcbus-micro-sd/) and an [RCBus video card](https://peacockmedia.software/RC2014/TMSEMU/) from Sheila Dixon to experiment with.
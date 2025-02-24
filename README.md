# RCBUS-68000-Board

This is my 68000 design for the RCBus. My design uses a 68000 microprocessor - not a 68008 - and is currently being tested on an [SC701](https://smallcomputercentral.com/rcbus/sc700-series/sc701-rcbus-backplane/) 6-slot RCBus backplane.

![](./images/RCBus68000.JPG)

The initial design has a "private" connector between the 68000 board and the ROM/RAM board. This connector carries D8..D15, A17..A23, /AS, /UDS, /LDS, R/W, /DTACK & /RCBUS_DTACK as well as bunch of unassigned pins for use if needed during testing. I should have used a connector with longer pins. When the 2 boards are mated together, they are about 5mm closer together than the spacing of the SC701 backplane connectors.

The RCBus specification doesn't specifically mention the 68000 in the backplane signal assignments table so there may be a bit of wiggle room on the pins used. I will detail the RCBus 80-pin signal assignments once I have something more concrete - most likely once the next iteration of the boards gets produced as I will remove the private connector between the 68000 and the ROM/RAM board.

I'm also going to test the mapping of IO space (/IORQ) and Memory space (/MREQ) into an area of the 68000 memory and test with some of the various boards I have to hand.

## Zilog compatability
There is no intention to support any Zilog specific chips such as the PIO, SIO, CTC or KIO as their signals and timing are just too different. The PIO and SIO have equivalents in the 68230 and 68681 chips. The CTC may not be needed as the 68230 and 68681 have their own timers.

## What works so far
Currently the following boards are completed and are under test:
* 68000 procesor card
* ROM / RAM card - 128K ROM & 1M RAM
* Quad serial I/O card - with 2 68681 DUARTs

![](./images/RCBusBoards.JPG)

## To do
These boards are waiting to be populated and tested:
* Digital I/O card - with 2 68230 PI/Ts
* Multifunction card - with 2 68901

## Progress
Currently the 68000 card, the ROM/RAM card and the serial I/O card are working and a small monitor program is running that allows me to download Motorola S-records. Both S2 & S3 record types are handled.

Further details available shortly once sufficient testing is done.

# Still to do
* Complete serial I/O testing
* Tidy up the monitor program
* Build and test the 68230 digital I/O card
* Build and test the 68901 multifunction card

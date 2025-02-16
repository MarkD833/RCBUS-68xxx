# RCBUS-68000-Board

This is my 68000 design for the RCBus. My design uses a 68000 microprocessor - not a 68008 - and is currently being tested on an [SC701](https://smallcomputercentral.com/rcbus/sc700-series/sc701-rcbus-backplane/) 6-slot RCBus backplane.

![](./images/RCBus68000.jpg)

Currently the following boards are completed and are under test:
* 68000 procesor card
* ROM / RAM card - 128K ROM & 1M RAM
* Quad serial I/O card - with 2 68681 DUARTs

![](./images/RCBusBoards.jpg)

These boards are waiting to be populated and tested:
* Digital I/O card - with 2 68230 PI/Ts
* Multifunction card - with 2 68901

Currently the 68000 card, the ROM/RAM card and the serial I/O card are working.

Further details available shortly once sufficient testing is done.

# Still to do
* Complete serial I/O testing
* Tidy up the monitor program
* Build and test the digital I/O card
* Build and test the multifunction card

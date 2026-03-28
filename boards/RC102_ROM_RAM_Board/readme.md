# ROM & RAM board - V1 - 128K ROM + 1M RAM

![](../../images/ROM_RAM_Front.JPG)

# Details
The ROM & RAM board is designed to plug into an RCBus-80 backplane with support for 128K ROM (via 2x Winbond W27C512 EEPROMs) and 1M RAM (via 2x Alliance Memory AS6C4008 SRAMs). The EEPROMs and SRAMs are used as a pair to allow 16-bit wide memory accesses.

## Address Decoding
The address decoding is carried out by a 74LS138 and divides the lower 8Mb of memory space into eight 1Mb blocks. The EEPROMs are hard wired to /CS0 (pin 15) and the SRAMs are hard wired to /CS1 (pin 14). This configuration always places the EEPROMs starting at address 0x000000 and the SRAMs starting at address 0x100000.

## Bus Width 
A 74LS139 generates the read and write signals for each of the memory chips and takes care of byte or word accesses.

## DTACK
A 74LS125 is used to generate a simple /DTACK signal driven directly from the EEPROM and SRAM chip select signals without any wait period.

# Board Assembly
Assembly of the board should be fairly straightforward as there are no surface mount devices to deal with.

When fitting the 80-pin right angle connector, initially only solder a couple of pins at opposite ends of the connector so that you can make any adjustments if the board is not vertical when fitted to the backplane.

# Winbond W27C512 EEPROMs
Be careful where you source these devices from. I bought mine from AliExpress and they were sold as new. In fact they were salvaged from boards and the IC legs were tinned with solder. This makes the pins slightly "sticky" when you insert the chips into IC sockets. My experience with these chips is that you may get 6-10 insertions/removals before the IC socket spring contacts start to break.

# Errors
None so far.

# To Do
+ Experiment to find the maximum width of board that JLCPCB will accept to keep the low price.
+ Modify the RCBus80 medium board footprint in Kicad so that pins 1,40,41 & 80 don't throw DRC warnings/errors.



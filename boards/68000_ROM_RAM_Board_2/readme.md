# ROM & RAM board - V2 - 1M ROM + 1M RAM

![](../../images/ROM_RAM_v2_Front.JPG)

# Details
The ROM & RAM board is designed to plug into an RCBus-80 backplane with support for 1M ROM (via 2x SST39SF040 FLASH chips) and 1M RAM (via 2x Alliance Memory AS6C4008 SRAMs). The FLASH chips and SRAMs are used as a pair to allow 16-bit wide memory accesses.

## Address Decoding
The address decoding is carried out by a 74LS138 and divides the lower 8Mb of memory space into eight 1Mb blocks. Each pair of chips can be assigned to any of the 8 chip selects - but not both pairs to the same chip select.

Note that if this is the only memory board in the 68000 system, then a pair of FLASH chips should be assigned to /CS0 so that the 68000 finds the stack pointer and program counter on boot.

## Bus Width 
A 74LS139 generates the read and write signals for each of the memory chips and takes care of byte or word accesses.

## DTACK
A 74LS125 is used to generate a simple /DTACK signal driven directly from the EEPROM and SRAM chip select signals without any wait period.

# Board Assembly
Assembly of the board should be fairly straightforward as there are no surface mount devices to deal with.

Note the location of the decoupling capacitors for the memory devices are located within the IC sockets. THese decoupling capacitors should be bent over so that they do not interfere with the insertion of the memory chips.
 
When fitting the 80-pin right angle connector, initially only solder a couple of pins at opposite ends of the connector so that you can make any adjustments if the board is not vertical when fitted to the backplane.

Do not mix ROM & RAM chips in the same bank.

# Memory Bank Configuration
The pinout of the 32-pin FLASH and SRAM chips are slightly different and in order to accommodate both types, a pair of jumpers need to be set per chip. J6,J7,J8 & J9 set the memory type fitted to memory bank #0 and J2,J3,J4 & J5 set the memory type fitted to memory bank #1.

# Jumpers
+ FLASH ROM chips installed in Bank #1
  + J2: Jumper pins 1-2
  + J3: Jumper pins 2-3
  + J4: Jumper pins 1-2
  + J5: Jumper pins 2-3
+ RAM chips installed in Bank #1
  + J2: Jumper pins 2-3
  + J3: Jumper pins 1-2
  + J4: Jumper pins 2-3
  + J5: Jumper pins 1-2
+ FLASH ROM chips installed in Bank #0
  + J6: Jumper pins 2-3
  + J7: Jumper pins 1-2
  + J8: Jumper pins 2-3
  + J9: Jumper pins 1-2
+ RAM chips installed in Bank #0
  + J6: Jumper pins 1-2
  + J7: Jumper pins 2-3
  + J8: Jumper pins 1-2
  + J9: Jumper pins 2-3
+ J10: Memory Address selection
  + $000000 .. $0FFFFF
  + $100000 .. $1FFFFF
  + $200000 .. $2FFFFF
  + $300000 .. $3FFFFF
  + $400000 .. $4FFFFF
  + $500000 .. $5FFFFF
+ J11 (with J10): Specify the memory address for bank #0
+ J12 (with J10): Specify the memory address for bank #1

# Errors
None so far.

# To Do
+ Experiment to find the maximum width of board that JLCPCB will accept to keep the low price.
+ Modify the RCBus80 medium board footprint in Kicad so that pins 1,40,41 & 80 don't throw DRC warnings/errors.





# Errors
+ The signals /RAM_CS and /ROM_CS don't go anywhere!
  + /RAM_CS should be called /CS_BANK0 & /ROM_CS should be called /CS_BANK1
    + Fix by connecting LS125 pin 1 to either pin 22 of bank 1 ICs & adding a 10K pullup resistor.
    + Fix by connecting LS125 pin 4 to either pin 22 of bank 2 ICs & adding a 10K pullup resistor.
+ J4 & J5 at the top of U7 are not on a 0.1in pitch.



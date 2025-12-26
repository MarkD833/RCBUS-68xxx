# RCBUS-68000-Boards

These folders contain the KiCad (v8/v9) design files for the various RCBus 68000 boards I'm currently testing.

| Board Folder | Description |
| :---- | :---- |
| 68000 CPU Board | 68000 processor card using the PLCC package variant of the 68000 |
| 68000 ROM RAM_Board | 128K ROM & 1M RAM board |
| 68000 ROM/RAM Board v2 | 1M ROM & 1M RAM board |
| 68000 SIO Board | Dual MC68681 serial board - 4 serial ports |
| 68000 MFP Board | Dual MC68901 multifunction peripheral board |
| 68000 PIO Board | Dual MC68230 parallel interface / timer board |
| 68000 SPI Board | 6 channel SPI master board - 3V3 and 5V ports |
| 68000 LBE Board | Serial / parallel / timer board |
| 68302 CPU Board | 68302 processor card using the PGA package |

Make sure to look at the readme files in each board folder as they will detail any errors and corrections I've noticed so far as well as any thoughts on future enhancements etc.

A minimal 68000 (or 68010) system would comprise of a 68000/68010 CPU board, ROM/RAM board and SIO board.

A minimal 68302 system would comprise of a 68302 CPU board and a ROM/RAM board.

---

# Chips
Below are the details of the chips that I'm using across my design in case anybody choosing to replicate my setup encounters problems.

## 68000 Processor Board

| Chip ID | Manufacturer | Chip Number | Description |
| :---- | :---- |  :---- | :---- |
| U1 | Motorola | MC68HC000FN20 | 68000 Processor |
| U2 | Philips | PC74HCT125P | Quad tri-state buffer |
| U3 | ST | T74LS148B1 | 8 line to 3 line priority encoder |
| U4 | TI? | SN74LS10N | Triple 3-input NAND gate |
| U5 | TI | SN74LS139AN | Dual 2-line to 4-line decoder |
| U6 | TI | SN74LS175N | Quadruple D-Type flip-flop |
| U8 | TI | SN74LS175N | Quadruple D-Type flip-flop |
| U9 | TI | SN74LS00N | Quad 2-input NAND gate |

Note there isn't a U7.

## 68302 Processor Board

| Chip ID | Manufacturer | Chip Number | Description |
| :---- | :---- |  :---- | :---- |
| U1 | Phillips | 74HCT10N | Triple 3-input NAND gate |
| U2 | TI | SN74HCT139N | Dual 2-line to 4-line decoder |
| U3 | Phillips | PC74HCT125P | Quad tri-state buffer |
| U4 | Motorola | MC68302CRC16C0 | 68302 Processor |
| U5 | ST | T74LS148B1 | 8 line to 3 line priority encoder |

## ROM / RAM Board v1

| Chip ID | Manufacturer | Chip Number | Description |
| :---- | :---- |  :---- | :---- |
| U1 | Phillips | PC74HCT125P | Quad tri-state buffer |
| U3 | Winbond | W27C512-45Z | 64K x 8 EEPROM |
| U4 | Alliance Memory | AS6C4008-55PCN | 512K x 8 SRAM |
| U5 | Alliance Memory | AS6C4008-55PCN | 512K x 8 SRAM |
| U6 | Winbond | W27C512-45Z | 64K x 8 EEPROM |
| U8 | Nat Semi | DM74LS138N | 3 to 8 line decoder |
| U9 | TI | SN74LS139AN | Dual 2-line to 4-line decoder |

Note there isn't a U2 or U7 as I forgot to re-annotate the schematic.

## ROM / RAM Board v2

| Chip ID | Manufacturer | Chip Number | Description |
| :---- | :---- |  :---- | :---- |
| U1 | Phillips | PC74HCT125P | Quad tri-state buffer |
| U2 | TI | SN74LS139AN | Dual 2-line to 4-line decoder |
| U3 & U4 | | See Note | Either a pair of ROMs or a pair of RAM chips |
| U5 | Nat Semi | DM74LS138N | 3 to 8 line decoder |
| U6 & U7 | | See Note | Either a pair of ROMs or a pair of RAM chips |

The board was designed around Alliance Memory AS6C4008 512K RAM chips and SST 39SF040 512K flash chips. As long as they are 32-pin devices they will likely work but check the pinouts just in case! 

## Serial I/O Board

| Chip ID | Manufacturer | Chip Number | Description |
| :---- | :---- |  :---- | :---- |
| U1 | ?? | 74LS138N | 3 to 8 line decoder |
| U2 | Philips | SCN68681 | Dual Universal Asynchronous Receiver/Transmitter **See Note** |
| U3 | Philips | SCN68681 | Dual Universal Asynchronous Receiver/Transmitter **See Note** |
| U4 | Philips | PC74HCT688P | 8 bit magnitude comparator |

Note:
There are various 68681 DUARTs but unfortunately they are not all entirely compatible. The issue appears to be in relation to the X2 input pin when an external oscillator is used rather than a crystal, specifically whether the X2 pin should be grounded or not. My current SIO board design grounds the X2 pin which limits the DUART choices.

Below are some 68681 DUARTs from different manufacturers and the relevant text from their datasheets:

+ Motorola MC68681
  + If an external TTL-level clock is used, this pin should be tied to ground. 
+ Motorola MC68HC681
  +  If an external CMOS-level clock is used, this pin must be left open. 
+ Philips SCC68681
  + If a crystal is not used it is best to keep this pin not connected. It **must not** be grounded.
+ Philips SCN68681
  + If a crystal is not used it is best to keep this pin not connected although it is permissible to ground it.
+ Philips SCC68692
  + If a crystal is not used it is best to keep this pin not connected although it is permissible to ground it.
+ Toshiba TMP68681
  + If an external TTL-level clock is used, this pin should be tied to ground. 

## Parallel I/O Board

| Chip ID | Manufacturer | Chip Number | Description |
| :---- | :---- |  :---- | :---- |
| U1 | ST | TS68230CP10 | Parallel Interface / Timer |
| U2 | ST | TS68230CP10 | Parallel Interface / Timer |
| U3 | Nat Semi | DM74LS138N | 3 to 8 line decoder |
| U4 | Philips | PC74HCT688P | 8 bit magnitude comparator |

## Multi-Function Peripheral Board

| Chip ID | Manufacturer | Chip Number | Description |
| :---- | :---- |  :---- | :---- |
| U2 | ?? | SN4LS138N | 3 to 8 line decoder |
| U4 | ST | MK68901N-04 | Multi-Function Peripheral |
| U5 | ST | MK68901N-04 | Multi-Function Peripheral |
| U6 | Philips | PC74HCT688P | 8 bit magnitude comparator |

Note there isn't a U1 or U3 as I forgot to re-annotate the schematic.


# RCBUS-68000-Boards

These folders contain the KiCad (v8/v9) design files for the various RCBus 68000 boards I'm currently testing.

| Board Folder | Description |
| :---- | :---- |
| 68000_CPU_Board | 68000 processor card using the PLCC package variant of the 68000 |
| 68000_ROM_RAM_Board | 128K ROM & 1M RAM board |
| 68000_SIO_Board | Dual MC68681 serial board - 4 serial ports |
| 68000_MFP_Board | Dual MC68901 multifunction peripheral board |
| 68000_PIO_Board | Dual MC68230 parallel interface / timer board |

Make sure to look at the readme.txt files in each board folder as they will detail any errors and corrections I've noticed so far as well as any thoughts on future enhancements etc.

# Chips

My processor board has a turned pin socket fitted so I can easily try different CPU clock frequencies. Initial testing was done with a 7.3728MHz oscillator but I've just tried an 18.432MHz oscillator.

I've re-un the test programs for the SC729 (CompactFlash module), SC611 (MicroSD module) and SC704 (I2C bus master module) and all appear to operate correctly.

It then occured to me that I should detail somewhere the chips that I'm using across my design in case that has a bearing on the crystal oscillator frequency on the processor board. What follows is a list of ICs I used on each board.

## Processor Board

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

## ROM / RAM Board

| Chip ID | Manufacturer | Chip Number | Description |
| :---- | :---- |  :---- | :---- |
| U1 | Phillips | PC74HCT125P | Quad tri-state buffer |
| U3 | Winbond | W27C512-45Z | 64K x 8 EEPROM |
| U4 | Alliance Memory | AS6C4008-55PCN | 512K x 8 SRAM |
| U5 | Alliance Memory | AS6C4008-55PCN | 512K x 8 SRAM |
| U6 | Winbond | W27C512-45Z | 64K x 8 EEPROM |
| U8 | Nat Semi | DM74LS138N | 3 to 8 line decoder |
| U9 | TI | SN74LS139AN | Dual 2-line to 4-line decoder |

Note there isn't a U2 or U7.

## Serial I/O Board

| Chip ID | Manufacturer | Chip Number | Description |
| :---- | :---- |  :---- | :---- |
| U1 | ?? | 74LS138N | 3 to 8 line decoder |
| U2 | Philips | SCN68681 | Dual Universal Asynchronous Receiver/Transmitter |
| U3 | Philips | SCN68681 | Dual Universal Asynchronous Receiver/Transmitter |
| U4 | Philips | PC74HCT688P | 8 bit magnitude comparator |

## Parallel I/O Board

To follow.

## Multi-Function Peripheral Board

To follow.

# SC611

The code in this folder provides a simple demonstration of sending bit banged SPI data out using an [SC611](https://smallcomputercentral.com/rcbus/sc600-series/sc611-rcbus-micro-sd/) MicroSD module to read some information from a Microchip 25LC256 SPI EEPROM.

The program reads a 16-bit address from location $0000 in the EEPROM. It then reads and prints characters starting at that 16-bit address until a NULL is read. The PNG images shows an LA trace of the reading of location $000 and the reading of the null terminated string. I've included the hex file of the data in the EEPROM. It's the vocabulary from my Arduino SP0256 module.

The code can be assembled using EASy68K.


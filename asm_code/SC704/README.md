# SC704

The code in this folder provides 2 simple demonstrations to exercise the [SC704](https://smallcomputercentral.com/rcbus/sc700-series/sc704-rcbus-i2c-bus-master/) I2C bus master module.

The first program is i2c_scan.x68 and it scans the I2C bus reporting back the addresses of any devices it finds. With no external devices connected, it should report back a device at address $50 (if the on-board 24LC256 EEPROM is fitted).

The second program works in conjunction with the [SC406](https://smallcomputercentral.com/i2c-bus-modules/sc406-i2c-temperature-sensor-module/) I2C temperature sensor module. It simply interrogates the TC74 temperature sensor and reports back the temperature in deg C.

The code can be assembled using EASy68K.


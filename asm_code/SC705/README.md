# SC705

The code in this folder provides 2 simple demonstrations to exercise the [SC705](https://smallcomputercentral.com/rcbus/sc700-series/sc705-rcbus-serial-acia/) serial ACIA module.

Note that the ACIA serial port is configured for 57600,8,N,1 as my SC705 has a 3.6864MHz crystal fitted instead of a 7.3728MHz crystal. If your board uses a 7.3728MHz crystal, then the baud rate doubles to 115200.

The first program is hello.x68 and it simply outputs the message "Hello World!" + CR & LF to the ACIA serial port.

The second program is echo.x68 and it simply echoes back any characters recevied by the ACIA.

The code can be assembled using EASy68K.


THOUGHTS:
=========
+ Should I have used SCC1?
  CTS1 is in input to SCC1 that can be used to tell SCC1 to stop transmitting.
  RTS1 is an output from SCC1 and is asserted when SCC1 Tx buffer has data to send.
  Don't appear to have software control over these pins to be able to tell the host PC
  to stop transmitting data to SCC1.

+ SCC2 provides software control of RTS2 (Port pin PA5) and CTS2 (Port pin PA4).
  Therefore can tell host PC to stop transmitting via software if our Rx buffers fill up.

+ SCC3 has no handshaking as the pins are used for the SPI interface.

+ For 115200 baud with RTS/CTS handshaking for quick xfer of srec files then it looks
  like SCC2 would have to be used.


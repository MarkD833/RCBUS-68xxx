![](../../images/MC68302_Front.JPG)
# Notes
- CPU Clock
  + The clock - X1 in the schematic - can be anything up to the max clock of your 68302.  I'm currently using a 7.3728MHz clock with my 16MHz device.

# Jumpers
+ J1: Fit jumper to route Timer #1 output onto RCBus CLOCK2 but only if CLOCK2 is **not** being used to share a clock between the SIO, PIO and MFP boards.
+ J3: Connect the 5v from Serial #1 or Serial #2 to the RCBus 5v line

# Thoughts
+ Should I have used SCC1 for the monitor port?
  + CTS1 is in input to SCC1 that can be used to tell SCC1 to stop transmitting.
  + RTS1 is an output from SCC1 and is asserted when SCC1 Tx buffer has data to send.
   +Don't appear to have software control over these pins to be able to tell the host PC to stop transmitting data to SCC1.

+ SCC2 provides software control of RTS2 (Port pin PA5) and CTS2 (Port pin PA4). Therefore can tell host PC to stop transmitting via software if our Rx buffers fill up.

+ SCC3 has no handshaking as the pins are used for the SPI interface.

+ For 115200 baud with RTS/CTS handshaking for quick xfer of srec files then it looks like SCC2 would be the better choice.


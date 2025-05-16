+ Should the SIOs each have their own choice of interrupt level?
+ Move the 6-pin serial port connectors further in from the board edge.
+ Jumpers to allow TXD1 & RXD1 to route to the RCBus TX & RX signals.
+ Jumpers to allow TXD2 & RXD2 to route to the RCBus TX2 & RX2 signals.

Physical Board
==============
Experiment to find the maximum width of board that JLCPCB will accept to keep the low price.
Modify the RCBus80 medium board footprint in Kicad so that pins 1,40,41 & 80 don't throw DRC warnings/errors.

![](../../images/Serial_Front.JPG)
# Notes
- SIO Clock
  + The clock - X1 in the schematic - should be 3.6864MHz
# Jumpers
+ J3: Connect the 5v from Ser1 or Ser2 to the RCBus 5v line
+ J6: Connect the 5v from Ser3 or Ser4 to the RCBus 5v line

**NOTE:** Only connect *one* of J3, J6 or an RCBus power supply.

+ J12: Specify the interupt line to be used by the serial cards
+ J4: TODO
+ J10: TODO
+ J14: Specify the clock source
  + 1&3 Use the onboard clock source
  + 1&2 Use the RCBus clock source
  + 1&2 *and* 3&4: Use the onboard clock source and supply the RCBus Clock2 signal with the clock.
+ J1: IO Address selection
  + D00000
  + D00800
  + D01000
  + D01800
  + D02000
  + D02800
  + D03000
  + D03800
+ J9 (with J1): Specify the IO Address for Serial chip A
+ J11 (with J1): Specify the IO Address for Serial chip B
# Thoughts
+ Should the SIOs each have their own choice of interrupt level?
+ Move the 6-pin serial port connectors further in from the board edge.
+ Jumpers to allow TXD1 & RXD1 to route to the RCBus TX & RX signals.
+ Jumpers to allow TXD2 & RXD2 to route to the RCBus TX2 & RX2 signals.
# Physical Board
+ Experiment to find the maximum width of board that JLCPCB will accept to keep the low price.
+ Modify the RCBus80 medium board footprint in Kicad so that pins 1,40,41 & 80 don't throw DRC warnings/errors.

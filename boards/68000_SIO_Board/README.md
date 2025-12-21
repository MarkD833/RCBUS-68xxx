# Quad Serial I/O Board

![](../../images/Serial_Front.JPG)

# Details
The serial board is populated with two 68681 (or equivalent) DUARTS giving 4 UARTs in total. The 4 serial ports are each fed to a 6-pin connector at the board edge. The layout of the 6 pins is compatible with an FTDI USB-TTL Serial interface board. Both DUART chips do not have to be fitted. The board will work with just one chip fitted.

## Address Decoding
The address decoding is carried out by a 74LS688 combined with a 74LS138 to generate 8 separate 2048 byte blocks residing between addresses $D00000 and $D03FFF.

The base address of each DUART is determined by the placement of a jumper between adjacent pins on J1 & J9 (DUART A) and J1 & J11 (DUART B).

## Device Register Access
The registers of the 68681 DUART are 8 bits wide and are accessed on consecutive ODD addresses from the base address set by the address decode logic. Assuming that the /CS0 jumper has been fitted for DUART #1, then the first few registers are accessed on the following addresses:
+ $D00001 : Mode Register A (R/W)
+ $D00003 : Status Register A (R) / Clock Select Register A (W)
+ $D00005 : Command Register A (W)

## DTACK
Each DUART generates its own /DTACK signal internally which is then routed back to the processor via RCBus-80 pin 62.

## Interrupts
The current board design combines the interrupts from both DUARTs into a single /INT signal. This /INT signal can then be assigned to an interrupt level of 1,2,5 or 6 depending on the jumper position on J12.

## Baud Rate Generator Clock
The clock signal for the baud rate generators can be sourced from the on board 3.6864MHz crystal oscillator (X1 in the schematic) or from an external clock source on the RCBus-80 CLOCK2 pin (pin 61) via the jumper J14.

The jumper J14 can also be configured to route the baud rate generator clock to the CLOCK2 pin on the RCBus-80 connector.

## Discrete Outputs
The 8 outputs from each DUART are routed to J4 on the edge of the board. J4 also provides GND and +5V signals. Note that the board **does not have** any protection built in to prevent damage to the DUART if one of these pins is mis-used.

## Discrete Inputs
The 6 inputs to each DUART are routed to J10 on the edge of the board. J10 also provides GND and +5V signals. Note that the board **does not have** any protection built in to prevent damage to the DUART if one of these pins is mis-used.

## Flow Control
Serial hardware flow control can be achieved on each of the 4 serial ports by shorting the appropriate solder jumpers on the rear of the board. This routes the 2 flow control signals for each serial port to an input pin and an output pin on the DUART.

## Power
The complete RCBus system can be powered from the 5V pin of one of the USB-TTL serial connectors by fitting a jumper in place on the appropriate pins of J3 or J6.

Note that there is a current limit of 500mA - imposed by the host system USB hardware - when the system is powered this way. It is relatively easy to exceed this limit once several boards are in use and I recommend that the system be powered from an external 5V supply connected to the RCBus backplane instead.
 
# Board Assembly
Assembly of the board should be fairly straightforward. There are no surface mount devices to deal with.

If you choose have a turned pin socket for the system clock, then an 8-pin DIL turned pin socket can be used. I flipped the socket over - pins pointing upwards - and easily pushed out pins 2,3,6 & 7.

When fitting the 80-pin right angle connector, initially only solder a couple of pins at opposite ends of the connector so that you can make any adjustments if the board is not vertical when fitted to the backplane.

# DUART Chip Compatability
There are various 68681 DUARTs but unfortunately they are not all entirely compatible. The issue appears to be in relation to the X2 input pin when an external oscillator is used rather than a crystal, specifically whether the X2 pin should be grounded or not.

Below are some 68681 DUARTs from different manufacturers and the relevant text from their datasheets:

+ Motorola MC68681
  + If an external TTL-level clock is used, this pin should be tied to ground. 
+ Motorola MC68HC681
  +  If an external CMOS-level clock is used, this pin must be left open. 
+ Philips SCC68681
  + If a crystal is not used it is best to keep this pin not connected. It **must not** be grounded.
+ Philips SCN68681
  + If a crystal is not used it is best to keep this pin not connected although it is permissible to ground it.
+ Toshiba TMP68681
  + If an external TTL-level clock is used, this pin should be tied to ground. 

# Jumpers
+ J1: IO Address selection
  + $D00000
  + $D00800
  + $D01000
  + $D01800
  + $D02000
  + $D02800
  + $D03000
  + $D03800
+ J2: Serial #3 port
+ J3: (**only fit one jumper** if not using an external 5V power source)
  + 1-2 : Power the system from the USB-TTL Serial board on Serial #1
  + 2-3 : Power the system from the USB-TTL Serial board on Serial #2
  + 1-2 : Power the system from the USB-TTL Serial board on Serial #3
  + 2-3 : Power the system from the USB-TTL Serial board on Serial #4
+ J4: Exposes the 16 digital outputs from the 2 DUARTS as well as GND and +5V. Note that there is **NO** output protection circuitry.
+ J5: Serial #4 port
+ J7: Serial #1 port
+ J8: Serial #2 port
+ J9 (with J1): Specify the IO Address for Serial chip A
+ J10: Exposes the 12 digital inputs to the 2 DUARTS as well as GND and +5V. Note that there is **NO** input protection circuitry.
+ J11 (with J1): Specify the IO Address for Serial chip B
+ J12: Specify the interupt line to be used by the serial cards
  + 1-2 : use /INT1
  + 3-4 : use /INT2
  + 5-6 : use /INT5
  + 7-8 : use /INT6 
+ J14: Specifies the clock source for the DUART baud rate generators
  + 1-3 Use the onboard clock source
  + 1-2 Use the RCBus clock source from CLOCK2
  + 1-2 *and* 3-4: Use the onboard clock source and supply the RCBus CLOCK2 signal with the clock.

# Errors
None so far.

# Thoughts / Enhancements
+ Should the SIOs each have their own choice of interrupt level?
+ Move the 6-pin serial port connectors further in from the board edge.
+ Jumpers to allow TXD1 & RXD1 to route to the RCBus TX & RX signals.
+ Jumpers to allow TXD2 & RXD2 to route to the RCBus TX2 & RX2 signals.

# To Do
+ Experiment to find the maximum width of board that JLCPCB will accept to keep the low price.
+ Modify the RCBus80 medium board footprint in Kicad so that pins 1,40,41 & 80 don't throw DRC warnings/errors.


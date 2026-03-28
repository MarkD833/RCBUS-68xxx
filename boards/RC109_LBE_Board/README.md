# 68000 LBE (Little Bit of Everything) Board #1

![](../../images/LBE_Front.JPG)

# Details

The intention of this board is to try and make a 68000 equivalent of Steve Cousins Z80 [SC110 board](https://smallcomputercentral.com/rcbus/sc100-series/sc110-z80-serial-rc2014-3/) which consists of a Z80 SIO/2 serial chip and a Z80 CTC counter timer chip providing 2 serial ports and 4 8-bit down counters.

By combining an MC68681 DUART (or equivalent) with an MC68901 MFP I managed to achieve a similar board, but with a bit more functionality - mainly due to the MC68901.

The MC68681 provides:
+ 2 Serial Ports (SER1 & SER2)
+ 8 Digital Outputs
+ 6 Digital Inputs
+ 1 16-bit Timer

The MC68901 provides:
+ 1 Serial Port (SER3)
+ 8 Digital Inputs/Outputs
+ 4 8-bit Timers

The design provides serial I/O, digital I/O and some timers so the name Little Bit of Everything seemed appropriate.

Note that the X2 pin of the MC68681 has a solder jumper (JP7) so that this pin can be grounded if required. This should allow a greater choice of MC68681 alternatives to be fitted.

## Address Decoding
The address decoding is carried out by a 74LS688 combined with a 74LS138 to generate 8 separate 2048 byte blocks residing between addresses $D00000 and $D03FFF. This is the same address range that the SIO (quad serial) board uses, allowing for the same monitor program to work with either board.

The base address of the DUART and the MPF are determined by the placement of a jumper between adjacent pins on J12 & J13 (DUART) and J12 & J18 (MFP).

## MC68681 DUART
### 68681 Register Access
The registers of the 68681 DUART are 8 bits wide and are accessed on consecutive ODD addresses from the base address set by the address decode logic. Assuming that the /CS0 jumper has been fitted for the DUART, then the first few registers are accessed on the following addresses:
+ $D00001 : Mode Register A (R/W)
+ $D00003 : Status Register A (R) / Clock Select Register A (W)
+ $D00005 : Command Register A (W)

### 68681 Baud Rate Generator Clock
The clock signal for the baud rate generators can be sourced from the on board 3.6864MHz crystal oscillator (X1 in the schematic) or from an external clock source on the RCBus-80 CLOCK2 pin (pin 61) via the jumper J4.

The jumper J4 can also be configured to route the baud rate generator clock to the CLOCK2 pin on the RCBus-80 connector.

### 68681 Discrete Outputs
The lower 6 outputs from the DUART (OP0..OP5) are routed to J8 on the edge of the board. Note that the board **does not have** any protection built in to prevent damage to the DUART if one of these pins is mis-used.

The upper 2 outputs from the DUART (OP6 & OP7) are routed to 2 on-board LEDs that can be turned on or off as required.

**CAUTION:**  Be careful with J8 if you use a pinheader as J8 also provides GND and +5V signals which can easily short to something they shouldn't.
 
### 68681 Discrete Inputs
The 6 inputs to the DUART (IP0..IP5) are also routed to J8 on the edge of the board. Note that the board **does not have** any protection built in to prevent damage to the DUART if one of these pins is mis-used.

### 68681 Flow Control
Serial hardware flow control can be achieved on each of the 2 serial ports by shorting the appropriate solder jumpers on the rear of the board. This routes the 2 flow control signals for each serial port to an input pin and an output pin on the DUART.

## MC68901
### 68901 Register Access
The registers of the MFP are 8 bits wide and are accessed on consecutive ODD addresses from the base address set by the address decode logic. Assuming that the /CS1 jumper has been fitted for the MFP, then the first few registers are accessed on the following addresses:

+ $D00801 : General Purpose I/O Data Register
+ $D00803 : Active Edge Register
+ $D00805 : Data Direction Register

### 68901 Baud Rate Generator Clock
The MFP does not have a built-in baud rate generator like the 68681 does. In order to generate the required UART clock, the output of timer D is hard wired to the Tx and Rx clock inputs.

The 68901 uses the same clock source that the 68681 does and is determined by the setting of jumper J4.

### 68901 Discrete Input / Output
The 8 discrete I/O signals of the bit programmable 8-bit I/O port are routed to J5. Note that the board **does not have** any protection built in to prevent damage to the MFP if one of these pins is mis-used.

**CAUTION:**  Be careful with J5 if you use a pinheader as J5 also provides GND and +5V signals which can easily short to something they shouldn't.

### 68901 Serial Port Flow Control
Serial hardware flow control can be achieved on the serial port by shorting the appropriate solder jumpers on the rear of the board. This routes the 2 flow control signals to IO0 & IO1 on the 8-bit I/O port of the MFP.

### 68901 Timers
Timers A, B & C are available for general use. Timer D is used to generate the baud rate clock for the UART, but is also available for general use if the UART is not used.

The timer outputs TA0, TB0, TC0 & TD0 are available on J6 along with the TAI & TBI signals.

## DTACK
The DUART and MFP generate their own /DTACK signal internally which is then routed back to the processor via RCBus-80 pin 62.

## Interrupts
The board design allows for the DUART & MFP to use separate (but not the same) interrupts. Depending on the jumper setting the DUART and MFP can be assigned to an interrupt level of 1,2,5 or 6 depending on the jumper positions on J1 & J2.

## Power
The 5V pin on each of the SER1, SER2 & SER3 headers is not connected. System power must be supplied from another source.

# Board Assembly
Assembly of the board should be fairly straightforward. There are no surface mount devices to deal with.

If you choose have a turned pin socket for the system clock, then an 8-pin DIL turned pin socket can be used. I flipped the socket over - pins pointing upwards - and easily pushed out pins 2,3,6 & 7.

When fitting the 80-pin right angle connector, initially only solder a couple of pins at opposite ends of the connector so that you can make any adjustments if the board is not vertical when fitted to the backplane.

# Choice of DUART Chip
There are various 68681 DUARTs but unfortunately they are not all entirely compatible. The issue appears to be in relation to the X2 input pin when an external oscillator is used rather than a crystal, specifically whether the X2 pin should be grounded or not. The LBE #1 board design can ground the X2 pin via solder jumper JP7 - see jumpers section below.

Below are some 68681 DUARTs from different manufacturers and the relevant text from their datasheets:

+ Motorola MC68681 (max 38400 baud)
  + If an external TTL-level clock is used, this pin should be tied to ground. 
+ Motorola MC68HC681 (max 38400 baud)
  +  If an external CMOS-level clock is used, this pin must be left open. 
+ Philips SCC68681 (max 115200 baud)
  + If a crystal is not used it is best to keep this pin not connected. It **must not** be grounded.
+ Philips SCN68681 (max 115200 baud)
  + If a crystal is not used it is best to keep this pin not connected although it is permissible to ground it.
+ Philips SCC68692 (max 115200 baud)
  + If a crystal is not used it is best to keep this pin not connected although it is permissible to ground it.
+ Toshiba TMP68681 (max 38400 baud)
  + If an external TTL-level clock is used, this pin should be tied to ground. 

For the Philips devices that support 115200 baud, this is achieved by putting the device into a test mode and is documented in the Philips Semiconductors document titled "Extended baud rates for SCN2681, SCN68681, SCC2691, SCC2692, SCC68681 and SCC2698B".

# Jumpers
+ J1 : Specify the interupt line to be used by the MFP
  + 1-2 : use /INT1
  + 3-4 : use /INT2
  + 5-6 : use /INT5
  + 7-8 : use /INT6 
+ J2 : Specify the interupt line to be used by the DUART
  + 1-2 : use /INT1
  + 3-4 : use /INT2
  + 5-6 : use /INT5
  + 7-8 : use /INT6 
+ J4: Specifies the clock source for the DUART baud rate generator & MFP timers
  + 1-3 Use the onboard clock source
  + 1-2 Use the RCBus clock source from CLOCK2
  + 1-2 *and* 3-4: Use the onboard clock source and supply the RCBus CLOCK2 signal with the clock.
+ J5: Carries the digital I/O pins of the MFP as well as GND and +5V. Note that there is **NO** input protection circuitry.
+ J6: Carries the 4 MFP timer outputs as well as timer A & B inputs.
+ J8: Carries the digital I/O pins of the DUART as well as GND and +5V. Note that there is **NO** input protection circuitry.
+ J12: IO Address selection
  + $D00000
  + $D00800
  + $D01000
  + $D01800
  + $D02000
  + $D02800
  + $D03000
  + $D03800
+ J13 (with J12): Specify the IO Address for the DUART
+ J15: Serial #1 port (DUART channel 1)
+ J16: Serial #2 port (DUART channel 2)
+ J17: Serial #3 port (MFP)
+ J18 (with J12): Specify the IO Address for the MFP

# Solder Jumpers (rear of board)
+ JP1 : Connects SER1 pin 6 to DUART IP0
+ JP2 : Connects SER1 pin 1 to DUART OP0
+ JP3 : Connects SER2 pin 6 to DUART IP1
+ JP4 : Connects SER2 pin 1 to DUART OP1
+ JP5 : Connects SER3 pin 6 to MFP IO0
+ JP6 : Connects SER3 pin 1 to MFP IO1
+ JP7 : Connects DUART X2 pin to GND (check your specific DUART datasheet)

# Errors
None so far.


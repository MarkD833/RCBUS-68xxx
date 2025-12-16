# Dual MultiFunction Peripheral Board

![](../../images/MFP_Front.JPG)

# Details
The multifunction peripheral board is populated with two 68901 chips. Both chips do not have to be fitted. The board will work with just one chip fitted.

## Address Decoding
The address decoding is carried out by a 74LS688 combined with a 74LS138 to generate 8 separate 2048 byte blocks residing between addresses $D10000 and $D13FFF.

The base address of each MFP is determined by the placement of a jumper between adjacent pins on J12 & J9 (MFP A) and J12 & J11 (MFP B).

## Device Register Access
The registers of the MFP are 8 bits wide and are accessed on consecutive ODD addresses from the base address set by the address decode logic. Assuming that the /CS0 jumper has been fitted for MFP #1, then the first few registers are accessed on the following addresses:
+ $D10001 : General Purpose I/O Data Register
+ $D10003 : Active Edge Register
+ $D10005 : Data Direction Register

## DTACK
Each MFP generates its own /DTACK signal internally which is then routed back to the processor via RCBus-80 pin 62.

## Clock Source
The clock signal for the chip functions and timers can be sourced from the on board 3.6864MHz crystal oscillator (X1 in the schematic) or from an external clock source on the RCBus-80 CLOCK2 pin (pin 61) via the jumper J6.

Note that each MFP chip **requires** a clock signal in order to function correctly, even if the UART and timer are not being used. 

## UART Baud Rate Clock
The MFP does not have a built-in baud rate generator like the 68681 does. In order to generate the required UART clock, the output of timer D hard wired to the Tx and Rx clock inputs.

Assuming that the crystal oscillator (or CLOCK2) frequency is 3.6864MHz, with the prescaled set to DIV 4 and the required baud rate of 9600 baud, then the following calculation will provide the timer D reload value:
```
reload value = clock / prescaler / 16 / baud rate
reload value = 3686400 / 4 / 16 / 9600 = 6
```

## UART Edge Connector
The 6-pin UART connector is compatible with an FTDI USB-TTL Serial interface board.

## UART Flow Control
Serial hardware flow control can be achieved on the serial port by shorting the appropriate solder jumpers on the rear of the board. This routes the 2 flow control signals for each serial port to 2 I/O pins one each MFT.

## Input / Output Pins
Each MFP provides a single 8-bit I/O port with programmable direction control for each bit. Connector J4 carries the 8 port pins for both MFP chips as well as 2 GND pins.

Note that the board **does not have** any protection built in to prevent damage to the MFP chips if one of these pins is mis-used.

## Power
The complete RCBus system can be powered from the 5V pin of one of the USB-TTL serial connectors by fitting a jumper in place on the appropriate pins of J3.

Note that there is a current limit of 500mA - imposed by the host system USB hardware - when the system is powered this way. It is relatively easy to exceed this limit once several boards are in use and I recommend that the system be powered from an external 5V supply connected to the RCBus backplane instead.

# Board Assembly
Assembly of the board should be fairly straightforward as there are no surface mount devices to deal with.

If you choose have a turned pin socket for the system clock, then an 8-pin DIL turned pin socket can be used. I flipped the socket over - pins pointing upwards - and easily pushed out pins 2,3,6 & 7.

When fitting the 80-pin right angle connector, initially only solder a couple of pins at opposite ends of the connector so that you can make any adjustments if the board is not vertical when fitted to the backplane.

Note the orientation of the two MFP chips - they are effectively upside down.

# Jumpers
+ J2: Specify the interupt line to be shared by the MFP chips
  + 1-2 : use /INT1
  + 3-4 : use /INT2
  + 5-6 : use /INT5
  + 7-8 : use /INT6 
+ J3: (**only fit one jumper** if not using an external 5V power source)
  + 1-2 : Power the system from the USB-TTL Serial board on Serial #1
  + 2-3 : Power the system from the USB-TTL Serial board on Serial #2
+ J4: I/O pins for both MFP chips - refer to schematic
+ J5: Timer A, B & C outputs for both MFP chips - refer to schematic
+ J6: Specify the clock source
  + 1-3 Use the onboard clock source
  + 1-2 Use the RCBus clock source from CLOCK2
  + 1-2 *and* 3-4: Use the onboard clock source and supply the RCBus CLOCK2 signal with the clock.
+ J7: Serial #1 port
+ J8: Serial #2 port
+ J9 (with J12): Specify the IO Address for MFP chip A
+ J11 (with J12): Specify the IO Address for MFP chip B
+ J12: IO Address selection
  + $D10000
  + $D10800
  + $D11000
  + $D11800
  + $D12000
  + $D12800
  + $D13000
  + $D13800
+ J14: Timer A & B inputs - refer to schematic

# Caution
Pay attention to the orientation of the chips on this board.

# Errors
None so far.

# Thoughts / Enhancements
+ Should the MFPs each have their own choice of interrupt level?

# To Do
+ Experiment to find the maximum width of board that JLCPCB will accept to keep the low price.
+ Modify the RCBus80 medium board footprint in Kicad so that pins 1,40,41 & 80 don't throw DRC warnings/errors.


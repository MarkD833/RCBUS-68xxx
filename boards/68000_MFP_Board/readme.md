![](../../images/MFP_Front.JPG)
# Caution
Pay attention to the orientation of the chips on this board.

# Notes
- MFP Clock
  + The clock - X1 in the schematic - should be 3.6864MHz

# Jumpers
+ J2: Specify the interupt line to be used by the MFP chips
+ J3: Connect the 5v from Ser1 or Ser2 to the RCBus 5v line
+ J6: Specify the clock source
  + 1&3 Use the onboard clock source
  + 1&2 Use the RCBus clock source from CLOCK2
  + 1&2 *and* 3&4: Use the onboard clock source and supply the RCBus CLOCK2 signal with the clock.
+ J12: IO Address selection
  + D10000
  + D10800
  + D11000
  + D11800
  + D12000
  + D12800
  + D13000
  + D13800
+ J9 (with J12): Specify the IO Address for MFP chip A
+ J11 (with J12): Specify the IO Address for MFP chip B

# Thoughts
+ Should the MFPs each have their own choice of interrupt level?

# To Do
+ Experiment to find the maximum width of board that JLCPCB will accept to keep the
  low price.
+ Modify the RCBus80 medium board footprint in Kicad so that pins 1,40,41 & 80 don't
  throw DRC warnings/errors.






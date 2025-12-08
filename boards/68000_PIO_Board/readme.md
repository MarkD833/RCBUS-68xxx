![](../../images/PIO_Front.JPG)
# Reliability
For some reason that I can't yet figure out, the 68230 board is very unreliable. The issue seems to be with the write timing as the chips always report the correct port pin levels during a read of the alternate data registers.

I've tried 68230s from ST and Mostek with a simple test program with the timer configured to output a square wave on PC3 whilst also toggling pin PA0 in software. I'm getting all combinations of results from no pin activity, only PA0 toggles, only PC3 toggles and both PA0 and PC3 toggling.

I know the code works as a PLCC 68230 (Freescale badged) on another 68000 system I have works correctly.

# Notes
+ The 68230 needs a clock signal in order to function correctly, even if the timer is not being used. Set J2 and J6 for your choice of clock source.

# Jumpers
+ J2: Select RCBus CLOCK or CLOCK2 for PI/T #1 clock source
+ J6: Select RCBus CLOCK or CLOCK2 for PI/T #2 clock source
+ J7: IO Address selection
  + D08000
  + D08800
  + D09000
  + D09800
  + D0A000
  + D0A800
  + D0B000
  + D0B800
+ J8: Select the interrupt line for PI/T #1 timer interrupt
+ J9: Select the interrupt line for PI/T #1 port interrupt
+ J10: Select the interrupt line for PI/T #2 timer interrupt
+ J11: Select the interrupt line for PI/T #2 port interrupt
+ J12 (with J7): Specify the IO Address for PI/T chip #1
+ J13 (with J7): Specify the IO Address for PI/T chip #2

# Errors
+ The 68230 chip select has to include one of the /nDS signals not just /AS. Fix by cutting the /AS track between RCBus pin 41 and the 74LS688 pin 1. Add a wire link between RCBus pin 43 (/LDS) and the 74LS688 pin 1.



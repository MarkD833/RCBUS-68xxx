NOTE:
For some reason that I can't yet figure out, the 68230 board is very unreliable. The issue seems to be with the write timing as the chips always report the correct port pin levels during a read of the alternate data registers.

I've tried 68230s from ST and Mostek with a simple test program with the timer configured to output a square wave on PC3 whilst also toggling pin PA0 in software. I'm getting all combinations of results from no pin activity, only PA0 toggles, only PC3 toggles and both PA0 and PC3 toggling.

I know the code works as a PLCC 68230 (Freescale badged) on another 68000 system I have works correctly.

 
* The 68230 chip select has to include one of the /nDS signals not just /AS.
  Fix by cutting the /AS track between RCBus pin 41 and the 74LS688 pin 1.
  Add a wire link between RCBus pin 43 (/LDS) and the 74LS688 pin 1.



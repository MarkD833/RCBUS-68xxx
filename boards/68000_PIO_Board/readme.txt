* The 68230 chip select has to include one of the /nDS signals not just /AS.
  Fix by cutting the /AS track between RCBus pin 41 and the 74LS688 pin 1.
  Add a wire link between RCBus pin 43 (/LDS) and the 74LS688 pin 1.


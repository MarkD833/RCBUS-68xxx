R/W Signal:
===========
The 68681 doesn't like R/W changing after /CS goes low. The internal FIFO
pointers (RX only?) get messed up and phantom characters appear. 

Disconnect 68681 R/W signal (pin 8) from RCBus pin 24.
Connect 68681 R/W signal (pin 8) to RCBus pin 35 (temporary fix).

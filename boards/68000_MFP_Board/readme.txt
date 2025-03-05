+ Should the MFPs each have their own choice of interrupt level?

R/W Signal:
===========
Following issues with R/W on the 68681, modify as follows just in case:
+ Disconnect 68901 R/W signal (pin 1) from RCBus pin 24.
+ Connect 68901 R/W signal (pin 1) to RCBus pin 35 (temporary fix).

J6 - Clock source jumper:
=========================
Silkscreen pin numbers missing.

74LS138 - Pin 6 unconnected:
============================
Connect pin 6 to +5V for now.

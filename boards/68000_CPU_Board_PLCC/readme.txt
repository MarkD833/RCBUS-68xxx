DTACK Circuit:
==============
Silkscreen: It's 1,2,3 or 4 clocks NOT 2,4,8 or 16!

RCBus /RD & /WR signals:
========================
Possibly don't use /UDS or /LDS to gate the /RD or /WR signals.
Disconnect U4-8 from U5-13.
Connect U5-13 to +5V.

68000 R/W signal:
=================
This needs to go on the backplane as the 68681 needs the R/W signal
set before /CS is active.
Connect 68000 R/W signal (pin 9) to RCBus pin 35 (temporary fix).

# Note
- CPU Clock
  + The clock - X1 in the schematic - can be anything up to the max clock of your 68000.  I'm using a 7.3728MHz clock but an 18.432MHz clock works with my 20MHz 68HC000. Any faster clock and there are likely to be issues with the timing of the EEPROMs and RAM chips - depending on the access times of your particular devices.
- Error
  + MREQ & IORQ Activity LEDs - The silkscreen labels I/O & MEM are the wrong way round!
  + Missing 4K7 pullup on the M1 signal - wire link M1 to a spare pin on RN1.
- Physical Board
  + Experiment to find the maximum width of board that JLCPCB will accept to keep the low price.
  + Modify the RCBus80 medium board footprint in Kicad so that pins 1,40,41 & 80 don't throw DRC warnings/errors.
- CPU Insertion
  + Make sure you orientate the CPU the correct way. It can be easy to miss the notches on CPU and sockets
    ![](../../images/Bad_CPU_Insertion.JPG)
    ![](../../images/Good_CPU_Insertion.JPG):

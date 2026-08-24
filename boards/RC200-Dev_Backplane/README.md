# RCBus-80 Developers Backplane

Initial testing with Steve Cousins SC108 CPU board and SC110 serial & timer board.

![](../../images/RC200_1.JPG)

# Details
This is the current build state of an RCBus-80 backplane that I've been working on. In the past I have used Steve Cousins SC701 6-slot  backplanes for my boards. However, I found that at 6 slots, I might run out slots. A 12 slot board would be too big for my bench and I don't have the psychological strength to contemplate soldering 12 80-pin connectors.

I had a chat with Steve to get his approval for me to take his SC701 backplane design and alter it for my own needs.

This backplane I've put together has 2 additional slots - making 8 in total. It also incorporates parts of Steve's SC129 digital I/O board to give 8 debug LEDs and 8 tactile pushbuttons. I also incorporated his SC729 CompactFlash module as well.

The downside is that there is no expansion RCBus-80 connector to extend the bus further.

Initial testing with my Z80 boards is looking good. I can boot CP/M off the CompactFlash card and the LEDs light up in sequence as part of Steve's SC108 Z80 CPU boot up.


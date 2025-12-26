# TMS9918A

The code in this folder is my port of J B Langston's code (for the original TMS9918A chip) to run on my RCBus-68000 with [Shiela Dixon's TMSEMU](https://peacockmedia.software/RC2014/TMSEMU/) graphics module.

The ASCII font demo is the simplest. It needed quite a few of the TMS library routines to be ported to 68K assembler in order to get it to work correctly. It demonstrates the loading of a font and then displaying all 256 characters of that font.

The Nyan Cat demo was quite straightforward to port as almost all the TMS library routines had already been ported as part of the ASCII font demo. This demonstrates repeated cycling through a set of bitmaps on order to produce an animation of sorts.

The sprites demo adds more functionality to the TMS library and should show a spinning globe bouncing off the screen edges.

The code can be assembled using EASy68K.


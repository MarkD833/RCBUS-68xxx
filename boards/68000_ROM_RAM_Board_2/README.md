![](../../images/ROM_RAM_v2_Front.JPG)
=======
+ The signals /RAM_CS and /ROM_CS don't go anywhere!
+ /RAM_CS should be called /CS_BANK0 & /ROM_CS should be called /CS_BANK1
  + Fix by connecting LS125 pin 1 to either pin 22 of bank 1 ICs & adding a 10K pullup resistor.
  + Fix by connecting LS125 pin 4 to either pin 22 of bank 2 ICs & adding a 10K pullup resistor.
+ J4 & J5 at the top of U7 are not on a 0.1in pitch.



# 68000 Processor Board (Series 2)

Actual image of the processor board under test.

![](../../images/RC201-68000_CPU_VI_Board_v2_Real.png)

# Details
This is my newer 68000 CPU board that will hopefully support a mixture of vectored and autovectored interrupts. I've redesigned it to avoid the use of a CPLD and will shortly be sending the board files off to JLCPCB.

The board has arrived and is undergoing testing. However, due to an oversimplification in the design, the vectored interrupts are not working as expected.

I forget that during the request for the interrupt vector from the peripheral device, that the 68000 sets address lines A4..A23 to a '1'. In the current design, this activates the /IORQ memory space and a subsequent /DTACK which interferes with the /DTACK signal from the peripheral when it has placed the interrupt vector number onto the data bus.

A simple work around is to pull the 74HCT125 so that the onboard /DTACK signal cannot be generated for an /MREQ or /IORQ access on the RCBus. The downside being that I can't access any of Steve Cousins RCBus boards till a fix is implemented. 

I have an updated board which is currently being manufactured at JLCPCB.

# RCBUS MC68302 Simple Monitor

This folder contains the simple monitor program I created to support my RCBus 68302 system. The 68302 monitor uses the internal Serial Comms Controllers (SCCs) and is not compatible with my 68000 board although the same commands have been implemented.

I wanted a simple monitor that supported a few basic commands. This monitor was originally written for my 68008 board and then modified for my 68302 board before being modified again to support my RCBus 68302 board. None of the commands support any use of cursor keys or the backspace/delete keys.

The monitor operates at 38400 baud without any handshaking via SCC1.

There are now two versions of the monitor program.

## The original monitor (rcMON68302_v0.2) 
This is my original version of the monitor and it supports both CP/M-68K and EhBASIC which are separate applications that need to be programmed into the ROMs. The ROMs are mapped starting at address 0x000000.

## The ROM/RAM swapping monitor (rcMON68302_sw_v1.0)
This version of the monitor utilises the MC68302 chip select hardware and signals /CS0 and /CS1. /CS0 selects the ROM chips and /CS1 selects the RAM chips.

Note that CP/M-68K and EhBASIC have been dropped from this version of the monitor.

The monitor has been tested with a modified ROM/RAM v2 board. This version of MON302 will boot with ROM at address 0x000000. It will then map the RAM starting at address 0x000000 and move the ROM up to address 0x600000.

In order to use this version of the monitor, a few hardware changes need to be made to the ROM/RAM v2 as follows:
  + U1 (74LS125) should be removed as the 68302 is configured to generate the /DTACK signals for /CS0 and /CS1 itself
  + U5 (74LS138) should be removed as the 68302 is configured to generate the chip select signals itself
  + A wire link inserted between pin J1-45 and any pin on J11 - this is /CS0 for the ROMs
  + A wire link inserted between pin J1-46 and any pin on J12 - this is /CS1 for the RAMs

Although not tested, this version of the monitor should also work with the original ROM/RAM board with the following changes:
  + U1 (74LS125) should be removed as the 68302 is configured to generate the /DTACK signals for /CS0 and /CS1 itself
  + U5 (74LS138) should be removed as the 68302 is configured to generate the chip select signals itself
  + A wire link inserted between pin J2-45 and pin U8-15 - this is /CS0 for the ROMs
  + A wire link inserted between pin J2-46 and pin U8-14 - this is /CS1 for the RAMs
  
# Commands
There a few basic commands that the monitor understands as follows:

## B (v0.2 only)

Boots the embedded EhBASIC v3.54 from the ROM. It will check that EhBASIC is programmed into the ROM first. I need to provide a write-up on how to include EhBASIC and/or a ROM image that already includes it.

## C (v0.2 only)

Boots the embedded CP/M-68K v1.3 from the ROM. It will check that CP/M and the BIOS are programmed into the ROM first. I need to provide a write-up on how to include CP/M-68K and/or a ROM image that already includes it.

The CP/M68K v1.3 BIOS uses Steve Cousin's SC145 (or SC729) CompactFlash module to provide disk drives for CP/M. Please see the readme in the CP/M-68K code folder for more details.
 
## Dnnnn

Displays a block of 256 bytes starting at address nnnn. The address is in hexadecimal and can be any address from 0x00000000 to 0xFFFFFFFF. Any printable ASCII characters are also displayed to aid in showing text strings etc.

The command doesn't support going forwards or backwards in 256 byte pages or any other variations. To display the next 256 bytes, issue another D command.

## Gnnnn

Executes the code starting at address nnnn. The address is in hexadecimal and can be any address from 0x00000000 to 0xFFFFFFFF.

If the user code does return to the monitor, then a message is displayed to show that this has happened. No registers are saved prior to executing the user code and correct operation of the monitor is not guaranteed.

## Iaa

Displays the 8-bit value at address aa in IO space. Address aa is an address between 0x00 and 0xFF. This command will activate the /IORQ signal on the RCBus. Similar to the Z80 IN instruction.

The monitor takes care of the mapping of the requested address into 68000 memory space.

## Mnnnn

Modifies a byte of memory starting at address nnnn. The address is in hexadecimal and can be any address from 0x00000000 to 0xFFFFFFFF.

Once the byte has been entered, the next address is displayed to enable alteration of that address.

The command doesn't support going forwards or backwards or editing memory as 16-bit words or 32-bit long words.

## Oaabb

Writes the 8-bit value bb to address aa in IO space. Both the address and the value are 8-bit hexadecimal numbers between 0x00 and 0xFF. This command will activate the /IORQ signal on the RCBus. Similar to the Z80 OUT instruction.

The monitor takes care of the mapping of the requested address into 68000 memory space.

## S1 / S2

These commands are not entered directly by the user. They are detected by the monitor when Motorola S-records are transferred via a serial terminal program such as RealTerm. Each S-record is treated individually and is written to memory as it is received.

There is no need to initiate a download from the monitor by entering a command as the monitor will detect any lines beginning with an S and try and interpret them as Motorola S-records.
 
As user memory starts at address 0x100000 on my RCBus 68000, all S-records will be S2 records.

## ?

Simply displays the list of available commands that the monitor supports.


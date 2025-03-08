# RCBUS MC68000 Software

This folder cotains the software that I've either developed myself or ported to my RCBus 68000 board(s).

| Code | Description |
| :---- | :---- |
| [MON68K](#68000-monitor) | My simple monitor program for my RCBus 68000. |
| [SC129](#sc129) | SC129 digital i/o module. |

---

# 68000 monitor

I wanted a simple monitor that supported a few simple commands. This monitor was originally written for my 68008 board and then modified for my 68302 board before being modified again to support my RCBus 68000 board.

There a few basic commands that the monitor understands as follows:

## Dnnnn

Displays a block of 256 bytes starting at address nnnn. The address is in hexaddecimal and can be any address from 0x00000000 to 0xFFFFFFFF. Any printable ASCII characters are also displayed to aid in showing text strings etc.

The command doesn't support going forwards or backwards in 256 byte pages or any other variations. To display the next 256 bytes, issue another D command.

## Gnnnn

Executres the code starting at address nnnn. The address is in hexaddecimal and can be any address from 0x00000000 to 0xFFFFFFFF.

Once the code is executing, there isn't a way back into the monitor, except by pressing the reset button on the RCBus backplane.

## Iaa

Displays the 8-bit value at address aa in IO space. Address aa is an address between 0x00 and 0xFF. This command will activate the /IORQ signal on the RCBus.

The monitor takes care of the mapping of the requested address into 68000 memory space.

## Mnnnn

Modifies a byte of memory starting at address nnnn. The address is in hexaddecimal and can be any address from 0x00000000 to 0xFFFFFFFF.

Once the byte has been entered, the next address is displayed to enable alteration of that address.

The command doesn't support going forwards or backwards or editing memory as 16-bit words or 32-bit long words.

## Oaabb

Writes the 8-bit value bb to address aa in IO space. Both the address and the value are 8-bit hexadecimal numbers between 0x00 and 0xFF. This command will activate the /IORQ signal on the RCBus.

The monitor takes care of the mapping of the requested address into 68000 memory space.

## S1 / S2

These commands are not entered directly by the user. They are detected by the monitor when Motorola S-records are transferred to it from a serial terminal program such as RealTerm. Each S-record is treated individually and is written to memory as it is received.

There is no need to initiate a download from the monitor by entering a command as the monitor will detect any lines beginning with an S and try and interpret them as Motorola S-records.
 
As user memory starts at address 0x100000 on my RCBus 68000, all S-records will be S2 records.

## ?

Simply displays the list of available commands that the monitor supports.

---

# SC129 digital I/O module

The code in this folder provides 2 simple demonstrations to exercise the [SC129](https://smallcomputercentral.com/rcbus/sc100-series/sc129-digital-i-o-rc2014/) digital I/O module.

The first program is count.x68 and it simply counts up in binary on the 8 LEDs on the output port of the SC129 board.

The second prgram is echo.x68 and it simply reads the 8 bits on the input port and then echoes them back out on the 8 bits of the output port of the SC129 board.

Both programs assume that the SC129 has been configured for the default address of 0x00. 


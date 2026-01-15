# RCBUS MC68000 Simple Monitor

This folder contains the simple monitor program I created to support my RCBus 6800 system. The 68000 monitor uses the SIO board for its serial comms and is not compatible with my 68302 board although the same commands have been implemented.

# CP/M-68K
As of MON68K v1.4 the ability to boot CP/M-68K from ROM has been removed as there was limited interest in CP/M-68K and few applications available for it.

I have left MON68K v1.3 available as it is the last version that supports both CP/M-68K and EhBASIC which are separate applications that need to be programmed into the ROMs.

# Serial Communications
## MON68K v1.3
The monitor assumes that there is an MC68681 DUART present at address $D00000. The DUART serial port #1 operates at 38400,8,N,1 with no hardware flow control.

## MON68K v1.4
The monitor assumes that there is an MC68681 (or compatible) DUART present at address $D00000. The baud rate is determeined by the setting of HI_SPEED in the MON68K source code.
+ Setting HI_SPEED = 0 puts the DUART into normal operation mode and 38400 baud. 
+ Setting HI_SPEED = 1 puts the DUART into a test mode where 115200 baud is achieved.

**Note:** 115200 baud can only be achieved when using a DUART that supports the test mode - i.e. one of the Philips devices.

When operating the DUART in the test mode at 115200 buad, RTS/CTS hardware flow control is required. In order to use hardware flow control, the solder jumper JP2 on the rear of the SIO board needs to be bridged to allow the DUART OP0 signal to control the CTS signal.

Hardware flow control is now used regardless of the baud rate.

**Note:** The serial routines are now interrupt driven and require the IRQ2 jumper to be fitted on the SIO board.

# Commands
I wanted a simple monitor that supported a few basic commands. None of the commands support any use of cursor keys or the backspace/delete keys.

Th basic commands that the monitor understands are as follows:

## B

Boots the embedded EhBASIC v3.54 from the ROM. It will check that EhBASIC is programmed into the ROM first. I need to provide a write-up on how to include EhBASIC and/or a ROM image that already includes it.

## C (v1.3 only)

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


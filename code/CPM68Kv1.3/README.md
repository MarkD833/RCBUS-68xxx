# RCBUS MC68000 CP/M-68K v1.3

This folder cotains the various files for CP/M-68K v1.3 on my RCBus 68000 system.

---

# BIOS_JMP (jump)

This code is only needed when tweaking & testing the CP/M BIOS. It allows the BIOS to be downloaded into RAM whilst testing to save constantly programming the EEPROMs!
  
This is a very simple piece of assembler code that places a jump instruction at address $6000 in ROM. It jumps to address $F10000 where the BIOS under test gets loaded to.

# BIOS

This is my BIOS for CP/M-68K v1.3. I've included a lot of comments in the code to remind me of what is gong on. Hopefully it will be of use to you too.

The value of DEBUG can be changed from 0 (normal) to 1 (debug). If it is set to 1, the BIOS will use Serial #2 @ 115200 baud to output diagnostic information relating to the CompactFlash CP/M filesystem such as drive number, track number, sector number, CompactFlash Logical Block Address and the contents of the 128 byte CP/M sector. 

The BIOS works with the RAM based exception vector table that the monitor has already set up.

Note that if you are modifying the BIOS in RAM, then you need to change the address of INIT_ENTRY to match the RAM address in the BIOS_JMP code. You also need to alter the length of the memory region to reduce the size of the transient program area (TPA) so that CP/M-68K doesn't trash the RAM BIOS.

Initially the BIOS would work correctly as long as it was in debug mode (i.e. printing out lots of debug information). As soon as debug mode was turned off, then issues started to appear when using PIP to transfer files from drive A to drive B. PIP would generate the error "ERROR: CLOSE FILE - {filename}" and frequently the directory information would become corrupted.

I never discovered exactly what was causing this but after a complete rewrite of the BIOS read and write code, I didn't see this error again.
 
# CP/M-68K v1.3

CP/M-68K v1.3 and the BDOS are both contained within the CPM400-1FD800.S68 file.

CP/M-68K resides at address $400 onwards within my EEPROM - BUT IT IS NOT the CPM400 file that was supplied on distribution disk #9. The CPM400 supplied in the official distribution has been badly built in that the private variables that the CCP & BDOS use reside within the same memory space that the hardware specific BIOS would - i.e. address $6000 onwards. 

This version of CP/M-68K has been rebuilt so that the internal variables now reside at the top of RAM at address $1FD800 onwards. I've also included the linker map file showing the actual memory locations of the variables in case it is of interest.

# CP/M-68K filesystem

This BIOS supports 8 drives hosted on the one CompactFlash card. Each drive is configured to be 8Mb (8,388,608 bytes) in size, requiring at least a 64Mb CompactFlash card.

The drive contents were created using CPMTOOLS. The diskdefs entry I created looks like this:

```
diskdef M68K_1024SPT
  seclen 128
  tracks 64
  sectrk 1024
  blocksize 4096
  maxdir 512
  skew 0
  boottrk 0
end
```
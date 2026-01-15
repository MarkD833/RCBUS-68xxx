*******************************************************************************
* RCBus MC68000 Memory Map - No CP/M-68K - for rcMON68Kv1.4
*******************************************************************************
*    #     # ####### #     # ####### ######  #     # 
*    ##   ## #       ##   ## #     # #     #  #   #  
*    # # # # #       # # # # #     # #     #   # #   
*    #  #  # #####   #  #  # #     # ######     #    
*    #     # #       #     # #     # #   #      #    
*    #     # #       #     # #     # #    #     #    
*    #     # ####### #     # ####### #     #    #    v2
*******************************************************************************
* This file holds the memory layout information for my RCBus MC68000 processor
* board.
*
* ROM : 128K organised as 64K  x 16bits (2x W27C512 EEPROM)
* RAM : 1M   organised as 512K x 16bits (2x AS6C4008)
*
* ROM starts at 0x000000 up to 0x01FFFF (128K)
* RAM starts at 0x100000 up to 0x1FFFFF (1M)
*
* Use EASyBIN to split the S-Record into ODD and EVEN bytes.
* The *_0.BIN file goes in the U ROM socket - holding D08..D15
* The *_1.BIN file goes in the L ROM socket - holding D00..D07
*******************************************************************************
* The memory map looks like this:
*
* +--------------------+ <- $00000000 (Start of ROM)
* | ROM Exception      |
* | Vector Table       |
* +--------------------+ <- $00000400
* | EhBASIC            |
* +--------------------+ <- $00004000
* | rcMON68K           |
* +--------------------+
* .                    .
* +--------------------+ <- $0001FFFF (End of ROM)
* .                    .
* .                    .
* .                    .
* +--------------------+ <- $00100000 (Start of RAM)
* | RAM Exception      |
* | Vector Table       |
* +--------------------+ <- $00100400
* | Free RAM           |
* +--------------------+
* .                    .
* +--------------------+
* | Stack              |
* +--------------------+ <- $001FF800
* | rcMON Variables    |
* +--------------------+ <- $001FFFFF (End of RAM)
*
*******************************************************************************

*******************************************************************************
* MON_BASE is the start address in ROM for the simple ROM monitor program.
*
MON_BASE		EQU		$4000

*******************************************************************************
* EHBASIC_BASE is the start address in ROM for EhBASIC.
*
EHBASIC_BASE	EQU		$0400

*******************************************************************************
* RAM_BASE is the start address of the RAM and is hardware configured for
* address $100000. There's 1Mb RAM fitted so RAM_LEN is set to $100000.
*
RAM_BASE		EQU		$100000
RAM_LEN			EQU		$100000

*******************************************************************************
* VEC_BASE is the start address in RAM for the RAM based MC68000 exception
* vector table. It's normally set to RAM_BASE (i.e. start of RAM).
*
VEC_BASE		EQU		RAM_BASE
VEC_SIZE		EQU     $400         * table takes up 1024 bytes

*******************************************************************************
* IO_BASE is the start address of a block of memory in MC68000 memory space
* that maps onto the RCBus 256 byte IO space. Accessing this memory will
* generate an /IORQ on the RCBus.
* 
IO_BASE			EQU		$F80000		* I/O space base address = 00F8_0000

*******************************************************************************
* MEM_BASE is the start address of a block of memory in MC68000 memory space
* that maps onto the RCBus 64K Memory space. Accessing this memory will
* generate an /MREQ on the RCBus.
* 
MEM_BASE		EQU		$F00000		* Mem space base address = 00F0_0000

*******************************************************************************
* MON_PRIV is a block of RAM for the monitor to use to store any private
* variables. It's currently set to be 2048 bytes.
*
MON_PRIV		EQU     2048

*******************************************************************************
* STACK_START is the initial stack start address and is set to be just below
* the monitor private variables area. The stack will grow downwards from this
* address.
*
STACK_START		EQU		RAM_BASE+RAM_LEN-MON_PRIV


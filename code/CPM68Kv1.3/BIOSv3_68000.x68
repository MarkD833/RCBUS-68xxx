*****************************************************************
*                                                               *
*                 CP/M-68K BIOS                                 *
*       Basic Input/Output Subsystem v1.0                       *
*           For my RCBus 68000 board                            *
*             CompactFlash Version                              *
*                                                               *
*****************************************************************
* This code is based on the code in ERGBIOS.S on disk #7.
*****************************************************************
* NOTE: The CPM400.S68 on disk #9 should not be used as the 
* addresses for the RAM variables clash with the BIOS.
*
* My new build CPM400 occupies addresses $0400..$5276 (approx).
*
* For my CPM400, _init is defined as $6000 in the MAP file.
*****************************************************************
* This code is configured so it can be assembled using EASY68K.
* Assumes at least a 64Mb CompactFlash card as BIOS assumes 8
* drives (A..H), each of 8Mb.
*****************************************************************

*****************************************************************
* Define some memory sizes etc
*
RAM_BASE    EQU     $100000       * RAM base addr = 0010_0000
RAM_LEN     EQU     $100000       * 1M RAM fitted
MON_PRIV    EQU     2048          * Reserve 2K at the top of RAM for monitor
BIOS_PRIV   EQU     4096          * Reserve 4K at the top of RAM for this BIOS
CCP_PRIV    EQU     4096          * Reserve 4K at the top of RAM for CCP & BDOS
IO_BASE     EQU     $F00000       * RCBus I/O space base addr = 00F0_0000

*****************************************************************
* The location for _ccp comes from the CPM400.MAP file and it is
* hard coded to $04BC.
* 
CCP_ENTRY   EQU     $04BC         * ccp entry point

*****************************************************************
* The location for _init comes from the CPM400.MAP file and it
* is hard coded to $6000
* Only change this address if you are using the dummy BIOS and
* change INIT_ENTRY to match the address in the BIOS stub file.
*
INIT_ENTRY  EQU     $6000         * BIOS init entry point
*INIT_ENTRY  EQU     $1F0000       * RAM BIOS init entry point

*****************************************************************
* The location of the exception vector table placed in RAM by the
* monitor program. Currently the start of RAM.
*
VEC_BASE    EQU     RAM_BASE      * Exception vectors table in RAM
VEC_SIZE    EQU     $400          * table takes up 1024 bytes

*****************************************************************
* These addresses are as configured on the individual boards in
* what would be the Z80 8-bit I/O space.
*
SC145ADDR   EQU     $10           * SC145 base address is 0x10
DUARTADDR   EQU     $C0           * 68681 base address is 0xC0

*****************************************************************
* These are the same addresses converted into 68000 memory space
*
SC145       EQU     IO_BASE+(SC145ADDR<<1)
DUART       EQU     IO_BASE+(DUARTADDR<<1)

*****************************************************************
* Set DEBUG to a 1 to enable serial port B on the SCC68692. Any
* disk, sector or track changes will be output along with the
* calculated CompactFlash LBA for each read or write.
*
DEBUG       EQU     0

*****************************************************************
* SCC68692 Duart Register Addresses
* DUART 8-bit data is on D0..D7 - i.e. the odd addresses
*
MRA         EQU DUART+1           * Mode Register A             (R/W)
SRA         EQU DUART+3           * Status Register A           (R)
CSRA        EQU DUART+3           * Clock Select Register A     (W)
CRA         EQU DUART+5           * Commands Register A         (W)
RBA         EQU DUART+7           * Receiver Buffer A           (R)
TBA         EQU DUART+7           * Transmitter Buffer A        (W)
ACR         EQU DUART+9           * Aux. Control Register       (R/W)
ISR         EQU DUART+11          * Interrupt Status Register   (R)
IMR         EQU DUART+11          * Interrupt Mask Register     (W)
MRB         EQU DUART+17          * Mode Register B             (R/W)
SRB         EQU DUART+19          * Status Register B           (R)
CSRB        EQU DUART+19          * Clock Select Register B     (W)
CRB         EQU DUART+21          * Commands Register B         (W)
RBB         EQU DUART+23          * Reciever Buffer B           (R)
TBB         EQU DUART+23          * Transmitter Buffer B        (W)
IVR         EQU DUART+25          * Interrupt Vector Register   (R/W)
IPR         EQU DUART+27          * Input Port Register         (R)
OPCR        EQU DUART+27          * Output Port Config Register (W)
BCNT        EQU DUART+29          * Start Counter               (R)
SOPR        EQU DUART+29          * Set Output Port Register    (W)
ECNT        EQU DUART+31          * Stop Counter                (R)
ROPR        EQU DUART+31          * Reset Output Port Register  (W)

*****************************************************************
* CompactFlash register addresses
* CF 8-bit data is on D0..D7 - i.e. the odd addresses
*
CF_DATA	    EQU SC145+1           * Data               (R/W)
CF_FEATURES EQU SC145+3           * Features           (W)
CF_ERROR    EQU SC145+3           * Error              (R)
CF_SECCOUNT EQU SC145+5           * Sector Count       (R/W)
CF_SECTOR   EQU SC145+7           * Sector Number      (R/W)
CF_CYL_LOW  EQU SC145+9           * Cylinder Low Byte  (R/W) 
CF_CYL_HI   EQU SC145+11          * Cylinder High Byte (R/W)
CF_HEAD     EQU SC145+13          * Drive / Head       (R/W)
CF_STATUS   EQU SC145+15          * Status             (R)
CF_COMMAND  EQU SC145+15          * Command            (W)
*
* CompactFlash Logical Block Address registers
*
CF_LBA0007  EQU SC145+7           * LBA bits 07..00    (R/W)
CF_LBA0815  EQU SC145+9           * LBA bits 15..08    (R/W)
CF_LBA1623  EQU SC145+11          * LBA bits 23..16    (R/W)
CF_LBA2427  EQU SC145+13          * LBA bits 27..24    (R/W)

*****************************************************************
* CompactFlash Features
*
CF_8BIT		EQU	1
CF_NOCACHE	EQU	$82

*****************************************************************
* CompactFlash Commands
*
CF_RD_SEC   EQU $20               * Read Sector Command
CF_WR_SEC   EQU $30               * Write Sector Command
CF_SET_FEAT EQU $EF               * Set Feature Command
CF_LBAMODE  EQU $E0               * LBA mode

*****************************************************************
* Define the maximum number of drives supported
*
MAXDISK     EQU    8              * this BIOS supports 8 drives

*****************************************************************
* CP/M-68K will jump to this code to setup the hardware etc.
* The start of this code has to be at a specific memory location.
*
    org     INIT_ENTRY            * bios initialization entry point
_init:
    move.b  #0,IMR                * disable DUART interrupts
    move.w  #$2700,sr             * disable all interrupts

    ifne DEBUG
        bsr.w   SerBInit
        movea.l #strBanner, a0         * Show the debugger string
        bsr.w   putString    
    endc

    * put CompactFlash into 8-bit mode
    bsr.w   cfBusy
    move.b  #CF_8BIT,CF_FEATURES
    move.b  #CF_SET_FEAT,CF_COMMAND

    * disable the CompactFlash cache
    bsr.w    cfBusy
    move.b  #CF_NOCACHE,CF_FEATURES
    move.b  #CF_SET_FEAT,CF_COMMAND

    * display our own CP/M-68K banner as CP/M-68K doesn't do this itself
    movea.l #strCPMBanner,a0
.loop:
    move.b  (a0)+, d1             * Get character
    beq.s   .end                  * Check for the null
    
    bsr.w   conout                * Otherwise write the character
    bra.s   .loop                 * And continue
.end:    	

    * copy the disk parameter headers from ROM to RAM as CP/M-68K
    * writes to one or more scratchpad words in the DPH
    movea.l #dph0,a0
    movea.l #rdph0,a1
    move.w  #dphlen*MAXDISK-1,d0
.dphcopy:
    move.b  (a0)+,(a1)+
    dbra    d0,.dphcopy	
	
    move.b  #-1,seldrv            * set the selected drive to invalid value
    move.l  #-1,bufferLBA         * set the 512 byte buffer LBA to invalid value
    move.b  #0,writeFlag          * clear the write flag
	
    * Insert the TRAP #3 handler address into the RAM vector table
    move.l  #traphnd3,VEC_BASE+$8c
    clr.l   d0                    * log on disk A, user 0
    rts
	
	
*****************************************************************
* TRAP #3 exception handler routine
*****************************************************************	
traphnd3:
    cmpi    #nfuncs,d0
    bcc     trapng
    lsl     #2,d0                 * multiply bios function by 4
* EASy68K doesn't understand the following instruction:
*    movea.l    6(pc,d0),a0        * get handler address
    movea.l *+8(pc,d0),a0         * use this instruction instead
    jsr     (a0)                  * call handler
trapng:
    rte

biosbase:
    dc.l    _init
    dc.l    wboot
    dc.l    constat
    dc.l    conin
    dc.l    conout
    dc.l    lstout
    dc.l    pun
    dc.l    rdr
    dc.l    home
    dc.l    seldsk
    dc.l    settrk
    dc.l    setsec
    dc.l    setdma
    dc.l    read
    dc.l    write
    dc.l    listst
    dc.l    sectran
    dc.l    setdma
    dc.l    getseg
    dc.l    getiob
    dc.l    setiob
    dc.l    flush
    dc.l    setexc

nfuncs      EQU    (*-biosbase)/4

*****************************************************************
* BIOS FUNCTION 1 - Warm Boot
*****************************************************************
wboot:
    jmp     CCP_ENTRY

*****************************************************************
* BIOS FUNCTION 2 - Console Status
* Check for a received byte on DUART channel A
* D0 = 1 if byte available, otherwise D0 = 0
*****************************************************************
constat:
    btst.b  #0,SRA                * check RxRDYA bit
    beq     nochar                * branch if not
    moveq.l #$1,d0                * set result to true
    rts
nochar:
    clr.l   d0                    * set result to false
    rts

*****************************************************************
* BIOS FUNCTION 3 - Read Console Character
* Read a byte from DUART channel A into D0 - WILL WAIT FOR CHAR
*****************************************************************
conin:
    bsr     constat               * see if key pressed
    tst     d0
    beq     conin                 * wait until key pressed
    move.b  RBA,d0                * get the byte
    and.l   #$7f,d0               * clear all but low 7 bits
    rts

*****************************************************************
* BIOS FUNCTION 4 - Write Console Character
* Write the byte in D1 to DUART channel A
*****************************************************************
conout:
    btst.b  #2,SRA                * check TxRDYA bit
    beq     conout                * wait until DUART is ready
    move.b  d1,TBA                * and output it
    rts

*****************************************************************
* BIOS FUNCTION 5 - List Character Output
* This may be a printer but we don't have one so simply return.
*****************************************************************
lstout:
    rts

*****************************************************************
* BIOS FUNCTION 6 - Auxillary Output
* This may have been a punched paper tape or punched card writer
* but we don't have one so just return the character back in D0.
*****************************************************************
pun:
    move.w  d1,d0                 * echo the char back
    rts

*****************************************************************
* BIOS FUNCTION 7 - Auxillary Input
* This may have been a punched paper tape or punched card reader
* but we don't have one so just return EOF.
*****************************************************************
rdr:
    move.w  #$1A,d0               * Return EOF
    rts

*****************************************************************
* BIOS FUNCTION 8 - Home
* Move to track 0
*****************************************************************
home:
    clr.w   track
    rts

*****************************************************************
* BIOS FUNCTION 9 - Select Disk Drive
* The byte in D1 holds the disk drive number.
* Return 0 in D0 if max no of disks exceeded.
*****************************************************************
seldsk:    
    moveq   #0,d0
    cmp.b   #MAXDISK,d1           * valid drive number?
    bpl     selrtn                * if no, return 0 in d0
    move.b  d1,seldrv             * else, save drive number
    
    ifne DEBUG
        * display the new disk number
        move.b  #'D',d0
        bsr.w   putc    
        move.b  seldrv,d0
        bsr.w   writeByte
        bsr.w   putCRLF
    endc
    
    move.b  seldrv,d0
    mulu    #dphlen,d0
    add.l   #rdph0,d0             * point d0 at correct RAM dph table
selrtn:
    rts

*****************************************************************
* BIOS FUNCTION 10 - Set Track Number
* The word in D1 holds the track number.
* The original BIOS code only stored a byte but the System Guide
* says that a WORD is used.
*****************************************************************
settrk:
    move.w    d1,track

    ifne DEBUG
        * display the new track number
        move.b  #'T',d0
        bsr.w   putc    
        move.w  d1,d0
        bsr.w   writeWord
        bsr.w   putCRLF
    endc
    
    rts

*****************************************************************
* BIOS FUNCTION 11 - Set Sector Number
* The word in D1 holds the sector number.
* The original BIOS code only stored a byte but the System Guide
* says that a WORD is used.
*****************************************************************
setsec:
    move.w    d1,sector

    ifne DEBUG
        * display the new sector number
        move.b  #'S',d0
        bsr.w   putc    
        move.w  d1,d0
        bsr.w   writeWord
        bsr.w   putCRLF
    endc
    
    rts

*****************************************************************
* BIOS FUNCTION 12 - Set DMA Address
* D1 holds address of 128 byte memory area which may not be word
* aligned.
*****************************************************************
setdma:
    move.l  d1,dma
    rts


*****************************************************************
* BIOS FUNCTION 13 - Read 1 CP/M Sector (i.e. 128 bytes)
* Return D0 = 0 if ok, else non-zero.
*****************************************************************
read:
    movem.l d0-d2/a0-a1,-(sp)

    ifne DEBUG
        * print the READ string
        movea.l #strRead, a0    
        bsr.w   putString
    endc

    bsr.w   cfMakeLBA             * make a new LBA 

    * if the new LBA is the same as our old LBA, then we already have
	* the data in our CF buffer from a previous read
    move.l  newLBA,d1             * get the new LBA
    cmp.l   bufferLBA,d1          * compare with the buffer LBA
    beq     .noread               * if 0, then already in our 512 byte buffer

    * new LBA but has the existing buffer been modified by a write?
	btst.b  #0,writeFlag
    beq     .newread              * if 0, then buffer hasn't been written to

    * need to write out the modified 512 byte buffer first
	bsr.w   cfWriteBlock
.newread:
    bsr.w   cfReadBlock           * read a 512 byte block from the CF card 

.noread:
    * there are 4 CP/M sectors in 1 CF block so work out which
    * quarter of the CF block is needed using sector bits 0 & 1
    move.w  sector,d0             * get the CP/M sector number
    andi.l  #$0003,d0             * just bits 0 & 1 of the CP/M sector number
    asl.w   #7,d0                 * D0 = 0, 128, 256 or 384
    add.l   #cfBuffer,d0          * D0 now points to the 128 bytes needed
    move.l  d0,a0                 * A0 points to the start of the new data
    move.l  dma,a1                * A1 points to where CP/M wants the data to go

    * copy the 128 bytes into the CP/M buffer
    * MUST BE A BYTE COPY as the CP/M DMA address is not guaranteed to
    * be word aligned.
    move.w  #127,d0               * 128 bytes to copy (DBRA so always 1 less!)        
.rdCopy:
    move.b  (a0)+,(a1)+
    dbra    d0,.rdCopy

    ifne DEBUG
        move.l  dma,a0                * start of the buffer we put the data in
        move.w  #7,d2                 * 8 rows of data
.rdLoop2:
        move.w  #15,d1                * 16 bytes per row
.rdLoop3:
        move.b  (a0)+,d0              * get the byte
        bsr.w   writeByte             * print it out
        move.b  #' ',d0
        bsr.w   putc                  * followed by a space
        dbra    d1,.rdLoop3
        bsr.w   putCRLF
        dbra    d2,.rdLoop2
    endc

    movem.l (sp)+,d0-d2/a0-a1
    clr.l   d0                    * return OK status         
    rts 

*****************************************************************
* BIOS FUNCTION 14 - Write 1 CP/M Sector (i.e. 128 bytes)
* Return D0 = 0 if ok, else non-zero.
*****************************************************************
write:
    movem.l d0-d2/a0-a1,-(sp)

    ifne DEBUG
        * print the WRITE string
        movea.l #strWrite, a0    
        bsr.w   putString
    endc

    bsr.w   cfMakeLBA             * make a new LBA 

    * if the new LBA is the same as our old LBA, then we already have
	* the data in our CF buffer from a previous read
    move.l  newLBA,d1             * get the new LBA
    cmp.l   bufferLBA,d1          * compare with the buffer LBA
    beq     .noread               * if 0, then already in our 512 byte buffer

    * new LBA but has the existing buffer been modified by a write?
	btst.b  #0,writeFlag
    beq     .newread              * if 0, then buffer hasn't been written to

	bsr.w   cfWriteBlock          * write out the modified 512 byte buffer

.newread:
    bsr.w   cfReadBlock           * read a 512 byte block from the CF card 

.noread:
    * our buffer now holds 4 CP/M sectors from the CF card
    * work out which one to over write using sector bits 0 & 1
    move.w  sector,d0             * get the CP/M sector number
    andi.l  #$0003,d0             * just bits 0 & 1 of the CP/M sector number
    asl.w   #7,d0                 * D0 = 0, 128, 256 or 384
    add.l   #cfBuffer,d0          * D0 now points to the 128 bytes to overwrite
    move.l  d0,a0
    move.l  dma,a1                * A1 points to CP/M data to write

    * transfer the 128 bytes of CP/M data into our 512 byte CF buffer
    * MUST BE A BYTE COPY as the CP/M DMA address is not guaranteed to
    * be word aligned.
    move.w  #127,d0               * 128 bytes to copy (DBRA so always 1 less!)        
.wrCopy:
    move.b  (a1)+,(a0)+
    dbra    d0,.wrCopy        

    ifne DEBUG
        move.l  dma,a0                * start of the buffer we put the data in
        move.w  #7,d2                 * 8 rows of data
.wrLoop2:
        move.w  #15,d1                * 16 bytes per row
.wrLoop3:
        move.b  (a0)+,d0              * get the byte
        bsr.w   writeByte             * print it out
        move.b  #' ',d0
        bsr.w   putc                  * followed by a space
        dbra    d1,.wrLoop3
        bsr.w   putCRLF
        dbra    d2,.wrLoop2
    endc

    movem.l (sp)+,d0-d2/a0-a1
	move.b  #1,writeFlag          * set the write flag
    clr.l   d0                    * return OK status         
    rts

*****************************************************************
* BIOS FUNCTION 15 - Return the status of the LIST device
*****************************************************************
listst:
    move.b  #$FF,d0               * $FF = device ready
    rts

*****************************************************************
* BIOS FUNCTION 16 - Sector translate
* No sector translation, so simply copy D1 into D0 and return
*****************************************************************
sectran:
    move.w  d1,d0
    rts

*****************************************************************
* BIOS FUNCTION 18 - Get memory region table address
* Return the 32-bit address of the memory region table in D0
*****************************************************************
getseg:
    move.l  #memrgn,d0
    rts

*****************************************************************
* BIOS FUNCTION 19 - Get i/o mapping byte
*****************************************************************
getiob:
    rts

*****************************************************************
* BIOS FUNCTION 20 - Set i/o mapping byte
*****************************************************************
setiob:
    rts

*****************************************************************
* BIOS FUNCTION 21 - Flush buffers
*****************************************************************
flush:
    clr.l   d0                    * return successful
    rts

*****************************************************************
* BIOS FUNCTION 22 - Set exception handler address
* The word in D1 holds the exception vector number.
* The long word in D2 holds the address of the exception handler.
* On return D0 holds the address of the previous exception handler.
*****************************************************************
setexc:
    andi.l  #$FF,d1               * do only for exceptions 0 - 255
    cmpi    #47,d1
    beq     noset                 * this BIOS doesn't set Trap 15
    cmpi    #9,d1                 * or Trace
    beq     noset
    lsl     #2,d1                 * multiply exception number by 4
    addi.l  #VEC_BASE,d1          * add RAM vector base address
    movea.l d1,a0
    move.l  (a0),d0               * return old vector address in D0
    move.l  d2,(a0)               * insert new vector address
noset:
    rts
	
*****************************************************************
* Read a logical block from the CF card from the LBA held in
* newLBA into the 512-byte buffer.
*****************************************************************
cfReadBlock:
    bsr.w   cfBusy

    * write out the 32 bit LBA to the 4 LBA registers
    move.b  newLBA+3,CF_LBA0007
    move.b  newLBA+2,CF_LBA0815
    move.b  newLBA+1,CF_LBA1623
    move.b  newLBA,CF_LBA2427
    
    move.b  #1,CF_SECCOUNT        * one 512-byte CF sector to write

    move.b  #CF_RD_SEC,CF_COMMAND
    bsr.w   cfBusy
    bsr.w   cfDatReq

    * read the 512 byte CF block into our CF buffer
    move.w  #511,d0
    movea.l #cfBuffer,a0
.rdLoop:    
    move.b  CF_DATA,(a0)+
    dbra    d0,.rdLoop        

    bsr.w   cfBusy
    move.l  newLBA,bufferLBA      * update the buffer LBA
    rts

*****************************************************************
* Write the current 512-byte CF buffer to the card at the LBA
* held in bufferLBA.
*****************************************************************
cfWriteBlock:
    bsr.w   cfBusy

    * write out the 32 bit LBA to the 4 LBA registers
    move.b  bufferLBA+3,CF_LBA0007
    move.b  bufferLBA+2,CF_LBA0815
    move.b  bufferLBA+1,CF_LBA1623
    move.b  bufferLBA,CF_LBA2427
    
    move.b  #1,CF_SECCOUNT        * one 512-byte CF sector to write

    move.b  #CF_WR_SEC,CF_COMMAND
    bsr.w   cfBusy
    bsr.w   cfDatReq

    * write the 512 byte CF block from our buffer
    move.w  #511,d0
    movea.l #cfBuffer,a0
.wrLoop:    
    move.b  (a0)+,CF_DATA
    dbra    d0,.wrLoop    

    * wait for write to complete
    bsr.w   cfBusy
    move.b  #0,writeFlag          * clear the write flag
	rts
	
*****************************************************************
* The CP/M Disk, Track & Sector numbers are combined to create
* the CompactFlash Logical Block Address (LBA) as follows:
*
* | LBA3                          | LBA2                          |
* | 1 | 1 | 1 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | D3| D2|

* | LBA1                          | LBA0                          |
* | D1| D0| T5| T4| T3| T2| T1| T0| S9| S8| S7| S6| S5| S4| S3| S2|  
*
* Sector bits S0 & S1 are not used to create the CF LBA but are
* used to determine which quarter of the 512 byte CF block is
* being addressed.
*****************************************************************
* Create a CompactFlash Logical Block Address from the current
* CP/M disk, track & sector values.
* LBA is stored in newLBA.
*****************************************************************
cfMakeLBA:
    * create the new CF 32 bit LBA in D0
    move.l  #CF_LBAMODE,d0        * set LBA mode bits
    asl.l   #8,d0                 * shift left 10 bits
    asl.l   #2,d0
    move.b  seldrv,d1             * get the drive number
    andi.l  #$0F,d1               * clear unwanted bits
    or.w    d1,d0                 * insert the drive number
    asl.l   #6,d0                 * shift left 6 bits
    move.w  track,d1              * get the track number
    andi.l  #$3F,d1               * clear unwanted bits
    or.w    d1,d0                 * insert the track number
    asl.l   #8,d0                 * shift left 8 bits
    move.w  sector,d1             * get the sector number
    andi.l  #$3FF,d1              * clear unwanted bits
    asr.w   #2,d1                 * sector number >> 2
    or.w    d1,d0                 * insert the sector number
	move.l  d0,newLBA             * save the new LBA
	
    ifne DEBUG
        movea.l #strLBA, a0
        bsr.w   putString
        move.l  newLBA,d0
        bsr.w   writeAddr32           * print the computed LBA
        bsr.w   putCRLF
    endc
    rts

*****************************************************************
* Wait for CompactFlash disk to be ready
*****************************************************************
cfBusy:
    btst.b  #7,CF_STATUS          * check busy bit
    bne.s   cfBusy
    rts

*****************************************************************
* Wait for CompactFlash to request a data read or write
*****************************************************************
cfDatReq:
    btst.b  #3,CF_STATUS          * check data request bit
    beq     cfDatReq
    rts

	ifne DEBUG
*****************************************************************
*****************************************************************
* DEBUGGING HELPER ROUTINES
*****************************************************************
*****************************************************************

*------------------------------------------------------------------------------
* Serial Port B initialisation
* Uses the SUART test mode to set 115200 baud on Port B
*------------------------------------------------------------------------------
SerBInit:
    move.b  #$30, CRB             * Reset Transmitter
    move.b  #$20, CRB             * Reset Reciever
    move.b  #$10, CRB             * Reset Mode Register Pointer
    
    move.b  #$13, MRB             * No Parity & 8-bit
    move.b  #$07, MRB             * Normal Mode, No CTS/RTS & 1 stop bit
	
    move.b  CRA,d0                * Read CRA - sets BRG test mode
    move.b  #$66, CSRB            * Set Tx and Rx baud rates to 115200 (old 1200)
    move.b  #$05, CRB             * Enable Transmit/Recieve
    rts

*------------------------------------------------------------------------------
* Output a CR & LF to the debug serial port
*------------------------------------------------------------------------------
putCRLF:
    move.b  d0,-(sp)              * save D0 first
    move.b  #10,d0
    bsr.s   putc
    move.b  #13,d0
    bsr.s   putc
    move.b  (sp)+,d0              * restore D0
    rts
    
*------------------------------------------------------------------------------
* Print a null terminated string
* A0 holds the address of the first character of the null terminated string
*------------------------------------------------------------------------------
putString:
.loop:
    move.b  (a0)+, d0             * Get character
    beq.s   .end                  * Check for the null
    
    bsr.s   putc                  * Otherwise write the character
    bra.s   .loop                 * And continue
.end:
    rts

*------------------------------------------------------------------------------
* Serial Port B put routine
* D0 holds the byte/char to send
*------------------------------------------------------------------------------
putc:
    btst    #2, SRB               * Check if transmitter ready bit is set
    beq     putc
    move.b  d0, TBB               * Transmit Character
    rts

*------------------------------------------------------------------------------
* Output a 32-bit address as 8 ASCII hexadecimal digits
* D0 holds the 32-bit address
*------------------------------------------------------------------------------
writeAddr32:
    move.l  d0,-(sp)              * save D0 first
    ror.l   #8,d0
    ror.l   #8,d0
    bsr.s   writeWord             * write bits 16..31
    move.l  (sp)+,d0              * restore D0
    bra.s   writeWord
    
*------------------------------------------------------------------------------
* Output a 24-bit address as 6 ASCII hexadecimal digits
* D0 holds the address in bits 0..23
* NOTE: the writeWord function must be directly after this function
*------------------------------------------------------------------------------
writeAddr24:
    move.l  d0,-(sp)              * save D0 first
    ror.l   #8,d0
    ror.l   #8,d0
    bsr.s   writeByte             * write bits 16..23
    move.l  (sp)+,d0              * restore D0
    
*------------------------------------------------------------------------------
* Output a word as 4 ASCII hexadecimal digits
* D0 holds the word in bits 0..15
* NOTE: the writeByte function must be directly after this function
*------------------------------------------------------------------------------
writeWord:
    move.w  d0,-(sp)              * save D0 first
    ror.w   #8,d0                 * get upper byte (0 => shift 8 times)
    bsr.s   writeByte
    move.w  (sp)+,d0              * restore D0

*------------------------------------------------------------------------------
* Output a byte as 2 ASCII hexadecimal digits
* D0 holds the byte in bits 0..7
* NOTE: the writeNibble function must be directly after this function
*------------------------------------------------------------------------------
writeByte:
    move.b  d0,-(sp)              * save D0 first
    ror.b   #4,d0                 * get upper nibble
    bsr.s   writeNibble
    move.b  (sp)+,d0              * restore D0
    
*------------------------------------------------------------------------------
* Output 4 bits as an ASCII hexadecimal digit
* D0 holds the nibble in bits 0..3
*------------------------------------------------------------------------------
writeNibble:
    move.b  d0,-(sp)              * save D0 first
    andi.b  #$0F,d0               * make sure we only have the lower 4 bits
    cmpi.b  #10,d0                * compare D0 to 10
    bcs.b   .wn1                  * less than 10 so don't add 7
    addi.b  #07,d0                * add 7
.wn1:
    addi.b  #'0',d0               * add ASCII code for char zero
    bsr     putc                  * write the ASCII digit out
    move.b  (sp)+,d0              * restore D0
    rts

*------------------------------------------------------------------------------
* Debug helper strings
*------------------------------------------------------------------------------
strBanner:
    dc.b    'CP/M-68K BIOS Debug Information',10,13,0
strNewline:
    dc.b    10,13,0
strLBA:
    dc.b    'LBA ',0
strRead:
    dc.b    'READ',10,13,0
strWrite
    dc.b    'WRITE',10,13,0

    endc    
	
*****************************************************************
*****************************************************************
* END OF DEBUGGING HELPER ROUTINES
*****************************************************************
*****************************************************************

strCPMBanner:
    dc.b    10,13,'CP/M-68K(tm) Version 1.3  08/05/85',10,13
    dc.b    'Copyright (c) 1985 Digital Research, Inc.',10,13,0
	
*****************************************************************
* Memory regions
* There's only 1 memory region and it must be WORD aligned.
*  START: just above the RAM vector table - i.e. VEC_BASE+VEC_SIZE
* LENGTH: RAM_LEN-BIOS_PRIV-MON_PRIV-CCP_PRIV-VEC_SIZE
*
    org     (*+1)&-2              * force word alignment
memrgn:
    dc.w    1
    dc.l    VEC_BASE+VEC_SIZE
    dc.l    RAM_LEN-BIOS_PRIV-MON_PRIV-CCP_PRIV-VEC_SIZE
*    dc.l    $E0000

*****************************************************************
* disk parameter headers - 1 per drive
*****************************************************************

dph0:
    dc.l    0                     * (XLT) no sector translation table
    dc.w    0                     * Scratchpad word - used by BDOS
    dc.w    0                     * Scratchpad word - used by BDOS
    dc.w    0                     * Scratchpad word - used by BDOS
    dc.l    dirbuf                * (DIRBUF) pointer to directory buffer
    dc.l    dpb                   * (DPB) pointer to disk parameter block
    dc.l    0                     * (CSV) fixed disk so no check vector needed
    dc.l    alv0                  * (ALV) pointer to allocation vector

dphlen      EQU *-dph0            * length of a single disk parameter header

dph1:
    dc.l    0                     * (XLT) no sector translation table
    dc.w    0                     * Scratchpad word - used by BDOS
    dc.w    0                     * Scratchpad word - used by BDOS
    dc.w    0                     * Scratchpad word - used by BDOS
    dc.l    dirbuf                * (DIRBUF) pointer to directory buffer
    dc.l    dpb                   * (DPB) pointer to disk parameter block
    dc.l    0                     * (CSV) fixed disk so no check vector needed
    dc.l    alv1                  * (ALV) pointer to allocation vector

dph2:
    dc.l    0                     * (XLT) no sector translation table
    dc.w    0                     * Scratchpad word - used by BDOS
    dc.w    0                     * Scratchpad word - used by BDOS
    dc.w    0                     * Scratchpad word - used by BDOS
    dc.l    dirbuf                * (DIRBUF) pointer to directory buffer
    dc.l    dpb                   * (DPB) pointer to disk parameter block
    dc.l    0                     * (CSV) fixed disk so no check vector needed
    dc.l    alv2                  * (ALV) pointer to allocation vector

dph3:
    dc.l    0                     * (XLT) no sector translation table
    dc.w    0                     * Scratchpad word - used by BDOS
    dc.w    0                     * Scratchpad word - used by BDOS
    dc.w    0                     * Scratchpad word - used by BDOS
    dc.l    dirbuf                * (DIRBUF) pointer to directory buffer
    dc.l    dpb                   * (DPB) pointer to disk parameter block
    dc.l    0                     * (CSV) fixed disk so no check vector needed
    dc.l    alv3                  * (ALV) pointer to allocation vector

dph4:
    dc.l    0                     * (XLT) no sector translation table
    dc.w    0                     * Scratchpad word - used by BDOS
    dc.w    0                     * Scratchpad word - used by BDOS
    dc.w    0                     * Scratchpad word - used by BDOS
    dc.l    dirbuf                * (DIRBUF) pointer to directory buffer
    dc.l    dpb                   * (DPB) pointer to disk parameter block
    dc.l    0                     * (CSV) fixed disk so no check vector needed
    dc.l    alv4                  * (ALV) pointer to allocation vector

dph5:
    dc.l    0                     * (XLT) no sector translation table
    dc.w    0                     * Scratchpad word - used by BDOS
    dc.w    0                     * Scratchpad word - used by BDOS
    dc.w    0                     * Scratchpad word - used by BDOS
    dc.l    dirbuf                * (DIRBUF) pointer to directory buffer
    dc.l    dpb                   * (DPB) pointer to disk parameter block
    dc.l    0                     * (CSV) fixed disk so no check vector needed
    dc.l    alv5                  * (ALV) pointer to allocation vector

dph6:
    dc.l    0                     * (XLT) no sector translation table
    dc.w    0                     * Scratchpad word - used by BDOS
    dc.w    0                     * Scratchpad word - used by BDOS
    dc.w    0                     * Scratchpad word - used by BDOS
    dc.l    dirbuf                * (DIRBUF) pointer to directory buffer
    dc.l    dpb                   * (DPB) pointer to disk parameter block
    dc.l    0                     * (CSV) fixed disk so no check vector needed
    dc.l    alv6                  * (ALV) pointer to allocation vector

dph7:
    dc.l    0                     * (XLT) no sector translation table
    dc.w    0                     * Scratchpad word - used by BDOS
    dc.w    0                     * Scratchpad word - used by BDOS
    dc.w    0                     * Scratchpad word - used by BDOS
    dc.l    dirbuf                * (DIRBUF) pointer to directory buffer
    dc.l    dpb                   * (DPB) pointer to disk parameter block
    dc.l    0                     * (CSV) fixed disk so no check vector needed
    dc.l    alv7                  * (ALV) pointer to allocation vector


*****************************************************************
* Disk Parameter Blocks
*****************************************************************
*
* Choose a BLS (block size) of 4096 bytes, therefore:
*   BSH = 5 and BLM = 31 (from table 5-3 in the CP/M-68K System Guide)
*
* Assume we want 8Mb disks, then DSM+1 = 8 Megabyte / BLS = 2048
*   Therefore DSM = 2047
*
* EXM = 1 (from table 5-4 in the CP/M-68K System Guide, as DSM > 255)
*
* Choose 1024 SPT (sectors per track) where 1 CP/M sector = 128 bytes
*   4 CP/M sectors fit exactly into 1 CompactFlash Logical Block (512 bytes)
*
* With 1024 SPT, one CP/M track = 1024 sectors x 128 bytes = 131,072 bytes (128K)
*   An 8Mb disk will therefore require 8388608 / 131072 = 64 tracks.
*
*****************************************************************
* We can use the same DPB decriptor for all 8 drives
dpb:
    dc.w    1024                  * (SPT) 1024 sectors per track
    dc.b    5                     * (BSH) block shift for BLS of 4096
    dc.b    31                    * (BLM) block mask for BLS of 4096
    dc.b    1                     * (EXM) extent mask
    dc.b    0
    dc.w    2047                  * (DSM)
    dc.w    511                   * (DRM) 512 directory entries
    dc.w    0                     * reserved
    dc.w    0                     * permanently mounted drive, check size is zero
    dc.w    0                     * (OFF) track offset of 0 (CP/M & BIOS in EEPROM)
        
* no sector translation table needed

*****************************************************************
* Allocate some storage right up at the top of available RAM 
* to hold our BIOS variables.
*
* The monitor uses    $1FF800 .. $1FFFFF
* This BIOS uses      $1FF000 .. $1FF7FF
* The CCP & BDOS uses $1FE000 .. $1FEFFF
*

    org        RAM_BASE+RAM_LEN-BIOS_PRIV-MON_PRIV

dirbuf:     ds.b    128           * CP/M directory buffer
cfBuffer:   ds.b    512           * space for 1 CompactFlash logical block of 512 bytes

* ALV size is calculated as (DSM/8)+1 (from table 5-1) - 1 per drive
 
    org     (*+1)&-2              * force word alignment
alv0:       ds.b    258           * allocation vector, DSM/8+1 = 2048/8+1 = 257 (use 258)
alv1:       ds.b    258
alv2:       ds.b    258
alv3:       ds.b    258
alv4:       ds.b    258
alv5:       ds.b    258
alv6:       ds.b    258
alv7:       ds.b    258

    org     (*+1)&-2              * force word alignment

newLBA:     ds.l    1             * Computed new CF LBA
bufferLBA:  ds.l    1             * CF LBA of the 512 byte buffer

dma:        ds.l    1             * address of CP/M 128 byte memory area

* keep track and sector together as they can be read in as as 32-bit long word
track:      ds.w    1             * track requested by settrk
sector:     ds.w    1             * sector requested by setsec
seldrv:     ds.b    1             * drive requested by seldsk
writeFlag   ds.b    1             * write flag - 1 => CF buffer changed

    org     (*+1)&-2              * force word alignment

* RAM copy of the Disk Parameter Header definitions - 1 per drive
rdph0:      ds.b    dphlen
rdph1:      ds.b    dphlen
rdph2:      ds.b    dphlen
rdph3:      ds.b    dphlen
rdph4:      ds.b    dphlen
rdph5:      ds.b    dphlen
rdph6:      ds.b    dphlen
rdph7:      ds.b    dphlen

*****************************************************************
* Make sure we have not exceeded the available RAM
*****************************************************************

    ifgt *-RAM_BASE-RAM_LEN-MON_PRIV
    FAIL ERROR:  Variable storage extends beyond available RAM.
    endc

    end    0






*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~8~

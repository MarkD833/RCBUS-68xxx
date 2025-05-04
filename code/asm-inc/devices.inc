*******************************************************************************
* RCBus MC68000
*******************************************************************************
*    ######   #######  #     #  ###   #####   #######   #####  
*    #     #  #        #     #   #   #     #  #        #     # 
*    #     #  #        #     #   #   #        #        #       
*    #     #  #####    #     #   #   #        #####     #####  
*    #     #  #         #   #    #   #        #              # 
*    #     #  #          # #     #   #     #  #        #     # 
*    ######   #######     #     ###   #####   #######   #####
*******************************************************************************
* This file holds some global device definitions that are used in the RCBus 68000
* system.
*******************************************************************************

*******************************************************************************
* These addresses are as configured on the individual boards in what would be
* the Z80 8-bit I/O space.
* SC145 = CompactFlash module
* DUART = my own dual MC68681 serial module
*
SC145ADDR   EQU     $10           * SC145 base address is 0x10
DUART1ADDR  EQU     $C0           * 68681 base address is 0xC0

*******************************************************************************
* These are the same addresses converted into 68000 memory space
*
SC145       EQU     IO_BASE+(SC145ADDR<<1)
DUART1      EQU     IO_BASE+(DUART1ADDR<<1)

*******************************************************************************
*    ######   #     #     #     ######   ####### 
*    #     #  #     #    # #    #     #     #    
*    #     #  #     #   #   #   #     #     #    
*    #     #  #     #  #     #  ######      #    
*    #     #  #     #  #######  #   #       #    
*    #     #  #     #  #     #  #    #      #    
*    ######    #####   #     #  #     #     #
*******************************************************************************
* SCN68681 / SCC68692 Register Addresses for DUART #1
* DUART 8-bit data is on D0..D7 - i.e. the odd addresses
*******************************************************************************

MRA         EQU DUART1+1           * Mode Register A             (R/W)
SRA         EQU DUART1+3           * Status Register A           (R)
CSRA        EQU DUART1+3           * Clock Select Register A     (W)
CRA         EQU DUART1+5           * Commands Register A         (W)
RBA         EQU DUART1+7           * Receiver Buffer A           (R)
TBA         EQU DUART1+7           * Transmitter Buffer A        (W)
ACR         EQU DUART1+9           * Aux. Control Register       (R/W)
ISR         EQU DUART1+11          * Interrupt Status Register   (R)
IMR         EQU DUART1+11          * Interrupt Mask Register     (W)
MRB         EQU DUART1+17          * Mode Register B             (R/W)
SRB         EQU DUART1+19          * Status Register B           (R)
CSRB        EQU DUART1+19          * Clock Select Register B     (W)
CRB         EQU DUART1+21          * Commands Register B         (W)
RBB         EQU DUART1+23          * Reciever Buffer B           (R)
TBB         EQU DUART1+23          * Transmitter Buffer B        (W)
IVR         EQU DUART1+25          * Interrupt Vector Register   (R/W)
IPR         EQU DUART1+27          * Input Port Register         (R)
OPCR        EQU DUART1+27          * Output Port Config Register (W)
BCNT        EQU DUART1+29          * Start Counter               (R)
SOPR        EQU DUART1+29          * Set Output Port Register    (W)
ECNT        EQU DUART1+31          * Stop Counter                (R)
ROPR        EQU DUART1+31          * Reset Output Port Register  (W)

*******************************************************************************
* Baud rates with ACR[7]=0 straight from the SCC68692 datasheet table
*
BAUD_1200       EQU     $66         * 1200 baud
BAUD_2400       EQU     $88         * 2400 baud
BAUD_4800       EQU     $99         * 4800 baud
BAUD_9600       EQU     $BB         * 9600 baud
BAUD_38400      EQU     $CC         * 38400 baud

BAUD_RATE       EQU     BAUD_38400

*******************************************************************************
*     #####    #####     #    #        ####### 
*    #     #  #     #   ##    #    #   #       
*    #        #        # #    #    #   #       
*     #####   #          #    #    #   ######  
*          #  #          #    #######        # 
*    #     #  #     #    #         #   #     # 
*     #####    #####   #####       #    #####
*******************************************************************************
* Small Computer Central SC145 CompactFlash module AND
* Small Computer Central SC715 CompactFlash module.
*******************************************************************************
*
* CompactFlash card register addresses.
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

*******************************************************************************
* CompactFlash Logical Block Address registers
*
CF_LBA0007  EQU SC145+7           * LBA bits 07..00    (R/W)
CF_LBA0815  EQU SC145+9           * LBA bits 15..08    (R/W)
CF_LBA1623  EQU SC145+11          * LBA bits 23..16    (R/W)
CF_LBA2427  EQU SC145+13          * LBA bits 27..24    (R/W)

*******************************************************************************
* CompactFlash Features register
*
CF_8BIT		EQU	1                 * Set 8-bit mode
CF_NOCACHE	EQU	$82               * Disable the cache

*******************************************************************************
* CompactFlash Commands
*
CF_RD_SEC   EQU $20               * Read Sector Command
CF_WR_SEC   EQU $30               * Write Sector Command
CF_SET_FEAT EQU $EF               * Set Feature Command
CF_LBAMODE  EQU $E0               * LBA mode

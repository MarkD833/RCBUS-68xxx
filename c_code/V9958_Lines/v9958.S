/******************************************************************************
* RCBus-68000 V9958 graphics subroutines
*******************************************************************************
* Based on the original Z80 code by Dean Netherton.
* https://github.com/dinoboards/yellow-msx-series-for-rc2014/tree/main/apps-rc2014
*
* Simple Z80 to 68000 translation with registers mapped roughly as
* A -> D0, BC -> D1, DE -> D2 & HL -> A0
******************************************************************************/

#define RCBUS_IO_BASE_ADDRESS   0xF80000

#define SC129_ADDRESS			0x00
#define SC129					RCBUS_IO_BASE_ADDRESS+SC129_ADDRESS+1

#define V9958_DATA_IOADDR		0x98
#define V9958_ADDR_IOADDR		0x99
#define V9958_STAT_IOADDR		0x99
#define V9958_PALT_IOADDR		0x9A
#define V9958_REGS_IOADDR		0x9B

#define CMD_VDP_TO_VRAM			0xC0

	.globl	outCmd
	.globl	outDat
	.globl	outPal
	.globl	clearScreenBank0
	.globl	_commandDrawLine
	.globl	_waitForCommandCompletion
	.globl	_writeRegister

/******************************************************************************
* Define the V9958 register addresses in 68000 memory space
******************************************************************************/

#define VDP_DATA		RCBUS_IO_BASE_ADDRESS+(V9958_DATA_IOADDR<<1)+1
#define	VDP_ADDR		RCBUS_IO_BASE_ADDRESS+(V9958_ADDR_IOADDR<<1)+1
#define	VDP_STAT		RCBUS_IO_BASE_ADDRESS+(V9958_STAT_IOADDR<<1)+1
#define	VDP_PALT		RCBUS_IO_BASE_ADDRESS+(V9958_PALT_IOADDR<<1)+1
#define	VDP_REGS		RCBUS_IO_BASE_ADDRESS+(V9958_REGS_IOADDR<<1)+1

/******************************************************************************
* outDat - write data byte to the V9958
*
* void outDat(uint8_t b)
*   - byte to write is on the stack at 4(sp) - always a 32-bit value.
******************************************************************************/
outDat:
	move.l	4(%sp),%d0
	move.b	%d0,VDP_DATA
	rts

/******************************************************************************
* outCmd - write command byte to the V9958
*
* void outCmd(uint8_t b)
*   - byte to write is on the stack at 4(sp) - always a 32-bit value.
******************************************************************************/
outCmd:
	move.l	4(%sp),%d0
	move.b	%d0,VDP_ADDR
	rts

/******************************************************************************
* outPal - write to the V9958 palette registers
* 
* void outPal(uint8_t b)
*   - byte to write is on the stack at 4(sp) - always a 32-bit value.
******************************************************************************/
outPal:
	move.l	4(%sp),%d0
	move.b	%d0,VDP_PALT
	rts

/******************************************************************************
* clearScreenBank0 - Clear bitmap data from 0x0000 to 0x3FFF
*
* void clearScreenBank0(uint8_t color)
*   - byte to write is on the stack at 4(sp) - always a 32-bit value.
******************************************************************************/
clearScreenBank0:
	// set indirect register to 36
	move.b	#36,VDP_ADDR
	move.b	#0x80+17,VDP_ADDR

	move.b	#0,VDP_REGS			// DX=0 (16-bits - LSB first)
	move.b	#0,VDP_REGS
	move.b	#0,VDP_REGS			// DY=0 (16-bits - LSB first)
	move.b	#0,VDP_REGS
	move.b	#0,VDP_REGS			// NX=512 (16-bits - LSB first)
	move.b	#2,VDP_REGS
	move.b	#212,VDP_REGS		// NY=212 (16-bits - LSB first)
	move.b	#0,VDP_REGS

	move.l	4(%sp),%d0			// COLOUR for both pixels (assuming G7 mode)
	lsl.b	#4,%d0
	or.l	4(%sp),%d0
	move.b	%d0,VDP_REGS
	move.b	#0,VDP_REGS			// Direction: VRAM, Right, Down
	move.b	#CMD_VDP_TO_VRAM,VDP_REGS
	bra.w	_waitForCommandCompletion

/******************************************************************************
* _writeRegister - write a byte to a register 
*
* void _writeRegister(uint16_t rd)
*   - word to write is on the stack at 4(sp) - always a 32-bit value.
*   - bits 00..07 hold the data
*   - bits 08..15 hold the register number
******************************************************************************/
_writeRegister:
	move.l	4(%sp),%d0
	move.b	%d0,VDP_ADDR		// write the data byte out
	ror.w	#8,%d0				// shift the register number into the LSB
	ori.b	#0x80,%d0			// set the MSB
	move.b	%d0,VDP_ADDR		// write the register number out
	rts

/******************************************************************************
* commandDrawLine - 
******************************************************************************/
_commandDrawLine:
	move.b	#0x55,SC129
	
	// setup to access status register #2
	move.b	#2,VDP_ADDR
	move.b	#0x80+15,VDP_ADDR

	// wait for any previous command to complete
_commandDrawLineReady:
	move.b	VDP_STAT,%d0
	andi.b	#0x01,%d0
	bne.s	_commandDrawLineReady

	// set indirect register to 36
	move.b	#36,VDP_ADDR
	move.b	#0x80+17,VDP_ADDR

	// copy the values to the registers - 16bit values are LSB first
	move.l	#_fromX,%a0			// start address

	move.w	(%a0)+,%d0			// fromX - 16bit
	move.b	%d0,VDP_REGS		// LSB
	ror.w	#8,%d0
	move.b	%d0,VDP_REGS		// MSB

	move.w	(%a0)+,%d0			// fromY - 16bit
	move.b	%d0,VDP_REGS		// LSB
	ror.w	#8,%d0
	move.b	%d0,VDP_REGS		// MSB

	move.w	(%a0)+,%d0			// longSide - 16bit
	move.b	%d0,VDP_REGS		// LSB
	ror.w	#8,%d0
	move.b	%d0,VDP_REGS		// MSB

	move.w	(%a0)+,%d0			// shortside - 16bit
	move.b	%d0,VDP_REGS		// LSB
	ror.w	#8,%d0
	move.b	%d0,VDP_REGS		// MSB

	move.b	(%a0)+,VDP_REGS		// color - 8bit
	move.b	(%a0)+,VDP_REGS		// dir - 8bit
	move.b	(%a0)+,VDP_REGS		// operation - 8bit

	move.b	#0,VDP_ADDR
	move.b	#0x80+15,VDP_ADDR
	rts

/******************************************************************************
* waitForCommandCompletion - wait for the VDP to finish executing the command
******************************************************************************/
_waitForCommandCompletion:
	// setup to access status register #2
	move.b	#2,VDP_ADDR
	move.b	#0x80+15,VDP_ADDR

	// wait for any previous command to complete
_waitForCommandCompletionLoop:
	move.b	VDP_STAT,%d0
	andi.b	#0x01,%d0
	bne.s	_waitForCommandCompletionLoop

	move.b	#0,VDP_ADDR
	move.b	#0x80+15,VDP_ADDR
	rts

	.data
	.align 2

	.globl	_fromX,_fromY,_color,_operation
	.globl	_longSide,_shortSide,_dir
	
_fromX:			ds.w	1
_fromY:			ds.w	1
_longSide:		ds.w	1
_shortSide:		ds.w	1
_color:			ds.b	1
_dir:			ds.b	1
_operation:		ds.b	1

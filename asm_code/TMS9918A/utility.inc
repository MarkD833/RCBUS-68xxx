*******************************************************************************
* RCBus-68000 TMS9918A graphics utility routines
*******************************************************************************
* My implementation of simmilar functionality
*******************************************************************************
* Copyright 2025 Mark Durham
*
* Permission is hereby granted, free of charge, to any person obtaining a 
* copy of this software and associated documentation files (the "Software"), 
* to deal in the Software without restriction, including without limitation 
* the rights to use, copy, modify, merge, publish, distribute, sublicense, 
* and/or sell copies of the Software, and to permit persons to whom the 
* Software is furnished to do so, subject to the following conditions:
* 
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
* 
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING 
* FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER 
* DEALINGS IN THE SOFTWARE.

*------------------------------------------------------------------------------
* Output a byte as 2 ASCII hexadecimal digits
* D0 holds the byte in bits 0..7
* NOTE: the writeNibble function must be directly after this function
*------------------------------------------------------------------------------
writeByte:
    move.w  d0,-(sp)    ; save D0 first
    ror.b   #4,d0       ; get upper nibble
    bsr.s   writeNibble
    move.w  (sp)+,d0    ; restore D0
    
*------------------------------------------------------------------------------
* Output 4 bits as an ASCII hexadecimal digit
* D0 holds the nibble in bits 0..3
*------------------------------------------------------------------------------
writeNibble:
    move.w  d0,-(sp)    ; save D0 first - write 16 bits to keep stack aligned
    andi.b  #$0F,d0     ; make sure we only have the lower 4 bits
    cmpi.b  #10,d0      ; compare D0 to 10
    bcs.b   .wn1        ; less than 10 so don't add 7
    addi.b  #07,d0      ; add 7
.wn1:
    addi.b  #'0',d0     ; add ASCII code for char zero
    bsr     putc        ; write the ASCII digit out
    move.w  (sp)+,d0    ; restore D0
    rts

*------------------------------------------------------------------------------
* Print a null terminated string
* A0 holds the address of the first character of the null terminated string
*------------------------------------------------------------------------------
putString:
.loop:
    move.b  (a0)+, d0    * Read in character
    beq.s   .end         * Check for the null
    
    bsr.s   putc		 * Otherwise write the character
    bra.s   .loop        * And continue
.end:
    rts

*------------------------------------------------------------------------------
* Write a character to UART Port A, blocking if UART is not ready
* D0 = char to send
*------------------------------------------------------------------------------
putc:
	movem.l	d0-d1,-(sp)		* save d0, d1
	move.b	d0,d1			* copy character
	moveq	#6,d0			* character out
	trap	#15				* call rcMON BIOS I/O function
	movem.l	(sp)+,d0-d1		* restore d0, d1
	rts
	
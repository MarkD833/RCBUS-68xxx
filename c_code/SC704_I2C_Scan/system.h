/******************************************************************************
* RCBus MC68000
*******************************************************************************
*  #####   #     #   #####   #######  #######  #     # 
* #     #   #   #   #     #     #     #        ##   ## 
* #          # #    #           #     #        # # # # 
*  #####      #      #####      #     #####    #  #  # 
*       #     #           #     #     #        #     # 
* #     #     #     #     #     #     #        #     # 
*  #####      #      #####      #     #######  #     #
*******************************************************************************
* RCBus-68000 System wide definitions etc
******************************************************************************/

#ifndef SYSTEM_H
#define SYSTEM_H

/******************************************************************************
* RAM_BASE is the start address of the RAM and is hardware configured for
* address $100000.
*/
#define RAM_BASE 0x100000

/******************************************************************************
* VEC_BASE is the start address in RAM for the RAM based MC68000 exception
* vector table. It should be set to RAM_BASE (i.e. start of RAM).
*/
#define VEC_BASE RAM_BASE
#define VEC_SIZE 0x400

/******************************************************************************
* MEM_BASE is the start address of a block of memory in MC68000 memory space
* that maps onto the RCBus 64K Memory space.
*/
#define MEM_BASE 0xF00000

/******************************************************************************
* IO_BASE is the start address of a block of memory in MC68000 memory space
* that maps onto the RCBus 256 byte IO space.
*/
#define IO_BASE 0xF80000

#endif
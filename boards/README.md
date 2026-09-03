# RCBUS-68000-Boards

These folders contain the KiCad (v8/v9/v10) design files for the various RCBus 68000 boards I'm currently testing.

## Series 1 boards

The series 1 boards are my first attempt at a 68000 based RCBus-80 system. Processor boards support autovectored interrupts only.

**NOTE:** The series 1 boards have been largly superseeded by the series 2 boards as my knowledge expanded.

| ID | Description | Notes |
| :---- | :---- | :---- |
| RC101 | 68000 processor card using the PLCC package variant of the 68000 | |
| RC102 | 128K ROM & 1M RAM board | Use RC208 instead |
| RC103 | Dual MC68681 serial board - 4 serial ports | |
| RC104 | Dual MC68230 parallel interface / timer board | |
| RC105 | Dual MC68901 multifunction peripheral board | |
| RC106 | 68302 processor card using the PGA package | |
| RC107 | 1M ROM & 1M RAM board | Use RC208 instead |
| RC108 | 6 channel SPI master board - 3V3 and 5V ports | |
| RC109 | Serial / parallel / timer board | |
| RC110 | 68020 processor card using the PGA package | |
| RC111 | SCC68692 DUART + MC68881 maths coprocessor | |

Note that the 68020 board is still very much at the prototype stage.

## Series 2 boards

The series 2 boards are based on my time spent with the series 1 boards and the hope is that the processor boards will feature a mixture of vectored and autovectored interrupts.

| ID | Description | Notes |
| :---- | :---- | :---- |
| RC200 | RCBus-80 Developers Backplane | |
| RC201 | 68000 processor card using the PLCC package variant of the 68000 | |
| RC202 | Single SCC68692 DUART + SPI & I2C board - 2 serial ports | |
| RC203 | Dual MC68230 parallel interface / timer board | |
| RC204 | 1M ROM & 3M RAM board | Untested but likely replaced with RC209 shortly |
| RC205 | 68020 processor card using the PGA package | |
| RC206 | 68008 processor card using the PLCC package variant of the 68008 | |
| RC207 | 1M ROM & 1M RAM board - manual BOOT ROM switching | Abandoned - use RC208 instead |
| RC208 | 1M ROM & 1M RAM board - automatic BOOT ROM switching | |
| RC209 | 1M ROM & 3M RAM board - automatic BOOT ROM switching | |

Several of the series 2 boards are now working and I've put details in their respectove folders whilst others are still very much at the prototype stage.

## Notes
Make sure to look at the readme files in each board folder as they will detail any errors and corrections I've noticed so far as well as any thoughts on future enhancements etc.

A minimal 68000 (or 68010) system would comprise of a 68000/68010 CPU board, ROM/RAM board and SIO board.

A minimal 68302 system would comprise of a 68302 CPU board and a ROM/RAM board.


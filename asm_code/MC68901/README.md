# MC68901

The code in this folder has some basic examples of using the MC6901 multi-function peripheral chip that can be assembled using EASy68K.

Toggle simple toggles an i/o pin using a crude software delay loop.

Ser_echo simply waits for a char on the MPF serial port (9600 baud) and echoes it back.

Timer uses the MFP timer C to generate interrupts that are counted and used to toggle an LED on an SC129 digital I/O board at around 1Hz.


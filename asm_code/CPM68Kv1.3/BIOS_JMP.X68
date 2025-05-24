* Simple BIOS Jumper for the RCBus 68000 to get CP/M-68K to jump from the
* hard coded loaction $6000 to the temporary RAM based BIOS at $1F0000

START:
	org	$6000
	jmp	$1F0000


    END    START        ; last line of source


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~

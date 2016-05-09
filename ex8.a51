$include(t89c51cc01.inc)

ORG 000h
LJMP init

init:    	MOV TMOD,#11h // sets the timer0 and 1 in 16bit mode
			MOV TH0,#0ECh // Timer0 for the verification at 100Hz
			MOV TL0,#077h
			MOV TH1, #0FBh // Timer1 for the buzzer 400Hz
			MOV TL1, #08Fh
			SETB ET0 // timer0 interrupt enable (sets to 1)
			SETB ET1
			SETB EA // global interrupt enable
			SETB TR0
			LJMP main



main:       MOV R1, #028h  ; =40 = all leds of a line
loopcol:    CLR P4.1    
            SETB P4.0
            CLR P4.0

            DJNZ R1, loopcol

            ;SETB P4.1   ; floating value of data between the 40 cols and the 7 rows
            ;SETB P4.0
            ;CLR P4.0


            MOV R2, #07h  ;= 6 first rows disabled
looprow:    CLR P4.1
            SETB P4.0
            CLR P4.0

            DJNZ R2, looprow

            ;CLR P4.1   ; last row enabled
            ;SETB P4.0
            ;CLR P4.0


            SETB P3.2
            CLR P3.2  ; display store

            LJMP main

END
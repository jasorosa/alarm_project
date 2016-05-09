
$include(t89c51cc01.inc)
	

ORG 0000h
LJMP init
ORG 000Bh
LJMP timer0int
init:					MOV TMOD,#01h ; 
						MOV TH0,#0FBh ; set value of timer 0 
						MOV TL0,#08Fh ; same  for LSB
						SETB ET0 ; enable timer 0  on int
						SETB EA ; enable int
						SETB TR0 ; enable all interrupt
						
main:					LJMP $
; first step is to check if a button is pressed by setting all rows to 0 and all columns to 1 and see which columns is activated
; then use dichotomy : 2 first rows at 0 two next at 1, if no columns goes to 0, it is one of the 2 lasts rows, otherwise the two first
; last step is again dichotomy : even rows to 1 and odd rows to 0 to decide which is the button presssed

timer0int:				MOV P0,#00001111b
						
						JNB P0.0, dichotomy00
						JNB P0.1, dichotomy01
						JNB P0.2, dichotomy02
						JNB P0.3, dichotomy03
						LJMP reset
						
dichotomy00:			CLR P0.4
						CLR P0.5
						SETB P0.6
						SETB P0.7
						JNB P0.0, dichotomy00zero
						LJMP dichotomy00one
						
dichotomy01:			CLR P0.4
						CLR P0.5
						SETB P0.6
						SETB P0.7
						JNB P0.1, dichotomy01zero
						LJMP dichotomy01one
						
dichotomy02:			CLR P0.4
						CLR P0.5
						SETB P0.6
						SETB P0.7
						JNB P0.2, dichotomy02zero
						LJMP dichotomy02one

dichotomy03:			CLR P0.4
						CLR P0.5
						SETB P0.6
						SETB P0.7
						JNB P0.3, dichotomy03zero
						LJMP dichotomy03one
						
dichotomy00zero:		CLR P0.4
						SETB P0.5
						CLR P0.6
						SETB P0.7
						JNB P0.0, intermediateletterC
						LJMP letterD
						
						
dichotomy01zero:		CLR P0.4
						SETB P0.5
						CLR P0.6
						SETB P0.7
						JNB P0.1, letterB
						LJMP three
						
dichotomy02zero:		CLR P0.4
						SETB P0.5
						CLR P0.6
						SETB P0.7
						JNB P0.2, zero
						LJMP two
						
dichotomy03zero:		CLR P0.4
						SETB P0.5
						CLR P0.6
						SETB P0.7
						JNB P0.3, letterA
						LJMP one

intermediateletterC: 	LJMP letterC ; too long jump otherwise

dichotomy00one: 		CLR P0.4
						SETB P0.5
						CLR P0.6
						SETB P0.7
						JNB P0.0, letterE
						LJMP letterF
						
dichotomy01one:			CLR P0.4
						SETB P0.5
						CLR P0.6
						SETB P0.7
						JNB P0.1, six
						LJMP nine
						
dichotomy02one: 		CLR P0.4
						SETB P0.5
						CLR P0.6
						SETB P0.7
						JNB P0.2, five
						LJMP eight
						
dichotomy03one: 		CLR P0.4
						SETB P0.5
						CLR P0.6
						SETB P0.7
						JNB P0.3, four
						LJMP seven
						
zero:					LJMP buzzer
one:					LJMP led1
two:					LJMP buzzer
three:					LJMP buzzer
four:					LJMP led2
five:					LJMP buzzer
six:					LJMP buzzer
seven:					LJMP buzzer
eight:					LJMP buzzer
nine:					LJMP buzzer
letterA:				LJMP buzzer
letterB:				LJMP buzzer
letterC:				LJMP buzzer
letterD:				LJMP buzzer
letterE:				LJMP buzzer
letterF:				LJMP buzzer

						
buzzer:					CPL P2.2 ; change state of buzzer
						MOV TH0,#0FBh ; freq at 440
						MOV TL0,#08Fh
						LJMP endint
led1:					CLR	P2.3						
						LJMP endint
led2:					CLR	P2.4						
						LJMP endint
reset:					SETB P2.3
						SETB P2.4
						LJMP endint 
						
endint:					RETI
end						
						
		

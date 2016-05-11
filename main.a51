$include(t89c51cc01.inc)
	
ORG 0000h
LJMP init
ORG 000Bh
LJMP timer0int
ORG 0003h
LJMP ext0int
ORG 001Bh
LJMP timer1int

init:					MOV TMOD,#00010001b ; 16 bit mode for timer 0 and 1 
						MOV TH0,#0FBh ; MSB set 880Hz of timer 0 
						MOV TL0,#08Fh ; LSB same  for LSB
						MOV TH1, #0Bh ; about 15Hz for timer 1
						MOV TL1, #0DBh ;
						SETB ET0 ; enable timer 0  on int
						SETB ET1 ; enable timer 1 interrupt
						SETB EX0 ; enable external interrupt 0
						SETB EA ; enable int
						SETB TR0 ; enable all interrupt
						SETB TR1
						MOV R4, #00110100b ; 2 LSD 4 first = 4, 4 next = 3
						MOV R5, #00010010b ; 2 MSD 4 next = 2, 4 next = 1 => code is 1234
						MOV R0, #00h
						MOV R6, #00h
						MOV 31h, #0Fh ; RAM byte addressable to save previous state of keyboard (random initial value)
						
main:					LJMP main

timer0int:				MOV P0,#00001111b
						
						JNB P0.0, dichotomy00
						JNB P0.1, dichotomy01
						JNB P0.2, dichotomy02
						JNB P0.3, dichotomy03
						LJMP nothing
						
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
						JNB P0.1, intermediateletterB
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

intermediateletterB:	LJMP letterB

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
						
zero:					MOV R1, #00h
						LJMP entercode
one:					MOV R1, #01h
						LJMP entercode
two:					MOV R1, #02h
						LJMP entercode
three:					MOV R1, #03h
						LJMP entercode
four:					MOV R1, #04h
						LJMP entercode
five:					MOV R1, #05h
						LJMP entercode
six:					MOV R1, #06h
						LJMP entercode
seven:					MOV R1, #07h
						LJMP entercode
eight:					MOV R1, #08h
						LJMP entercode
nine:					MOV R1, #09h
						LJMP entercode
letterA:				LJMP endint1
letterB:				LJMP endint1
letterC:				LJMP clearcode
letterD:				LJMP endint1
letterE:				LJMP endint1
letterF:				LJMP endint1
nothing: 				MOV 31h,#0Fh
						LJMP endint1

ext0int:				CJNE R6, #01h, intermEndIntExt ;if alarm is not OFF : end
						LJMP detection

detection:				MOV R7, #0E1h ; set counter to 225 to go to 15s
						LJMP endintExt

timer1int:				CJNE R6, #00h, next ; alarm is not activated : end otherwise next
						LJMP endint
next:					SETB P2.4
						DJNZ R7, intermEndInt ; normally screen !
						CLR P2.3 ; flashing led
						CJNE R6, #01h, scream ; if not pre alarm it is pre alert and we can start SKRIMIN
						CJNE R6, #03h, activation ; it is prealarm so activate alarm system
						LJMP endint
						
activation:				INC R6
						CLR P2.4 ; led shows alarm is on
						LJMP endint
						
scream:					INC R6
						CPL P2.2 ; change state of buzzer
						MOV TH0, #0FBh ; freq at 440
						MOV TL0, #08Fh
						LJMP endint
						
intermEndIntExt:		LJMP endintExt
intermEndInt:			LJMP endint
						
entercode:				MOV A,31h
						CJNE A,#0Fh, endint1
						LJMP continue
continue:				MOV A, R1
						MOV 31h, A
						CJNE R0, #00h, code2 ;if counter of pressed button is 0 its the first number of the code
						MOV  A, R1
						SWAP A
						MOV  R3, A
code2:					CJNE R0, #01h, code3
						MOV  A, R1			;second number of the code
						ADD  A, R3
						MOV  R3, A
code3:					CJNE R0, #02h, code4
						MOV  A, R1			;third
						SWAP A
						MOV  R2, A
code4:					CJNE R0, #03h, incR0
						MOV  A, R1			;fourth
						ADD  A, R2
						MOV  R2, A
						LJMP checkCode
incR0:					INC R0
						LJMP endint1
						
checkCode:				MOV R0, #00h
						MOV A,R4
						XRL A,R2
						CPL A    ;XNOR to check that R4 and R2 are the same (if 11111111b)
						CJNE A, #0FFh, wrong ;check if code == main code
						MOV A,R5
						XRL A,R3
						CPL A
						CJNE A, #0FFh, wrong
						CLR P2.4 ;debug only
						CJNE R6, #00h, desactivate ; if alarm is screaming
						MOV R6, #01h ; we shut the alarm up but still activated
						MOV R7, #0E1h ; put 15 seconds in the counter before prealarm => alarm (counter at 225 with 15Hz) 
						LJMP endint1
						
desactivate:			MOV R6, #00h
						MOV R7, #00h ; reset the counter if the alarm is desactivate
						SETB P2.3
						LJMP endint1
						
wrong:					; screen
						LJMP clearcode

clearcode:				MOV R2, #00h
						MOV R3, #00h
						MOV R0, #00h
						LJMP endint1
						
endint1:				MOV TH1,#0Bh 
						MOV TL1,#0DBh 
						RETI
endint:					MOV TH0,#0FBh ; MSB set 880Hz of timer 0 
						MOV TL0,#08Fh ; LSB same  for LSB
						RETI
endintExt:				RETI

end						
						
		

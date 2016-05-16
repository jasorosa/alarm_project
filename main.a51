$include(t89c51cc01.inc)

; DEFINITIONS
SHIFT EQU P4.0
DATA_BITS  EQU P4.1
STORE EQU P3.2

;INIT ISRs
ORG 0000h
LJMP init
ORG 000Bh
LJMP keyboardISR ; timer 0
ORG 0013h
LJMP extISR ; ext interrupt 1
ORG 001Bh
LJMP mainISR ; timer 1
ORG 002Bh
LJMP screenISR ; timer 2


init:					MOV SP,#070h
						MOV TMOD,#00010001b ; 16 bit mode for timer 0 and 1 
						MOV TH0,#0FBh ; MSB set 880Hz of timer 0 
						MOV TL0,#08Fh ; LSB same  for LSB
						MOV TH1, #0Bh ; about 15Hz for timer 1
						MOV TL1, #0DBh ;
						MOV TH2,#0FBh 
						MOV TL2,#08Fh 
						MOV R4, #00110100b ; 2 LSD 4 first = 4, 4 next = 3
						MOV R5, #00010010b ; 2 MSD 4 next = 2, 4 next = 1 => code is 1234
						MOV R0, #00h
						MOV R6, #00h
						MOV 31h, #0Fh ; RAM byte addressable to save previous state of keyboard (random initial value)
						MOV 32h, #0Fh ; RAM byte addressable to store temporarily "data pointer" for screen (random init value) 
						
						MOV 38h, #88
						MOV 39h, #88
						MOV 3Ah, #88
						MOV 3Bh, #88
						MOV 3Ch, #80
						MOV 3Dh, #80
						MOV 3Eh, #80
						MOV 3Fh, #80
						
						CLR DATA_BITS
						CLR SHIFT
						CLR STORE
						SETB RS1 ; init some registers in register bank (1,1) for screen
						SETB RS0
						MOV R6, #0
						CLR A
						MOV R5, #0
						CLR RS1
						CLR RS0
						SETB ET0 ; enable timer 0 interrupt
						SETB ET1 ; enable timer 1 interrupt
						SETB ET2 ; enable timer 2 interrupt
						SETB EX1 ; enable external interrupt 1
						SETB EA ; enable int
						SETB TR0 ; enable timer 0, 1, 2
						SETB TR1
						SETB TR2
						

main:					CJNE R6, #01h, main ;if alarm is not OFF : end
						LJMP detection

detection:				MOV R7, #0E1h ; set counter to 225 to go to 15s
						LJMP main


;------------------------------------   KEYBOARD   --------------------------------------------------
keyboardISR:			PUSH PSW ; review PSW, ACC and PUSH/POP !!!!
						PUSH ACC
						CLR P2.3 ; debug
						MOV P0,#00001111b
						
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
						JNB P0.3, intermediateletterA
						LJMP one

intermediateletterC: 	LJMP letterC ; too long jump otherwise
intermediateletterB:	LJMP letterB

dichotomy00one: 		CLR P0.4
						SETB P0.5
						CLR P0.6
						SETB P0.7
						JNB P0.0, intermediateletterE
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

intermediateletterA: 	LJMP letterA ; too long jump otherwise
intermediateletterE:	LJMP letterE

dichotomy03one: 		CLR P0.4
						SETB P0.5
						CLR P0.6
						SETB P0.7
						JNB P0.3, four
						LJMP seven
						
zero:					MOV R1, #00h
						MOV 32h, #0 ; each code block has 8 lines so if we want key0, we start from key0+0, if key1 : key0+8 and so on
						LJMP entercode
one:					MOV R1, #01h
						MOV 32h, #8
						LJMP entercode
two:					MOV R1, #02h
						MOV 32h, #16
						LJMP entercode
three:					MOV R1, #03h
						MOV 32h, #24
						LJMP entercode
four:					MOV R1, #04h
						MOV 32h, #32
						LJMP entercode
five:					MOV R1, #05h
						MOV 32h, #40
						LJMP entercode
six:					MOV R1, #06h
						MOV 32h, #48
						LJMP entercode
seven:					MOV R1, #07h
						MOV 32h, #56
						LJMP entercode
eight:					MOV R1, #08h
						MOV 32h, #34
						LJMP entercode
nine:					MOV R1, #09h
						MOV 32h, #72
						LJMP entercode
letterA:				LJMP endKeyboardISR
letterB:				LJMP endKeyboardISR
letterC:				LJMP clearcode
letterD:				LJMP endKeyboardISR
letterE:				LJMP endKeyboardISR
letterF:				LJMP endKeyboardISR
nothing: 				MOV 31h,#0Fh ; if no button pressed : set the stored value at a random value 0Fh
						LJMP endKeyboardISR

entercode:				MOV A,31h
						CJNE A,#0Fh, endKeyboardISR ; the stored value in 31h is used to debounce the keyboard
						LJMP continue
continue:				MOV A, R1
						MOV 31h, A
						CJNE R0, #00h, code2 ;if counter of pressed button (R0) is 0 its the first number of the code, else go to code2(second number)
						MOV A, 32h			 ;code stored on 2 registers. we use SWAP function to do this well. If code is 1234 : R3 : 00010010 (1,2)
						MOV 3Bh, A			 ;																					  R4 : 00110100 (3,4)
						MOV  A, R1
						SWAP A
						MOV  R3, A
code2:					CJNE R0, #01h, code3
						MOV A, 32h
						MOV 3Ah, A
						MOV  A, R1			;second number of the code
						ADD  A, R3
						MOV  R3, A
code3:					CJNE R0, #02h, code4
						MOV A, 32h
						MOV 39h, A
						MOV  A, R1			;third
						SWAP A
						MOV  R2, A
code4:					CJNE R0, #03h, incR0
						MOV A, 32h
						MOV 38h, A
						MOV  A, R1			;fourth
						ADD  A, R2
						MOV  R2, A
						LJMP checkCode
incR0:					INC R0				; increment the counter of button pressed
						LJMP endKeyboardISR

checkCode:				MOV R0, #00h
						MOV A,R4
						XRL A,R2
						CPL A    ;XNOR to check that R4 and R2 are the same (if 11111111b)
						CJNE A, #0FFh, wrong ;check if code == main code otherwise wrong
						MOV A,R5
						XRL A,R3 ;same XNOR for R3,R5
						CPL A
						CJNE A, #0FFh, wrong
						CLR P2.4 ;debug only
						CJNE R6, #00h, desactivate ; if alarm activated, desactivate it
						MOV R6, #01h ; otherwise, activate it (prealarm before actually set on)
						MOV R7, #0E1h ; put 15 seconds of period in the counter before prealarm => alarm (counter at 225 with 15Hz) 
						LJMP endKeyboardISR
						
desactivate:			MOV R6, #00h
						MOV R7, #00h ; reset the counter if the alarm is desactivate
						SETB P2.3 ;debug
						LJMP endKeyboardISR
						
wrong:					; SHOW WITH SCREEN OR LED ITS WRONG
						LJMP clearcode

clearcode:				MOV R2, #00h
						MOV R3, #00h
						MOV R0, #00h
						MOV DPTR, #KeyUS ; reset screen data
						MOVX A, @DPTR
						MOV 3Bh, A
						MOV 3Ah, A
						MOV 39h, A
						MOV 38h, A
						LJMP endKeyboardISR
						
endKeyboardISR:			MOV TH1,#0Bh 
						MOV TL1,#0DBh 
						POP ACC
						POP PSW
						RETI						


;------------------------------------   EXT INTERRUPT (PIR SENSOR)   --------------------------------------------------
;extISR:					PUSH PSW ; STILL HAVE TO TEST PIR SENSOR AND CONFIGURE THE ISR CORRECTLY
						;PUSH ACC
						;CJNE R6, #01h, endExtISR ;if alarm is not OFF : end
						;LJMP detection

;detection:				MOV R7, #0E1h ; set counter to 225 to go to 15s
						;LJMP endExtISR
						
;endExtISR:				POP ACC
						;POP PSW
						;RETI


;------------------------------------   "MAIN" PROGRAM   --------------------------------------------------

mainISR:				PUSH PSW
						PUSH ACC
						CJNE R6, #00h, next ; alarm is not activated : end otherwise next
						LJMP endMainISR
next:					SETB P2.4 ; debug
						DJNZ R7, endMainISR ; 15s decounting. normally screen ! (?? what ? why screen ?)
						CPL P2.3 ; flashing led
						CJNE R6, #01h, scream ; if not pre alarm it is pre alert and after 15s we can start SKRIMIN
						CJNE R6, #03h, activation ; it is prealarm so activate alarm system after 15sc
						LJMP endMainISR
						
activation:				INC R6 ;prealarm mode to alarm mode
						CLR P2.4 ; led shows alarm is on
						LJMP endMainISR
						
scream:					INC R6 ;prealert mode to alert mode
						CPL P2.2 ; change state of buzzer
						LJMP endMainISR
					

endMainISR:				MOV TH0,#0FBh ; MSB set 880Hz of timer 0 
						MOV TL0,#08Fh ; LSB same  for LSB
						POP ACC
						POP PSW
						RETI


			
;------------------------------------   DISPLAY   --------------------------------------------------			
screenISR:				PUSH PSW
						PUSH ACC
						SETB RS1
						SETB RS0
						CLR DATA_BITS
						CLR SHIFT
						CLR STORE
						CLR P2.3
						MOV A,R5 ; init = 0, its index of the block we are dealing with
						;SUBB A, #1; WATT ? R5 - R5 = 0 -> something wrong, should delete this line right?
						MOV R4,A
						
						MOV DPTR, #KeyEmpty ; first some empty blocks 
						
						CJNE R4, #0, loop4a ; if R4 = 0 skip this loop !
						LJMP skip
						; loop on number of repeated pattern
loop4a:					MOV A, R6 ; R6 is an index for the used row
						CJNE A,#7, column_dispa ; reset row index when complete
reseta:					MOV A, #0
						MOV R6, #0
						
column_dispa:			MOVC A, @A+DPTR
						MOV R3, #5
						;each column bit (one by one)
loop3a:					RRC A ;right shift
						MOV DATA_BITS,C ;carry of the right shift in data output for display
						CLR SHIFT ;shift register
						SETB SHIFT
						DJNZ R3, loop3a
						
						DJNZ R4, loop4a
						
						;now display the wanted value 
skip:					MOV DPTR, #Key0 ;start index at Key0
						;MOV R4, #1 ; repeat pattern N times NO NEED
						; number of repeated pattern
loop4b:					MOV A, R6 ; R6 is an index for the used row
						CJNE A,#7, column_dispb ; reset row index when complete
resetb:					MOV R6, #0
						MOV A, #0
column_dispb:			ADD A, 38h
						MOVC A, @A+DPTR
						MOV R3, #5
						;each column bit (one by one)
loop3b:					RRC A ;right shift
						MOV DATA_BITS,C ;carry of the right shift in data output for display
						CLR SHIFT ;shift register
						SETB SHIFT
						DJNZ R3, loop3b

						;DJNZ R4, loop4b NO NEED

						MOV A, #07h
						SUBB A,R5  ; number of empty block at left: 8 : MUST BE CHANGED
						MOV R4,A
						MOV DPTR, #KeyEmpty

						; number of repeated pattern
loop4c:					MOV A, R6 ; R6 is an index for the used row
						CJNE A,#7, column_dispc ; reset row index when complete
resetc:					MOV A, #0
						MOV R6, #0
						
column_dispc:			MOVC A, @A+DPTR
						MOV R3, #5
						;each column bit (one by one)
loop3c:					RRC A ;right shift
						MOV DATA_BITS,C ;carry of the right shift in data output for display
						CLR SHIFT ;shift register
						SETB SHIFT
						DJNZ R3, loop3c

						DJNZ R4, loop4c



						;loop on the lines
						MOV DPTR, #lines
						MOV A, R6
						MOVC A, @A+DPTR

						MOV R2, #8
loop2:					RRC A
						MOV DATA_BITS,C ;carry of the right shift in data output for display
						CLR SHIFT ;shift register
						SETB SHIFT
						DJNZ R2,loop2

						CLR STORE 
						SETB STORE ; store
						CLR STORE

						INC R6
						INC R5; increment the counter of Blocks 
						CJNE R5, #8, endScreenISR
						MOV R5, #0 	
						
endScreenISR:			
						CLR RS0
						CLR RS1
						MOV TH2,#0FBh 
						MOV TL2,#08Fh 
						POP ACC
						POP PSW
						RETI		


;;------------------------------------   CODE MEM DATA   --------------------------------------------------

lines:		DB 01111111b ; pattern to easily follow lines
			DB 10111111b
			DB 11011111b
			DB 11101111b
			DB 11110111b
			DB 11111011b
			DB 11111101b
Key0:		DB 11001b
			DB 10110b
			DB 10110b
			DB 10110b
			DB 10110b
			DB 10110b
			DB 11001b
			DB 00000b
Key1: 		DB 11101b
			DB 11001b
			DB 11101b
			DB 11101b
			DB 11101b
			DB 11101b
			DB 11000b
			DB 00000b
Key2: 		DB 11001b
			DB 10110b
			DB 11110b
			DB 11001b
			DB 10111b
			DB 10110b
			DB 11001b
			DB 00000b
Key3: 		DB 11001b
			DB 10110b
			DB 11110b
			DB 10001b
			DB 11110b
			DB 10110b
			DB 11001b
			DB 00000b
Key4: 		DB 11101b
			DB 11001b
			DB 10101b
			DB 10101b
			DB 10000b
			DB 11101b
			DB 11101b
			DB 00000b
Key5: 		DB 11001b
			DB 10110b
			DB 10111b
			DB 11001b
			DB 11110b
			DB 10110b
			DB 11001b
			DB 00000b
Key6: 		DB 11001b
			DB 10110b
			DB 10111b
			DB 11001b
			DB 10110b
			DB 10110b
			DB 11001b
			DB 00000b
Key7: 		DB 11001b
			DB 10110b
			DB 11110b
			DB 11000b
			DB 11110b
			DB 11110b
			DB 11110b
			DB 00000b
Key8: 		DB 11001b
			DB 10110b
			DB 10110b
			DB 11001b
			DB 10110b
			DB 10110b
			DB 11001b
			DB 00000b
Key9: 		DB 11001b
			DB 10110b
			DB 10110b
			DB 11001b
			DB 11110b
			DB 10110b
			DB 11001b
			DB 00000b
KeyEmpty:	DB 11111b
			DB 11111b
			DB 11111b
			DB 11111b
			DB 11111b
			DB 11111b
			DB 11111b
			DB 00000b
KeyUS:		DB 11111b
			DB 11111b
			DB 11111b
			DB 11111b
			DB 11111b
			DB 11111b
			DB 10000b
			DB 00000b
end

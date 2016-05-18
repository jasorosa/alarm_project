$include(t89c51cc01.inc)

; DEFINITIONS
SHIFT EQU P4.0
DATA_BITS  EQU P4.1
STORE EQU P3.2
DATABLOCK EQU 040h
BUZZER EQU P2.2
TMP_KB EQU 031h
TMP_DP EQU 032h
BLOCK1 EQU 041h
BLOCK2 EQU 042h
BLOCK3 EQU 043h
BLOCK4 EQU 044h
BLOCK5 EQU 045h
BLOCK6 EQU 046h
BLOCK7 EQU 047h
BLOCK8 EQU 048h
;INIT ISRs
ORG 0000h
LJMP init
ORG 000Bh
LJMP keyboardISR ; timer 0
;ORG 0013h
;LJMP extISR ; ext interrupt 1
ORG 001Bh
LJMP tempISR ; timer 1
ORG 002Bh
LJMP screenISR ; timer 2


init:					MOV SP,#070h
						MOV TMOD,#00010001b ; 16 bit mode for timer 0 and 1 
						MOV TH0,#0FBh ; low freq to check keyboard
						MOV TL0,#08Fh ;
						MOV TH1, #0Bh ; about 15Hz for timer 1
						MOV TL1, #0DBh ;
						MOV TH2,#0FBh ;400Hz
						MOV TL2,#01Dh 
						
						MOV R4, #00110100b ; 2 LSD 4 first = 4, 4 next = 3
						MOV R5, #00010010b ; 2 MSD 4 next = 2, 4 next = 1 => code is 1234
						MOV R0, #00h
						MOV R6, #00h
						MOV TMP_KB, #0Fh ; RAM byte addressable to save previous state of keyboard (random initial value)
						MOV TMP_DP, #0Fh ; RAM byte addressable to store temporarily "data pointer" for screen (random init value) 
						
						MOV BLOCK1, #0
						MOV BLOCK2, #8
						MOV BLOCK3, #16
						MOV BLOCK4, #24
						MOV BLOCK5, #32
						MOV BLOCK6, #40
						MOV BLOCK7, #48
						MOV BLOCK8, #56
						
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
						SETB EA ; enable int
						SETB ET0 ; enable timer 0 interrupt
						SETB ET1 ; enable timer 1 interrupt
						SETB ET2 ; enable timer 2 interrupt
						SETB TR0 ; enable timer 0, 1, 2
						SETB TR1
						SETB TR2
						

main:					CJNE R6, #02h, main ;if alarm is not OFF : end
						MOV C, P1.0
						MOV P2.3, C
						JNC main
						LJMP detection

detection:				MOV R7, #0E1h ; set counter to 225 to go to 15s
						INC R6
						MOV BLOCK1, #18h
						LJMP main

;------------------------------------   KEYBOARD   --------------------------------------------------
keyboardISR:			PUSH PSW ; review PSW, ACC and PUSH/POP !!!!
						PUSH ACC
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
						MOV TMP_DP, #0 ; each code block has 8 lines so if we want key0, we start from key0+0, if key1 : key0+8 and so on
						LJMP entercode
one:					MOV R1, #01h
						MOV TMP_DP, #8
						LJMP entercode
two:					MOV R1, #02h
						MOV TMP_DP, #16
						LJMP entercode
three:					MOV R1, #03h
						MOV TMP_DP, #24
						LJMP entercode
four:					MOV R1, #04h
						MOV TMP_DP, #32
						LJMP entercode
five:					MOV R1, #05h
						MOV TMP_DP, #40
						LJMP entercode
six:					MOV R1, #06h
						MOV TMP_DP, #48
						LJMP entercode
seven:					MOV R1, #07h
						MOV TMP_DP, #56
						LJMP entercode
eight:					MOV R1, #08h
						MOV TMP_DP, #64
						LJMP entercode
nine:					MOV R1, #09h
						MOV TMP_DP, #72
						LJMP entercode
letterA:				LJMP endKeyboardISR
letterB:				LJMP endKeyboardISR
letterC:				LJMP clearcode
letterD:				LJMP endKeyboardISR
letterE:				LJMP endKeyboardISR
letterF:				LJMP endKeyboardISR
nothing: 				MOV TMP_KB,#0Fh ; if no button pressed : set the stored value at a random value 0Fh
						LJMP endKeyboardISR

entercode:				MOV A,TMP_KB
						CJNE A,#0Fh, endKeyboardISR ; the stored value in TMP_KB is used to debounce the keyboard
						LJMP continue
continue:				MOV A, R1
						MOV TMP_KB, A
						CJNE R0, #00h, code2 ;if counter of pressed button (R0) is 0 its the first number of the code, else go to code2(second number)
						MOV A, TMP_DP			 ;code stored on 2 registers. we use SWAP function to do this well. If code is 1234 : R3 : 00010010 (1,2)
						MOV BLOCK5, A			 ;																					  R4 : 00110100 (3,4)
						MOV  A, R1
						SWAP A
						MOV  R3, A
code2:					CJNE R0, #01h, code3
						MOV A, TMP_DP
						MOV BLOCK6, A
						MOV  A, R1			;second number of the code
						ADD  A, R3
						MOV  R3, A
code3:					CJNE R0, #02h, code4
						MOV A, TMP_DP
						MOV BLOCK7, A
						MOV  A, R1			;third
						SWAP A
						MOV  R2, A
code4:					CJNE R0, #03h, incR0
						MOV A, TMP_DP
						MOV BLOCK8, A
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
						CJNE R6, #00h, desactivate ; if alarm activated, desactivate it
						MOV R6, #01h ; otherwise, activate it (prealarm before actually set on)
						MOV BLOCK1, #08h
						MOV R7, #0E1h ; put 15 seconds of period in the counter before prealarm => alarm (counter at 225 with 15Hz)
						LJMP endKeyboardISR
						
desactivate:			MOV R6, #00h
						MOV R7, #00h ; reset the counter if the alarm is desactivate
						SETB P2.4 ;debug
						MOV BLOCK1, #00h
						LJMP clearcode
						
wrong:					; SHOW WITH SCREEN OR LED ITS WRONG
						LJMP clearcode

clearcode:				MOV R2, #00h
						MOV R3, #00h
						MOV R0, #00h
						MOV BLOCK5, #58h
						MOV BLOCK6, #58h
						MOV BLOCK7, #58h
						MOV BLOCK8, #58h
						LJMP endKeyboardISR
						
endKeyboardISR:			MOV TH0,#00h ; low freq to detect keyboard 
						MOV TL0,#00h 
						POP ACC
						POP PSW
						RETI						

;------------------------------------   "Temporisation" PROGRAM   --------------------------------------------------

tempISR:				PUSH PSW
						PUSH ACC
						CJNE R6, #00h, next ; alarm is not activated : end otherwise next
						LJMP endTempISR
next:					CJNE R6, #01h, decR7
						MOV BLOCK1, #08h
						CJNE R6, #03h, kikou
						MOV BLOCK1, #18h
kikou:					CJNE R7, #96h, decR7 ; after 5s clear the display
						MOV R2, #00h
						MOV R3, #00h
						MOV R0, #00h
						MOV BLOCK5, #58h
						MOV BLOCK6, #58h
						MOV BLOCK7, #58h
						MOV BLOCK8, #58h
decR7:					DJNZ R7, endTempISR ; 15s decounting. normally screen ! (?? what ? why screen ?)
						CLR P2.4
						CJNE R6, #01h, setAlert ; if not pre alarm it is pre alert and after 15s we can start SKRIMIN
						CJNE R6, #03h, activation ; it is prealarm so activate alarm system after 15sc
						LJMP endTempISR

						
activation:				INC R6 ;prealarm mode to alarm mode
						CLR P2.4
						MOV BLOCK1, #10h
						LJMP endTempISR
						
						
setAlert:				MOV R6, #04h ;prealert mode to alert mode
						MOV BLOCK1, #20h
						LJMP endTempISR
					

endTempISR:				MOV TH1,#0Bh 
						MOV TL1,#0DBh 
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
						MOV DPTR, #Key0
						SETB RS1 ; change register bank
						MOV R4, #8 ; repeat pattern 8 times
						; number of repeated pattern
loop4:					MOV A,R4
						ADD A,#DATABLOCK
						MOV R0,A
								
						MOV A, R6 ; R6 is an index for the used row
						
						CJNE A,#7, column_disp ; reset row index when complete
reset:					MOV A, #00h
						MOV R6, #0
						
column_disp:			ADD A, @R0
						MOVC A, @A+DPTR
						MOV R3, #5
						;each column bit (one by one)
loop3:					RRC A ;right shift
						MOV DATA_BITS,C ;carry of the right shift in data output for display
						CLR SHIFT ;shift register
						SETB SHIFT
						DJNZ R3, loop3
						
						DJNZ R4, loop4
						;lines
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
						CLR RS1
						LJMP endScreenISR	
						
endScreenISR:			
						CLR RS0
						CLR RS1
						
						CJNE R6, #04h, endint
						CPL BUZZER
						MOV TH2,#0FBh ;400Hz
						MOV TL2,#01Dh 
						
endint:					POP ACC
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
Key1: 		DB 10110b
			DB 10010b
			DB 10010b
			DB 10100b
			DB 10100b
			DB 10100b
			DB 10110b
			DB 00000b
Key2: 		DB 10000b
			DB 10111b
			DB 10111b
			DB 10000b
			DB 10111b
			DB 10111b
			DB 10000b
			DB 00000b
Key3: 		DB 10000b
			DB 10110b
			DB 10110b
			DB 10000b
			DB 10111b
			DB 10111b
			DB 10111b
			DB 00000b
Key4: 		DB 11000b
			DB 11101b
			DB 11101b
			DB 11101b
			DB 11101b
			DB 11101b
			DB 11000b
			DB 00000b
Key5: 		DB 10000b
			DB 10111b
			DB 10111b
			DB 10000b
			DB 10111b
			DB 10111b
			DB 10000b
			DB 00000b
Key6: 		DB 10000b
			DB 10111b
			DB 10111b
			DB 10111b
			DB 10111b
			DB 10111b
			DB 10000b
			DB 00000b
Key7: 		DB 10000b
			DB 10111b
			DB 10111b
			DB 10000b
			DB 10111b
			DB 10111b
			DB 10000b
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
			DB 11000b
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

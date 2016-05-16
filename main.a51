$include (t89c51cc01.inc)

;Boot code
ORG 0000h
LJMP init

;Interrupt address vectors

ORG 000Bh
LJMP timer0int


init :

	SHIFT EQU P4.0
	DATA_BITS  EQU P4.1
	STORE EQU P3.2
	;SETB RS1 ; change register bank
	; TIMER  AND REGISTER P0 INITIALIZATION
	MOV TMOD,#00000001h
	MOV TH0,#0FFh  ; 440Hz
	MOV TL0,#0FFh
	CLR SHIFT ; shift
	CLR DATA_BITS ; data
	CLR STORE ; store
	SETB RS1 ; init some registers in register bank (1,1) for screen
	SETB RS0
	MOV R6, #0
	MOV A,  #0
	MOV R5, #0 ; counter of blocks
	MOV 38h, #88
	MOV 39h, #88
	MOV 3Ah, #88
	MOV 3Bh, #88
	MOV 3Ch, #80
	MOV 3Dh, #80
	MOV 3Eh, #80
	MOV 3Fh, #80
	CLR RS0
	CLR RS1
	SETB ET0
	SETB EA
	SETB TR0
	

;Main program

main:					LJMP	main

timer0int:				PUSH PSW
						PUSH ACC
						SETB RS1
						SETB RS0
						CLR DATA_BITS
						CLR SHIFT
						CLR STORE
						CLR P2.3
						MOV A,R5
						;SUBB A,#01h ; number of empty block
						MOV R4,A
						
						
						MOV DPTR, #KeyEmpty
						
						CJNE R4, #0, loop4a
						LJMP skip
;;;;;;;;;;;;;;;;;;;;;; number of repeated pattern
loop4a:					MOV A, R6 ; R6 is an index for the used row
						CJNE A,#7, column_dispa ; reset row index when complete
reseta:					MOV A, #0
						MOV R6, #0
						
column_dispa:			MOVC A, @A+DPTR
						MOV R3, #5
;;;;;;;;;;;;;;;;;;;;;;;;;each column bit (one by one)
loop3a:					RRC A ;right shift
						MOV DATA_BITS,C ;carry of the right shift in data output for display
						CLR SHIFT ;shift register
						SETB SHIFT
						DJNZ R3, loop3a
						
						DJNZ R4, loop4a
						
						
skip:					MOV DPTR, #Key0
						;MOV R4, #1 ; repeat pattern N times
;;;;;;;;;;;;;;;;;;;;;; number of repeated pattern
loop4b:					MOV A, R6 ; R6 is an index for the used row
						CJNE A,#7, column_dispb ; reset row index when complete
resetb:					MOV A, #0
						MOV R6, #0
						
column_dispb:			ADD A, 38h
						MOVC A, @A+DPTR
						MOV R3, #5
;;;;;;;;;;;;;;;;;;;;;;;;;each column bit (one by one)
loop3b:					RRC A ;right shift
						MOV DATA_BITS,C ;carry of the right shift in data output for display
						CLR SHIFT ;shift register
						SETB SHIFT
						DJNZ R3, loop3b
						
						;DJNZ R4, loop4b
						
						MOV A, #08
						SUBB A,R5  ; number of empty block at left : 8 - position of current block
						MOV R4,A
						
						MOV DPTR, #KeyEmpty
						
;;;;;;;;;;;;;;;;;;;;;; number of repeated pattern
loop4c:					MOV A, R6 ; R6 is an index for the used row
						CJNE A,#7, column_dispc ; reset row index when complete
resetc:					MOV A, #0
						MOV R6, #0
						
column_dispc:			MOVC A, @A+DPTR
						MOV R3, #5
;;;;;;;;;;;;;;;;;;;;;;;;;each column bit (one by one)
loop3c:					RRC A ;right shift
						MOV DATA_BITS,C ;carry of the right shift in data output for display
						CLR SHIFT ;shift register
						SETB SHIFT
						DJNZ R3, loop3c
						
						DJNZ R4, loop4c
						
						
						
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;lines
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
						INC R5
						CLR RS1
						CLR RS0
						LJMP RESET_TIMER	
						; TIMER RESETTING
RESET_TIMER:			MOV TH0,#0FFh
						MOV TL0,#0FFh
						POP ACC
						POP PSW
						LJMP endint

endint:					RETI

						
						

;Functions

;Code Memory Data

lines:		DB 01111111b ; pattern to easily follow lines
			DB 10111111b
			DB 11011111b
			DB 11101111b
			DB 11110111b
			DB 11111011b
			DB 11111101b
Key0:		DB 10000b
			DB 10110b
			DB 10110b
			DB 10110b
			DB 10110b
			DB 10110b
			DB 10000b
			DB 00000b
Key1: 		DB 11101b
			DB 11001b
			DB 11101b
			DB 11101b
			DB 11101b
			DB 11101b
			DB 11000b
			DB 00000b
Key2: 		DB 10000b
			DB 11110b
			DB 11110b
			DB 10000b
			DB 10111b
			DB 10111b
			DB 10000b
			DB 00000b
Key3: 		DB 10000b
			DB 11110b
			DB 11110b
			DB 10000b
			DB 11110b
			DB 11110b
			DB 10000b
			DB 00000b
Key4: 		DB 11101b
			DB 11001b
			DB 10101b
			DB 10101b
			DB 10000b
			DB 11101b
			DB 11101b
			DB 00000b
Key5: 		DB 10000b
			DB 10111b
			DB 10111b
			DB 10000b
			DB 11110b
			DB 11110b
			DB 10000b
			DB 00000b
Key6: 		DB 10000b
			DB 10111b
			DB 10111b
			DB 10000b
			DB 10110b
			DB 10110b
			DB 10000b
			DB 00000b
Key7: 		DB 10000b
			DB 11110b
			DB 11110b
			DB 11000b
			DB 11110b
			DB 11110b
			DB 11110b
			DB 00000b
Key8: 		DB 10000b
			DB 10110b
			DB 10110b
			DB 10000b
			DB 10110b
			DB 10110b
			DB 10000b
			DB 00000b
Key9: 		DB 10000b
			DB 10110b
			DB 10110b
			DB 10000b
			DB 11110b
			DB 11110b
			DB 10000b
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
						
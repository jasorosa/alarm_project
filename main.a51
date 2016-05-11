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
	
	; TIMER  AND REGISTER P0 INITIALIZATION
	MOV TMOD,#00000001h
	MOV TH0,#0FBh  ; 440Hz
	MOV TL0,#08Fh
	SETB ET0
	SETB EA
	SETB TR0
	CLR SHIFT ; shift
	CLR DATA_BITS ; data
	CLR STORE ; store
	MOV R6, #0
	MOV A,  #0


;Main program

main:					LJMP	main

timer0int:				CLR DATA_BITS
						CLR SHIFT
						CLR STORE
						CLR P2.3
						MOV DPTR, #Key0
						SETB RS1 ; change register bank
						MOV R4, #8 ; repeat pattern 8 times
;;;;;;;;;;;;;;;;;;;;;; number of repeated pattern
loop4:					MOV A, R6 ; R6 is an index for the used row
						CJNE A,#7, column_disp ; reset row index when complete
reset:					MOV A, #0
						MOV R6, #0
						
column_disp:			MOVC A, @A+DPTR
						MOV R3, #5
;;;;;;;;;;;;;;;;;;;;;;;;;each column bit (one by one)
loop3:					RRC A ;right shift
						MOV DATA_BITS,C ;carry of the right shift in data output for display
						CLR SHIFT ;shift register
						SETB SHIFT
						DJNZ R3, loop3
						
						DJNZ R4, loop4
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
						CLR RS1
						LJMP RESET_TIMER	
						; TIMER RESETTING
RESET_TIMER:			MOV TH0,#0FBh
						MOV TL0,#08Fh
						LJMP endint

endint:					RETI

						
						

;Functions

;Code Memory Data

lines:		DB	01111111b ; pattern to easily follow lines
			DB	10111111b
			DB	11011111b
			DB	11101111b
			DB	11110111b
			DB	11111011b
			DB	11111101b

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
			
KeyVoid:	DB 11111b
			DB 11111b
			DB 11111b
			DB 11111b
			DB 11111b
			DB 11111b
			DB 10000b
			DB 00000b
					
end						
						

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
	
timer0int:				JB P2.6,nosound ; nosound if button isnt pressed
						CPL P2.2 ; change state of buzzer
						
nosound:				JB P2.5,Hz880 ; if switch on, other freq
						MOV TH0,#0FBh ; freq at 440
						MOV TL0,#08Fh
						LJMP endint
						
Hz880:					MOV TH0,#0FDh ; freq at 880 
						MOV TL0,#0C7h
						
endint:					RETI
end
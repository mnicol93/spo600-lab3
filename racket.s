	define BLACK $00
	define WHITE $01
	define UP $80
	define DOWN $82

	; Initial position of user's 1 racket
	lda #WHITE
	sta $03C0
	sta $03E0
	sta $0400
	sta $0420

	; Setting a pointer to the top pixel of the 		 
 	; racket, which will be used as a reference
	LDA #$C0
	STA $10
	LDA #$03
	STA $11

	; Initial point, waiting for user to move
INPUT:	LDA $FF
	CMP #$71
	BEQ DONE
	CMP #DOWN
	BEQ MDOWN
	JMP INPUT

	
DONE:	BRK

MDOWN:  LDA #$00	; Only move once, so reset $FF
	STA $FF 
	
	; Print reference pixel black to give moving 
        ; sensation
	LDA #BLACK
	LDY #$00
	STA ($10),y

	; Move the reference one pixel below
	CLC
	LDA $10
	ADC #$20
	STA $10
	LDA $11
	ADC #$00
	STA $11

	; Print one more pixel at the new end	
	LDA #WHITE
	LDY #$60
	STA ($10),y

	JMP INPUT 	; Wait for user's input again

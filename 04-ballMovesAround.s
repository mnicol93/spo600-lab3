	define BLACK $00
	define WHITE $01
	define UP $80
	define DOWN $82
	define XBALL $22 
	define YBALL $24
	define BDIR  $26

;Random initial ball position
	LDA $FE		; Load Random Number
	CMP #$7F	; Compare to half of #FF
	BPL ILEFT	; Ball starts on P1
	JMP IRIGHT	; Ball starts on P2

ILEFT:
	; Initial position of the ball
	lda #$08
	sta $03C1
	; Memory location where ball is stored
	lda #$C1
	sta $20
	lda #$03
	sta $21
	; Adjust X position
	LDA #$1
	STA XBALL
	JMP SET

	LDA #$00
	STA BDIR

IRIGHT:
	; Initial position of the ball
	lda #$08
	sta $03DE
	; Memory location where ball is stored
	lda #$DE
	sta $20
	lda #$03
	sta $21
	; Adjust X position
	LDA #$1E
	STA XBALL

	LDA #$10
	STA BDIR

	JMP SET

SET:
	; Initial position of user's 1 racket
	lda #WHITE
	sta $03C0
	sta $03E0
	sta $0400
	sta $0420

	;Initial position of user's 2 racket
	sta $03DF
	sta $03FF
	sta $041F
	sta $043F

	; Setting a pointer to the top pixel of the 		 
 	; racket, which will be used as a reference
	LDA #$C0
	STA $10
	LDA #$03
	STA $11
	
	; Setting a pointer to the top pixel of the 		 
 	; racket, which will be used as a reference
	LDA #$DF
	STA $12
	LDA #$03
	STA $13

	; Index to control the racket's 1 position
	LDA #$E		; Position where it starts
	STA $14		; Memory where index resides 
	
	JMP SERVE

SERVE:  ; Everything is ready. Wait for user's service
	LDA $FF
	CMP #$71
	BEQ DONE
	CMP #DOWN
	BEQ SRVDW
	CMP #UP
	BEQ SRVUP
	JMP SERVE

SRVDW:
	; Print current pixel black 
	LDA #BLACK
	LDY #$00
	STA ($20),y

	; Move the reference one pixel below
	CLC
	LDA $20
	ADC #$21
	STA $20

	; Add one pixel to the index X & Y
	CLC
	LDA $22
	ADC #$01
	STA $22

	LDA $24
	ADC #$01
	STA $24

	; Print the ball on the new index
	LDA #$08
	LDY #$20
	STA ($20),y

	JMP MAIN
SRVUP:
	; Print current pixel black 
	LDA #BLACK
	LDY #$00
	STA ($20),y

	; Move reference one above and one to the right
	CLC
	LDA $20
	ADC #$01
	STA $20
	LDA $21
	ADC #$00
	STA $21	

	SEC
	LDA $20
	SBC #$20
	STA $20
	LDA $21
	SBC #$00
	STA $21

	; Add one pixel to the index X, Subtract 1 to Y
	CLC
	LDA $22
	ADC #$01
	STA $22

	SEC
	LDA $24
	SBC #$01
	STA $24

	; Print the ball on the new index
	LDA #$08
	LDY #$00
	STA ($20),y

	CLC
	LDA BDIR
	ADC #$01
	STA BDIR

	JMP MAIN
	
DONE:	BRK
	; Initial point, waiting for user to move
MAIN:	
	CLC
	LDA $27
	ADC #$01
	STA $27
	CMP #$FF
	BEQ MOVBAL

	LDA $FF
	CMP #$71
	BEQ DONE
	CMP #DOWN
	BEQ MDOWN
	CMP #UP
	BEQ MOVUP

	
	JMP MAIN


; ------------------ USER 1 RACKET -------------------

MDOWN:  LDA #$00	; Only move once, so reset $FF
	STA $FF 

	JSR DCHECK	; Check limits are not reached

	; Print reference pixel black to move
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

	; Add one pixel to the index
	CLC
	LDA $14
	ADC #$01
	STA $14

	; Print one more pixel at the new end	
	LDA #WHITE
	LDY #$60
	STA ($10),y

	JMP MAIN 	; Wait for user's input again

JMAIN:
	JMP MAIN

MOVUP:  LDA #$00	; Only move once, so reset $FF
	STA $FF 

	JSR UCHECK	; Check limits are not reached

	; Print reference pixel black to move
	LDA #BLACK
	LDY #$60
	STA ($10),y

	; Move the reference one pixel above
	SEC
	LDA $10
	SBC #$20
	STA $10
	LDA $11
	SBC #$00
	STA $11

	; Subtract one pixel to the index
	SEC
	LDA $14
	SBC #$01
	STA $14

	; Print one more pixel at the new index
	LDA #WHITE
	LDY #$00
	STA ($10),y

	JMP MAIN

DCHECK: LDA $14
	CMP #$1C        ; Lower bound
	BPL MAIN
	RTS

UCHECK: LDA $14
	CMP #$01	; Upper bound
	BMI MAIN
	RTS

; ------------------ USER 2 RACKET -------------------


; ------------------ BALL DIRECTION -------------------
; I am gonna use BDIR ($26) to set the direction:
	; #$00 means ball goes to the right and down
	; #$01 means ball goes to the right and up
	; #$11 means ball goes to the left and up
	; #$10 means ball goes to the left and down

MOVBAL: ; Check the direction
	LDA BDIR
	CMP #$01
	BEQ BALLUP
	CMP #$00
	BEQ BALLDW

BALLUP:	; Ball moving upwards.
	; Print current pixel black
	LDA #BLACK
	LDY #$00
	STA ($20),y
	
	; Move the reference one pixel up
	CLC
	LDA $20
	ADC #$20
	STA $20

	LDA $21
	ADC #$00
	STA $21
	
	; Subtract one pixel to index Y
	CLC
	LDA $24
	SBC #$01
	STA $24
	
	; If ball hasn't reached end, return
	CMP #$00
	BNE JMAIN
	; Otherwise, subtract #01 from BDIR
	; to indicate down
	SEC
	LDA BDIR
	SBC #$01
	STA BDIR
	
	JMP JMAIN

BALLDW: ; Ball moving downwards

BALLRG: ; Ball moving to the right.

BALLLT: ; Ball moving to the left.


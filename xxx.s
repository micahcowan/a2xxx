;#define CFGFILE apple2-asm.cfg

.macpack apple2

.include "common.inc"

Asc_1   = $31
Asc_2   = $32
Scr_CR  = $8D
Scr_1   = $B1
Scr_2   = $B2
Scr_A   = $C1
Scr_Z   = $DA

WNDTOP  = $22
CH      = $24
CV      = $25
BASL	= $28
CSWL    = $36

KbdStrobe= $C000
AnyKey   = $C010
Page2Off = $C054
Page2On  = $C055
OpenApple   = $C061
ClosedApple = $C062

Mon_HOME    = $fc58
Mon_VTABZ   = $fc24
Mon_COUT    = $FDED

.ifdef __8BITWORKSHOP__
.org $803
bootStrap8bws:
	jmp Begin
.res $2000 - *
.endif

.org $2000

Begin:  JSR Mon_HOME    ; Clear the screen at start
	JSR PrintText	; Draw text to screen, as quickly as possible
	JSR CopyP2
        LDA #1
        STA PrevKey
KeyWait:LDA KbdStrobe
	CMP #$C1
        BCS @doRepeats
	CMP PrevKey
        BEQ KeyWait
        STA PrevKey
@doRepeats:
        CMP #$B1 ; '1'
        BNE :+
        JSR PrintText
        JMP KeyWait
:	CMP #$B2 ; '2'
	BNE :+
        JSR PrintXText
        JMP KeyWait
:	CMP #$B3 ; '3'
	BNE :+
        JSR BlastText
        JMP KeyWait
:	CMP #$B4 ; '4'
	BNE :+
        JSR BlastXText
        JMP KeyWait
:       CMP #$B5 ; '5'
	BNE :+
        BIT Page2Off
	JMP KeyWait
:       CMP #$B6 ; '6'
	BNE :+
        BIT Page2On
        JMP KeyWait
:	CMP #$C1 ; 'A'
	BNE :+
        JSR PrintText
        JSR PrintXText
        JMP KeyWait
:	CMP #$C2 ; 'B'
	BNE :+
        JSR BlastText
        JSR BlastXText
        JMP KeyWait
:	CMP #$C3 ; 'C'
	BNE :+
        BIT Page2On
        BIT Page2Off
        JMP KeyWait
:	JMP KeyWait

CopyP2: LDA #0
	STA BASL
        STA $6
        LDA #$4
        STA BASL+1
        LDA #$8
        STA $7
CopySt: LDY #0
CopyLp: LDA (BASL),y
	CMP #$C1 ; >= 'A'?
        BCC @noTrans
        CMP #$DB ; < 'Z'+1 ?
        BCS @noTrans
        LDA #$D8 ; -> 'X'
@noTrans:
	STA ($6),y
        INY
        CPY #120
        BNE CopyLp
        ; Done with a set of 3 lines.
       	LDA #$80
        CLC
        ADC BASL
        STA BASL
        BCC :+
        INC BASL+1
:	LDA #$80
	CLC
        ADC $6
        STA $6
        BCC :+
        INC $7
:	LDA $7
	CMP #$D
        BNE CopySt
	rts

PrevKey:
	.byte 0
Message:
	xTrans .set 0
	.include "print-defs.inc"
        .include "message.inc"
XMessage:
	xTrans .set 1
        .include "print-defs.inc"
        .include "message.inc"
PrintText:
	lda #<Message
        sta $6
        lda #>Message
        sta $7
PrintStart:
	lda #0
        sta CH
        sta CV
        jsr Mon_VTABZ
        ldy #0
PrintLoop:
	lda ($6),y
        beq PrintDone
        jsr Mon_COUT
        iny
        bne PrintLoop
        inc $7
        bne PrintLoop
PrintDone:
	rts
PrintXText:
	lda #<XMessage
        sta $6
        lda #>XMessage
        sta $7
        jmp PrintStart

BlastText:
	xTrans .set 0
	.include "blast-defs.inc"
	.include "message.inc"
BlastXText:
	xTrans .set 1
	.include "blast-defs.inc"
	.include "message.inc"


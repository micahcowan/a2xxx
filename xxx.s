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

TxtBufPg1 = $4
TxtBufPg2 = $8
StrPtr  = $06
CpyFlag = $08
TxtAddr1= $1A
TxtAddr2= $1C
KeySv   = $EB
TransFn = $EC

WNDTOP  = $22
CH      = $24
CV      = $25
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
	LDA #1
        STA PrevKey
KeyWait:LDA KbdStrobe
        AND #7
	CMP PrevKey
        BEQ KeyWait
        STA PrevKey
        CMP #1
        BNE :+
        JSR PrintText
        JMP KeyWait
:	CMP #2
	BNE :+
        JSR PrintXText
        JMP KeyWait
:	CMP #3
	BNE :+
        JSR BlastText
        JMP KeyWait
:	CMP #4
	BNE :+
        JSR BlastXText
:       JMP KeyWait

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


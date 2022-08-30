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
BASL    = $28
PROMPT  = $33
CSWL    = $36
A2L     = $3E

KbdStrobe= $C000
AnyKey   = $C010
Page2Off = $C054
Page2On  = $C055
OpenApple   = $C061
ClosedApple = $C062

Mon_HOME    = $fc58
Mon_VTABZ   = $fc24
Mon_CLREOL  = $FC9C
Mon_WAIT    = $FCA8
Mon_GETLN   = $FD6A
Mon_PRBYTE  = $FDDA
Mon_COUT    = $FDED
Mon_GETNUM  = $FFA7

.ifdef __8BITWORKSHOP__
.org $803
bootStrap8bws:
        jmp Begin
.res $2000 - *
.endif

.org $2000

Begin:  JSR Mon_HOME    ; Clear the screen at start
        JSR PrintText   ; Draw text to screen, as quickly as possible
        JSR CopyP2
        LDA #1
        STA PrevKey
KeyWait:
ToggleFn = KeyWait + 1
        JSR NoToggle
        LDA KbdStrobe
        BPL KeyWait
        BIT AnyKey
        CMP #$C1 ; 'A'
        BCS Toggles ; >= 'A'?
        PHA
        LDA #<NoToggle
        STA ToggleFn
        LDA #>NoToggle
        STA ToggleFn+1
        PLA
        ; Start checking keypresses
        CMP #$B0 ; '0'
        BNE :+
        LDA #$1
        STA WaitVal
        JMP SetPageToggle
:       CMP #$B1 ; '1'
        BNE :+
        JSR PrintText
        JMP KeyWait
:       CMP #$B2 ; '2'
        BNE :+
        JSR PrintXText
        JMP KeyWait
:       CMP #$B3 ; '3'
        BNE :+
        JSR BlastText
        JMP KeyWait
:       CMP #$B4 ; '4'
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
:       CMP #$AB ; '+' or '->'
        BEQ :+
        CMP #$95
        BNE :++
:       INC WaitVal
        JMP SetPageToggle
:       CMP #$AD ; '-' or '<-'
        BEQ :+
        CMP #$88
        BNE :++
:       DEC WaitVal
        JMP SetPageToggle
:       CMP #$BD ; '='
        BNE :+
        LDA #$70
        STA WaitVal
        JMP SetPageToggle
:       JMP KeyWait
Toggles:CMP #$C1 ; 'A'
        BNE :+
        LDA #<PrintToggle
        STA ToggleFn
        LDA #>PrintToggle
        STA ToggleFn+1
        JMP KeyWait
:       CMP #$C2 ; 'B'
        BNE :+
        LDA #<BlastToggle
        STA ToggleFn
        LDA #>BlastToggle
        STA ToggleFn+1
        JMP KeyWait
:       CMP #$C3 ; 'C'
        BNE NotC
SetPageToggle:
        LDA #<PageToggle
        STA ToggleFn
        LDA #>PageToggle
        STA ToggleFn+1
        ; Put the wait time in the corner
        LDA #23
        STA CV
        JSR Mon_VTABZ
        LDA #37
        STA CH
        LDA WaitVal
        JSR Mon_PRBYTE
        ; Now copy the wait time to page 2 also
        LDA BASL
        STA $6
        LDA BASL+1
        CLC
        ADC #4
        STA $7
        LDY #37
        LDA (BASL),Y
        STA ($6),Y
        INY
        LDA (BASL),Y
        STA ($6),Y
        JMP KeyWait
NotC:   CMP #$C9 ; 'I'
        BNE :+
        ; Prompt for a hex "wait" value for 'C' demo
        LDA #0
        STA CH
        STA CV
        JSR Mon_VTABZ
        JSR Mon_CLREOL
        LDA #$BA ; ':'
        STA PROMPT
        BIT AnyKey
        JSR Mon_GETLN
        LDY #0
        JSR Mon_GETNUM
        LDA A2L
        STA WaitVal
        JMP Begin
:       JMP KeyWait

PrintToggle:
        JSR PrintXText
        JMP PrintText
BlastToggle:
        JSR BlastXText
        JMP BlastText
PageToggle:
        BIT Page2On
WaitLda:
WaitVal = WaitLda + 1
        LDA #$70
        JSR Mon_WAIT
        BIT Page2Off
        LDA WaitVal
        JMP Mon_WAIT
NoToggle:
        RTS

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
:       LDA #$80
        CLC
        ADC $6
        STA $6
        BCC :+
        INC $7
:       LDA $7
        CMP #$D
        BNE CopySt
        RTS

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


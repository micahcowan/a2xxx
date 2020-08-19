.macpack apple2

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

.org $2000

Begin:  JSR Mon_HOME    ; Clear the screen at start
        LDA #$80        ; Indicate we should copy to scr 2 when X's (first time)
        STA CpyFlag
CtrInit:
        JSR SaveKey
        JSR XXX
DrawMsg:LDA #<Message   ; Initialize start of string
        STA StrPtr
        LDA #>Message
        STA StrPtr+1
        LDY #$00
DrawLp:
        LDA (StrPtr),Y  ; Load next character
        BEQ IterMsg     ; Done drawing if == NUL byte
        JSR XCall       ; Replace letters with "X" if open-apple pressed

        ; Just before CR, check our vertical position,
        ; and halt if we're on the last line
        CMP #Scr_CR
        BNE NotLastCR
        LDX CV
        CPX #23
        BEQ DrawEnd
NotLastCR:
        JSR MyCout      ; Jump to user-hookable/monitor's char-printing routine
        INC StrPtr
        BNE DS
        INC StrPtr+1
DS:     
        JSR MaybeSwitch
        JMP DrawLp
IterMsg:
        Jmp DrawMsg
DrawEnd:JSR Origin      ; Return cursor to 0, 0
        JSR MaybeCopy
        JMP CtrInit     ;  -- could pause or exit on some key here?

MyCout: JMP (CSWL)

SaveKey:LDA AnyKey
        BPL NoKey
        LDA KbdStrobe
        AND #$7F
        STA KeySv
        RTS
NoKey:  LDA #$00
        STA KeySv
        RTS

XXX:
        LDA KeySv
        CMP #Asc_1
        BNE XNo         ;  return if it isn't
XYes:   LDA #<XTrans    ; Arrange for all uppercase letters to transform to X
        STA TransFn
        LDA #>XTrans
        STA TransFn+1
        RTS
XNo:    LDA #<XEnd
        STA TransFn
        LDA #>XEnd
        STA TransFn+1
XTrans: JSR IsALetter   ; is the current character an uppercase letter?
        BCS XEnd        ;  return if it isn't
        LDA #('X' | $80)
XEnd:   RTS

XCall:  JMP (TransFn)

IsALetter:              ;; Sets carry flag if A is NOT an uppercase letter
        CMP #Scr_A      ; Is the character in Acc is <'A' or >'Z'
        BMI IALNo
        CMP #(Scr_Z+1)
        BCC IALYes
IALNo:  SEC
IALYes: RTS

Origin: LDA WNDTOP
        STA CV
        LDA #$00
        STA CH
        jmp Mon_VTABZ   ; will return to Origin's caller

MaybeSwitch:            ;; Swap to text page 1 or 2 depending on
                        ;; state of the `2` key
        BIT CpyFlag
        BMI NoSw        ; Don't switch if we haven't copied to it!
        LDA KeySv
        CMP #Asc_2
        BEQ Switch
NoSw:   LDA Page2Off    ; `2` not pressed, use page 1
        RTS
Switch: LDA Page2On     ; pressed, use page 2
        JSR SaveKey     ;  and stay there (not writing or copying)
        JMP MaybeSwitch ;  until no longer pressed

MaybeCopy:              ;; Copy text buf 1 to txt buf 2 if open-apple and
                        ;; we haven't done it already (check CpyFlag)
        LDA TransFn
        CMP #<XTrans
        BNE MCEnd
        BIT CpyFlag
        BPL MCEnd
        LDA #$00        ; We copy! First, clear the copy flag
        STA CpyFlag
        LDY #TxtBufPg1   ; Initialize some pointers to $400 and $800
        STY TxtAddr1+1  ;  (the two 40-col text buffers)
        LDY #TxtBufPg2
        STY TxtAddr2+1
        LDY #$00
        STY TxtAddr1
        STY TxtAddr2    ; Y is now already initialized to zero
MCCopyRow3:             ; Copy 120 chars (3 rows)
        LDA (TxtAddr1),Y
        STA (TxtAddr2),Y
        INY
        CPY #120
        BNE MCCopyRow3
        LDY #$00        ; Reset Y

        CLC             ; Add $80 to each address
        LDA TxtAddr1
        ADC #$80
        STA TxtAddr1
        LDA TxtAddr1+1
        ADC #$00
        STA TxtAddr1+1

        CLC
        LDA TxtAddr2
        ADC #$80
        STA TxtAddr2
        LDA TxtAddr2+1
        ADC #$00
        STA TxtAddr2+1
        CMP #$0C        ; Exit if we reached the end of page 2
        BNE MCCopyRow3
MCEnd:  RTS

Message:
         ;       "0123456789012345678901234567890123456789"
         scrcode "THE PURPOSE OF THIS PROGRAM IS TO", $0D
         scrcode "SHOW THE DIFFERENCE IN SPEED BETWEEN", $0D
         scrcode "DRAWING A BUNCH OF X'S TO THE SCREEN", $0D
         scrcode "THAT YOU ARE CURRENTLY VIEWING,", $0D
         scrcode "VERSUS SWAPPING TO A DIFFERENT TEXT", $0D
         scrcode "BUFFER, INSTANTLY CHANGING THE DISPLAY.", $0D
         scrcode $0D
         scrcode "TO TRY IT OUT, HOLD THE `1` KEY TO DRAW", $0D
         scrcode "X'S - AS FAST AS POSSIBLE - OVER EVERY", $0D
         scrcode "LETTER ON THE SCREEN; OR HOLD THE `2`", $0D
         scrcode "KEY DOWN TO SWITCH TO TEXT PAGE 2.", $0D
         scrcode $0D
         scrcode "DO NOT TRY PRESSING `2` UNTIL YOU'VE", $0D
         scrcode "TYPED `1` AT LEAST ONCE, OR NOTHING", $0D
         scrcode "WILL HAPPEN!", $0D
         scrcode $0D
         scrcode "~~~ MESSAGE REPEATS ~~~", $0D
         scrcode $0D
         .BYTE $00
         .BYTE $00

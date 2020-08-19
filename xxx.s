.macpack apple2

Scr_A   = $C1
Scr_Z   = $DA
OpenApple   = $C061
ClosedApple = $C062

TxtBufPg1 = $4
TxtBufPg2 = $8

StrPtr  = $06
CpyFlag = $08

TxtAddr1= $1A
TxtAddr2= $1C

TransFn = $30

WNDTOP  = $22
CH      = $24
CV      = $25
CSWL    = $36

Page2Off = $C054
Page2On  = $C055

Mon_HOME    = $fc58
Mon_VTABZ   = $fc24

.org $2000

Begin:  JSR Mon_HOME    ; Clear the screen at start
        LDA #$80        ; Indicate we should copy to scr 2 when X's (first time)
        STA CpyFlag
DrawMsg:LDA #<Message   ; Initialize start of string
        STA StrPtr
        LDA #>Message
        STA StrPtr+1
        LDY #$00
        JSR XXX
DrawLp: LDA (StrPtr),Y  ; Load next charactr
        BEQ DrawEnd     ; Done drawing if == NUL byte
        JSR XCall       ; Replace letters with "X" if open-apple pressed
        JSR MyCout      ; Jump to user-hookable/monitor's char-printing routine
        INY
        BNE DrawLp
DrawEnd:JSR Origin      ; Return cursor to 0, 0
        JSR MaybeCopy
        JSR MaybeSwitch
        JMP DrawMsg     ;  -- could pause or exit on some key here?

MyCout: JMP (CSWL)

XXX:
        BIT OpenApple   ; Test if the open apple is pressed
        BPL XNo         ;  return if it isn't
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
                        ;; state of closed-apple
        BIT ClosedApple
        BMI Switch
        LDA Page2Off    ; not pressed, use page 1
        RTS
Switch: LDA Page2On     ; pressed, use page 2
        RTS

MaybeCopy:              ;; Copy text buf 1 to txt buf 2 if open-apple and
                        ;; we haven't done it already (check CpyFlag)
        LDA TransFn
        CMP #<XTrans
        BNE MCEnd
        BIT CpyFlag
        BPL MCEnd
        BIT OpenApple
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

Message: scrcode $0D
         scrcode $0D
         scrcode "THIS IS THE SONG THAT NEVER ENDS,"
         scrcode $0D
         scrcode "IT JUST GOES ON AND ON MY FRIEND!"
         scrcode $0D
         scrcode "SOME PEOPLE"
         scrcode $0D
         scrcode "  - STARTED SINGING IT -"
         scrcode $0D
         scrcode "NOT KNOWING WHAT IT WAS,"
         scrcode $0D
         scrcode "AND THEY'LL CONTINUE SINGING IT FOREVER"
         scrcode $0D
         scrcode "    JUST BECAUSE..."
         scrcode $0D
         scrcode "THIS IS THE SONG THAT NEVER ENDS,"
         scrcode $0D
         scrcode "IT JUST GOES ON AND ON MY FRIEND!"
         scrcode $0D
         scrcode "SOME PEOPLE"
         scrcode $0D
         scrcode "  - STARTED SINGING IT -"
         scrcode $0D
         scrcode "NOT KNOWING WHAT IT WAS,"
         scrcode $0D
         scrcode "AND THEY'LL CONTINUE SINGING IT FOREVER"
         scrcode $0D
         scrcode "    JUST BECAUSE..."
         scrcode $0D
         scrcode $0D
         .BYTE $00
         .BYTE $00

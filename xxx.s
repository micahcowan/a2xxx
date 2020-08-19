.macpack apple2

Scr_A   = $C1
Scr_Z   = $DA
OpenApple   = $C061

StrPtr  = $06

WNDTOP  = $22
CH      = $24
CV      = $25
CSWL    = $36

Mon_HOME    = $fc58
Mon_VTABZ   = $fc24

.org $800

Begin:  JSR Mon_HOME    ; Clear the screen at start
DrawMsg:LDA #<Message   ; Initialize start of string
        STA StrPtr
        LDA #>Message
        STA StrPtr+1
        LDY #$00
DrawLp: LDA (StrPtr),Y  ; Load next charactr
        BEQ DrawEnd     ; Done drawing if == NUL byte
        JSR XXX         ; Replace letters with "X" if open-apple pressed
        JSR MyCout      ; Jump to user-hookable/monitor's char-printing routine
        INY
        BNE DrawLp

DrawEnd:JSR Origin      ; Return cursor to 0, 0
        BEQ DrawMsg     ;  -- could pause or exit on some key here?

MyCout: JMP (CSWL)

XXX:
        BIT OpenApple   ; Test if the open apple is pressed
        BPL XEnd        ;  return if it isn't
        JSR IsALetter   ; is the current character an uppercase letter?
        BCS XEnd        ;  return if it isn't
        LDA #('X' | $80)
XEnd:   RTS

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
         scrcode $0D
         .BYTE $00
         .BYTE $00

Scr_A   = $C1
Scr_Z   = $DA
LcBit   = $20
IsLcBit = $01
IsUcBit = $02

        .include "install.inc"
Begin:  CLD
        STX Temp        ; Save existing value in X
        TAX             ; Move character arg to X
TstUC:  CPX #Scr_A      ; Note if the character in Acc is <'A' or >'Z'
        BMI TstLC
        CPX #(Scr_Z+1)
        BCS TstLC
        LDA #IsUcBit    ; Yes: note uppercase letter
        BNE CheckFlipC  ; Skip lowercase check
TstLC:  CPX #(Scr_A|LcBit); Note if the character in Acc is <'a' or >'z'
        BMI COut        ; Not a letter - don't change flag nor char
        CPX #(Scr_Z|LcBit+1)
        BCS COut        ; Not a letter - don't change flag nor char
        LDA #IsLcBit    ; Yes: note lowercase letter
CheckFlipC:
        CMP Flag        ; If letter is already the right one
        BEQ DontFlipChar; then don't flip the char
        TXA             ; Otherwise (<-- obliterating lc/uc info)
        EOR #LcBit      ; flip the char
        TAX
DontFlipChar:
        LDA #$03        ; Either way, flip the flag for next time
                        ; because we found a letter
        EOR Flag
        STA Flag
COut:   TXA             ; Restore char arg to A
        LDX Temp        ; Restore X orig value
        JMP MON_COut    ; INVOKE the monitor's COut1 function.
        NOP
Flag:   .BYTE IsLcBit   ; what kind of letter to output next time
Temp:   .BYTE $00

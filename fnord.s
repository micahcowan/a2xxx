.macpack apple2

Scr_CR = $8D

.include "install.inc"
Begin:  CLD
        CMP #Scr_CR
        BEQ Fnord
        JMP MON_COut
Fnord:  STX Temp_X          ; Save away current X
        LDX #$00            ; For X = 0 to Len(Suffix)
Fnord_: LDA Suffix, X       ;   Char = Suffix[X]
        JSR MON_COut        ;   Output(Char)
        INX
        CPX #(Suffix_ - Suffix)
        BNE Fnord_          ; Next X

        LDX Temp_X          ; Restore previous X
        RTS

        NOP

Suffix: scrcode " fnord"
        .BYTE Scr_CR
Suffix_:
Temp_X: NOP

LcBit   = $20

.macpack apple2

.include "install.inc"
Begin:  CLD
        PHA         ; Push A, X onto stack
        TXA
        PHA
        TSX         ; Get A back from stack, leaving it there:
        INX
        INX         ; X should now hold the offset of the stack to the
                    ; original A
        LDA $100,X  ; Okay, now A should have its original value

        AND #(~LcBit + 256)
                    ; Mask out the lower-case bit to examine
                    ; the upper-cased letter

                    ; SEARCH through the Lookup table to find a matching
                    ;   letter
Search: LDX #(VowelTblEnd - VowelTblStart)
Search_:CMP VowelTblStart-1, X  ; This is so that when X=0, we've dec'd
                                ; BELOW the table. Easy loop
                                ; termination.
        BEQ Found
        DEX
        BNE Search_
NotFound:           ; Not a vowel.
        LDA #$00    ; Mark that the case.
        STA LastWasVowel
PassThrough:
        PLA         ; Pull up the original X...
        TAX
        PLA         ; ...and A from stack
        JMP MON_COut; And output the orig char as-is.

Found:              ; We found a vowel!
        BIT LastWasVowel
        BMI PassThrough     ; If we already saw a vowel before, just
                            ; pass the new vowel through.
        LDA #$FF    ; Otherwise, mark that we saw a vowel
        STA LastWasVowel
        LDA #('A' | $80)    ; print out "AB"
        JSR MON_COut
        LDA #('B' | $80)
        JSR MON_COut
        CLC
        BCC PassThrough     ; ...and then finally pass through our character

        NOP

VowelTblStart:
        scrcode "AEIOU"
VowelTblEnd:

LastWasVowel: .BYTE $00

        NOP

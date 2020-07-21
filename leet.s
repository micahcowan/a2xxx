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
Search: LDX #(LookupEnd - LookupStart)
Search_:CMP LookupStart-1, X  ; This is so that when X=0, we've dec'd
                                ; BELOW the table. Easy loop
                                ; termination.
        BEQ Found
        DEX
        BNE Search_
NotFound:           ; We failed to find the character.
        PLA         ; Pull up the original X...
        TAX
        PLA         ; ...and A from stack
        JMP MON_COut; And output the orig char as-is.

Found:  LDA TransStart-1, X
                    ; We found the character!
                    ; Load up its translation
        JSR MON_COut; ...output it
        PLA         ; And pull up the original X...
        TAX
        PLA         ; ...and A from stack
        RTS         ; before returning.


LookupStart:
        scrcode "LEASGTBO"
LookupEnd:
TransStart:
        scrcode "13456780"
TransEnd:

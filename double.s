Scr_A   = $C1
Scr_Z   = $DA
Scr_CR  = $8D
LcBit   = $20


        .include "install.inc"
Begin:  CLD
        CMP #Scr_A      ; Is the character in Acc is <'A' or >'Z'
        BMI TstLC
        CMP #(Scr_Z+1)
        BCS TstLC
        BNE FlipChar    ; It's an uppercase char. Skip lowercase check.
TstLC:  CMP #(Scr_A|LcBit); Else is the character in Acc is <'a' or >'z'
        BMI DoubleChar  ; Not a letter - don't change flag nor char
        CMP #(Scr_Z|LcBit+1)
        BCS DoubleChar  ; Not a letter - don't change flag nor char

FlipChar:               ; We have a letter. Emit upper, then lowercase.
        AND #(~ LcBit + 256)  ; Mask out any lowercase bit
        JSR MON_COut    ;  and output
        ORA #LcBit      ; Add lowercase bit
        JMP MON_COut    ;  and output
        NOP
DoubleChar:             ; Not a letter. Simply double it.
        CMP #Scr_CR
        BEQ Is_CR       ; ...except if it's a carriage return.
        JSR MON_COut
Is_CR:  JMP MON_COut

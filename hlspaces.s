.macpack apple2

Scr_SPC= ($20 | $80)
Scr_FLASH = $60
Scr_INVERSE = $20

.include "install.inc"
Begin:  CLD
        CMP #Scr_SPC
        BNE Literal
        LDA #Scr_INVERSE
Literal:JMP MON_COut

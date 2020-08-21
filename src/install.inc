MON_COut= $FDF0

DOS_CSWL= $AA53

        .org $0300
        ;; This is how you hook an output routine in DOS 3.3
        ;; - though the routine is the same, how to hook it is different
        ;;   in ProDOS, and different again with no DOS loaded
        LDA #<Begin
        STA DOS_CSWL
        LDA #>Begin
        STA DOS_CSWL+1
        RTS

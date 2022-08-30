reset

.if .definedmacro(line)
.delmacro line
.endif
.macro line s
	.repeat .strlen(s), i
        	char {.strat(s, i)}
        .endrepeat
        lineDone
.endmacro

.if .definedmacro(char)
.delmacro char
.endif
.macro char c
.if xTrans && c >= 'A' && c <= 'Z'
	LDA #$D8
.else
	LDA #(c | $80)
.endif
        STA currentBase
        currentBase .set currentBase + 1
.endmacro

.if .definedmacro(lineDone)
.delmacro lineDone
.endif
.macro lineDone
	lineNum .set lineNum + 1
        calcBase
.endmacro

.if .definedmacro(msgDone)
.delmacro msgDone
.endif
.macro msgDone
	rts
.endmacro

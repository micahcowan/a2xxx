reset
lastChar .set 0

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
.if c <> ' '
.if xTrans && c >= 'A' && c <= 'Z'
        curChar .set $D8
.else
        curChar .set (c | $80)
.endif ; xTrans && alpha
.if (!xTrans) || curChar <> lastChar
	LDA #curChar
        lastChar .set curChar
.endif ; avoid repeated LDA on xTrans
        STA currentBase
.endif ; ' '
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

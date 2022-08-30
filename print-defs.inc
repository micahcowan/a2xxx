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
	.byte $D8
.else
	.byte (c | $80)
.endif
.endmacro

.if .definedmacro(lineDone)
.delmacro lineDone
.endif
.macro lineDone s
	.byte $8D
.endmacro

.if .definedmacro(msgDone)
.delmacro msgDone
.endif
.macro msgDone
	.byte $0
.endmacro

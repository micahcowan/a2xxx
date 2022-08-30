.macro calcBase
	currentBase .set ((4 | (lineNum/2 & 3)) << 8 | (5 * ((lineNum & $18) + $80 * (lineNum & 1))) & $FF)
.endmacro

.macro reset
	lineNum .set 0
	calcBase
.endmacro

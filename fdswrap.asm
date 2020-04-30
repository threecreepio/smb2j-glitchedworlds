;This file takes the assembled binaries of the program files and puts
;them into an FDS file along with the character files that are needed.
;In order for this to work, the program files need to already be assembled
;and the character files from the disk or disk image are also needed.

DiskInfoBlock     = 1
FileAmountBlock   = 2
FileHeaderBlock   = 3
FileDataBlock     = 4
PRG = 0
CHR = 1
VRAM = 2

 .org $0

;FWNES header
 .byte "FDS",$1a,1,0,0,0,0,0,0,0,0,0,0,0

 .byte DiskInfoBlock
 .byte "*NINTENDO-HVC*"
 .byte $01,"SMB ",0,0,0,0,0,$0f
 .byte $ff,$ff,$ff,$ff,$ff
 .byte $61,$07,$23
 .byte $49,$61,$00,$00,$02,$00,$1b,$00,$97,$00
 .byte $61,$07,$23
 .byte $ff,$ff,$ff,$ff,$ff,$00,$00,$00,$00

 .byte FileAmountBlock
 .byte 8

 .byte FileHeaderBlock
 .byte $00,$00
 .byte "KYODAKU-"
 .word $2800
 .word KyodakuEnd-KyodakuStart
 .byte VRAM

 .byte FileDataBlock
KyodakuStart:
 .byte $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$17,$12,$17,$1d,$0e
 .byte $17,$0d,$18,$24,$28,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24
 .byte $24,$24,$24,$24,$24,$24,$24,$0f,$0a,$16,$12,$15,$22,$24,$0c,$18
 .byte $16,$19,$1e,$1d,$0e,$1b,$24,$1d,$16,$24,$24,$24,$24,$24,$24,$24
 .byte $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24
 .byte $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24
 .byte $24,$24,$1d,$11,$12,$1c,$24,$19,$1b,$18,$0d,$1e,$0c,$1d,$24,$12
 .byte $1c,$24,$16,$0a,$17,$1e,$0f,$0a,$0c,$1d,$1e,$1b,$0e,$0d,$24,$24
 .byte $24,$24,$0a,$17,$0d,$24,$1c,$18,$15,$0d,$24,$0b,$22,$24,$17,$12
 .byte $17,$1d,$0e,$17,$0d,$18,$24,$0c,$18,$27,$15,$1d,$0d,$26,$24,$24
 .byte $24,$24,$18,$1b,$24,$0b,$22,$24,$18,$1d,$11,$0e,$1b,$24,$0c,$18
 .byte $16,$19,$0a,$17,$22,$24,$1e,$17,$0d,$0e,$1b,$24,$24,$24,$24,$24
 .byte $24,$24,$15,$12,$0c,$0e,$17,$1c,$0e,$24,$18,$0f,$24,$17,$12,$17
 .byte $1d,$0e,$17,$0d,$18,$24,$0c,$18,$27,$15,$1d,$0d,$26,$26,$24,$24
KyodakuEnd:

 .byte FileHeaderBlock
 .byte $01,$01
 .byte "SM2CHAR1"
 .word $0000
 .word Char1End-Char1Start
 .byte CHR

 .byte FileDataBlock
Char1Start:
 .incbin "SM2CHAR1.CHR"
Char1End:

 .byte FileHeaderBlock
 .byte $02,$10
 .byte "SM2CHAR2"
 .word $0760
 .word Char2End-Char2Start
 .byte CHR

 .byte FileDataBlock
Char2Start:
 .incbin "SM2CHAR2.CHR"
Char2End:

.byte FileHeaderBlock,$03,$05
.byte "SM2MAIN "
.word $6000, SM2MAINEND-SM2MAINSTART
.byte PRG, FileDataBlock
.include "sm2main.asm"

.byte FileHeaderBlock,$04,$04
.byte "SM2MENU1"
.word $6000, SM2MENU1END-SM2MENU1START
.byte PRG, FileDataBlock
.include "sm2menu.asm"


 .byte FileHeaderBlock
 .byte $06,$20
 .byte "SM2DATA2"
 .word $c470
 .word Data2End-Data2Start
 .byte PRG

 .byte FileDataBlock
Data2Start:
 .incbin "sm2data2.o.bin"
Data2End:

 .byte FileHeaderBlock
 .byte $07,$30
 .byte "SM2DATA3"
 .word $c5d0
 .word Data3End-Data3Start
 .byte PRG

 .byte FileDataBlock
Data3Start:
 .incbin "sm2data3.o.bin"
Data3End:

 .byte FileHeaderBlock
 .byte $08,$40
 .byte "SM2DATA4"
 .word $c2b4
 .word Data4End-Data4Start
 .byte PRG

 .byte FileDataBlock
Data4Start:
 .incbin "sm2data4.o.bin"
Data4End:

.byte FileHeaderBlock,$09,$0f
.byte "SM2SAVE "
.word $6000, 1
.byte PRG, FileDataBlock
.byte 0

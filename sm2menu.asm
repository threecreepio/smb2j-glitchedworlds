.org $6000
JumpEngineCore = $EAFD

SM2MENU1START:
    jsr CopySettingsToMemory
; pad this to make it easier for the game to throw us back here
; without making too many changes to the original files.
.byte $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA
.byte $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA
.byte $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA
.byte $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA
.byte $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA
.byte $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA
TitleReset:
    lda #<TitleNMI
    sta $DFFA
    lda #>TitleNMI
    sta $DFFB
    ; setup
    ldx #$00
    stx PPU_CTRL
    stx PPU_MASK
wait_vbl0:
    lda PPU_STATUS
    bpl wait_vbl0
wait_vbl1:
    lda PPU_STATUS
    bpl wait_vbl1
    jsr CopyMemoryToSettings
    ldy #$FF
    jsr MInitializeMemory
    jsr CopySettingsToMemory
    ldx #0
    stx OperMode_Task
    cli
    lda #%10010000
    sta PPU_CTRL
:   jmp :-

TitleNMI:
      ldx #$FF
      txs
      sei
:     jsr TitleJumpEngine
      jmp :-

TitleJumpEngine:
    lda OperMode_Task
    jsr JumpEngineCore
    .word Title_Setup
    .word Title_Main

Title_Setup:
    inc OperMode_Task
    lda #%00010000
    sta PPU_CTRL
    sta $FF
    lda #%00000000
    sta PPU_MASK

    lda #$3F
    sta PPU_ADDRESS
    lda #$00
    sta PPU_ADDRESS
    ldx #0
@WRITE_PAL:
    clc
    lda PALETTE,x
    sta PPU_DATA
    inx
    cpx #(PALETTEEND-PALETTE)
    bne @WRITE_PAL

    ldx #0
    lda #$20
    sta PPU_ADDRESS
    lda #$00
    sta PPU_ADDRESS
@WRITE_L1:
    lda BG_L1, x
    sta PPU_DATA
    inx
    bne @WRITE_L1
@WRITE_L2:
    lda BG_L2, x
    sta PPU_DATA
    inx
    bne @WRITE_L2
@WRITE_L3:
    lda BG_L3, x
    sta PPU_DATA
    inx
    bne @WRITE_L3
@WRITE_L4:
    lda BG_L4, x
    sta PPU_DATA
    inx
    bne @WRITE_L4

    jsr RenderMenu
    lda #%00001110
    sta PPU_MASK
    lda #0
    sta PPU_SCROLL
    sta PPU_SCROLL

    lda #%10010000
    sta PPU_CTRL
    sta $FF
    : jmp :-


ReadOrDownVerifyPads = $ea4c
Title_Main:
    jsr ReadOrDownVerifyPads
    lda $f5
    clc
    cmp #0
    bne @READINPUT
    : jmp :-

@READINPUT:
    ldy WSelection
    ldx SettablesLow,y
    stx $3
    ldx SettablesHi,y
    stx $4
    ldy #0

@RIGHT:
    cmp #%00000001
    bne @LEFT

    lda #$0
    adc ($3),y
    sta ($3),y
    jmp Rerender

@LEFT:
    cmp #%00000010
    bne @DOWN
    lda #$FE
    adc ($3),y
    sta ($3),y
    jmp Rerender

@DOWN:
    cmp #%00000100
    bne @UP
    lda #$EF
    adc ($3),y
    sta ($3),y
    jmp Rerender

@UP:
    cmp #%00001000
    bne @SELECT
    lda #$F
    adc ($3),y
    sta ($3),y
    jmp Rerender

@SELECT:
    cmp #%00100000
    bne @START
    inc WSelection
    lda WSelection
    cmp #(SettablesLowEnd-SettablesLow)
    bne @SELECT2
    lda #0
    sta WSelection
@SELECT2:
    jmp Rerender

@START:
    cmp #%00010000
    bne @DONE
    ldx $f7
    cpx #%10000000
    lda #0
    bcc @START2
    lda #1
@START2:
    sta HardWorldFlag
    jmp TStartGame
@DONE:
    : jmp :-

Rerender:
    jsr RenderMenu
    lda #0
    sta PPU_SCROLL
    sta PPU_SCROLL
    : jmp :-

RenderMenu:
    lda #$20
    sta $1
    lda #$52
    sta $2

    lda #0
    sta $0
@RenderMenu:
    ldy $0

    clc
    lda $2
    adc #$40
    sta $2
    bcc @NoOverflow
    inc $1
@NoOverflow:
    lda $1
    sta PPU_ADDRESS
    lda $2
    sta PPU_ADDRESS

    ldy $0
    ldx SettablesLow,y
    stx $3
    ldx SettablesHi,y
    stx $4
    ldy #0

    lda ($3),y
    clc
    jsr print_hexbyte

    lda #$24
    sta PPU_DATA

    ldy $0
    cpy WSelection
    bne @RenderSelectionTick
    adc #3
@RenderSelectionTick:
    sta PPU_DATA
    inc $0
    lda $0
    cmp #(SettablesLowEnd-SettablesLow)
    bne @RenderMenu
    rts

MInitializeMemory:
    ldx #$07          ;set initial high byte to $0700-$07ff
    lda #$00          ;set initial low byte to start of page (at $00 of page)
    sta $06
MInitPageLoop: stx $07
MInitByteLoop: cpx #$01          ;check to see if we're on the stack ($0100-$01ff)
    bne MInitByte      ;if not, go ahead anyway
    cpy #$60          ;otherwise, check to see if we're at $0160-$01ff
    bcs MSkipByte      ;if so, skip write
    cpy #$09          ;otherwise, check to see if we're at $0100-$0108
    bcc MSkipByte      ;if so, skip write
MInitByte:     sta ($06),y       ;otherwise, initialize memory
MSkipByte:     dey
    cpy #$ff          ;do this until all bytes in page have been erased
    bne MInitByteLoop
    dex               ;go onto the next page
    bpl MInitPageLoop  ;do this until all desired pages of memory have been erased
    rts

print_hexchar:
    cmp #10
    bcc @after1
@after1:
    sta PPU_DATA
    rts
print_hexbyte:
    pha
    lsr a
    lsr a
    lsr a
    lsr a
    jsr print_hexchar
    pla
    and #$0F
    jsr print_hexchar
    rts

TStartGame:
    lda #%00000000
    sta PPU_CTRL
    lda #%00000000
    sta PPU_MASK

    lda #$00
    sta $4015
    sta IRQUpdateFlag
    lda #Silence             ;silence music
    sta EventMusicQueue

    lda Mirror_FDS_CTRL_REG     ;get setting previously used by FDS bios
    and #$f7                    ;and set for vertical mirroring
    sta FDS_CTRL_REG

    lda AreaNumber
    sta LevelNumber

    lda #$7F
    sta NumberofLives

    lda #1
    sta OperMode
    lda #0
    sta OperMode_Task
    lda #0
    sta GameEngineSubroutine

    lda #4
    sta GameTimerDisplay

    lda #$00                  ;game timer from header
    sta TimerControl          ;also set flag for timers to count again

    lda #>(GL_ENTER - 1)
    pha
    lda #<(GL_ENTER - 1)
    pha
    lda #>(LoadAreaPointer - 1)
    pha
    lda #<(LoadAreaPointer - 1)
    pha
    lda #>(PatchPlayerNamePal - 1)
    pha
    lda #<(PatchPlayerNamePal - 1)
    pha
    jmp TitleLoadFiles
    : jmp :-






CopySettingsToMemory:
    ldy #0
    ldx #(SettablesLowEnd-SettablesLow)
@CopySetting:
    lda SettablesLow-1,x
    sta $0
    lda SettablesHi-1,x
    sta $1
    lda SettingsFileStart,x
    sta ($0),y
    dex
    bne @CopySetting
    rts

CopyMemoryToSettings:
    ldy #0
    ldx #(SettablesLowEnd-SettablesLow)
@CopySetting:
    lda SettablesLow-1,x
    sta $0
    lda SettablesHi-1,x
    sta $1
    lda ($0),y
    sta SettingsFileStart,x
    dex
    bne @CopySetting
    rts



; Load game data
TitleFileListAddrs:
      .byte TitleWorld14List-TitleWorldLists
      .byte TitleWorld58List-TitleWorldLists
      .byte TitleEndingList-TitleWorldLists
      .byte TitleWorldADList-TitleWorldLists

TitleWorldLists:
TitleWorld14List:
      .byte $01, $0e, $ff
TitleWorld58List:
      .byte $01, $0e, $20, $ff
TitleEndingList:
      .byte $10, $0e, $20, $30, $ff
TitleWorldADList:
      .byte $01, $0e, $20, $40, $ff

TitleLoadFiles:
    ldy FileListNumber
    ldx TitleFileListAddrs,y
    ldy #$03
    sty ListPointer+1
    ldy #$00
    sty ListPointer
TitleKeepCopying:
    lda TitleWorldLists,x
    sta $0300,y
    inx
    iny
    cmp $ff
    bcc TitleKeepCopying
    jmp LoadFilesDirect


SettablesLow:
    .byte <FileListNumber
    .byte <WorldNumber
    .byte <AreaNumber
    .byte <PlayerStatus
    .byte <PlayerSize
    .byte <SelectedPlayer
SettablesLowEnd:

SettablesHi:
    .byte >FileListNumber
    .byte >WorldNumber
    .byte >AreaNumber
    .byte >PlayerStatus
    .byte >PlayerSize
    .byte >SelectedPlayer

WSelection = $761

.include "sm2menubg.asm"
.res $6F00 - *, $00
SettingsFileStart:
.byte $00
WSelections:
WFile:
.byte $00
WWorldNumber:
.byte $00
WAreaNumber:
.byte $00
WPlayerStatus:
.byte $00
WPlayerSize:
.byte $01
WCurrentPlayer:
.byte $00
SettingsFileEnd:
.res $7000 - *, $00
SM2MENU1END:

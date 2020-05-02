.org $6000
JumpEngineCore = $EAFD

SM2MENU1START:
; pad this to make it easier for the game to throw us back here
; without making too many changes to the original files.
.byte $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA
.byte $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA
.byte $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA
.byte $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA
.byte $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA
.byte $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA
TitleReset:
    jsr CopyFromBackup
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
    jsr MInitializeMemory
    ldx #0
    stx OperMode_Task
    cli
    lda #%10010000
    sta PPU_CTRL
:   jmp :-




MenuIRQHandler:
      sei
      php                      ;save regs
      pha
      txa
      pha
      tya
      pha
      lda FDS_STATUS           ;get disk status register, acknowledge IRQs
      pha
      and #$02                 ;if byte transfer flag set, branch elsewhere
      bne MenuDelayNoScr
      pla
      and #$01                 ;if IRQ timer flag not set, branch to leave
      beq MenuExitIRQ
      lda Mirror_PPU_CTRL
      and #$f7                 ;mask out sprite address high reg of ctrl reg mirror
      ora NameTableSelect      ;mask in whatever's set here
      sta Mirror_PPU_CTRL      ;update the register and its mirror
      sta PPU_CTRL
      lda #$00
      sta FDS_IRQTIMER_CTRL    ;disable IRQ timer for the rest of the frame
      lda HorizontalScroll
      sta PPU_SCROLL           ;set scroll regs for the screen under the status bar
      lda VerticalScroll       ;to achieve the split screen effect
      sta PPU_SCROLL
      lda #$00
      sta IRQAckFlag           ;indicate IRQ was acknowledged
      jmp MenuExitIRQ              ;skip over the next part to end IRQ
MenuDelayNoScr: pla                      ;throw away disk status reg byte
      jsr FDSBIOS_DELAY        ;run delay subroutine in FDS bios
MenuExitIRQ:    pla
      tay                      ;return regs, reenable IRQs and leave
      pla
      tax
      pla
      plp
      cli
      rti

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
    cpx #4
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
    ldx $f7
    lda $f5
    clc
    ldy WSelection
    cmp #0
    bne @RIGHT
    : jmp :-

@RIGHT:
    cmp #%00000001
    bne @LEFT
    lda #0
    adc WSelections,y
    sta WSelections,y
    jmp Rerender

@LEFT:
    cmp #%00000010
    bne @DOWN
    lda #$FE
    adc WSelections,y
    sta WSelections,y
    jmp Rerender

@DOWN:
    cmp #%00000100
    bne @UP
    lda #$EF
    adc WSelections,y
    sta WSelections,y
    jmp Rerender

@UP:
    cmp #%00001000
    bne @B
    lda #$F
    adc WSelections,y
    sta WSelections,y
    jmp Rerender

@B:
    cmp #%01000000
    bne @SELECT
    jsr WriteSettingsFile
    jmp Rerender

@SELECT:
    cmp #%00100000
    bne @START
    inc WSelection
    lda WSelection
    cmp #5
    bne @SELECT2
    lda #0
    sta WSelection
@SELECT2:
    jmp Rerender

@START:
    cmp #%00010000
    bne @DONE
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
    ldx WSelection
    lda #$20
    sta PPU_ADDRESS
    lda #$92
    sta PPU_ADDRESS
    lda WFile
    jsr print_hexbyte
    lda #$24
    sta PPU_DATA
    lda #$24
    cpx #0
    bne R0
    adc #3
    R0:
    sta PPU_DATA
    
    ldx WSelection
    lda #$20
    sta PPU_ADDRESS
    lda #$D2
    sta PPU_ADDRESS
    lda WWorldNumber
    jsr print_hexbyte
    lda #$24
    sta PPU_DATA
    lda #$24
    cpx #1
    bne R1
    adc #3
    R1:
    sta PPU_DATA

    lda #$21
    sta PPU_ADDRESS
    lda #$12
    sta PPU_ADDRESS
    lda WAreaNumber
    jsr print_hexbyte
    lda #$24
    sta PPU_DATA
    lda #$24
    cpx #2
    bne R2
    adc #3
    R2:
    sta PPU_DATA
    
    lda #$21
    sta PPU_ADDRESS
    lda #$52
    sta PPU_ADDRESS
    lda WPlayerStatus
    jsr print_hexbyte
    lda #$24
    sta PPU_DATA
    lda #$24
    cpx #3
    bne R3
    adc #3
    R3:
    sta PPU_DATA

    lda #$21
    sta PPU_ADDRESS
    lda #$92
    sta PPU_ADDRESS
    lda WPlayerSize
    jsr print_hexbyte
    lda #$24
    sta PPU_DATA
    lda #$24
    cpx #4
    bne R4
    adc #3
    R4:
    sta PPU_DATA
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
    jsr CopyToBackup

    lda Mirror_FDS_CTRL_REG     ;get setting previously used by FDS bios
    and #$f7                    ;and set for vertical mirroring
    sta FDS_CTRL_REG

    lda #$7F
    sta NumberofLives

    lda WPlayerSize
    sta PlayerSize
    lda WPlayerStatus
    sta PlayerStatus
    lda WWorldNumber
    sta WorldNumber
    lda WAreaNumber
    sta AreaNumber
    sta LevelNumber

    lda #1
    sta OperMode
    lda #2
    sta OperMode_Task
    lda #0
    sta GameEngineSubroutine
    lda #0
    sta DiskIOTask

    lda #<NMIHandler
    sta $DFFA
    lda #>NMIHandler
    sta $DFFB

    lda WFile
    sta FileListNumber

    lda #4
    sta GameTimerDisplay

    lda #>(GL_ENTER - 1)
    pha
    lda #<(GL_ENTER - 1)
    pha
    lda #>(ContinueGame2 - 1)
    pha
    lda #<(ContinueGame2 - 1)
    pha
    lda #>(LoadAreaPointer - 1)
    pha
    lda #<(LoadAreaPointer - 1)
    pha
    jmp TitleLoadFiles
    : jmp :-


; Save settings file to disk
SaveFileHeader:
    .byte $0d, "SM2MENU2"
    .word SettingsFileStart
    .byte SettingsFileEnd-SettingsFileStart, $00, $00
    .word SettingsFileStart
    .byte $00

WriteSettingsFile:
    lda #%00010000
    sta PPU_CTRL
    lda #%11101110
    sta PPU_MASK
    lda #$0A               ;set file sequential position
    jsr FDSBIOS_WRITEFILE  ;save number of games beaten to SM2SAVE
    .word DiskIDString
    .word SaveFileHeader
    lda #%00001110
    sta PPU_MASK
    lda #%10010000
    sta PPU_CTRL
    : jmp :-



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





WBackupLocation = $761

CopyToBackup:
    ldx #$69
    stx WBackupLocation
    ldx #(SettingsFileEnd-SettingsFileStart)
@KeepCopying:
    lda SettingsFileStart-1,x
    sta WBackupLocation,x
    dex
    bne @KeepCopying
@Exit:
    rts

CopyFromBackup:
    ldx WBackupLocation
    cpx #$69
    bne @Exit
    ldx #(SettingsFileEnd-SettingsFileStart)
@KeepCopying:
    lda WBackupLocation,x
    sta SettingsFileStart-1,x
    dex
    bne @KeepCopying
@Exit:
    rts


.include "sm2menubg.asm"
.res $6F00 - *, $00
SettingsFileStart:
WSelection:
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
SettingsFileEnd:
.res $7000 - *, $00
SM2MENU1END:

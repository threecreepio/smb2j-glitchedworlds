.org $6000
JumpEngineCore = $EAFD

SM2MENU1START:
TitleReset:
      lda #<TitleNMI
      sta $DFFA
      lda #>TitleNMI
      sta $DFFB
      lda #<IRQHandler
      sta $DFFE
      lda #>IRQHandler
      sta $DFFF


    jsr InitializeWRAM

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

InitializeWRAM:
    lda WInitialized
    cmp #$9a
    beq InitializeWRAM_Done
    lda #$9a
    sta WInitialized
    lda #1
    sta WPlayerSize
InitializeWRAM_Done:
    rts



TitleJumpEngine:
    lda OperMode_Task
    jsr JumpEngineCore
    .word STitle_Setup
    .word STitle_Main




VRAMStructWrite = $E7BB
VINTWait = $E1B2
STitle_Setup:
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









WInitialized = $D0FE
WSelection = $0010
WSelections = $0011
WWorldNumber = $0011
WAreaNumber = $0012
WPlayerStatus = $0013
WPlayerSize = $0014

STitle_Main:
    jsr TReadJoypads
    lda SavedJoypad2Bits
    clc
    ldy WSelection

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
    bne @SELECT
    lda #$F
    adc WSelections,y
    sta WSelections,y
    jmp Rerender

@SELECT:
    cmp #%00100000
    bne @START
    inc WSelection
    lda WSelection
    cmp #4
    bne @SELECT2
    lda #0
    sta WSelection
@SELECT2:
    jmp Rerender


@START:
    cmp #%00010000
    bne @DONE
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
    lda #$D2
    sta PPU_ADDRESS
    lda WWorldNumber
    jsr print_hexbyte
    lda #$24
    sta PPU_DATA
    lda #$24
    cpx #0
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
    cpx #1
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
    cpx #2
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
    cpx #3
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

TReadJoypads:
        lda #0
        sta SavedJoypad2Bits
        lda #$01
        sta JOYPAD_PORT
        lsr
        sta JOYPAD_PORT
        ldy #$08
TPortLoop:
        pha
        lda JOYPAD_PORT
        sta $00
        lsr
        ora $00
        lsr
        pla
        rol
        dey
        bne TPortLoop
        cmp SavedJoypadBits
        beq TPortLoop2
        sta SavedJoypad2Bits
TPortLoop2:
        sta SavedJoypadBits
        rts


TStartGame:
      lda #0
      sta PPU_CTRL
      sta PPU_MASK

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
      
      jsr LoadAreaPointer
      jsr Entrance_GameTimerSetup
      
      lda #1
      sta GameTimerSetting

      lda #1
      sta OperMode
      lda #0
      sta OperMode_Task
      lda #0
      sta DiskIOTask
      lda #0
      sta ScreenRoutineTask
      lda #0
      sta GameEngineSubroutine
      sta FileListNumber

      ldx #50
      ; Load SM2J
      ldx #0
      lda #>(GL_ENTER - 1)
      pha
      lda #<(GL_ENTER - 1)
      pha
      lda #0
      jsr TitleLoadFiles


      : jmp :-





TitleFileListAddrLow:
      .byte <TitleWorld14List, <TitleWorld58List, <TitleEndingList, <TitleWorldADList
TitleFileListAddrHigh:
      .byte >TitleWorld14List, >TitleWorld58List, >TitleEndingList, >TitleWorldADList

;file lists used by FDS bios to load files
;value $ff is end terminator
TitleWorld14List:
      .byte $04, $ff
TitleWorld58List:
      .byte $20, $ff
TitleEndingList:
      .byte $10, $30, $0f, $ff
TitleWorldADList:
      .byte $40, $ff

TitleLoadFiles:
      ldx FileListNumber      ;get address to file list
      lda FileListAddrLow,x
      sta TitleListPointer
      lda FileListAddrHigh,x
      sta TitleListPointer+1
      jsr FDSBIOS_LOADFILES   ;now load the files

;used by FDS BIOS routine
.word DiskIDString
TitleListPointer: .word World14List  ;overwritten in RAM



.include "sm2menubg.asm"
.res $7000 - *, $ff
SM2MENU1END:

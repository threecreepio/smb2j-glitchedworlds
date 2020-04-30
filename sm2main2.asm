
;-------------------------------------------------------------------------------------
;DIRECTIVES

.org $c2b4
SM2MAIN2START:

;-------------------------------------------------------------------------------------

FindAreaPointer:
      ldy WorldNumber        ;load offset from world variable
      lda WorldAddrOffsets,y
      clc                    ;add area number used to find data
      adc AreaNumber
      tay
      lda AreaAddrOffsets,y  ;from there we have our area pointer
      rts

GetAreaDataAddrs:
            lda AreaPointer          ;use 2 MSB for Y
            jsr GetAreaType
            tay
            lda AreaPointer          ;mask out all but 5 LSB
            and #%00011111
            sta AreaAddrsLOffset     ;save as low offset
            lda EnemyAddrHOffsets,y  ;load base value with 2 altered MSB,
            clc                      ;then add base value to 5 LSB, result
            adc AreaAddrsLOffset     ;becomes offset for level data
            asl
            tay
            lda EnemyDataAddrs+1,y   ;use offset to load pointer
            sta EnemyDataHigh
            lda EnemyDataAddrs,y
            sta EnemyDataLow
            ldy AreaType             ;use area type as offset
            lda AreaDataHOffsets,y   ;do the same thing but with different base value
            clc
            adc AreaAddrsLOffset
            asl
            tay
            lda AreaDataAddrs+1,y    ;use this offset to load another pointer
            sta AreaDataHigh
            lda AreaDataAddrs,y
            sta AreaDataLow
            ldy #$00                 ;load first byte of header
            lda (AreaData),y     
            pha                      ;save it to the stack for now
            and #%00000111           ;save 3 LSB for foreground scenery or bg color control
            cmp #$04
            bcc StoreFore
            sta BackgroundColorCtrl  ;if 4 or greater, save value here as bg color control
            lda #$00
StoreFore:  sta ForegroundScenery    ;if less, save value here as foreground scenery
            pla                      ;pull byte from stack and push it back
            pha
            and #%00111000           ;save player entrance control bits
            lsr                      ;shift bits over to LSBs
            lsr
            lsr
            sta PlayerEntranceCtrl       ;save value here as player entrance control
            pla                      ;pull byte again but do not push it back
            and #%11000000           ;save 2 MSB for game timer setting
            clc
            rol                      ;rotate bits over to LSBs
            rol
            rol
            sta GameTimerSetting     ;save value here as game timer setting
            iny
            lda (AreaData),y         ;load second byte of header
            pha                      ;save to stack
            and #%00001111           ;mask out all but lower nybble
            sta TerrainControl
            pla                      ;pull and push byte to copy it to A
            pha
            and #%00110000           ;save 2 MSB for background scenery type
            lsr
            lsr                      ;shift bits to LSBs
            lsr
            lsr
            sta BackgroundScenery    ;save as background scenery
            pla           
            and #%11000000
            clc
            rol                      ;rotate bits over to LSBs
            rol
            rol
            cmp #%00000011           ;if set to 3, store here
            bne StoreStyle           ;and nullify other value
            sta CloudTypeOverride    ;otherwise store value in other place
            lda #$00
StoreStyle: sta AreaStyle
            lda AreaDataLow          ;increment area data address by 2 bytes
            clc
            adc #$02
            sta AreaDataLow
            lda AreaDataHigh
            adc #$00
            sta AreaDataHigh
            rts

;-------------------------------------------------------------------------------------

WorldAddrOffsets:
  .byte World1Areas-AreaAddrOffsets, World2Areas-AreaAddrOffsets
  .byte World3Areas-AreaAddrOffsets, World4Areas-AreaAddrOffsets
  .byte World5Areas-AreaAddrOffsets, World6Areas-AreaAddrOffsets
  .byte World7Areas-AreaAddrOffsets, World8Areas-AreaAddrOffsets
  .byte World9Areas-AreaAddrOffsets

AreaAddrOffsets:
World1Areas: .byte $20, $29, $40, $21, $60
World2Areas: .byte $22, $23, $24, $61
World3Areas: .byte $25, $29, $00, $26, $62
World4Areas: .byte $27, $28, $2a, $63
World5Areas: .byte $2b, $29, $43, $2c, $64
World6Areas: .byte $2d, $29, $01, $2e, $65
World7Areas: .byte $2f, $30, $31, $66
World8Areas: .byte $32, $35, $36, $67
World9Areas: .byte $38, $06, $68, $07

AreaDataOfsLoopback:
  .byte $0c, $0c, $42, $42, $10, $10, $30, $30, $06, $0c, $54, $06

EnemyAddrHOffsets:
  .byte $2c, $0a, $27, $00

EnemyDataAddrs:
  .word E_CastleArea1, E_CastleArea2, E_CastleArea3, E_CastleArea4, E_CastleArea5, E_CastleArea6
  .word E_CastleArea7, E_CastleArea8, E_CastleArea9, E_CastleArea10, E_GroundArea1, E_GroundArea2
  .word E_GroundArea3, E_GroundArea4, E_GroundArea5, E_GroundArea6, E_GroundArea7, E_GroundArea8
  .word E_GroundArea9, E_GroundArea10, E_GroundArea11, E_GroundArea12, E_GroundArea13, E_GroundArea14
  .word E_GroundArea15, E_GroundArea16, E_GroundArea17, E_GroundArea18, E_GroundArea19, E_GroundArea20
  .word E_GroundArea21, E_GroundArea22, E_GroundArea23, E_GroundArea24, E_GroundArea25, E_GroundArea26
  .word E_GroundArea27, E_GroundArea28, E_GroundArea29, E_UndergroundArea1, E_UndergroundArea2
  .word E_UndergroundArea3, E_UndergroundArea4, E_UndergroundArea5, E_WaterArea1, E_WaterArea2
  .word E_WaterArea3, E_WaterArea4, E_WaterArea5, E_WaterArea6, E_WaterArea7, E_WaterArea8

AreaDataHOffsets:
  .byte $2c, $0a, $27, $00

AreaDataAddrs:
  .word L_CastleArea1, L_CastleArea2, L_CastleArea3, L_CastleArea4, L_CastleArea5, L_CastleArea6
  .word L_CastleArea7, L_CastleArea8, L_CastleArea9, L_CastleArea10, L_GroundArea1, L_GroundArea2
  .word L_GroundArea3, L_GroundArea4, L_GroundArea5, L_GroundArea6, L_GroundArea7, L_GroundArea8
  .word L_GroundArea9, L_GroundArea10, L_GroundArea11, L_GroundArea12, L_GroundArea13, L_GroundArea14
  .word L_GroundArea15, L_GroundArea16, L_GroundArea17, L_GroundArea18, L_GroundArea19, L_GroundArea20
  .word L_GroundArea21, L_GroundArea22, L_GroundArea23, L_GroundArea24, L_GroundArea25, L_GroundArea26
  .word L_GroundArea27, L_GroundArea28, L_GroundArea29, L_UndergroundArea1, L_UndergroundArea2
  .word L_UndergroundArea3, L_UndergroundArea4, L_UndergroundArea5, L_WaterArea1, L_WaterArea2
  .word L_WaterArea3, L_WaterArea4, L_WaterArea5, L_WaterArea6, L_WaterArea7, L_WaterArea8

;some unused bytes
  .byte $ff, $ff

GameMenuRoutine:
              lda SavedJoypadBits         ;check to see if the player pressed start
              and #Start_Button
              beq ChkSelect               ;if not, branch to check other buttons
              lda #$00
              sta CompletedWorlds
              sta DiskIOTask
              sta HardWorldFlag
              lda GamesBeatenCount        ;check to see if player has beaten
              cmp #$08                    ;the game at least 8 times
              bcc StG                     ;if not, start the game as usual at world 1
              lda SavedJoypadBits
              and #A_Button               ;check if the player pressed A + start
              beq StG                     ;if not, start the game as usual at world 1
              inc HardWorldFlag           ;otherwise start playing the letter worlds
StG:          jmp StartGame
ChkSelect:    lda SavedJoypadBits
              cmp #Select_Button          ;branch if pressing select
              beq SelectLogic
              ldx DemoTimer
              bne NullJoypad
              sta SelectTimer             ;run demo after a certain period of time
              jsr DemoEngine
              bcs ResetTitle
              bcc RunDemo
SelectLogic:  lda DemoTimer               ;if select pressed, check demo timer one last time
              beq ResetTitle              ;if demo timer expired, branch to reset attract mode
              lda #$18                    ;otherwise reset demo timer
              sta DemoTimer
              lda FrameCounter            ;erase LSB of frame counter
              and #$fe
              sta FrameCounter
              lda SelectTimer             ;if select timer not expired, skip to slow select down
              bne NullJoypad
              lda #$10                    ;reset select button timer
              sta SelectTimer
              lda SelectedPlayer          ;switch between the two players to select one
              eor #$01
              sta SelectedPlayer
              jsr DrawMenuCursor
NullJoypad:   lda #$00
              sta SavedJoypadBits
RunDemo:      jsr GameCoreRoutine         ;run game engine
              lda GameEngineSubroutine    ;check to see if we're running lose life routine
              cmp #$06
              bne ExitMenu                ;if not, do not do all the resetting below
ResetTitle:   lda #$00                    ;reset game modes, disable
              sta OperMode                ;IRQ update and screen output 
              sta OperMode_Task           ;screen output
              sta IRQUpdateFlag
              inc DisableScreenFlag
              rts

StartGame:
              lda DemoTimer
              beq ResetTitle
              inc OperMode_Task
              jsr PatchPlayerNamePal      ;patch data over based on selected player
              lda #$00
              sta WorldNumber
              lda #$00
              sta LevelNumber
              lda #$00
              sta AreaNumber
              ldx #$0b
              lda #$00
InitScore:    sta ScoreAndCoinDisplay,x   ;clear player score and coin display
              dex
              bpl InitScore
ExitMenu:     rts

MenuCursorTemplate:
  .byte $22, $4b, $83
  .byte $ce, $24, $24
  .byte $00

MenuCursorTiles:
  .byte $ce, $24, $ce

DrawMenuCursor:
  lda #$1c                 ;set up VRAM address controller to draw cursor
  sta VRAM_Buffer_AddrCtrl

SetupMenuCursor:
  ldy SelectedPlayer       ;write blank and mushroom icon to template
  lda MenuCursorTiles,y    ;in the order based on selected player
  sta MenuCursorTemplate+3
  lda MenuCursorTiles+1,y  ;e.g. if mario, write mushroom, then blank
  sta MenuCursorTemplate+5 ;and if luigi, write blank, then mushroom
  rts

DemoActionData:
  .byte $01, $81, $01, $81, $01, $81, $02, $01
  .byte $81, $00, $81, $00, $80, $01, $81, $01
  .byte $00

DemoTimingData:
  .byte $b0, $10, $10, $10, $28, $10, $28, $06
  .byte $10, $10, $0c, $80, $10, $28, $08, $90
  .byte $ff, $00

DemoEngine:
          ldx DemoAction         ;load current demo action
          lda DemoActionTimer    ;load current action timer
          bne DoAction           ;if timer still counting down, skip
          inx
          inc DemoAction         ;if expired, increment action, X, and
          sec                    ;set carry by default for demo over
          lda DemoTimingData-1,x ;get next timer
          sta DemoActionTimer    ;store as current timer
          beq DemoOver           ;if timer already at zero, skip
DoAction: lda DemoActionData-1,x ;get and perform action (current or next)
          sta SavedJoypad1Bits
          dec DemoActionTimer    ;decrement action timer
          clc                    ;clear carry if demo still going
DemoOver: rts

ClearBuffersDrawIcon:
             lda OperMode               ;check game mode
             bne IncModeTask_B          ;if not attract mode, leave
             ldx #$00                   ;otherwise, clear buffer space
TScrClear:   sta VRAM_Buffer1-1,x
             sta VRAM_Buffer1-1+$100,x
             dex
             bne TScrClear
             jsr DrawMenuCursor         ;draw player select cursor
             inc ScreenRoutineTask      ;move onto next task
             rts

WriteTopScore:
               lda #$fa                    ;run display routine to display top score on title
               jsr WriteDigits
IncModeTask_B: jmp IncModeTask

InitializeGame:
            lda #$00
            sta CompletedWorlds      ;clean slate player's progress (except for games beaten)
            sta HardWorldFlag
            sta SelectedPlayer
            jsr PatchPlayerNamePal   ;set up mario's/luigi's name and palette
            jsr SetupMenuCursor      ;put menu cursor next to mario's name
            ldy #$33                 ;set up offset in the title screen tiles
            lda #$0c                 ;set up counter to print up to 12 stars per row
            sta $00
            ldx #$00                 ;init star counter
PrintStars: lda #$26                 ;print blank by default
            cpx GamesBeatenCount     ;check star counter against games beaten
            bcs PrintToTS            ;if counted up to games beaten, print the blank
            lda #$f1                 ;otherwise print a star for a beaten game
PrintToTS:  sta TitleScreenGfxData,y ;print to title screen
            iny
            dec $00                  ;decrement until done printing a row
            bne NextStarR
            ldy #$4d                 ;set up offset in title screen tiles for next row
NextStarR:  inx
            cpx #$18                 ;printed 24 tiles yet?  if not, go back
            bne PrintStars
            ldy #$6f                 ;clear all memory as in initialization procedure,
            jsr InitializeMemory     ;but this time, clear only as far as $076f
            ldy #$1f
ClrSndLoop: sta SoundMemory,y        ;clear out memory used
            dey                      ;by the sound engines
            bpl ClrSndLoop

DemoReset:
            lda #$18             ;set demo timer
            sta DemoTimer
            jsr LoadAreaPointer
            jmp InitializeArea

PrimaryGameSetup:
      lda #$01
      sta FetchNewGameTimerFlag   ;set flag to load game timer from header
      sta PlayerSize              ;set player's size to small
      lda #$02
      sta NumberofLives           ;give each player three lives
      jmp SecondaryGameSetup

;-------------------------------------------------------------------------------------

PlayerNameData:
  .byte $16, $0a, $1b, $12, $18 ;"MARIO"
  .byte $15, $1e, $12, $10, $12 ;"LUIGI"

PlayerPaletteData:
  .byte $22, $16, $27, $18
  .byte $22, $30, $27, $19

PlayerNameOffsets:
  .byte $04, $09                       ;note that offsets point to last byte

PatchPlayerNamePal:
           ldy SelectedPlayer        ;get offset based on selected player
           lda PlayerNameOffsets,y
           pha
           iny
           sty $00                   ;save player + 1 temporarily (mario = 1, luigi = 2)
           tay
           ldx #$04
NamePatch: lda PlayerNameData,y      ;get name of selected player
           sta TopStatusBarLine+3,x  ;patch to top status bar and victory message
           sta ThankYouMessage+$d,x
           dey
           dex
           bpl NamePatch
           pla                       ;subtract player + 1 from offset loaded earlier
           sec                       ;to get proper offset for palette loading
           sbc $00
           tay
           ldx #$03
PalPatch:  lda PlayerPaletteData,y   ;overwrite palette with the appropriate one
           sta PlayerColors,x
           dey
           dex
           bpl PalPatch
           rts

;-------------------------------------------------------------------------------------

TitleScreenGfxData:
       .byte $20, $84, $01, $44
       .byte $20, $85, $57, $48
       .byte $20, $9c, $01, $49
       .byte $20, $a4, $c9, $46
       .byte $20, $a5, $57, $26
       .byte $20, $bc, $c9, $4a
       .byte $20, $a5, $0a, $d0, $d1, $d8, $d8, $de, $d1, $d0, $da, $de, $d1
       .byte $20, $c5, $17, $d2, $d3, $db, $db, $db, $d9, $db, $dc, $db, $df
       .byte $26, $26, $26, $26, $26, $26, $26, $26, $26, $26, $26, $26, $26
       .byte $20, $e5, $17, $d4, $d5, $d4, $d9, $db, $e2, $d4, $da, $db, $e0
       .byte $26, $26, $26, $26, $26, $26, $26, $26, $26, $26, $26, $26, $26
       .byte $21, $05, $57, $26
       .byte $21, $05, $0a, $d6, $d7, $d6, $d7, $e1, $26, $d6, $dd, $e1, $e1
       .byte $21, $25, $17, $d0, $e8, $d1, $d0, $d1, $de, $d1, $d8, $d0, $d1
       .byte $26, $de, $d1, $de, $d1, $d0, $d1, $d0, $d1, $26, $26, $d0, $d1
       .byte $21, $45, $17, $db, $42, $42, $db, $42, $db, $42, $db, $db, $42
       .byte $26, $db, $42, $db, $42, $db, $42, $db, $42, $26, $26, $db, $42
       .byte $21, $65, $46, $db
       .byte $21, $6b, $11, $df, $db, $db, $db, $26, $db, $df, $db, $df, $db
       .byte $db, $e4, $e5, $26, $26, $ec, $ed
       .byte $21, $85, $17, $db, $db, $db, $de, $43, $db, $e0, $db, $db, $db
       .byte $26, $db, $e3, $db, $e0, $db, $db, $e6, $e3, $26, $26, $ee, $ef
       .byte $21, $a5, $17, $db, $db, $db, $db, $42, $db, $db, $db, $d4, $d9
       .byte $26, $db, $d9, $db, $db, $d4, $d9, $d4, $d9, $e7, $26, $de, $da
       .byte $21, $c4, $19, $5f, $95, $95, $95, $95, $95, $95, $95, $95, $97
       .byte $98, $78, $95, $96, $95, $95, $97, $98, $97, $98, $95, $78, $95
       .byte $f0, $7a
       .byte $21, $ef, $0e, $cf, $01, $09, $08, $06, $24, $17, $12, $17, $1d
       .byte $0e, $17, $0d, $18
       .byte $22, $4d, $0a, $16, $0a, $1b, $12, $18, $24, $10, $0a, $16, $0e
       .byte $22, $8d, $0a, $15, $1e, $12, $10, $12, $24, $10, $0a, $16, $0e
       .byte $22, $eb, $04, $1d, $18, $19, $28
       .byte $22, $f5, $01, $00
       .byte $23, $c9, $47, $55
       .byte $23, $d1, $47, $55
       .byte $23, $d9, $47, $55
       .byte $23, $cc, $43, $f5
       .byte $23, $d6, $01, $dd
       .byte $23, $de, $01, $5d
       .byte $23, $e2, $04, $55, $aa, $aa, $aa
       .byte $23, $ea, $04, $95, $aa, $aa, $2a
       .byte $00, $ff, $ff

;-------------------------------------------------------------------------------------

;GAME LEVELS DATA

;level 1-4
E_CastleArea1:
  .byte $35, $9d, $55, $9b, $c9, $1b, $59, $9d, $45, $9b, $c5, $1b, $26, $80, $45, $1b
  .byte $b9, $1d, $f0, $15, $59, $9d, $0f, $08, $78, $2d, $96, $28, $90, $b5, $ff

;level 2-4
E_CastleArea2:
  .byte $74, $80, $f0, $38, $a0, $bb, $40, $bc, $8c, $1d, $c9, $9d, $05, $9b, $1c, $0c
  .byte $59, $1b, $b5, $1d, $2c, $8c, $40, $15, $7c, $1b, $dc, $1d, $6c, $8c, $bc, $0c
  .byte $78, $ad, $a5, $28, $90, $b5, $ff

;level 3-4
E_CastleArea3:
  .byte $0f, $04, $9c, $0c, $0f, $07, $c5, $1b, $65, $9d, $49, $9d, $5c, $8c, $78, $2d
  .byte $90, $b5, $ff

;level 4-4
E_CastleArea4:
  .byte $49, $9f, $67, $03, $79, $9d, $a0, $3a, $57, $9f, $bb, $1d, $d5, $25, $0f, $05
  .byte $18, $1d, $74, $00, $84, $00, $94, $00, $c6, $29, $49, $9d, $db, $05, $0f, $08
  .byte $05, $9b, $09, $1d, $b0, $38, $80, $95, $c0, $3c, $ec, $a8, $cc, $8c, $4a, $9b
  .byte $78, $2d, $90, $b5, $ff

;level 1-1
E_GroundArea1:
  .byte $07, $8e, $47, $03, $0f, $03, $10, $38, $1b, $80, $53, $06, $77, $0e, $83, $83
  .byte $a0, $3d, $90, $3b, $90, $b7, $60, $bc, $b7, $0e, $ee, $42, $00, $f7, $80, $6b
  .byte $83, $1b, $83, $ab, $06, $ff

;level 1-3
E_GroundArea2:
  .byte $96, $a4, $f9, $24, $d3, $83, $3a, $83, $5a, $03, $95, $07, $f4, $0f, $69, $a8
  .byte $33, $87, $86, $24, $c9, $24, $4b, $83, $67, $83, $17, $83, $56, $28, $95, $24
  .byte $0a, $a4, $ff

;level 2-1
E_GroundArea3:
  .byte $0f, $02, $47, $0e, $87, $0e, $c7, $0e, $f7, $0e, $27, $8e, $ee, $42, $25, $0f
  .byte $06, $ac, $28, $8c, $a8, $4e, $b3, $20, $8b, $8e, $f7, $90, $36, $90, $e5, $8e
  .byte $32, $8e, $c2, $06, $d2, $06, $e2, $06, $ff

;level 2-2
E_GroundArea4:
  .byte $15, $8e, $9b, $06, $e0, $37, $80, $bc, $0f, $04, $2b, $3b, $ab, $0e, $eb, $0e
  .byte $0f, $06, $f0, $37, $4b, $8e, $6b, $80, $bb, $3c, $4b, $bb, $ee, $42, $20, $1b
  .byte $bc, $cb, $00, $ab, $83, $eb, $bb, $0f, $0e, $1b, $03, $9b, $37, $d4, $0e, $a3
  .byte $86, $b3, $06, $c3, $06, $ff

;level 2-3
E_GroundArea5:
  .byte $c0, $be, $0f, $03, $38, $0e, $15, $8f, $aa, $83, $f8, $07, $0f, $07, $96, $10
  .byte $0f, $09, $48, $10, $ba, $03, $ff

;level 3-1
E_GroundArea6:
  .byte $87, $85, $a3, $05, $db, $83, $fb, $03, $93, $8f, $bb, $03, $ce, $42, $42, $9b
  .byte $83, $ae, $b3, $40, $db, $00, $f4, $0f, $33, $8f, $74, $0f, $10, $bc, $f5, $0f
  .byte $2e, $c2, $45, $b7, $03, $f7, $03, $c8, $90, $ff

;level 3-3
E_GroundArea7:
  .byte $80, $be, $83, $03, $92, $10, $4b, $80, $b0, $3c, $07, $80, $b7, $24, $0c, $a4
  .byte $96, $a9, $1b, $83, $7b, $24, $b7, $24, $97, $83, $e2, $0f, $a9, $a9, $38, $a9
  .byte $0f, $0b, $74, $8f, $ff

;level 4-1
E_GroundArea8:
  .byte $e2, $91, $0f, $03, $42, $11, $0f, $06, $72, $11, $0f, $08, $ee, $02, $60, $02
  .byte $91, $ee, $b3, $60, $d3, $86, $ff

;level 4-2
E_GroundArea9:
  .byte $0f, $02, $9b, $02, $ab, $02, $0f, $04, $13, $03, $92, $11, $60, $b7, $00, $bc
  .byte $00, $bb, $0b, $83, $cb, $03, $7b, $85, $9e, $c2, $60, $e6, $05, $0f, $0c, $62
  .byte $10, $ff

;level 4-3
E_GroundArea11:
  .byte $e6, $a9, $57, $a8, $b5, $24, $19, $a4, $76, $28, $a2, $0f, $95, $8f, $9d, $a8
  .byte $0f, $07, $09, $29, $55, $24, $8b, $17, $a9, $24, $db, $83, $04, $a9, $24, $8f
  .byte $65, $0f, $ff

;cloud level used in levels 2-1, 3-1 and 4-1
E_GroundArea20:
  .byte $0a, $aa, $1e, $22, $29, $1e, $25, $49, $2e, $27, $66, $ff

;level 1-2
E_UndergroundArea1:
  .byte $0a, $8e, $de, $b4, $00, $e0, $37, $5b, $82, $2b, $a9, $aa, $29, $29, $a9, $a8
  .byte $29, $0f, $08, $f0, $3c, $79, $a9, $c5, $26, $cd, $26, $ee, $3b, $01, $67, $b4
  .byte $0f, $0c, $2e, $c1, $00, $ff

;warp zone area used by level 1-2
E_UndergroundArea2:
  .byte $09, $a9, $19, $a9, $de, $42, $02, $7b, $83, $ff

;underground bonus rooms used in many levels
E_UndergroundArea3:
  .byte $1e, $a0, $0a, $1e, $23, $2b, $1e, $28, $6b, $0f, $03, $1e, $40, $08, $1e, $25
  .byte $4e, $0f, $06, $1e, $22, $25, $1e, $25, $45, $ff

;level 3-2
E_WaterArea1:
  .byte $0f, $01, $2a, $07, $2e, $3b, $41, $e9, $07, $0f, $03, $6b, $07, $f9, $07, $b8
  .byte $80, $2a, $87, $4a, $87, $b3, $0f, $84, $87, $47, $83, $87, $07, $0a, $87, $42
  .byte $87, $1b, $87, $6b, $03, $ff

;water area used by level 4-1
E_WaterArea3:
  .byte $1e, $a7, $6a, $5b, $82, $74, $07, $d8, $07, $e8, $02, $0f, $04, $26, $07, $ff

;level 1-4
L_CastleArea1:
  .byte $9b, $07, $05, $32, $06, $33, $07, $34, $33, $8e, $4e, $0a, $7e, $06, $9e, $0a
  .byte $ce, $06, $e3, $00, $ee, $0a, $1e, $87, $53, $0e, $8e, $02, $9c, $00, $c7, $0e
  .byte $d7, $37, $57, $8e, $6c, $05, $da, $60, $e9, $61, $f8, $62, $fe, $0b, $43, $8e
  .byte $c3, $0e, $43, $8e, $b7, $0e, $ee, $09, $fe, $0a, $3e, $86, $57, $0e, $6e, $0a
  .byte $7e, $06, $ae, $0a, $be, $06, $fe, $07, $15, $e2, $55, $62, $95, $62, $fe, $0a
  .byte $0d, $c4, $cd, $43, $ce, $09, $de, $0b, $dd, $42, $fe, $02, $5d, $c7, $fd

;level 2-4
L_CastleArea2:
  .byte $9b, $07, $05, $32, $06, $33, $07, $34, $03, $e2, $0e, $06, $1e, $0c, $7e, $0a
  .byte $8e, $05, $8e, $82, $8a, $8e, $8e, $0a, $ee, $02, $0a, $e0, $19, $61, $23, $06
  .byte $28, $62, $2e, $0b, $7e, $0a, $81, $62, $87, $30, $8e, $04, $a7, $31, $c7, $0e
  .byte $d7, $33, $fe, $03, $03, $8e, $0e, $0a, $11, $62, $1e, $04, $27, $32, $4e, $0a
  .byte $51, $62, $57, $0e, $5e, $04, $67, $34, $9e, $0a, $a1, $62, $ae, $03, $b3, $0e
  .byte $be, $0b, $ee, $09, $fe, $0a, $2e, $82, $7a, $0e, $7e, $0a, $97, $31, $be, $04
  .byte $da, $0e, $ee, $0a, $f1, $62, $fe, $02, $3e, $8a, $7e, $06, $ae, $0a, $ce, $06
  .byte $fe, $0a, $0d, $c4, $11, $53, $21, $52, $24, $0b, $51, $52, $61, $52, $cd, $43
  .byte $ce, $09, $dd, $42, $de, $0b, $fe, $02, $5d, $c7, $fd

;level 3-4
L_CastleArea3:
  .byte $5b, $09, $05, $34, $06, $35, $6e, $06, $7e, $0a, $ae, $02, $fe, $02, $0d, $01
  .byte $0e, $0e, $2e, $0a, $6e, $09, $be, $0a, $ed, $4b, $e4, $60, $ee, $0d, $5e, $82
  .byte $78, $72, $a4, $3d, $a5, $3e, $a6, $3f, $a3, $be, $a6, $3e, $a9, $32, $e9, $3a
  .byte $9c, $80, $a3, $33, $a6, $33, $a9, $33, $e5, $06, $ed, $4b, $f3, $30, $f6, $30
  .byte $f9, $30, $fe, $02, $0d, $05, $3c, $01, $57, $73, $7c, $02, $93, $30, $a7, $73
  .byte $b3, $37, $cc, $01, $07, $83, $17, $03, $27, $03, $37, $03, $64, $3b, $77, $3a
  .byte $0c, $80, $2e, $0e, $9e, $02, $a5, $62, $b6, $61, $cc, $02, $c3, $33, $ed, $4b
  .byte $03, $b7, $07, $37, $83, $37, $87, $37, $dd, $4b, $03, $b5, $07, $35, $5e, $0a
  .byte $8e, $02, $ae, $0a, $de, $06, $fe, $0a, $0d, $c4, $cd, $43, $ce, $09, $dd, $42
  .byte $de, $0b, $fe, $02, $5d, $c7, $fd

;level 4-4
L_CastleArea4:
  .byte $9b, $07, $05, $32, $06, $33, $07, $34, $4e, $03, $5c, $02, $0c, $f1, $27, $00
  .byte $3c, $74, $47, $0e, $fc, $00, $fe, $0b, $77, $8e, $ee, $09, $fe, $0a, $45, $b2
  .byte $55, $0e, $99, $32, $b9, $0e, $fe, $02, $0e, $85, $fe, $02, $16, $8e, $2e, $0c
  .byte $ae, $0a, $ee, $05, $1e, $82, $47, $0e, $07, $bd, $c4, $72, $de, $0a, $fe, $02
  .byte $03, $8e, $07, $0e, $13, $3c, $17, $3d, $e3, $03, $ee, $0a, $f3, $06, $f7, $03
  .byte $fe, $0e, $fe, $8a, $38, $e4, $4a, $72, $68, $64, $37, $b0, $98, $64, $a8, $64
  .byte $e8, $64, $f8, $64, $0d, $c4, $71, $64, $cd, $43, $ce, $09, $dd, $42, $de, $0b
  .byte $fe, $02, $5d, $c7, $fd

;level 1-1
L_GroundArea1:
  .byte $50, $31, $0f, $26, $13, $e4, $23, $24, $27, $23, $37, $07, $66, $61, $ac, $74
  .byte $c7, $01, $0b, $f1, $77, $73, $b6, $04, $db, $71, $5c, $82, $83, $2d, $a2, $47
  .byte $a7, $0a, $b7, $29, $4f, $b3, $87, $0b, $93, $23, $cc, $06, $e3, $2c, $3a, $e0
  .byte $7c, $71, $97, $01, $ac, $73, $e6, $61, $0e, $b1, $b7, $f3, $dc, $02, $d3, $25
  .byte $07, $fb, $2c, $01, $e7, $73, $2c, $f2, $34, $72, $57, $00, $7c, $02, $39, $f1
  .byte $bf, $37, $33, $e7, $cd, $41, $0f, $a6, $ed, $47, $fd

;level 1-3
L_GroundArea2:
  .byte $50, $11, $0f, $26, $fe, $10, $47, $92, $56, $40, $ac, $16, $af, $12, $0f, $95
  .byte $73, $16, $82, $44, $ec, $48, $bc, $c2, $1c, $b1, $b3, $16, $c2, $44, $86, $c0
  .byte $9c, $14, $9f, $12, $a6, $40, $df, $15, $0b, $96, $43, $12, $97, $31, $d3, $12
  .byte $03, $92, $27, $14, $63, $00, $c7, $15, $d6, $43, $ac, $97, $af, $11, $1f, $96
  .byte $64, $13, $e3, $12, $2e, $91, $9d, $41, $ae, $42, $df, $20, $cd, $c7, $fd

;level 2-1
L_GroundArea3:
  .byte $52, $21, $0f, $20, $6e, $64, $4f, $b2, $7c, $5f, $7c, $3f, $7c, $d8, $7c, $38
  .byte $83, $02, $a3, $00, $c3, $02, $f7, $16, $5c, $d6, $cf, $35, $d3, $20, $e3, $0a
  .byte $f3, $20, $25, $b5, $2c, $53, $6a, $7a, $8c, $54, $da, $72, $fc, $50, $0c, $d2
  .byte $39, $73, $5c, $54, $aa, $72, $cc, $53, $f7, $16, $33, $83, $40, $06, $5c, $5b
  .byte $09, $93, $27, $0f, $3c, $5c, $0a, $b0, $63, $27, $78, $72, $93, $09, $97, $03
  .byte $a7, $03, $b7, $22, $47, $81, $5c, $72, $2a, $b0, $28, $0f, $3c, $5f, $58, $31
  .byte $b8, $31, $28, $b1, $3c, $5b, $98, $31, $fa, $30, $03, $b2, $20, $04, $7f, $b7
  .byte $f3, $67, $8d, $c1, $bf, $26, $ad, $c7, $fd

;level 2-2
L_GroundArea4:
  .byte $54, $11, $0f, $26, $38, $f2, $ab, $71, $0b, $f1, $96, $42, $ce, $10, $1e, $91
  .byte $29, $61, $3a, $60, $4e, $10, $78, $74, $8e, $11, $06, $c3, $1a, $e0, $1e, $10
  .byte $5e, $11, $67, $63, $77, $63, $88, $62, $99, $61, $aa, $60, $be, $10, $0a, $f2
  .byte $15, $45, $7e, $11, $7a, $31, $9a, $e0, $ac, $02, $d9, $61, $d4, $0a, $ec, $01
  .byte $d6, $c2, $84, $c3, $98, $fa, $d3, $07, $d7, $0b, $e9, $61, $ee, $10, $2e, $91
  .byte $39, $71, $93, $03, $a6, $03, $be, $10, $e1, $71, $e3, $31, $5e, $91, $69, $61
  .byte $e6, $41, $28, $e2, $99, $71, $ae, $10, $ce, $11, $be, $90, $d6, $32, $3e, $91
  .byte $5f, $37, $66, $60, $d3, $67, $6d, $c1, $af, $26, $9d, $c7, $fd

;level 2-3
L_GroundArea5:
  .byte $54, $11, $0f, $26, $af, $32, $d8, $62, $e8, $62, $f8, $62, $fe, $10, $0c, $be
  .byte $f8, $64, $0d, $c8, $2c, $43, $98, $64, $ac, $39, $48, $e4, $6a, $62, $7c, $47
  .byte $fa, $62, $3c, $b7, $ea, $62, $fc, $4d, $f6, $02, $03, $80, $06, $02, $13, $02
  .byte $da, $62, $0d, $c8, $0b, $17, $97, $16, $2c, $b1, $33, $43, $6c, $31, $ac, $31
  .byte $17, $93, $73, $12, $cc, $31, $1a, $e2, $2c, $4b, $67, $48, $ea, $62, $0d, $ca
  .byte $17, $12, $53, $12, $be, $11, $1d, $c1, $3e, $42, $6f, $20, $4d, $c7, $fd

;level 3-1
L_GroundArea6:
  .byte $52, $b1, $0f, $20, $6e, $75, $53, $aa, $57, $25, $b7, $0a, $c7, $23, $0c, $83
  .byte $5c, $72, $87, $01, $c3, $00, $c7, $20, $dc, $65, $0c, $87, $c3, $22, $f3, $03
  .byte $03, $a2, $27, $7b, $33, $03, $43, $23, $52, $42, $9c, $06, $a7, $20, $c3, $23
  .byte $03, $a2, $0c, $02, $33, $09, $39, $71, $43, $23, $77, $06, $83, $67, $a7, $73
  .byte $5c, $82, $c9, $11, $07, $80, $1c, $71, $98, $11, $9a, $10, $f3, $04, $16, $f4
  .byte $3c, $02, $68, $7a, $8c, $01, $a7, $73, $e7, $73, $ac, $83, $09, $8f, $1c, $03
  .byte $9f, $37, $13, $e7, $7c, $02, $ad, $41, $ef, $26, $0d, $0e, $39, $71, $7f, $37
  .byte $f2, $68, $02, $e8, $12, $3a, $1c, $00, $68, $7a, $de, $3f, $6d, $c5, $fd

;level 3-3
L_GroundArea7:
  .byte $55, $10, $0b, $1f, $0f, $26, $d6, $12, $07, $9f, $33, $1a, $fb, $1f, $f7, $94
  .byte $53, $94, $71, $71, $cc, $15, $cf, $13, $1f, $98, $63, $12, $9b, $13, $a9, $71
  .byte $fb, $17, $09, $f1, $13, $13, $21, $42, $59, $0f, $eb, $13, $33, $93, $40, $06
  .byte $8c, $14, $8f, $17, $93, $40, $cf, $13, $0b, $94, $57, $15, $07, $93, $19, $f3
  .byte $c6, $43, $c7, $13, $d3, $03, $e3, $03, $33, $b0, $4a, $72, $55, $46, $73, $31
  .byte $a8, $74, $e3, $12, $8e, $91, $ad, $41, $ce, $42, $ef, $20, $dd, $c7, $fd

;level 4-1
L_GroundArea8:
  .byte $52, $21, $0f, $20, $6e, $63, $a9, $f1, $fb, $71, $22, $83, $37, $0b, $36, $50
  .byte $39, $51, $b8, $62, $57, $f3, $e8, $02, $f8, $02, $08, $82, $18, $02, $2d, $4a
  .byte $28, $02, $38, $02, $48, $00, $a8, $0f, $aa, $30, $bc, $5a, $6a, $b0, $4f, $b6
  .byte $b7, $04, $9a, $b0, $ac, $71, $c7, $01, $e6, $74, $0d, $09, $46, $02, $56, $00
  .byte $6c, $01, $84, $79, $86, $02, $96, $02, $a4, $71, $a6, $02, $b6, $02, $c4, $71
  .byte $c6, $02, $d6, $02, $39, $f1, $6c, $00, $77, $02, $a3, $09, $ac, $00, $b8, $72
  .byte $dc, $01, $07, $f3, $4c, $00, $6f, $37, $e3, $03, $e6, $03, $5d, $ca, $6c, $00
  .byte $7d, $41, $cf, $26, $9d, $c7, $fd

;level 4-2
L_GroundArea9:
  .byte $50, $a1, $0f, $26, $17, $91, $19, $11, $48, $00, $68, $11, $6a, $10, $96, $14
  .byte $d8, $0a, $e8, $02, $f8, $02, $dc, $81, $6c, $81, $89, $0f, $9c, $00, $c3, $29
  .byte $f8, $62, $47, $a7, $c6, $61, $0d, $07, $56, $74, $b7, $00, $b9, $11, $cc, $76
  .byte $ed, $4a, $1c, $80, $37, $01, $3a, $10, $de, $20, $e9, $0b, $ee, $21, $c8, $bc
  .byte $9c, $f6, $bc, $00, $cb, $7a, $eb, $72, $0c, $82, $39, $71, $b7, $63, $cc, $03
  .byte $e6, $60, $26, $e0, $4a, $30, $53, $31, $5c, $58, $ed, $41, $2f, $a6, $1d, $c7
  .byte $fd

;level 4-3
L_GroundArea11:
  .byte $50, $11, $0f, $26, $fe, $10, $8b, $93, $a9, $0f, $14, $c1, $cc, $16, $cf, $11
  .byte $2f, $95, $b7, $14, $c7, $96, $d6, $44, $2b, $92, $39, $0f, $72, $41, $a7, $00
  .byte $1b, $95, $97, $13, $6c, $95, $6f, $11, $a2, $40, $bf, $15, $c2, $40, $0b, $9f
  .byte $53, $16, $62, $44, $72, $c2, $9b, $1d, $b7, $e0, $ed, $4a, $03, $e0, $8e, $11
  .byte $9d, $41, $be, $42, $ef, $20, $cd, $c7, $fd

;cloud level used in levels 2-1, 3-1 and 4-1
L_GroundArea20:
  .byte $00, $c1, $4c, $00, $03, $cf, $00, $d7, $23, $4d, $07, $af, $2a, $4c, $03, $cf
  .byte $3e, $80, $f3, $4a, $bb, $c2, $bd, $c7, $fd

;level 1-2
L_UndergroundArea1:
  .byte $48, $0f, $0e, $01, $5e, $02, $0a, $b0, $1c, $54, $6a, $30, $7f, $34, $c6, $64
  .byte $d6, $64, $e6, $64, $f6, $64, $fe, $00, $f0, $07, $00, $a1, $1e, $02, $47, $73
  .byte $7e, $04, $84, $52, $94, $50, $95, $0b, $96, $50, $a4, $52, $ae, $05, $b8, $51
  .byte $c8, $51, $ce, $01, $17, $f3, $45, $03, $52, $09, $62, $21, $6f, $34, $81, $21
  .byte $9e, $02, $b6, $64, $c6, $64, $c0, $0c, $d6, $64, $d0, $07, $e6, $64, $e0, $0c
  .byte $f0, $07, $fe, $0a, $0d, $06, $0e, $01, $4e, $04, $67, $73, $8e, $02, $b7, $0a
  .byte $bc, $03, $c4, $72, $c7, $22, $08, $f2, $2c, $02, $59, $71, $7c, $01, $96, $74
  .byte $bc, $01, $d8, $72, $fc, $01, $39, $f1, $4e, $01, $9e, $04, $a7, $52, $b7, $0b
  .byte $b8, $51, $c7, $51, $d7, $50, $de, $02, $3a, $e0, $3e, $0a, $9e, $00, $08, $d4
  .byte $18, $54, $28, $54, $48, $54, $6e, $06, $9e, $01, $a8, $52, $af, $47, $b8, $52
  .byte $c8, $52, $d8, $52, $de, $0f, $4d, $c7, $ce, $01, $dc, $01, $f9, $79, $1c, $82
  .byte $48, $72, $7f, $37, $f2, $68, $01, $e9, $11, $3a, $68, $7a, $de, $0f, $6d, $c5
  .byte $fd

;warp zone area used by level 1-2
L_UndergroundArea2:
  .byte $0b, $0f, $0e, $01, $9c, $71, $b7, $00, $be, $00, $3e, $81, $47, $73, $5e, $00
  .byte $63, $42, $8e, $01, $a7, $73, $be, $00, $7e, $81, $88, $72, $f0, $59, $fe, $00
  .byte $00, $d9, $0e, $01, $39, $79, $a7, $03, $ae, $00, $b4, $03, $de, $0f, $0d, $05
  .byte $0e, $02, $68, $7a, $be, $01, $de, $0f, $6d, $c5, $fd

;underground bonus rooms used with worlds 1-4
L_UndergroundArea3:
  .byte $08, $8f, $0e, $01, $17, $05, $2e, $02, $30, $07, $37, $03, $3a, $49, $44, $03
  .byte $58, $47, $df, $4a, $6d, $c7, $0e, $81, $00, $5a, $2e, $02, $87, $52, $97, $2f
  .byte $99, $4f, $0a, $90, $93, $56, $a3, $0b, $a7, $50, $b3, $55, $df, $4a, $6d, $c7
  .byte $0e, $81, $00, $5a, $2e, $00, $3e, $02, $41, $56, $57, $25, $56, $45, $68, $51
  .byte $7a, $43, $b7, $0b, $b8, $51, $df, $4a, $6d, $c7, $fd

;level 3-2
L_WaterArea1:
  .byte $41, $01, $03, $b4, $04, $34, $05, $34, $5c, $02, $83, $37, $84, $37, $85, $37
  .byte $09, $c2, $0c, $02, $1d, $49, $fa, $60, $09, $e1, $18, $62, $20, $63, $27, $63
  .byte $33, $37, $37, $63, $47, $63, $5c, $05, $79, $43, $fe, $06, $35, $d2, $46, $48
  .byte $91, $53, $d6, $51, $fe, $01, $0c, $83, $6c, $04, $b4, $62, $c4, $62, $d4, $62
  .byte $e4, $62, $f4, $62, $18, $d2, $79, $51, $f4, $66, $fe, $02, $0c, $8a, $1d, $49
  .byte $31, $55, $56, $41, $77, $41, $98, $41, $c5, $55, $fe, $01, $07, $e3, $17, $63
  .byte $27, $63, $37, $63, $47, $63, $57, $63, $67, $63, $78, $62, $89, $61, $9a, $60
  .byte $bc, $07, $ca, $42, $3a, $b3, $46, $53, $63, $34, $66, $44, $7c, $01, $9a, $33
  .byte $b7, $52, $dc, $01, $fa, $32, $05, $d4, $2c, $0d, $43, $37, $47, $35, $b7, $30
  .byte $c3, $64, $23, $e4, $29, $45, $33, $64, $43, $64, $53, $64, $63, $64, $73, $64
  .byte $9a, $60, $a9, $61, $b8, $62, $be, $0b, $d4, $31, $d5, $0d, $de, $0f, $0d, $ca
  .byte $7d, $47, $fd

;water area used by level 4-1
L_WaterArea3:
  .byte $01, $01, $78, $52, $b5, $55, $da, $60, $e9, $61, $f8, $62, $fe, $0b, $fe, $81
  .byte $0a, $cf, $36, $49, $62, $43, $fe, $07, $36, $c9, $fe, $01, $0c, $84, $65, $55
  .byte $97, $52, $9a, $32, $a9, $31, $b8, $30, $c7, $63, $ce, $0f, $d5, $0d, $7d, $c7
  .byte $fd

;a bunch of unused space
  .byte $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
  .byte $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
  .byte $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
  .byte $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
  .byte $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
  .byte $ff, $ff, $ff

;-------------------------------------------------------------------------------------

;this is overwritten by the contents of SM2SAVE
GamesBeatenCount:
       .byte 0

;-------------------------------------------------------------------------------------

SoundEngine:
         lda OperMode              ;are we in attract mode?
         bne SndOn
         sta SND_MASTERCTRL_REG    ;if so, disable sound and leave
         rts
SndOn:   lda #$ff
         sta JOYPAD_PORT2          ;disable irqs from apu and set frame counter mode
         lda #$0f
         sta SND_MASTERCTRL_REG    ;enable first four channels
         lda PauseModeFlag         ;is sound already in pause mode?
         bne InPause
         lda PauseSoundQueue       ;if not, check pause sfx queue    
         cmp #$01
         bne RunSoundSubroutines   ;if queue is empty, skip pause mode routine
InPause: lda PauseSoundBuffer      ;check pause sfx buffer
         bne ContPau
         lda PauseSoundQueue       ;check pause queue
         beq SkipSoundSubroutines
         sta PauseSoundBuffer      ;if queue full, store in buffer and activate
         sta PauseModeFlag         ;pause mode to interrupt game sounds
         lda #$00                  ;disable sound and clear sfx buffers
         sta SND_MASTERCTRL_REG
         sta Square1SoundBuffer
         sta Square2SoundBuffer
         sta NoiseSoundBuffer
         lda #$0f
         sta SND_MASTERCTRL_REG    ;enable sound again
         lda #$2a                  ;store length of sound in pause counter
         sta Squ1_SfxLenCounter
PTone1F: lda #$44                  ;play first tone
         bne PTRegC                ;unconditional branch
ContPau: lda Squ1_SfxLenCounter    ;check pause length left
         cmp #$24                  ;time to play second?
         beq PTone2F
         cmp #$1e                  ;time to play first again?
         beq PTone1F
         cmp #$18                  ;time to play second again?
         bne DecPauC               ;only load regs during times, otherwise skip
PTone2F: lda #$64                  ;store reg contents and play the pause sfx
PTRegC:  ldx #$84
         ldy #$7f
         jsr PlaySqu1Sfx
DecPauC: dec Squ1_SfxLenCounter    ;decrement pause sfx counter
         bne SkipSoundSubroutines
         lda #$00                  ;disable sound if in pause mode and
         sta SND_MASTERCTRL_REG    ;not currently playing the pause sfx
         lda PauseSoundBuffer      ;if no longer playing pause sfx, check to see
         cmp #$02                  ;if we need to be playing sound again
         bne SkipPIn
         lda #$00                  ;clear pause mode to allow game sounds again
         sta PauseModeFlag
SkipPIn: lda #$00                  ;clear pause sfx buffer
         sta PauseSoundBuffer
         beq SkipSoundSubroutines

RunSoundSubroutines:
         jsr Square1SfxHandler  ;play sfx on square channel 1
         jsr Square2SfxHandler  ; ''  ''  '' square channel 2
         jsr NoiseSfxHandler    ; ''  ''  '' noise channel
         jsr MusicHandler       ;play music on all channels
         lda #$00               ;clear the music queues
         sta AreaMusicQueue
         sta EventMusicQueue

SkipSoundSubroutines:
          lda #$00               ;clear the sound effects queues
          sta Square1SoundQueue
          sta Square2SoundQueue
          sta NoiseSoundQueue
          sta PauseSoundQueue
          ldy DAC_Counter        ;load some sort of counter 
          lda AreaMusicBuffer
          and #%00000011         ;check for specific music
          beq NoIncDAC
          inc DAC_Counter        ;increment and check counter
          cpy #$30
          bcc StrWave            ;if not there yet, just store it
NoIncDAC: tya
          beq StrWave            ;if we are at zero, do not decrement 
          dec DAC_Counter        ;decrement counter
StrWave:  sty SND_DELTA_REG+1    ;store into DMC load register (??)
          rts                    ;we are done here


;--------------------------------

Dump_Squ1_Regs:
      sty SND_SQUARE1_REG+1  ;dump the contents of X and Y into square 1's control regs
      stx SND_SQUARE1_REG
      rts
      
PlaySqu1Sfx:
      jsr Dump_Squ1_Regs     ;do sub to set ctrl regs for square 1, then set frequency regs

SetFreq_Squ1:
      ldx #$00               ;set frequency reg offset for square 1 sound channel

Dump_Freq_Regs:
        tay
        lda FreqRegLookupTbl+1,y  ;use previous contents of A for sound reg offset
        beq NoTone                ;if zero, then do not load
        sta SND_REGISTER+2,x      ;first byte goes into LSB of frequency divider
        lda FreqRegLookupTbl,y    ;second byte goes into 3 MSB plus extra bit for 
        ora #%00001000            ;length counter
        sta SND_REGISTER+3,x
NoTone: rts

Dump_Sq2_Regs:
      stx SND_SQUARE2_REG    ;dump the contents of X and Y into square 2's control regs
      sty SND_SQUARE2_REG+1
      rts

PlaySqu2Sfx:
      jsr Dump_Sq2_Regs      ;do sub to set ctrl regs for square 2, then set frequency regs

SetFreq_Squ2:
      ldx #$04               ;set frequency reg offset for square 2 sound channel
      bne Dump_Freq_Regs     ;unconditional branch

SetFreq_Tri:
      ldx #$08               ;set frequency reg offset for triangle sound channel
      bne Dump_Freq_Regs     ;unconditional branch

;--------------------------------

SwimStompEnvelopeData:
      .byte $9f, $9b, $98, $96, $95, $94, $92, $90
      .byte $90, $9a, $97, $95, $93, $92

PlayFlagpoleSlide:
       lda #$40               ;store length of flagpole sound
       sta Squ1_SfxLenCounter
       lda #$62               ;load part of reg contents for flagpole sound
       jsr SetFreq_Squ1
       ldx #$99               ;now load the rest
       bne FPS2nd

PlaySmallJump:
       lda #$26               ;branch here for small mario jumping sound
       bne JumpRegContents

PlayBigJump:
       lda #$18               ;branch here for big mario jumping sound

JumpRegContents:
       ldx #$82               ;note that small and big jump borrow each others' reg contents
       ldy #$a7               ;anyway, this loads the first part of mario's jumping sound
       jsr PlaySqu1Sfx
       lda #$28               ;store length of sfx for both jumping sounds
       sta Squ1_SfxLenCounter ;then continue on here

ContinueSndJump:
          lda Squ1_SfxLenCounter ;jumping sounds seem to be composed of three parts
          cmp #$25               ;check for time to play second part yet
          bne N2Prt
          ldx #$5f               ;load second part
          ldy #$f6
          bne DmpJpFPS           ;unconditional branch
N2Prt:    cmp #$20               ;check for third part
          bne DecJpFPS
          ldx #$48               ;load third part
FPS2nd:   ldy #$bc               ;the flagpole slide sound shares part of third part
DmpJpFPS: jsr Dump_Squ1_Regs
          bne DecJpFPS           ;unconditional branch outta here

PlayFireballThrow:
        lda #$05
        ldy #$99                 ;load reg contents for fireball throw sound
        bne Fthrow               ;unconditional branch

PlayBump:
          lda #$0a                ;load length of sfx and reg contents for bump sound
          ldy #$93
Fthrow:   ldx #$9e                ;the fireball sound shares reg contents with the bump sound
          sta Squ1_SfxLenCounter
          lda #$0c                ;load offset for bump sound
          jsr PlaySqu1Sfx

ContinueBumpThrow:    
          lda Squ1_SfxLenCounter  ;check for second part of bump sound
          cmp #$06   
          bne DecJpFPS
          lda #$bb                ;load second part directly
          sta SND_SQUARE1_REG+1
DecJpFPS: bne BranchToDecLength1  ;unconditional branch


Square1SfxHandler:
       ldy Square1SoundQueue   ;check for sfx in queue
       beq CheckSfx1Buffer
       sty Square1SoundBuffer  ;if found, put in buffer
       bmi PlaySmallJump       ;small jump
       lsr Square1SoundQueue
       bcs PlayBigJump         ;big jump
       lsr Square1SoundQueue
       bcs PlayBump            ;bump
       lsr Square1SoundQueue
       bcs PlaySwimStomp       ;swim/stomp
       lsr Square1SoundQueue
       bcs PlaySmackEnemy      ;smack enemy
       lsr Square1SoundQueue
       bcs PlayPipeDownInj     ;pipedown/injury
       lsr Square1SoundQueue
       bcs PlayFireballThrow   ;fireball throw
       lsr Square1SoundQueue
       bcs PlayFlagpoleSlide   ;slide flagpole

CheckSfx1Buffer:
       lda Square1SoundBuffer   ;check for sfx in buffer 
       beq ExS1H                ;if not found, exit sub
       bmi ContinueSndJump      ;small mario jump 
       lsr
       bcs ContinueSndJump      ;big mario jump 
       lsr
       bcs ContinueBumpThrow    ;bump
       lsr
       bcs ContinueSwimStomp    ;swim/stomp
       lsr
       bcs ContinueSmackEnemy   ;smack enemy
       lsr
       bcs ContinuePipeDownInj  ;pipedown/injury
       lsr
       bcs ContinueBumpThrow    ;fireball throw
       lsr
       bcs DecrementSfx1Length  ;slide flagpole
ExS1H: rts


PlaySwimStomp:
      lda #$0e               ;store length of swim/stomp sound
      sta Squ1_SfxLenCounter
      ldy #$9c               ;store reg contents for swim/stomp sound
      ldx #$9e
      lda #$26
      jsr PlaySqu1Sfx

ContinueSwimStomp: 
      ldy Squ1_SfxLenCounter        ;look up reg contents in data section based on
      lda SwimStompEnvelopeData-1,y ;length of sound left, used to control sound's
      sta SND_SQUARE1_REG           ;envelope
      cpy #$06   
      bne BranchToDecLength1
      lda #$9e                      ;when the length counts down to a certain point, put this
      sta SND_SQUARE1_REG+2         ;directly into the LSB of square 1's frequency divider

BranchToDecLength1: 
      bne DecrementSfx1Length  ;unconditional branch (regardless of how we got here)

PlaySmackEnemy:
      lda #$0e                 ;store length of smack enemy sound
      ldy #$cb
      ldx #$9f
      sta Squ1_SfxLenCounter
      lda #$28                 ;store reg contents for smack enemy sound
      jsr PlaySqu1Sfx
      bne DecrementSfx1Length  ;unconditional branch

ContinueSmackEnemy:
        ldy Squ1_SfxLenCounter  ;check about halfway through
        cpy #$08
        bne SmSpc
        lda #$a0                ;if we're at the about-halfway point, make the second tone
        sta SND_SQUARE1_REG+2   ;in the smack enemy sound
        lda #$9f
        bne SmTick
SmSpc:  lda #$90                ;this creates spaces in the sound, giving it its distinct noise
SmTick: sta SND_SQUARE1_REG

DecrementSfx1Length:
      dec Squ1_SfxLenCounter    ;decrement length of sfx
      bne ExSfx1

StopSquare1Sfx:
        ldx #$00                ;if end of sfx reached, clear buffer
        stx $f1                 ;and stop making the sfx
        ldx #$0e
        stx SND_MASTERCTRL_REG
        ldx #$0f
        stx SND_MASTERCTRL_REG
ExSfx1: rts

PlayPipeDownInj:  
      lda #$2f                ;load length of pipedown sound
      sta Squ1_SfxLenCounter

ContinuePipeDownInj:
         lda Squ1_SfxLenCounter  ;some bitwise logic, forces the regs
         lsr                     ;to be written to only during six specific times
         bcs NoPDwnL             ;during which d3 must be set and d1-0 must be clear
         lsr
         bcs NoPDwnL
         and #%00000010
         beq NoPDwnL
         ldy #$91                ;and this is where it actually gets written in
         ldx #$9a
         lda #$44
         jsr PlaySqu1Sfx
NoPDwnL: jmp DecrementSfx1Length

;--------------------------------

ExtraLifeFreqData:
      .byte $58, $02, $54, $56, $4e, $44

PowerUpGrabFreqData:
      .byte $4c, $52, $4c, $48, $3e, $36, $3e, $36, $30
      .byte $28, $4a, $50, $4a, $64, $3c, $32, $3c, $32
      .byte $2c, $24, $3a, $64, $3a, $34, $2c, $22, $2c

;residual frequency data
      .byte $22, $1c, $14

PUp_VGrow_FreqData:
      .byte $14, $04, $22, $24, $16, $04, $24, $26 ;used by both
      .byte $18, $04, $26, $28, $1a, $04, $28, $2a
      .byte $1c, $04, $2a, $2c, $1e, $04, $2c, $2e ;used by vinegrow
      .byte $20, $04, $2e, $30, $22, $04, $30, $32

PlayCoinGrab:
        lda #$35             ;load length of coin grab sound
        ldx #$8d             ;and part of reg contents
        bne CGrab_TTickRegL

PlayTimerTick:
        lda #$06             ;load length of timer tick sound
        ldx #$98             ;and part of reg contents

CGrab_TTickRegL:
        sta Squ2_SfxLenCounter 
        ldy #$7f                ;load the rest of reg contents 
        lda #$42                ;of coin grab and timer tick sound
        jsr PlaySqu2Sfx

ContinueCGrabTTick:
        lda Squ2_SfxLenCounter  ;check for time to play second tone yet
        cmp #$30                ;timer tick sound also executes this, not sure why
        bne N2Tone
        lda #$54                ;if so, load the tone directly into the reg
        sta SND_SQUARE2_REG+2
N2Tone: bne DecrementSfx2Length

PlayBlast:
        lda #$20                ;load length of fireworks/gunfire sound
        sta Squ2_SfxLenCounter
        ldy #$94                ;load reg contents of fireworks/gunfire sound
        lda #$5e
        bne SBlasJ

ContinueBlast:
        lda Squ2_SfxLenCounter  ;check for time to play second part
        cmp #$18
        bne DecrementSfx2Length
        ldy #$93                ;load second part reg contents then
        lda #$18
SBlasJ: bne BlstSJp             ;unconditional branch to load rest of reg contents

PlayPowerUpGrab:
        lda #$36                    ;load length of power-up grab sound
        sta Squ2_SfxLenCounter

ContinuePowerUpGrab:   
        lda Squ2_SfxLenCounter      ;load frequency reg based on length left over
        lsr                         ;divide by 2
        bcs DecrementSfx2Length     ;alter frequency every other frame
        tay
        lda PowerUpGrabFreqData-1,y ;use length left over / 2 for frequency offset
        ldx #$5d                    ;store reg contents of power-up grab sound
        ldy #$7f

LoadSqu2Regs:
        jsr PlaySqu2Sfx

DecrementSfx2Length:
        dec Squ2_SfxLenCounter   ;decrement length of sfx
        bne ExSfx2

EmptySfx2Buffer:
        ldx #$00                ;initialize square 2's sound effects buffer
        stx Square2SoundBuffer

StopSquare2Sfx:
        ldx #$0d                ;stop playing the sfx
        stx SND_MASTERCTRL_REG 
        ldx #$0f
        stx SND_MASTERCTRL_REG
ExSfx2: rts

Square2SfxHandler:
        lda Square2SoundBuffer ;special handling for the 1-up sound to keep it
        and #Sfx_ExtraLife     ;from being interrupted by other sounds on square 2
        bne ContinueExtraLife
        ldy Square2SoundQueue  ;check for sfx in queue
        beq CheckSfx2Buffer
        sty Square2SoundBuffer ;if found, put in buffer and check for the following
        bmi PlayBowserFall     ;bowser fall
        lsr Square2SoundQueue
        bcs PlayCoinGrab       ;coin grab
        lsr Square2SoundQueue
        bcs PlayGrowPowerUp    ;power-up reveal
        lsr Square2SoundQueue
        bcs PlayGrowVine       ;vine grow
        lsr Square2SoundQueue
        bcs PlayBlast          ;fireworks/gunfire
        lsr Square2SoundQueue
        bcs PlayTimerTick      ;timer tick
        lsr Square2SoundQueue
        bcs PlayPowerUpGrab    ;power-up grab
        lsr Square2SoundQueue
        bcs PlayExtraLife      ;1-up

CheckSfx2Buffer:
        lda Square2SoundBuffer   ;check for sfx in buffer
        beq ExS2H                ;if not found, exit sub
        bmi ContinueBowserFall   ;bowser fall
        lsr
        bcs Cont_CGrab_TTick     ;coin grab
        lsr
        bcs ContinueGrowItems    ;power-up reveal
        lsr
        bcs ContinueGrowItems    ;vine grow
        lsr
        bcs ContinueBlast        ;fireworks/gunfire
        lsr
        bcs Cont_CGrab_TTick     ;timer tick
        lsr
        bcs ContinuePowerUpGrab  ;power-up grab
        lsr
        bcs ContinueExtraLife    ;1-up
ExS2H:  rts

Cont_CGrab_TTick:
        jmp ContinueCGrabTTick

JumpToDecLength2:
        jmp DecrementSfx2Length

PlayBowserFall:    
         lda #$38                ;load length of bowser defeat sound
         sta Squ2_SfxLenCounter
         ldy #$c4                ;load contents of reg for bowser defeat sound
         lda #$18
BlstSJp: bne PBFRegs

ContinueBowserFall:
          lda Squ2_SfxLenCounter   ;check for almost near the end
          cmp #$08
          bne DecrementSfx2Length
          ldy #$a4                 ;if so, load the rest of reg contents for bowser defeat sound
          lda #$5a
PBFRegs:  ldx #$9f                 ;the fireworks/gunfire sound shares part of reg contents here
EL_LRegs: bne LoadSqu2Regs         ;this is an unconditional branch outta here

PlayExtraLife:
        lda #$30                  ;load length of 1-up sound
        sta Squ2_SfxLenCounter

ContinueExtraLife:
          lda Squ2_SfxLenCounter   
          ldx #$03                  ;load new tones only every eight frames
DivLLoop: lsr
          bcs JumpToDecLength2      ;if any bits set here, branch to dec the length
          dex
          bne DivLLoop              ;do this until all bits checked, if none set, continue
          tay
          lda ExtraLifeFreqData-1,y ;load our reg contents
          ldx #$82
          ldy #$7f
          bne EL_LRegs              ;unconditional branch

PlayGrowPowerUp:
        lda #$10                ;load length of power-up reveal sound
        bne GrowItemRegs

PlayGrowVine:
        lda #$20                ;load length of vine grow sound

GrowItemRegs:
        sta Squ2_SfxLenCounter   
        lda #$7f                  ;load contents of reg for both sounds directly
        sta SND_SQUARE2_REG+1
        lda #$00                  ;start secondary counter for both sounds
        sta Sfx_SecondaryCounter

ContinueGrowItems:
        inc Sfx_SecondaryCounter  ;increment secondary counter for both sounds
        lda Sfx_SecondaryCounter  ;this sound doesn't decrement the usual counter
        lsr                       ;divide by 2 to get the offset
        tay
        cpy Squ2_SfxLenCounter    ;have we reached the end yet?
        beq StopGrowItems         ;if so, branch to jump, and stop playing sounds
        lda #$9d                  ;load contents of other reg directly
        sta SND_SQUARE2_REG
        lda PUp_VGrow_FreqData,y  ;use secondary counter / 2 as offset for frequency regs
        jsr SetFreq_Squ2
        rts

StopGrowItems:
        jmp EmptySfx2Buffer       ;branch to stop playing sounds

WindFreqEnvData:
        .byte $37, $46, $55, $64, $74, $83, $93, $a2
        .byte $b1, $c0, $d0, $e0, $f1, $f1, $f2, $e2
        .byte $e2, $c3, $a3, $84, $64, $44, $35, $25

BrickShatterFreqData:
        .byte $01, $0e, $0e, $0d, $0b, $06, $0c, $0f
        .byte $0a, $09, $03, $0d, $08, $0d, $06, $0c

SkidSfxFreqData:
        .byte $47, $49, $42, $4a, $43, $4b

PlaySkidSfx:
        sty NoiseSoundBuffer
        lda #$06
        sta Noise_SfxLenCounter

ContinueSkidSfx:
        lda Noise_SfxLenCounter
        tay
        lda SkidSfxFreqData-1,y
        sta SND_TRIANGLE_REG+2
        lda #$18
        sta SND_TRIANGLE_REG
        sta SND_TRIANGLE_REG+3
        bne DecrementSfx3Length

PlayBrickShatter:
        sty NoiseSoundBuffer
        lda #$20                 ;load length of brick shatter sound
        sta Noise_SfxLenCounter

ContinueBrickShatter:
        lda Noise_SfxLenCounter  
        lsr                         ;divide by 2 and check for bit set to use offset
        bcc DecrementSfx3Length
        tay
        ldx BrickShatterFreqData,y  ;load reg contents of brick shatter sound
        lda BrickShatterEnvData,y

PlayNoiseSfx:
        sta SND_NOISE_REG        ;play the sfx
        stx SND_NOISE_REG+2
        lda #$18
        sta SND_NOISE_REG+3

DecrementSfx3Length:
        dec Noise_SfxLenCounter  ;decrement length of sfx
        bne ExSfx3
        lda #$f0                 ;if done, stop playing the sfx
        sta SND_NOISE_REG
        lda #$00
        sta SND_TRIANGLE_REG
        lda #$00
        sta NoiseSoundBuffer
ExSfx3: rts

NoiseSfxHandler:
        lda NoiseSoundBuffer
        bmi ContinueSkidSfx
        ldy NoiseSoundQueue
        bmi PlaySkidSfx
        lsr NoiseSoundQueue
        bcs PlayBrickShatter
        lsr
        bcs ContinueBrickShatter
        lsr NoiseSoundQueue
        bcs PlayBowserFlame
        lsr
        bcs ContinueBowserFlame
        lsr
        bcs ContinueWindSfx
        lsr NoiseSoundQueue
        bcs PlayWindSfx
        rts

PlayBowserFlame:
        sty NoiseSoundBuffer
        lda #$40                    ;load length of bowser flame sound
        sta Noise_SfxLenCounter

ContinueBowserFlame:
        lda Noise_SfxLenCounter
        lsr
        tay
        ldx #$0f                    ;load reg contents of bowser flame sound
        lda BowserFlameEnvData-1,y
WindBranch:
        bne PlayNoiseSfx            ;unconditional branch here

PlayWindSfx:
        sty NoiseSoundBuffer
        lda #$c0
        sta Noise_SfxLenCounter
ContinueWindSfx:
        lsr NoiseSoundQueue         ;get bit for the wind sfx, note that it must
        bcc ExSfx3                  ;be continuously set in order for it to play
        lda Noise_SfxLenCounter
        lsr
        lsr                         ;divide length counter by 8
        lsr
        tay
        lda WindFreqEnvData,y
        and #$0f                    ;use lower nybble as frequency data
        ora #$10
        tax
        lda WindFreqEnvData,y       ;use upper nybble as envelope data
        lsr
        lsr
        lsr
        lsr
        ora #$10
        bne WindBranch              ;unconditional branch

;--------------------------------

ContinueMusic:
        jmp HandleSquare2Music  ;if we have music, start with square 2 channel

MusicHandler:
        lda EventMusicQueue     ;check event music queue
        bne LoadEventMusic
        lda AreaMusicQueue      ;check area music queue
        bne LoadAreaMusic
        lda EventMusicBuffer    ;check both buffers
        ora AreaMusicBuffer
        bne ContinueMusic 
        rts                     ;no music, then leave

LoadEventMusic:
           sta EventMusicBuffer      ;copy event music queue contents to buffer
           cmp #DeathMusic           ;is it death music?
           bne NoStopSfx             ;if not, jump elsewhere
           jsr StopSquare1Sfx        ;stop sfx in square 1 and 2
           jsr StopSquare2Sfx        ;but clear only square 1's sfx buffer
NoStopSfx: ldx AreaMusicBuffer
           stx AreaMusicBuffer_Alt   ;save current area music buffer to be re-obtained later
           ldy #$00
           sty NoteLengthTblAdder    ;default value for additional length byte offset
           sty AreaMusicBuffer       ;clear area music buffer
           cmp #TimeRunningOutMusic  ;is it time running out music?
           bne FindEventMusicHeader
           ldx #$08                  ;load offset to be added to length byte of header
           stx NoteLengthTblAdder
           bne FindEventMusicHeader  ;unconditional branch

LoadAreaMusic:
         cmp #$04                  ;is it underground music?
         bne NoStop1               ;no, do not stop square 1 sfx
         jsr StopSquare1Sfx
NoStop1: ldy #$10                  ;start counter used only by ground level music
GMLoopB: sty GroundMusicHeaderOfs

HandleAreaMusicLoopB:
         ldy #$00                  ;clear event music buffer
         sty EventMusicBuffer
         sta AreaMusicBuffer       ;copy area music queue contents to buffer
         cmp #$01                  ;is it ground level music?
         bne FindAreaMusicHeader
         inc GroundMusicHeaderOfs  ;increment but only if playing ground level music
         ldy GroundMusicHeaderOfs  ;is it time to loopback ground level music?
         cpy #$32
         bne LoadHeader            ;branch ahead with alternate offset
         ldy #$11
         bne GMLoopB               ;unconditional branch

FindAreaMusicHeader:
        ldy #$08                   ;load Y for offset of area music
        sty MusicOffset_Square2    ;residual instruction here

FindEventMusicHeader:
        iny                       ;increment Y pointer based on previously loaded queue contents
        lsr                       ;bit shift and increment until we find a set bit for music
        bcc FindEventMusicHeader

LoadHeader:
        lda MusicHeaderOffsetData,y  ;load offset for header
        tay
        lda MusicHeaderData,y        ;now load the header
        sta NoteLenLookupTblOfs
        lda MusicHeaderData+1,y
        sta MusicDataLow
        lda MusicHeaderData+2,y
        sta MusicDataHigh
        lda MusicHeaderData+3,y
        sta MusicOffset_Triangle
        lda MusicHeaderData+4,y
        sta MusicOffset_Square1
        lda MusicHeaderData+5,y
        sta MusicOffset_Noise
        sta NoiseDataLoopbackOfs
        lda #$01                     ;initialize music note counters
        sta Squ2_NoteLenCounter
        sta Squ1_NoteLenCounter
        sta Tri_NoteLenCounter
        sta Noise_BeatLenCounter
        lda #$00                     ;initialize music data offset for square 2
        sta MusicOffset_Square2
        sta AltRegContentFlag        ;initialize alternate control reg data used by square 1
        lda #$0b                     ;disable triangle channel and reenable it
        sta SND_MASTERCTRL_REG
        lda #$0f
        sta SND_MASTERCTRL_REG

HandleSquare2Music:
        dec Squ2_NoteLenCounter  ;decrement square 2 note length
        bne MiscSqu2MusicTasks   ;is it time for more data?  if not, branch to end tasks
        ldy MusicOffset_Square2  ;increment square 2 music offset and fetch data
        inc MusicOffset_Square2
        lda (MusicData),y
        beq EndOfMusicData       ;if zero, the data is a null terminator
        bpl Squ2NoteHandler      ;if non-negative, data is a note
        bne Squ2LengthHandler    ;otherwise it is length data

EndOfMusicData:
        lda EventMusicBuffer     ;check secondary buffer for time running out music
        cmp #TimeRunningOutMusic
        bne NotTRO
        lda AreaMusicBuffer_Alt  ;load previously saved contents of primary buffer
        bne MusicLoopBack        ;and start playing the song again if there is one
NotTRO: and #VictoryMusic        ;check for victory music (the only secondary that loops)
        bne VictoryMLoopBack
        lda AreaMusicBuffer      ;check primary buffer for any music except pipe intro
        and #%01011111
        bne MusicLoopBack        ;if any area music except pipe intro, music loops
        lda #$00                 ;clear primary and secondary buffers and initialize
        sta AreaMusicBuffer      ;control regs of square and triangle channels
        sta EventMusicBuffer
        sta SND_TRIANGLE_REG
        lda #$90    
        sta SND_SQUARE1_REG
        sta SND_SQUARE2_REG
        rts

MusicLoopBack:
        jmp HandleAreaMusicLoopB

VictoryMLoopBack:
        jmp LoadEventMusic

Squ2LengthHandler:
        jsr ProcessLengthData    ;store length of note
        sta Squ2_NoteLenBuffer
        ldy MusicOffset_Square2  ;fetch another byte (MUST NOT BE LENGTH BYTE!)
        inc MusicOffset_Square2
        lda (MusicData),y

Squ2NoteHandler:
          ldx Square2SoundBuffer     ;is there a sound playing on this channel?
          bne SkipFqL1
          jsr SetFreq_Squ2           ;no, then play the note
          beq Rest                   ;check to see if note is rest
          jsr LoadControlRegs        ;if not, load control regs for square 2
Rest:     sta Squ2_EnvelopeDataCtrl  ;save contents of A
          jsr Dump_Sq2_Regs          ;dump X and Y into square 2 control regs
SkipFqL1: lda Squ2_NoteLenBuffer     ;save length in square 2 note counter
          sta Squ2_NoteLenCounter

MiscSqu2MusicTasks:
           lda Square2SoundBuffer     ;is there a sound playing on square 2?
           bne HandleSquare1Music
           lda EventMusicBuffer       ;check for death music or d4 set on secondary buffer
           and #%10010001             ;note that regs for death music or d4 are loaded by default
           bne HandleSquare1Music
           ldy Squ2_EnvelopeDataCtrl  ;check for contents saved from LoadControlRegs
           beq NoDecEnv1
           dec Squ2_EnvelopeDataCtrl  ;decrement unless already zero
NoDecEnv1: jsr LoadEnvelopeData       ;do a load of envelope data to replace default
           sta SND_SQUARE2_REG        ;based on offset set by first load unless playing
           ldx #$7f                   ;death music or d4 set on secondary buffer
           stx SND_SQUARE2_REG+1

HandleSquare1Music:
        ldy MusicOffset_Square1    ;is there a nonzero offset here?
        beq HandleTriangleMusic    ;if not, skip ahead to the triangle channel
        dec Squ1_NoteLenCounter    ;decrement square 1 note length
        bne MiscSqu1MusicTasks     ;is it time for more data?

FetchSqu1MusicData:
        ldy MusicOffset_Square1    ;increment square 1 music offset and fetch data
        inc MusicOffset_Square1
        lda (MusicData),y
        bne Squ1NoteHandler        ;if nonzero, then skip this part
        lda #$83
        sta SND_SQUARE1_REG        ;store some data into control regs for square 1
        lda #$94                   ;and fetch another byte of data, used to give
        sta SND_SQUARE1_REG+1      ;death music its unique sound
        sta AltRegContentFlag
        bne FetchSqu1MusicData     ;unconditional branch

Squ1NoteHandler:
           jsr AlternateLengthHandler
           sta Squ1_NoteLenCounter    ;save contents of A in square 1 note counter
           ldy Square1SoundBuffer     ;is there a sound playing on square 1?
           bne HandleTriangleMusic
           txa
           and #%00111110             ;change saved data to appropriate note format
           jsr SetFreq_Squ1           ;play the note
           beq SkipCtrlL
           jsr LoadControlRegs
SkipCtrlL: sta Squ1_EnvelopeDataCtrl  ;save envelope offset
           jsr Dump_Squ1_Regs

MiscSqu1MusicTasks:
              lda Square1SoundBuffer     ;is there a sound playing on square 1?
              bne HandleTriangleMusic
              lda EventMusicBuffer       ;check for death music or d4 set on secondary buffer
              and #%10010001
              bne DeathMAltReg
              ldy Squ1_EnvelopeDataCtrl  ;check saved envelope offset
              beq NoDecEnv2
              dec Squ1_EnvelopeDataCtrl  ;decrement unless already zero
NoDecEnv2:    jsr LoadEnvelopeData       ;do a load of envelope data
              sta SND_SQUARE1_REG        ;based on offset set by first load
DeathMAltReg: lda AltRegContentFlag      ;check for alternate control reg data
              bne DoAltLoad
              lda #$7f                   ;load this value if zero, the alternate value
DoAltLoad:    sta SND_SQUARE1_REG+1      ;if nonzero, and let's move on

HandleTriangleMusic:
        lda MusicOffset_Triangle
        dec Tri_NoteLenCounter    ;decrement triangle note length
        bne HandleNoiseMusic      ;is it time for more data?
        ldy MusicOffset_Triangle  ;increment triangle music offset and fetch data
        inc MusicOffset_Triangle
        lda (MusicData),y
        beq LoadTriCtrlReg        ;if zero, skip all this and move on to noise 
        bpl TriNoteHandler        ;if non-negative, data is note
        jsr ProcessLengthData     ;otherwise, it is length data
        sta Tri_NoteLenBuffer     ;save contents of A
        lda #$1f
        sta SND_TRIANGLE_REG      ;load some default data for triangle control reg
        ldy MusicOffset_Triangle  ;fetch another byte
        inc MusicOffset_Triangle
        lda (MusicData),y
        beq LoadTriCtrlReg        ;check once more for nonzero data

TriNoteHandler:
          jsr SetFreq_Tri
          ldx Tri_NoteLenBuffer   ;save length in triangle note counter
          stx Tri_NoteLenCounter
          lda EventMusicBuffer
          and #%01101110          ;check for death music or d4 set on secondary buffer
          bne NotDOrD4            ;if playing any other secondary, skip primary buffer check
          lda AreaMusicBuffer     ;check primary buffer for water or castle level music
          and #%00001010
          beq HandleNoiseMusic    ;if playing any other primary, or death or d4, go on to noise routine
NotDOrD4: txa                     ;if playing water or castle music or any secondary
          cmp #$12                ;besides death music or d4 set, check length of note
          bcs LongN
          lda EventMusicBuffer    ;check for win castle music again if not playing a long note
          and #EndOfCastleMusic
          beq MediN
          lda #$0f                ;load value $0f if playing the win castle music and playing a short
          bne LoadTriCtrlReg      ;note, load value $1f if playing water or castle level music or any
MediN:    lda #$1f                ;secondary besides death and d4 except win castle or win castle and playing
          bne LoadTriCtrlReg      ;a short note, and load value $ff if playing a long note on water, castle
LongN:    lda #$ff                ;or any secondary (including win castle) except death and d4

LoadTriCtrlReg:           
        sta SND_TRIANGLE_REG      ;save final contents of A into control reg for triangle

HandleNoiseMusic:
        lda AreaMusicBuffer       ;check if playing underground or castle music
        and #%11110011
        beq ExitMusicHandler      ;if so, skip the noise routine
        dec Noise_BeatLenCounter  ;decrement noise beat length
        bne ExitMusicHandler      ;is it time for more data?

FetchNoiseBeatData:
        ldy MusicOffset_Noise       ;increment noise beat offset and fetch data
        inc MusicOffset_Noise
        lda (MusicData),y           ;get noise beat data, if nonzero, branch to handle
        bne NoiseBeatHandler
        lda NoiseDataLoopbackOfs    ;if data is zero, reload original noise beat offset
        sta MusicOffset_Noise       ;and loopback next time around
        bne FetchNoiseBeatData      ;unconditional branch

NoiseBeatHandler:
        jsr AlternateLengthHandler
        sta Noise_BeatLenCounter    ;store length in noise beat counter
        txa
        and #%00111110              ;reload data and erase length bits
        beq SilentBeat              ;if no beat data, silence
        cmp #$30                    ;check the beat data and play the appropriate
        beq LongBeat                ;noise accordingly
        cmp #$20
        beq StrongBeat
        and #%00010000  
        beq SilentBeat
        lda #$1c        ;short beat data
        ldx #$03
        ldy #$18
        bne PlayBeat

StrongBeat:
        lda #$1c        ;strong beat data
        ldx #$0c
        ldy #$18
        bne PlayBeat

LongBeat:
        lda #$1c        ;long beat data
        ldx #$03
        ldy #$58
        bne PlayBeat

SilentBeat:
        lda #$10        ;silence

PlayBeat:
        sta SND_NOISE_REG    ;load beat data into noise regs
        stx SND_NOISE_REG+2
        sty SND_NOISE_REG+3

ExitMusicHandler:
        rts

AlternateLengthHandler:
        tax            ;save a copy of original byte into X
        ror            ;save LSB from original byte into carry
        txa            ;reload original byte and rotate three times
        rol            ;turning xx00000x into 00000xxx, with the
        rol            ;bit in carry as the MSB here
        rol

ProcessLengthData:
        and #%00000111              ;clear all but the three LSBs
        clc
        adc NoteLenLookupTblOfs     ;add offset loaded from first header byte
        adc NoteLengthTblAdder      ;add extra if time running out music
        tay
        lda MusicLengthLookupTbl,y  ;load length
        rts

LoadControlRegs:
           lda EventMusicBuffer  ;check secondary buffer for win castle music
           and #EndOfCastleMusic
           beq NotECstlM
           lda #$04              ;this value is only used for win castle music
           bne AllMus            ;unconditional branch
NotECstlM: lda AreaMusicBuffer
           and #%01111101        ;check primary buffer for water music
           beq WaterMus
           lda #$08              ;this is the default value for all other music
           bne AllMus
WaterMus:  lda #$28              ;this value is used for water music and all other event music
AllMus:    ldx #$82              ;load contents of other sound regs for square 2
           ldy #$7f
           rts

LoadEnvelopeData:
        lda EventMusicBuffer           ;check secondary buffer for win castle music
        and #EndOfCastleMusic
        beq LoadUsualEnvData
        lda EndOfCastleMusicEnvData,y  ;load data from offset for win castle music
        rts

LoadUsualEnvData:
        lda AreaMusicBuffer            ;check primary buffer for water music
        and #%01111101
        beq LoadWaterEventMusEnvData
        lda AreaMusicEnvData,y         ;load default data from offset for all other music
        rts

LoadWaterEventMusEnvData:
        lda WaterEventMusEnvData,y     ;load data from offset for water music and all other event music
        rts

MusicHeaderData:
  .byte DeathMusHdr-MHD
  .byte GameOverMusHdr-MHD
  .byte GameOverMusHdr-MHD
  .byte WinCastleMusHdr-MHD
  .byte GameOverMusHdr-MHD
  .byte EndOfLevelMusHdr-MHD
  .byte TimeRunningOutHdr-MHD
  .byte SilenceHdr-MHD

  .byte GroundLevelPart1Hdr-MHD   ;area music
  .byte WaterMusHdr-MHD
  .byte UndergroundMusHdr-MHD
  .byte CastleMusHdr-MHD
  .byte Star_CloudHdr-MHD
  .byte GroundLevelLeadInHdr-MHD
  .byte Star_CloudHdr-MHD
  .byte SilenceHdr-MHD

  .byte GroundLevelLeadInHdr-MHD  ;ground level music layout
  .byte GroundLevelPart1Hdr-MHD, GroundLevelPart1Hdr-MHD
  .byte GroundLevelPart2AHdr-MHD, GroundLevelPart2BHdr-MHD, GroundLevelPart2AHdr-MHD, GroundLevelPart2CHdr-MHD
  .byte GroundLevelPart2AHdr-MHD, GroundLevelPart2BHdr-MHD, GroundLevelPart2AHdr-MHD, GroundLevelPart2CHdr-MHD
  .byte GroundLevelPart3AHdr-MHD, GroundLevelPart3BHdr-MHD, GroundLevelPart3AHdr-MHD, GroundLevelLeadInHdr-MHD
  .byte GroundLevelPart1Hdr-MHD, GroundLevelPart1Hdr-MHD
  .byte GroundLevelPart4AHdr-MHD, GroundLevelPart4BHdr-MHD, GroundLevelPart4AHdr-MHD, GroundLevelPart4CHdr-MHD
  .byte GroundLevelPart4AHdr-MHD, GroundLevelPart4BHdr-MHD, GroundLevelPart4AHdr-MHD, GroundLevelPart4CHdr-MHD
  .byte GroundLevelPart3AHdr-MHD, GroundLevelPart3BHdr-MHD, GroundLevelPart3AHdr-MHD, GroundLevelLeadInHdr-MHD
  .byte GroundLevelPart4AHdr-MHD, GroundLevelPart4BHdr-MHD, GroundLevelPart4AHdr-MHD, GroundLevelPart4CHdr-MHD

;music headers
;header format is as follows: 
;1 byte - length byte offset
;2 bytes -  music data address
;1 byte - triangle data offset
;1 byte - square 1 data offset
;1 byte - noise data offset (not used by secondary music)
  
TimeRunningOutHdr:     .byte $08, <TimeRunOutMusData, >TimeRunOutMusData, $27, $18
Star_CloudHdr:         .byte $20, <Star_CloudMData, >Star_CloudMData, $2e, $1a, $40
EndOfLevelMusHdr:      .byte $20, <WinLevelMusData, >WinLevelMusData, $3d, $21
ResidualHeaderData:    .byte $20, $fb, $dc, $3f, $1d
UndergroundMusHdr:     .byte $18, <UndergroundMusData, >UndergroundMusData, $00, $00
SilenceHdr:            .byte $08, <SilenceData, >SilenceData, $00
CastleMusHdr:          .byte $00, <CastleMusData, >CastleMusData, $93, $62
GameOverMusHdr:        .byte $18, <GameOverMusData, >GameOverMusData, $1e, $14
WaterMusHdr:           .byte $08, <WaterMusData, >WaterMusData, $a0, $70, $68
WinCastleMusHdr:       .byte $08, <EndOfCastleMusData, >EndOfCastleMusData, $4c, $24
GroundLevelPart1Hdr:   .byte $18, <GroundM_P1Data, >GroundM_P1Data, $2d, $1c, $b8
GroundLevelPart2AHdr:  .byte $18, <GroundM_P2AData, >GroundM_P2AData, $20, $12, $70
GroundLevelPart2BHdr:  .byte $18, <GroundM_P2BData, >GroundM_P2BData, $1b, $10, $44
GroundLevelPart2CHdr:  .byte $18, <GroundM_P2CData, >GroundM_P2CData, $11, $0a, $1c
GroundLevelPart3AHdr:  .byte $18, <GroundM_P3AData, >GroundM_P3AData, $2d, $10, $58
GroundLevelPart3BHdr:  .byte $18, <GroundM_P3BData, >GroundM_P3BData, $14, $0d, $3f
GroundLevelLeadInHdr:  .byte $18, <GroundMLdInData, >GroundMLdInData, $15, $0d, $21
GroundLevelPart4AHdr:  .byte $18, <GroundM_P4AData, >GroundM_P4AData, $18, $10, $7a
GroundLevelPart4BHdr:  .byte $18, <GroundM_P4BData, >GroundM_P4BData, $19, $0f, $54
GroundLevelPart4CHdr:  .byte $18, <GroundM_P4CData, >GroundM_P4CData, $1e, $12, $2b
DeathMusHdr:           .byte $18, <DeathMusData, >DeathMusData, $1e, $0f, $2d

;--------------------------------

;MUSIC DATA
;square 2/triangle format
;d7 - length byte flag (0-note, 1-length)
;if d7 is set to 0 and d6-d0 is nonzero:
;d6-d0 - note offset in frequency look-up table (must be even)
;if d7 is set to 1:
;d6-d3 - unused
;d2-d0 - length offset in length look-up table
;value of $00 in square 2 data is used as null terminator, affects all sound channels
;value of $00 in triangle data causes routine to skip note

;square 1 format
;d7-d6, d0 - length offset in length look-up table (bit order is d0,d7,d6)
;d5-d1 - note offset in frequency look-up table
;value of $00 in square 1 data is flag alternate control reg data to be loaded

;noise format
;d7-d6, d0 - length offset in length look-up table (bit order is d0,d7,d6)
;d5-d4 - beat type (0 - rest, 1 - short, 2 - strong, 3 - long)
;d3-d1 - unused
;value of $00 in noise data is used as null terminator, affects only noise

;all music data is organized into sections (unless otherwise stated):
;square 2, square 1, triangle, noise

Star_CloudMData:
      .byte $84, $2c, $2c, $2c, $82, $04, $2c, $04, $85, $2c, $84, $2c, $2c
      .byte $2a, $2a, $2a, $82, $04, $2a, $04, $85, $2a, $84, $2a, $2a, $00

      .byte $1f, $1f, $1f, $98, $1f, $1f, $98, $9e, $98, $1f
      .byte $1d, $1d, $1d, $94, $1d, $1d, $94, $9c, $94, $1d

      .byte $86, $18, $85, $26, $30, $84, $04, $26, $30
      .byte $86, $14, $85, $22, $2c, $84, $04, $22, $2c

      .byte $21, $d0, $c4, $d0, $31, $d0, $c4, $d0, $00

GroundM_P1Data:
      .byte $85, $2c, $22, $1c, $84, $26, $2a, $82, $28, $26, $04
      .byte $87, $22, $34, $3a, $82, $40, $04, $36, $84, $3a, $34
      .byte $82, $2c, $30, $85, $2a

SilenceData:
      .byte $00

      .byte $5d, $55, $4d, $15, $19, $96, $15, $d5, $e3, $eb
      .byte $2d, $a6, $2b, $27, $9c, $9e, $59

      .byte $85, $22, $1c, $14, $84, $1e, $22, $82, $20, $1e, $04, $87
      .byte $1c, $2c, $34, $82, $36, $04, $30, $34, $04, $2c, $04, $26
      .byte $2a, $85, $22

GroundM_P2AData:
      .byte $84, $04, $82, $3a, $38, $36, $32, $04, $34
      .byte $04, $24, $26, $2c, $04, $26, $2c, $30, $00

      .byte $05, $b4, $b2, $b0, $2b, $ac, $84
      .byte $9c, $9e, $a2, $84, $94, $9c, $9e

      .byte $85, $14, $22, $84, $2c, $85, $1e
      .byte $82, $2c, $84, $2c, $1e

GroundM_P2BData:
      .byte $84, $04, $82, $3a, $38, $36, $32, $04, $34
      .byte $04, $64, $04, $64, $86, $64, $00

      .byte $05, $b4, $b2, $b0, $2b, $ac, $84
      .byte $37, $b6, $b6, $45

      .byte $85, $14, $1c, $82, $22, $84, $2c
      .byte $4e, $82, $4e, $84, $4e, $22

GroundM_P2CData:
      .byte $84, $04, $85, $32, $85, $30, $86, $2c, $04, $00

      .byte $05, $a4, $05, $9e, $05, $9d, $85
      
      .byte $84, $14, $85, $24, $28, $2c, $82
      .byte $22, $84, $22, $14

      .byte $21, $d0, $c4, $d0, $31, $d0, $c4, $d0, $00

GroundM_P3AData:
      .byte $82, $2c, $84, $2c, $2c, $82, $2c, $30
      .byte $04, $34, $2c, $04, $26, $86, $22, $00

      .byte $a4, $25, $25, $a4, $29, $a2, $1d, $9c, $95

GroundM_P3BData:
      .byte $82, $2c, $2c, $04, $2c, $04, $2c, $30, $85, $34, $04, $04, $00

      .byte $a4, $25, $25, $a4, $a8, $63, $04

;triangle data used by both sections of third part
      .byte $85, $0e, $1a, $84, $24, $85, $22, $14, $84, $0c

GroundMLdInData:
      .byte $82, $34, $84, $34, $34, $82, $2c, $84, $34, $86, $3a, $04, $00

      .byte $a0, $21, $21, $a0, $21, $2b, $05, $a3

      .byte $82, $18, $84, $18, $18, $82, $18, $18, $04, $86, $3a, $22

;noise data used by lead-in and third part sections
      .byte $31, $90, $31, $90, $31, $71, $31, $90, $90, $90, $00

GroundM_P4AData:
      .byte $82, $34, $84, $2c, $85, $22, $84, $24
      .byte $82, $26, $36, $04, $36, $86, $26, $00

      .byte $ac, $27, $5d, $1d, $9e, $2d, $ac, $9f

      .byte $85, $14, $82, $20, $84, $22, $2c
      .byte $1e, $1e, $82, $2c, $2c, $1e, $04

GroundM_P4BData:
      .byte $87, $2a, $40, $40, $40, $3a, $36 
      .byte $82, $34, $2c, $04, $26, $86, $22, $00

      .byte $e3, $f7, $f7, $f7, $f5, $f1, $ac, $27, $9e, $9d

      .byte $85, $18, $82, $1e, $84, $22, $2a
      .byte $22, $22, $82, $2c, $2c, $22, $04

DeathMusData:
      .byte $86, $04 ;death music share data with fourth part c of ground level music 

GroundM_P4CData:
      .byte $82, $2a, $36, $04, $36, $87, $36, $34, $30, $86, $2c, $04, $00
      
      .byte $00, $68, $6a, $6c, $45 ;death music only

      .byte $a2, $31, $b0, $f1, $ed, $eb, $a2, $1d, $9c, $95

      .byte $86, $04 ;death music only

      .byte $85, $22, $82, $22, $87, $22, $26, $2a, $84, $2c, $22, $86, $14

;noise data used by fourth part sections
      .byte $51, $90, $31, $11, $00

CastleMusData:
      .byte $80, $22, $28, $22, $26, $22, $24, $22, $26
      .byte $22, $28, $22, $2a, $22, $28, $22, $26
      .byte $22, $28, $22, $26, $22, $24, $22, $26
      .byte $22, $28, $22, $2a, $22, $28, $22, $26
      .byte $20, $26, $20, $24, $20, $26, $20, $28
      .byte $20, $26, $20, $28, $20, $26, $20, $24
      .byte $20, $26, $20, $24, $20, $26, $20, $28
      .byte $20, $26, $20, $28, $20, $26, $20, $24
      .byte $28, $30, $28, $32, $28, $30, $28, $2e
      .byte $28, $30, $28, $2e, $28, $2c, $28, $2e
      .byte $28, $30, $28, $32, $28, $30, $28, $2e
      .byte $28, $30, $28, $2e, $28, $2c, $28, $2e, $00

      .byte $04, $70, $6e, $6c, $6e, $70, $72, $70, $6e
      .byte $70, $6e, $6c, $6e, $70, $72, $70, $6e
      .byte $6e, $6c, $6e, $70, $6e, $70, $6e, $6c
      .byte $6e, $6c, $6e, $70, $6e, $70, $6e, $6c
      .byte $76, $78, $76, $74, $76, $74, $72, $74
      .byte $76, $78, $76, $74, $76, $74, $72, $74

      .byte $84, $1a, $83, $18, $20, $84, $1e, $83, $1c, $28
      .byte $26, $1c, $1a, $1c

GameOverMusData:
      .byte $82, $2c, $04, $04, $22, $04, $04, $84, $1c, $87
      .byte $26, $2a, $26, $84, $24, $28, $24, $80, $22, $00

      .byte $9c, $05, $94, $05, $0d, $9f, $1e, $9c, $98, $9d

      .byte $82, $22, $04, $04, $1c, $04, $04, $84, $14
      .byte $86, $1e, $80, $16, $80, $14

TimeRunOutMusData:
      .byte $81, $1c, $30, $04, $30, $30, $04, $1e, $32, $04, $32, $32
      .byte $04, $20, $34, $04, $34, $34, $04, $36, $04, $84, $36, $00

      .byte $46, $a4, $64, $a4, $48, $a6, $66, $a6, $4a, $a8, $68, $a8
      .byte $6a, $44, $2b

      .byte $81, $2a, $42, $04, $42, $42, $04, $2c, $64, $04, $64, $64
      .byte $04, $2e, $46, $04, $46, $46, $04, $22, $04, $84, $22

WinLevelMusData:
      .byte $87, $04, $06, $0c, $14, $1c, $22, $86, $2c, $22
      .byte $87, $04, $60, $0e, $14, $1a, $24, $86, $2c, $24
      .byte $87, $04, $08, $10, $18, $1e, $28, $86, $30, $30
      .byte $80, $64, $00

      .byte $cd, $d5, $dd, $e3, $ed, $f5, $bb, $b5, $cf, $d5
      .byte $db, $e5, $ed, $f3, $bd, $b3, $d1, $d9, $df, $e9
      .byte $f1, $f7, $bf, $ff, $ff, $ff, $34
      .byte $00 ;unused byte

      .byte $86, $04, $87, $14, $1c, $22, $86, $34, $84, $2c
      .byte $04, $04, $04, $87, $14, $1a, $24, $86, $32, $84
      .byte $2c, $04, $86, $04, $87, $18, $1e, $28, $86, $36
      .byte $87, $30, $30, $30, $80, $2c

;square 2 and triangle use the same data, square 1 is unused
UndergroundMusData:
      .byte $82, $14, $2c, $62, $26, $10, $28, $80, $04
      .byte $82, $14, $2c, $62, $26, $10, $28, $80, $04
      .byte $82, $08, $1e, $5e, $18, $60, $1a, $80, $04
      .byte $82, $08, $1e, $5e, $18, $60, $1a, $86, $04
      .byte $83, $1a, $18, $16, $84, $14, $1a, $18, $0e, $0c
      .byte $16, $83, $14, $20, $1e, $1c, $28, $26, $87
      .byte $24, $1a, $12, $10, $62, $0e, $80, $04, $04
      .byte $00

;noise data directly follows square 2 here unlike in other songs
WaterMusData:
      .byte $82, $18, $1c, $20, $22, $26, $28 
      .byte $81, $2a, $2a, $2a, $04, $2a, $04, $83, $2a, $82, $22
      .byte $86, $34, $32, $34, $81, $04, $22, $26, $2a, $2c, $30
      .byte $86, $34, $83, $32, $82, $36, $84, $34, $85, $04, $81, $22
      .byte $86, $30, $2e, $30, $81, $04, $22, $26, $2a, $2c, $2e
      .byte $86, $30, $83, $22, $82, $36, $84, $34, $85, $04, $81, $22
      .byte $86, $3a, $3a, $3a, $82, $3a, $81, $40, $82, $04, $81, $3a
      .byte $86, $36, $36, $36, $82, $36, $81, $3a, $82, $04, $81, $36
      .byte $86, $34, $82, $26, $2a, $36
      .byte $81, $34, $34, $85, $34, $81, $2a, $86, $2c, $00

      .byte $84, $90, $b0, $84, $50, $50, $b0, $00

      .byte $98, $96, $94, $92, $94, $96, $58, $58, $58, $44
      .byte $5c, $44, $9f, $a3, $a1, $a3, $85, $a3, $e0, $a6
      .byte $23, $c4, $9f, $9d, $9f, $85, $9f, $d2, $a6, $23
      .byte $c4, $b5, $b1, $af, $85, $b1, $af, $ad, $85, $95
      .byte $9e, $a2, $aa, $6a, $6a, $6b, $5e, $9d

      .byte $84, $04, $04, $82, $22, $86, $22
      .byte $82, $14, $22, $2c, $12, $22, $2a, $14, $22, $2c
      .byte $1c, $22, $2c, $14, $22, $2c, $12, $22, $2a, $14
      .byte $22, $2c, $1c, $22, $2c, $18, $22, $2a, $16, $20
      .byte $28, $18, $22, $2a, $12, $22, $2a, $18, $22, $2a
      .byte $12, $22, $2a, $14, $22, $2c, $0c, $22, $2c, $14, $22, $34, $12
      .byte $22, $30, $10, $22, $2e, $16, $22, $34, $18, $26
      .byte $36, $16, $26, $36, $14, $26, $36, $12, $22, $36
      .byte $5c, $22, $34, $0c, $22, $22, $81, $1e, $1e, $85, $1e
      .byte $81, $12, $86, $14

EndOfCastleMusData:
      .byte $81, $2c, $22, $1c, $2c, $22, $1c, $85, $2c, $04
      .byte $81, $2e, $24, $1e, $2e, $24, $1e, $85, $2e, $04
      .byte $81, $32, $28, $22, $32, $28, $22, $85, $32
      .byte $87, $36, $36, $36, $84, $3a, $00

      .byte $5c, $54, $4c, $5c, $54, $4c
      .byte $5c, $1c, $1c, $5c, $5c, $5c, $5c
      .byte $5e, $56, $4e, $5e, $56, $4e
      .byte $5e, $1e, $1e, $5e, $5e, $5e, $5e
      .byte $62, $5a, $50, $62, $5a, $50
      .byte $62, $22, $22, $62, $e7, $e7, $e7, $2b

      .byte $86, $14, $81, $14, $80, $14, $14, $81, $14, $14, $14, $14
      .byte $86, $16, $81, $16, $80, $16, $16, $81, $16, $16, $16, $16
      .byte $81, $28, $22, $1a, $28, $22, $1a, $28, $80, $28, $28
      .byte $81, $28, $87, $2c, $2c, $2c, $84, $30

;unused byte
      .byte $ff

FreqRegLookupTbl:
      .byte $00, $88, $00, $2f, $00, $00
      .byte $02, $a6, $02, $80, $02, $5c, $02, $3a
      .byte $02, $1a, $01, $df, $01, $c4, $01, $ab
      .byte $01, $93, $01, $7c, $01, $67, $01, $53
      .byte $01, $40, $01, $2e, $01, $1d, $01, $0d
      .byte $00, $fe, $00, $ef, $00, $e2, $00, $d5
      .byte $00, $c9, $00, $be, $00, $b3, $00, $a9
      .byte $00, $a0, $00, $97, $00, $8e, $00, $86
      .byte $00, $77, $00, $7e, $00, $71, $00, $54
      .byte $00, $64, $00, $5f, $00, $59, $00, $50
      .byte $00, $47, $00, $43, $00, $3b, $00, $35
      .byte $00, $2a, $00, $23, $04, $75, $03, $57
      .byte $02, $f9, $02, $cf, $01, $fc, $00, $6a

MusicLengthLookupTbl:
      .byte $05, $0a, $14, $28, $50, $1e, $3c, $02
      .byte $04, $08, $10, $20, $40, $18, $30, $0c
      .byte $03, $06, $0c, $18, $30, $12, $24, $08
      .byte $36, $03, $09, $06, $12, $1b, $24, $0c
      .byte $24, $02, $06, $04, $0c, $12, $18, $08
      .byte $12, $01, $03, $02, $06, $09, $0c, $04

EndOfCastleMusicEnvData:
      .byte $98, $99, $9a, $9b

AreaMusicEnvData:
      .byte $90, $94, $94, $95, $95, $96, $97, $98

WaterEventMusEnvData:
      .byte $90, $91, $92, $92, $93, $93, $93, $94
      .byte $94, $94, $94, $94, $94, $95, $95, $95
      .byte $95, $95, $95, $96, $96, $96, $96, $96
      .byte $96, $96, $96, $96, $96, $96, $96, $96
      .byte $96, $96, $96, $96, $95, $95, $94, $93

BowserFlameEnvData:
      .byte $15, $16, $16, $17, $17, $18, $19, $19
      .byte $1a, $1a, $1c, $1d, $1d, $1e, $1e, $1f
      .byte $1f, $1f, $1f, $1e, $1d, $1c, $1e, $1f
      .byte $1f, $1e, $1d, $1c, $1a, $18, $16, $14

BrickShatterEnvData:
      .byte $15, $16, $16, $17, $17, $18, $19, $19
      .byte $1a, $1a, $1c, $1d, $1d, $1e, $1e, $1f

        .word NMIHandler
        .word Start
        .word IRQHandler
SM2MAIN2END:

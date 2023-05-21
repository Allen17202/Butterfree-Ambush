*-----------------------------------------------------------
* Title      : Butterfree Ambush
* Written by : Gregory Allen
* Date       : 10/20/2022
* Description: This game is a spinoff of flappy bird inspired game which instead
*              has butterfree attempting to escape from flying type pokemon
*              Use the spacebar to escape incoming pokemon
*-----------------------------------------------------------
;-----------------------------------------------------------
; Trap Codes
*-----------------------------------------------------------
TIMER_TRAP                      EQU 8
CLEAR_SCREEN_TRAP               EQU 11
TURNON_DOUBLEBUFFER_TRAP        EQU 17
KEY_INPUT_TRAP                  EQU 19
SCREEN_SIZE_TRAP                EQU 33

PEN_COLOR_TRAP                  EQU 80
FILL_COLOR_TRAP                 EQU 81
DRAW_PIXEL_TRAP                 EQU 82
DRAW_FILLED_RECTANGLE           EQU 87
DRAW_LINE_TRAP_CODE             EQU 85
MOVE_GRAPHICS_XY_TRAP           EQU 86
FILL_COLOR_TRAP                 EQU 81

DRAW_MODE_TRAP                  EQU 92
PEN_WIDTH_TRAP                  EQU 93
DISPLAY_BUFFER_TRAP             EQU 94
SCREEN_TEXT_TRAP                EQU 95

;-----------------------------------------------------------
; Constant Variables
*-----------------------------------------------------------
SCREEN_WIDTH                    EQU 960
SCREEN_HEIGHT                   EQU 600
ENDGAME_WIDTH                   EQU 806
ENDGAME_HEIGHT                  EQU 112

FRAC_BITS                       EQU 8
CLEAR_WHOLE_SCREEN              EQU $FF00
LOAD_MSG_WIDTH                  EQU 60
SIZE_DISPLAY_PARAMETERS_DATA    EQU 24
SPACEBAR_KEY                    EQU $20
FILE_OFFSET_TO_PIXELARRAY       EQU 10

BUTTERFREE_WIDTH                EQU 56
BUTTERFREE_HEIGHT               EQU 56
BUTTERFREE_TOP_LEFT_X           EQU 0
BUTTERFREE_TOP_LEFT_Y           EQU 0
INITIAL_BUTTERFREE_TOP_LEFT_X   EQU 100
INITIAL_BUTTERFREE_TOP_LEFT_Y   EQU 300
BUTTERFREE_VELOCITY             EQU 13000
BUTTERFREE_MAX_TOP              EQU $05000
BUTTERFREE_MAX_BOTTOM           EQU $22000

BIRD_WIDTH                      EQU 72 
BIRD_HEIGHT                     EQU 70
BIRD_VELOCITY                   EQU 20000
NUMBER_OF_BIRD_SPAWNS           EQU 7
BIRD_TOP_SPAWN_POS_Y            EQU 100<<FRAC_BITS        ;100 (left shifted by FRAC_BITS)100 - 170 - 240 
BIRD_BMIDDLETOP_SPAWN_POS_Y     EQU 170<<FRAC_BITS        ;300 (left shifted by FRAC_BITS)
BIRD_BMIDDLETOP2_SPAWN_POS_Y    EQU 240<<FRAC_BITS        ;300 (left shifted by FRAC_BITS)
BIRD_MIDDLE_SPAWN_POS_Y         EQU 310<<FRAC_BITS        ;500 (left shifted by FRAC_BITS)
BIRD_BMIDDLEBOTTOM_SPAWN_POS_Y  EQU 380<<FRAC_BITS        ;300 (left shifted by FRAC_BITS)
BIRD_BMIDDLEBOTTOM2_SPAWN_POS_Y EQU 450<<FRAC_BITS        ;500 (left shifted by FRAC_BITS)
BIRD_BOTTOM_SPAWN_POS_Y         EQU 520<<FRAC_BITS        ;500 (left shifted by FRAC_BITS)


BIRD_COMMON_SPAWN_POS_X         EQU 900<<FRAC_BITS        ;900 (left shifted by FRAC_BITS)
BIRD_MAX_LEFT                   EQU $0
BIRD_X                          EQU 0
BIRD_Y                          EQU 0

SCORE_X                         EQU 435
SCORE_Y                         EQU 35
GRAVITY                         EQU 6000

LED_OFFSET                      EQU 2
LED_SIZE                        EQU 20
SEGMENT7                        EQU 7
DIGIT_PEN_WIDTH                 EQU 3
DEFAULT_PEN_WIDTH               EQU 1
DIGIT_WIDTH                     EQU LED_SIZE+LED_OFFSET+4
NUMBER_OF_DIGITS                EQU 3
WHITE_COLOR                     EQU $00FFFFFF
BACKGROUND_COLOR                EQU $00FAC979   
TRANSPARENT_REPLACEMENT_COLOR   EQU $00B7AAB4             ;Purple  
 
;-----------------------------------------------------------
; Registers
*-----------------------------------------------------------
ALL_REGISTERS                   REG d0-d7/a0-a6
REG_DRAW_BITMAP                 REG d0-d7/a0-a4
REGISTERS_COLLISION             REG d3-d6
REG_7SEGMENT_LED                REG d3-d7/a6

   ORG    $1000
START:                  
    jsr InitialGame
    jsr LoadSpawn
    move.l d3,Bird_1_X
    move.l d4,Bird_1_Y
    
One jsr LoadSpawn
    cmp.l Bird_1_Y,d4
    beq  One
    add.l #(72<<FRAC_BITS),d3
    move.l d3,Bird_2_X
    move.l d4,Bird_2_Y
    
Two jsr LoadSpawn
    cmp.l Bird_1_Y,d4
    beq  Two
    cmp.l Bird_2_Y,d4
    beq  Two
    add.l #(144<<FRAC_BITS),d3
    move.l d3,Bird_3_X
    move.l d4,Bird_3_Y

GAMELOOP:
    jsr HandlePlayerInput
   
   
    move.l Bird_1_X,d3
    move.l Bird_1_Y,d4
    jsr HandleBird
    move.l d3,Bird_1_X
    move.l d4,Bird_1_Y
    jsr DetectCollision
    
    
    move.l Bird_2_X,d3
    move.l Bird_2_Y,d4
    jsr HandleBird
    cmp.l Bird_1_X,d3
    bne skip1
    add.l #(72<<FRAC_BITS),d3
skip1    
    move.l d3,Bird_2_X
    move.l d4,Bird_2_Y
    jsr DetectCollision
    
    move.l Bird_3_X,d3
    move.l Bird_3_Y,d4
    jsr HandleBird
    cmp.l Bird_1_X,d3
    bne skip2
    cmp.l Bird_2_X,d3
    bne skip2
    add.l #(144<<FRAC_BITS),d3
skip2 
    move.l d3,Bird_3_X
    move.l d4,Bird_3_Y
    jsr DetectCollision
    
    
    bra GAMELOOP
GAMEOVER:
    jsr CoverButterfreeImage
    jsr CoverBirdImage
    jsr EndGame
    jsr DisplayBuffer
    SIMHALT          

EndGame:
    *Draw GameOver Image
    move.b  #CLEAR_SCREEN_TRAP,d0
    move.l  #CLEAR_WHOLE_SCREEN,d1
    trap    #15 
    
    lea LoadMsg, a1
    move.l #(SCREEN_WIDTH/2)-LOAD_MSG_WIDTH,d1
    move.l #(SCREEN_HEIGHT/2)-LOAD_MSG_WIDTH,d2
    move.l #SCREEN_TEXT_TRAP,d0
    trap   #15    
    jsr    DisplayBuffer

      
    movem.l REG_DRAW_BITMAP,-(sp)         
        
    lea     EndGameData,a5                  
    lea     EndGameImage,a0
              
    *Pass the arguements using stack
    move.l  #SCREEN_HEIGHT,-(sp)
    move.l  #SCREEN_WIDTH,-(sp)        
    move.l  #0,-(sp)                                       
    move.l  #0,-(sp)                                       
    move.l  #0,-(sp)                                    
    move.l  #0,-(sp)                                                     
    jsr     DisplayImage
    
    ;Draw Score
    add.l   #SIZE_DISPLAY_PARAMETERS_DATA,sp                 
    movem.l (sp)+,REG_DRAW_BITMAP             
    
    movem.l REG_7SEGMENT_LED,-(sp)             
    move.l  Score,d6                          
    
    move.l  #SCORE_X,Number_Position_X
    move.l  #SCORE_Y,Number_Position_Y
    jsr     Display7Segment      
    movem.l (sp)+,REG_7SEGMENT_LED            
    jsr    DisplayBuffer

    *--------------------------------------------------------------------------------------------------------------------------
    rts
   
    
DetectCollision:
        *d5 -> Butterfree's X
        *d6 -> Butterfree's Y
        *d3 -> Bird's X
        *d4 -> Bird's Y
        ;rect1 - Butterfree
        ;rect2 - Bird
        *if (rect1.x < rect2.x + rect2.width && rect1.x + rect1.width > rect2.x && rect1.y < rect2.y + rect2.height &&  rect1.y + rect1.height > rect2.y)
        *{
        *     Collision detected
        *} 
        *else
        *{
        *     Collision Not detected
        *}       

        movem.l REGISTERS_COLLISION,-(sp)           
                    
        ;Shift out all the registers from 2e-8 land            
        lsr.l   #FRAC_BITS,d5                          
        lsr.l   #FRAC_BITS,d6
        lsr.l   #FRAC_BITS,d3
        lsr.l   #FRAC_BITS,d4                 
    
        move.w  d3,d0                                   *if (rect1.x < rect2.x + rect2.width &&
        addi.w  #BIRD_WIDTH,d0                          
        cmp.w   d5,d0                                   
        blt     NOCOLLISION                             
        
        move.w  d5,d0                                   *rect1.x + rect1.width > rect2.x &&
        addi.w  #BUTTERFREE_WIDTH,d0                    
        cmp.w   d0,d3                                   
        bgt     NOCOLLISION                             
        
        move.w  d4,d0                                   *rect1.y < rect2.y + rect2.height &&
        addi.w  #BIRD_HEIGHT,d0                         
        cmp.w   d6,d0                                   
        blt     NOCOLLISION
        
        move.w  d6,d0                                   *rect1.y + rect1.height > rect2.y)
        addi.w  #BUTTERFREE_HEIGHT,d0                   
        cmp.w   d0,d4                                  
        bgt     NOCOLLISION
        
        movem.l (sp)+,REGISTERS_COLLISION               
        
        bra GAMEOVER
        rts

NOCOLLISION:
        movem.l (sp)+,REGISTERS_COLLISION                  
        rts

; Subroutine to spawn birds at spawn points
LoadSpawn
        jsr     GetRandomByteIntoD0
        move.l  #NUMBER_OF_BIRD_SPAWNS,d1
        and.b   d0,d1                                   
        
        cmpi.b  #0,d1                                 
        bne     CHECKFOR1        
        move.l  #BIRD_TOP_SPAWN_POS_Y,d4              
        bra.w   LOADSPAWNPOS_X                                                 
CHECKFOR1:
        cmpi.b  #1,d1                                   
        bne     CHECKFOR2                               
        move.l  #BIRD_BMIDDLETOP_SPAWN_POS_Y,d4             
        bra.w   LOADSPAWNPOS_X   
CHECKFOR2:
        cmpi.b  #2,d1                                   
        bne     CHECKFOR3                               
        move.l  #BIRD_BMIDDLETOP2_SPAWN_POS_Y,d4             
        bra.w   LOADSPAWNPOS_X   
CHECKFOR3:
        cmpi.b  #3,d1                                   
        bne     CHECKFOR4                               
        move.l  #BIRD_MIDDLE_SPAWN_POS_Y,d4             
        bra.w   LOADSPAWNPOS_X   
CHECKFOR4:
        cmpi.b  #4,d1                                   
        bne     CHECKFOR5                               
        move.l  #BIRD_BMIDDLEBOTTOM_SPAWN_POS_Y,d4             
        bra.w   LOADSPAWNPOS_X   
CHECKFOR5:
        cmpi.b  #5,d1                                   
        bne     CHECKFOR6                              
        move.l  #BIRD_BMIDDLEBOTTOM2_SPAWN_POS_Y,d4             
        bra.w   LOADSPAWNPOS_X                           
CHECKFOR6:
        move.l  #BIRD_BOTTOM_SPAWN_POS_Y,d4                                                                 
LOADSPAWNPOS_X:
        move.l  #BIRD_COMMON_SPAWN_POS_X,d3                                  
        rts   

DrawButterfree:
    move.l  d5,d1                                         
    move.l  d6,d2                                   
        
    lsr.l   #FRAC_BITS,d1                           
    lsr.l   #FRAC_BITS,d2                         
  
    movem.l REG_DRAW_BITMAP,-(sp)
  
    lea ButterfreeImageData,a5
    lea ButterfreeImage,a0
    move.l #BUTTERFREE_HEIGHT,-(sp)
    move.l #BUTTERFREE_WIDTH,-(sp)
    move.l #BUTTERFREE_TOP_LEFT_X,-(sp)
    move.l #BUTTERFREE_TOP_LEFT_Y,-(sp)
    move.l d1,-(sp)
    move.l d2,-(sp)
    jsr DisplayImage
    add.l #SIZE_DISPLAY_PARAMETERS_DATA,sp
    movem.l (sp)+,REG_DRAW_BITMAP
    jsr DisplayBuffer
    rts   
 
DrawBird:
    move.l  d3,d1                                          
    move.l  d4,d2                                 
        
    lsr.l   #FRAC_BITS,d1                          
    lsr.l   #FRAC_BITS,d2                          
    
    movem.l REG_DRAW_BITMAP,-(sp)
  
    lea BirdImageData,a5
    lea BirdImage,a0
    move.l #BIRD_HEIGHT,-(sp)
    move.l #BIRD_WIDTH,-(sp)
    move.l BIRD_X,-(sp)
    move.l BIRD_Y,-(sp)
    move.l d1,-(sp)
    move.l d2,-(sp)
    jsr DisplayImage
    add.l #SIZE_DISPLAY_PARAMETERS_DATA,sp
    movem.l (sp)+,REG_DRAW_BITMAP
    jsr DisplayBuffer
    rts 
    
CoverBirdImage:
    move.l d3,d1
    move.l d4,d2
    
    lsr.l #FRAC_BITS,d1
    lsr.l #FRAC_BITS,d2
    movem.l REG_DRAW_BITMAP,-(sp)
    
    lea BackgroundImageData,a5
    lea BackgroundImage,a0 
    move.l #BIRD_HEIGHT,-(sp)
    move.l #BIRD_WIDTH,-(sp)
    move.l d1,-(sp)
    move.l d2,-(sp)
    move.l d1,-(sp)
    move.l d2,-(sp)
    jsr DisplayImage
    add.l #SIZE_DISPLAY_PARAMETERS_DATA,sp
    movem.l (sp)+,REG_DRAW_BITMAP
    rts  
  
CoverButterfreeImage:
    move.l d5,d1
    move.l d6,d2
    
    lsr.l #FRAC_BITS,d1
    lsr.l #FRAC_BITS,d2
    movem.l REG_DRAW_BITMAP,-(sp)
    
    lea BackgroundImageData,a5
    lea BackgroundImage,a0 
    move.l #BUTTERFREE_HEIGHT,-(sp)
    move.l #BUTTERFREE_WIDTH,-(sp)
    move.l d1,-(sp)
    move.l d2,-(sp)
    move.l d1,-(sp)
    move.l d2,-(sp)
    jsr DisplayImage
    add.l #SIZE_DISPLAY_PARAMETERS_DATA,sp
    movem.l (sp)+,REG_DRAW_BITMAP
    rts   

DisplayBuffer:
    move.l  #DISPLAY_BUFFER_TRAP,d0
    trap    #15
    rts
    
AddScore:   
    movem.l REG_7SEGMENT_LED,-(sp)              
    lea Score,a6
    addi.l   #1,(a6)
    move.l  Score,d6                             
    
    move.l  #SCORE_X,Number_Position_X
    move.l  #SCORE_Y,Number_Position_Y
    jsr     Display7Segment      
    movem.l (sp)+,REG_7SEGMENT_LED            
    jsr    DisplayBuffer   
    rts
    
HandleBird:
    jsr DrawBird
    jsr CoverBirdImage
    subi.l  #BIRD_VELOCITY,d3                
    cmpi.l  #BIRD_MAX_LEFT,d3                 
    bge     SKIPMAXLEFT                         
    move.l  #BIRD_MAX_LEFT,d3                  
    jsr AddScore
    jsr CoverBirdImage 
Aga jsr LoadSpawn
    cmp Bird_1_Y,d4
    beq Aga
    cmp Bird_2_Y,d4
    beq Aga
    cmp Bird_3_Y,d4
    beq Aga
    rts
SKIPMAXLEFT:        
    jsr     DrawBird                      
EXIT:
    rts
; Need to do a coparison before the reload and use a label to skip if needed
* Put variables and constants here
InitialGame               INCLUDE    "Subroutines/InitialGame.X68"
BitmapHandeler            INCLUDE    "Subroutines/BitmapHandeler.X68"
PlayerMovement            INCLUDE    "Subroutines/PlayerMovement.X68"
NumberDisplay             INCLUDE    "Subroutines/7SegmentLED.X68"
RandomNumbers             INCLUDE    "Subroutines/RandomNumbers.X68"

MainMenuImage             incbin     "Images/MainMenu.bmp"
BackgroundImage           incbin     "Images/background-Recovered.bmp"
ButterfreeImage           incbin     "Images/butterfreeSprite224x56.bmp"
BirdImage                 incbin     "Images/Pidgeot3.bmp"
EndGameImage              incbin     "Images/EndGame.bmp"

LoadMsg                   dc.b       'Game is Loading...',0
Rand_Value                ds.l       1
Score                     dc.l       0
Number_Position_X         ds.l       1
Number_Position_Y         ds.l       1
Bird_1_X                  dc.l       0
Bird_1_Y                  dc.l       0
Bird_2_X                  dc.l       0
Bird_2_Y                  dc.l       0
Bird_3_X                  dc.l       0
Bird_3_Y                  dc.l       0
    END    START        












*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~

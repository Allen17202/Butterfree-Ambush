*-----------------------------------------------------------
* Title      : Initial Game
* Written by : Gregory Allen
* Date       : 10/20/2022
* Description: Subroutinue to load background, assets and anything else that is needed for game to start
*-----------------------------------------------------------
InitialGame
    ;Clears Screen at Start
    move.b  #CLEAR_SCREEN_TRAP,d0
    move.l  #CLEAR_WHOLE_SCREEN,d1
    trap    #15 
    
    ;Set the screen size
    ;Width is contained in upper word and height in lower set of word
    move.l  #SCREEN_SIZE_TRAP,d0
    move.w  #SCREEN_WIDTH,d1
    swap    d1
    move.w  #SCREEN_HEIGHT,d1
    trap    #15
    
    ;Turn on double buffer drawing mode
    move.b  #TURNON_DOUBLEBUFFER_TRAP,d1
    move.b  #DRAW_MODE_TRAP,d0
    trap    #15
    
    ;Display Loading Screen so I can start building assets in buffer
    lea LoadMsg, a1
    move.l #(SCREEN_WIDTH/2)-LOAD_MSG_WIDTH,d1
    move.l #(SCREEN_HEIGHT/2)-LOAD_MSG_WIDTH,d2
    move.l #SCREEN_TEXT_TRAP,d0
    trap   #15    
    jsr    DisplayBuffer
    
    ;Load image data
    lea MainMenuData,a5
    lea MainMenuImage,a0
    jsr LoadImageData
    
    ;Draw Main Menu
    lea MainMenuData,a5
    lea MainMenuImage,a0
    
    move.l #SCREEN_HEIGHT,-(sp)
    move.l #SCREEN_WIDTH,-(sp)
    move.l #0,-(sp)
    move.l #0,-(sp)
    move.l #0,-(sp)
    move.l #0,-(sp)
    jsr DisplayImage
    
    jsr    DisplayBuffer
    add.l #SIZE_DISPLAY_PARAMETERS_DATA,sp

DONTENTERGAME: 
    ;Check Spacebar to enter game 
    move.l #SPACEBAR_KEY,d1
    move.l #KEY_INPUT_TRAP,d0
    trap #15
    
    ;If not pressed, then loop until spacebar is pressed
    andi.l #$FF,d1              
    beq DONTENTERGAME
    
    ;Clear Screen and present a loading screen
    move.b  #CLEAR_SCREEN_TRAP,d0
    move.l  #CLEAR_WHOLE_SCREEN,d1
    trap    #15 
    
    lea LoadMsg, a1
    move.l #(SCREEN_WIDTH/2)-LOAD_MSG_WIDTH,d1
    move.l #(SCREEN_HEIGHT/2)-LOAD_MSG_WIDTH,d2
    move.l #SCREEN_TEXT_TRAP,d0
    trap   #15    
    jsr    DisplayBuffer
    
    ;Load background, Butterfree, and score to the data variables
    lea BackgroundImageData,a5
    lea BackgroundImage,a0
    jsr LoadImageData
    
    lea ButterfreeImageData,a5
    lea ButterfreeImage,a0
    jsr LoadImageData
    
    lea BirdImageData,a5
    lea BirdImage,a0
    jsr LoadImageData
    
    lea EndGameData,a5
    lea EndGameImage,a0
    jsr LoadImageData
    
    ; Draw Background
    lea BackgroundImageData,a5
    lea BackgroundImage,a0
    move.l #SCREEN_HEIGHT,-(sp)
    move.l #SCREEN_WIDTH,-(sp)
    move.l #0,-(sp)
    move.l #0,-(sp)
    move.l #0,-(sp)
    move.l #0,-(sp)
    jsr DisplayImage
    jsr    DisplayBuffer
    add.l #SIZE_DISPLAY_PARAMETERS_DATA,sp

    ; Draw Butterfree
    lea ButterfreeImageData,a5
    lea ButterfreeImage,a0
    move.l #BUTTERFREE_HEIGHT,-(sp)
    move.l #BUTTERFREE_WIDTH,-(sp)
    move.l #BUTTERFREE_TOP_LEFT_X,-(sp)
    move.l #BUTTERFREE_TOP_LEFT_Y,-(sp)
    move.l #INITIAL_BUTTERFREE_TOP_LEFT_X,-(sp)
    move.l #INITIAL_BUTTERFREE_TOP_LEFT_Y,-(sp)
    jsr DisplayImage
    add.l #SIZE_DISPLAY_PARAMETERS_DATA,sp
    
    move.l #INITIAL_BUTTERFREE_TOP_LEFT_X,d5
    move.l #INITIAL_BUTTERFREE_TOP_LEFT_Y,d6
    lsl.l #FRAC_BITS,d5
    lsl.l #FRAC_BITS,d6
    jsr    DisplayBuffer
   
    ; Draw Score
    movem.l REG_7SEGMENT_LED,-(sp)             
    move.l  Score,d6                                    
    move.l  #SCORE_X,Number_Position_X
    move.l  #SCORE_Y,Number_Position_Y
    jsr     Display7Segment      
    movem.l (sp)+,REG_7SEGMENT_LED            
    jsr    DisplayBuffer
    rts












*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~

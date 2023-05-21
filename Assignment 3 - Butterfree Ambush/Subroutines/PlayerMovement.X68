*-----------------------------------------------------------
* Title      : Player Movement Subroutine
* Written by : Gregory Allen
* Date       : 10/20/2022
* Description: Handles user input and applies a constant gravity to the main character
*-----------------------------------------------------------
HandlePlayerInput:    
        ; Check for Spacebar press   
        move.l  #SPACEBAR_KEY,d1
        move.l  #KEY_INPUT_TRAP,d0
        TRAP    #15
        ;Spacebar is not pressed, then apply gravity to butterfree
        andi.l  #$FF,d1                                 
        beq     APPLY_GRAVITY  

        ;Cover butterfree and move up the screen by decrementing Y coordinate                         
        jsr     CoverButterfreeImage
        subi.l  #BUTTERFREE_VELOCITY,d6
       
        ;Check Butterfrees Y coordinate has reached the top of  screen          
        cmpi.l  #BUTTERFREE_MAX_TOP,d6                  
        bge     SKIPMAXUP   
 
        ;Butterfree at top of screen -> set Butterfrees Y coordinate to the Max Top Value to prevent it from going off screen                                
        move.l  #BUTTERFREE_MAX_TOP,d6                  
SKIPMAXUP:        
        jsr     DrawButterfree                        


APPLY_GRAVITY: 
        ;Add Gravity to move Butterfree down the screen
        jsr      CoverButterfreeImage
        addi.l  #GRAVITY,d6                             
        cmpi.l  #BUTTERFREE_MAX_BOTTOM,d6               
        ble     SKIPMAXDOWN                              
        move.l  #(BUTTERFREE_MAX_BOTTOM+GRAVITY),d6  
SKIPMAXDOWN:                
        jsr     DrawButterfree                         
EXITPLAYERINPUT:
        rts





*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~

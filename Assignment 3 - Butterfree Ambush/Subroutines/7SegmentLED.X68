*-----------------------------------------------------------
* Title      : 7 Segment LED
* Written by : Gregory Allen
* Date       : 10/22/2022
* Description: Draw the seven segment LED using a digit table 
*              based off of offsets and manipulating the score given to 
*              handle the score in its number cases
*-----------------------------------------------------------



Display7Segment        
    ;(X,Y) Coordinates of the score on screen
    lea     Number_Position_X,a3
    lea     Number_Position_Y,a4
    
    ;Pen Width
    move.l  #DIGIT_PEN_WIDTH,d1                 
    move.l  #PEN_WIDTH_TRAP,d0 
    TRAP    #15

    ;Set color for the masking Rectangle behind score
    move.l  #BACKGROUND_COLOR,d1                        
    move.l  #PEN_COLOR_TRAP,d0            
    TRAP    #15        
    move.l  #FILL_COLOR_TRAP,d0          
    TRAP    #15
    
    
    ;Hide Previous numbers            
    move.l  (a3),d1                    
    move.l  (a4),d2                     
    
    move.l  (a3),d3
    move.l  #DIGIT_WIDTH,d7
    mulu.w  #(NUMBER_OF_DIGITS),d7
    add.l   d7,d3                       

    move.l  (a4),d4                     
    add.l   #LED_SIZE,d4
    add.l   #LED_SIZE,d4
           
    move.l  #DRAW_FILLED_RECTANGLE,d0  
    TRAP    #15        
    
    ;Number of Digits Counter
    move.l  #(NUMBER_OF_DIGITS-1),d4    
    
    ;Pen color
    move.l  #WHITE_COLOR,d1
    move.l  #PEN_COLOR_TRAP,d0
    TRAP    #15
          
PRINTNEXTDIGIT:
    
    divu.w  #10,d6                      ;Divide Score by 10 to get the remainder
    swap    d6                         
    move.w  d6,d0                       ;Move the remainderinto d0, d0 -> Digit to be drawn
    swap    d6                       
    ext.l   d6                          ;Extend the register to get rid of the remainder
    
    move.l  #DIGIT_WIDTH,d7             
    mulu.w  d4,d7                       ;Multiply Digit Width by the counter to get the offset X position where the digit is to be drawn
    
    lea     DigitTable,a6              
    add.l   d0,a6                       ;a6 -> Digit in table
                                        
       
    move.l  #0,d5                       ;Load the initial offset to 0
    move.b  (a6),d3                     ;Load the digit data
    
CHECKNEXTBIT:    
    lsr.l   #1,d3                      
    bcs     DrawLine                    ;If the carry flag is set then draw the line

INCREMENTBITCOUNTER:    
    addi.l  #1,d5                       ;Counter to check the 7 bits, which also acts as an offset
    cmpi.l  #SEGMENT7,d5               
    bne     CHECKNEXTBIT                ;Draw the next segment
    dbra    d4,PRINTNEXTDIGIT          

    bra     ESCAPE7SEGMENT              

DrawLine:
    lsl.l   #2,d5                       ;Counter
    
    lea     Led_Start_X1,a5             ;Load the X co-ordinate where the line starts 
    add.l   d5,a5                               
    move.l  (a5),d1                     ;Load X1 
    add.l   (a3),d1                     ;Add the X position
    add.l   d7,d1                       ;Add the digit's position
    
    lea     Led_Start_Y1,a5             ;Load the Y co-ordinate where the line starts
    add.l   d5,a5                       ;Add the offset to get the right segment
    move.l  (a5),d2                     ;Load Y1 
    add.l   (a4),d2                     ;Add the Y position
    
    move.l  #MOVE_GRAPHICS_XY_TRAP,d0  ;Move the drawing point.
    TRAP    #15
    
    
    lea     Led_End_X2,a5               ;Load the X co-ordinate where line ends
    add.l   d5,a5                             
    move.l  (a5),d1                     ;Load X1 
    add.l   (a3),d1                     ;Add the X position
    add.l   d7,d1                       ;Add the digit's position

    
    lea     Led_End_Y2,a5               ;Load the Y co-ordinate where line ends
    add.l   d5,a5                       ;Add the offset to get the right segment      
    move.l  (a5),d2                     ;Load X1 into data register
    add.l   (a4),d2                     ;Add the Y position



    move.l  #DRAW_LINE_TRAP_CODE,d0     
    trap    #15
    lsr.l   #2,d5                       ;Divide it by 4 to for counter
    bra     INCREMENTBITCOUNTER

ESCAPE7SEGMENT:       
    move.l  #DEFAULT_PEN_WIDTH,d1                 
    move.l  #PEN_WIDTH_TRAP,d0 
    TRAP    #15
    rts
*--------------------------------a----------------------b----------------------c------------------------------d-----------------------e--------------------------------f------------------g----------------
Led_Start_X1    dc.l    LED_OFFSET,                LED_SIZE,            LED_SIZE,                       LED_OFFSET,            0,                               0,                      LED_OFFSET
Led_Start_Y1    dc.l    0,                         LED_OFFSET,          LED_SIZE+LED_OFFSET,            LED_SIZE+LED_SIZE,     LED_SIZE+LED_OFFSET,             LED_OFFSET,             LED_SIZE
Led_End_X2      dc.l    LED_SIZE-LED_OFFSET,       LED_SIZE,            LED_SIZE,                       LED_SIZE-LED_OFFSET,   0,                               0,                      LED_SIZE-LED_OFFSET
Led_End_Y2      dc.l    0,                         LED_SIZE-LED_OFFSET, LED_SIZE+LED_SIZE-LED_OFFSET,   LED_SIZE+LED_SIZE,     LED_SIZE+LED_SIZE-LED_OFFSET,    LED_SIZE-LED_OFFSET,    LED_SIZE
*--------------------------------a----------------------b----------------------c------------------------------d-----------------------e--------------------------------f------------------g-----------------
DigitTable      dc.b    $3F,$06,$5B,$4F,$66,$6D,$7D,$07,$7F,$67









*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~

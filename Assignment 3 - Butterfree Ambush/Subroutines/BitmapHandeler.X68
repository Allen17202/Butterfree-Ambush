*-----------------------------------------------------------
* Title      : Bitmap Handeler
* Written by : Gregory Allen
* Date       : 10/22/2022
* Description: Loads bitmap file information and allow for drawing the bmp file based on parameters given
*-----------------------------------------------------------
;Paramater Offsets used to access from stack
PARAM_BITMAP_CHUNK_HEIGHT           EQU     24
PARAM_BITMAP_CHUNK_WIDTH            EQU     20
PARAM_BITMAP_CHUNK_TOPLEFT_X        EQU     16
PARAM_BITMAP_CHUNK_TOPLEFT_Y        EQU     12
PARAM_SCREEN_LOCATION_TOPLEFT_X     EQU     8
PARAM_SCREEN_LOCATION_TOPLEFT_Y     EQU     4

LoadImageData
        move.l  a0,a1
        adda    #FILE_OFFSET_TO_PIXELARRAY,a0                     
        move.l  (a0)+,d7                                    
        jsr     LittleToBigEndianLong                       
        add.l   d7,a1                                       ;a1 -> address to the pixel array                                                
        move.l  a1,(a5)+                                    ;Store address of the pixel array
        
        ;a0 -> DIB's header size 
        move.l  a0,a2
        move.l  (a0)+,d7                                     
        jsr     LittleToBigEndianLong                         
                                                            ;d7  holds size of the DIB header                                   
        add.l   d7,a2                                       ;a2 -> address to the color table
                                                            
        move.l  a2,(a5)+                                    ;Store address of color table
        
        ;a0 -> image's width
        move.l  (a0)+,d7                                    ;Move the width of image
        jsr     LittleToBigEndianLong                     
        move.l  d7,d5                                       ;d5 holds the width of the image   
        move.l  d5,(a5)+                                    ;Store the width of the image

        
        ;a0 -> image's height
        move.l  (a0),d7                                     ;Move height of image
        jsr     LittleToBigEndianLong                       
        move.l  d7,d3                                       ;d3 holds the height of the image
        move.l  d3,(a5)+                                    ;Store the height of the image
                                    
        rts
LittleToBigEndianLong
        ror.w   #$8,d7                                      
        swap    d7                                         
        ror.w   #$8,d7                                  
        rts                          

DisplayImage
        move.l  (a5)+,a1                                            ;Load address of the pixel array
        move.l  (a5)+,a2                                            ;Load address of the color table
        move.l  (a5)+,d5                                            ;Load width of the image
        move.l  (a5)+,d3                                            ;Load height of the image
                                                                                                                           

        move.l  PARAM_SCREEN_LOCATION_TOPLEFT_Y(sp),d2          
        add.l   PARAM_BITMAP_CHUNK_HEIGHT(sp),d2                    ;Y screen coordinate now points to the bottom left corner of the chunk image
        
                
        ;Get the address of the pixel array to the bottom left corner of the chunk     
        move.l  #0,d6                                               
        move.l  d3,d7                                               ;Move by the height of the image
        sub.l   PARAM_BITMAP_CHUNK_TOPLEFT_Y(sp),d7                 ;Subtract chunk's Y offset
        sub.l   PARAM_BITMAP_CHUNK_HEIGHT(sp),d7                    ;Subtract chunk height     
        cmp.l   d7,d6                                           
        bge     DontLoop 
         
LoopBack:
        add.l   d5,a1                                               ;Add the width of the image to the address of the pixel arrray
        addi.l  #1,d6                                               ;Increment the loop counter
        cmp.l   d7,d6                                               ;Check if the loop counter has reached the Y offset, if not then loop
        bne     LoopBack

DontLoop:             
        ;d4 -> width of the image to be drawn
        add.l  PARAM_BITMAP_CHUNK_TOPLEFT_X(sp),a1                                          
        move.l  PARAM_SCREEN_LOCATION_TOPLEFT_X(sp),d4              ;Move the Screen's X co-ordinate
        add.l   PARAM_BITMAP_CHUNK_WIDTH(sp),d4                     ;Add the chunk image's width.                                                                    
        
        ;Calculating the remaining width of the image that has be incremented after drawing each row of pixels
        lea     RemainingWidthOfBMP,a4
        move.l  d5,(a4)                                             ;Move the width of the image
        move.l  PARAM_BITMAP_CHUNK_WIDTH(sp),d6                   
        sub.l   d6,(a4)                                             ;Subtract the chunk image's width
        move.l  PARAM_BITMAP_CHUNK_TOPLEFT_X(sp),d6               
        sub.l   d6,(a4)                                             ;a4 will now point to the remaining width of the image   
        clr.l   d6


DrawEachRow:
        move.l  PARAM_SCREEN_LOCATION_TOPLEFT_X(sp),d7              ;d7 will contain the X corordinate of the screen             
          
DrawEachPixel:
        clr.w   d6 
        move.b  (a1)+,d6                                    ;Load the offset address of the color table and increment the address register
        lsl.l   #$02,d6                                     ;Multiple the offset address by 4 because each color on color table is 4 bytes long
        move.l  (a2,d6),d1                                  ;Load the color of the pixel to data register. 
        lsr.l   #$8,d1                                      
                                                          
        cmp.l   #TRANSPARENT_REPLACEMENT_COLOR,d1
        beq     JumpTransparent                                      
                          
        move.l  #PEN_COLOR_TRAP, d0                    
        trap    #15                                        
        
        
        ;Draw the pixel on the X,Y co-ordinate
        move.l  d7,d1                                 
                                                        
        move.l  #DRAW_PIXEL_TRAP,d0               
        trap    #15

JumpTransparent:        
       ;Increment the X co-ordinate
        addi.w    #1,d7

        ;Check if chunk width has got to the end, if not continue drawing row
        cmp.w   d4,d7                                       
        bne     DrawEachPixel
        add.l   (a4),a1
       
        ;Add the X offset to draw pixels in the new row
        add.l  PARAM_BITMAP_CHUNK_TOPLEFT_X(sp),a1
        
        ;Decrement the Y co-ordinate
        subi.w  #1,d2

        cmp.l   PARAM_SCREEN_LOCATION_TOPLEFT_Y(sp),d2   
        bne     DrawEachRow                
        rts
  
RemainingWidthOfBMP     ds.l    1
ButterfreeImageData     ds.l    4
BackgroundImageData     ds.l    4
BirdImageData           ds.l    4
EndGameData             ds.l    4 
MainMenuData            ds.l    4









*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~

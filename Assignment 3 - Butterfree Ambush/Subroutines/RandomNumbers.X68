*-----------------------------------------------------------
* Title      : Random Numbers Subroutine
* Written by : Gregory Allen
* Date       : 10/20/2022
* Description: Subroutine used to set the seed of a Random number Generator and get a random number from 0-255
*              Adapted from Utsabs Random Number Generator
*-----------------------------------------------------------

;  Stores random number based on time since midnight into Rand_Value
SeedRandomNumber
        move.b  #TIMER_TRAP,d0
        trap    #15
        move.l  d1,Rand_Value       
        rts

;Adapted from Utsabs Random Number Generator   
GetRandomByteIntoD0
        movem.l d1,-(sp)
        move.l  Rand_Value,d0
       	moveq	#$AF-$100,d1
       	moveq	#18,d2
Ninc0	
	    add.l	d0,d0
    	bcc	    Ninc1
	    eor.b	d1,d0
Ninc1
	    dbf	    d2,Ninc0
	
    	move.l	d0,Rand_Value
	
        movem.l (sp)+,d1
        rts





*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~

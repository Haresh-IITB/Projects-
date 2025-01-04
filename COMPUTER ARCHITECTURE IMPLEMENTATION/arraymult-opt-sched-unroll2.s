.data
.align 3
a: .double 1.0, 2.0, 3.0, 4.0, 5.0, 6.0 
b: .double 2.0, 3.0, 4.0, 5.0, 6.0, 7.0
c: .double 0.0, 0.0, 0.0, 0.0, 0.0, 0.0
d: .double 0.0, 0.0, 0.0, 0.0, 0.0, 0.0
n: .word 6 
alpha: .double 10.0

.text
.main:
    # r8 for i 
    dadd r8, r0, r0 # Loads 0 onto r8
    daddi r7 , r0 , 1 # Load 0 onto r7 (usd for i+1)
    lw r20, n(r0) # loads n in r20
    dsll r9, r8, 3 # 8*i for double  
    dsll r6, r7, 3 # 8*(i+1) for double  
    dsrl r20 , r20 , 1 # Placed after dsll , l.d to reduce the stall 
    # Also divided by 2 due to unrolling , 
    # the code will run only half a times 

    l.d  F7 , alpha(r0) # F7 has value of alpha

    # This uses 1 branch condition
    # THis is the initial check that whether or not we need to go to the branch
    slt r10, r8,r20 
    beq r10, r0, EXIT 

    BEGIN:

        l.d F8, a(r9)
        l.d F9, b(r9)
            
        mul.d F10, F8, F9 # a[i]*b[i]
        # loop counter ++ , is incremented here to minize the stall
        daddi r8, r8, 1
        mul.d F16 , F10 , F7 # c[i]*alpha
        # THis was earlier also here 
        l.d F11, d(r9) 
        # Loading for the next i+1 is done here to minimize the stalls 
        l.d F3, a(r6)
        l.d F4, b(r6)   
        add.d F13 ,F11 , F16 
        s.d F10, c(r9) # Moved down so store , when the F10 is calculated 
        s.d F13, d(r9)

            
        mul.d F5, F3, F4 # a[i]*b[i]
        daddi r9, r9, 16 # This moved here to reduce stall
        mul.d F20 , F5 , F7 # c[i]*alpha
        l.d F21, d(r6)
        slt r10 , r8 , r20  # Moved up 
        add.d F22 ,F21 , F20 
        s.d F5, c(r6) # THis moved down so no RAW stall 
        s.d F22, d(r6)

        # Between 2nd mul and add.d RAW stall isn't getting removed beacuse their aren't
        # Sufficient number of instr between them , and more can't be placed 
        # According to the structure of the code 
        # Also , due to same reason the RAW stall between Mul's can't get removed  
        # Also , str stall can't be removed 

        daddi r6, r6, 16

        bne r10 , r0 , BEGIN   

    EXIT: 
        halt 

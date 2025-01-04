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
    lw r20, n(r0) # loads n in r20
    dsll r9, r8, 3 # 8*i for double  

    slt r10, r8,r20 # moved before the load double to 
    # Remove the stall  
    l.d  F7 , alpha(r0) # F7 has value of alpha

    # This uses 1 branch condition
    # THis is the initial check that whether or not we need to go to the branch
    beq r10, r0, EXIT # There was a 
    # stall here removed by moving the sll instruction
    # Upwards 

    BEGIN:

        l.d F8, a(r9)
        l.d F9, b(r9)
        l.d F11, d(r9) 
        

        mul.d F10, F8, F9 # a[i]*b[i]
        # This instruction is moved up from the end of the loop
        # TO reomve the stall in mul.d while the values get load 
        # ALso moving it doesn't affect the code 
        # As once the loop is entered i has to be incremented 
        daddi r8, r8, 1
        # THis is also moved above so it takes 5 cycles less 
        # Earlier due to stall it took 5 more cycles  
        mul.d F12 , F10 , F7 # c[i]*alpha
        s.d F10, c(r9) # If this is moved above also between 2 muls , 
        # Number of stalls remain the same .  
        slt r10 , r8 , r20  # Intoducing it here reduces stall by 1 
        add.d F11 ,F12 , F10 
        
        # Between 2nd mul and add.d RAW stall isn't getting removed beacuse their aren't
        # Sufficient number of instr between them , and more can't be placed 
        # According to the structure of the code 
        # Also , due to same reason the RAW stall between Mul's can't get removed  
        # Also , str stall can't be removed 

        s.d F11, d(r9)

        daddi r9, r9, 8

        bne r10 , r0 , BEGIN   

    EXIT: 
        halt 

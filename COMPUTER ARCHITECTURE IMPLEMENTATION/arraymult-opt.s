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

    l.d  F7 , alpha(r0) # F7 has value of alpha

    # This uses 1 branch condition
    # THis is the initial check that whether or not we need to go to the branch
    slt r10, r8,r20 
    beq r10, r0, EXIT 

    BEGIN:

        l.d F8, a(r9)
        l.d F9, b(r9)
            
        mul.d F10, F8, F9 # a[i]*b[i]
        s.d F10, c(r9)

        mul.d F10 , F10 , F7 # c[i]*alpha
        l.d F11, d(r9)
        add.d F11 ,F11 , F10 
        s.d F11, d(r9)

        daddi r9, r9, 8

        daddi r8, r8, 1

        slt r10 , r8 , r20  
        bne r10 , r0 , BEGIN   

    EXIT: 
        halt 

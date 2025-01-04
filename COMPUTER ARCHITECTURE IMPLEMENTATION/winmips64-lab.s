.data
A:    .word 10       # A is a memory location with value 10
B:    .word 0x1234        # B is a memory location with value 8
C:    .word 0        # C is a memory location, initialized to 0

.text
main:

    # Checking delay in data forward from k-1 
    lw r4 , B(r0)
    sw r5 , 0(r4)
    # Writing first for a data stall i.e. (RAW in my case)
    lwu r2 , A(r0) # r0 = 10
    # data stall , at the EXE stage of the dadd instr beacuse the value read earlier was wrong , so after the EXE stage of the r2 , A(r0) , causing a stall (RAW) (*****PART 1(a)****)
    dadd r4 , r2 , r0 
    
    dadd r6 , r0 , r0 
    daddi r5 , r0 , 1 
    beq r2 , r6 , EXIT 
    # The above causes Part(3) , as it forwards the result of r6(EXEC) to ID of this instr , as this requires the data in the ID stage of BEQ
    
    lwu r6 , A(r0)
    dadd r8 , r2 , r5 
    # dadd r6 , r5 , r2 #This causes forwarding from MEM of lwu instr to ID of beq 
    dadd r10 , r5 , r6 #This causes forwarding from MEM of lwu instr to ID of beq 
    
    # This instruction for stall in ID of branch 
    daddi r5 , r0 , 10 
    beq r4 , r5 , EXIT
    dadd r4 , r0 , r0 # This to demonstrate the control stall (SInce this branch is not taken , it causes control stall as the instruction stops and waste one cycle **** (Part 1 (b)) *******
    dadd r5 , r2 , r0 

EXIT:
    dmul r3,r0,r5
    dadd r3,r4,r5 # These pair demonstrates the waw stall
    daddi r6, r0, 10         # r6 = 10 (EXIT label code)
    # data forwarding between two instructions that are as far apart as possible
    lw r13, 0(r4)  
    daddi r4,r4,1 
    dadd r12, r13, r5

    #maximum possible stall between a pair of instructions.
    ddiv r4,r4,r5
    ddiv r4,r4,r5
    
    daddi r4,r4,1
halt                         # Stop execution

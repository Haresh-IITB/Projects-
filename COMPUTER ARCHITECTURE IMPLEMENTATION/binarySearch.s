.data

    len: .word 10
    array: .word 1, 2, 3, 4, 5, 6, 7, 8, 9, 10
    start: .word 0 
    end: .word 10 
    prompt1: .asciiz "Enter values to search: " ; 
    prompt2: .asciiz "Index at which values is : " ; 

.text 
main:

    # For giving out prompt
    li	$v0, 4 ; 
	la	$a0, prompt1 ; 
    syscall ;

    # To take input value
    li $v0 , 5 ; # 5 for Reading the string value as integer 
    syscall
    or $s4 , $zero , $v0 ;

    la $s0 array  # array address
    lw $s1 len  # length 
    lw $s2 start #start
    lw $s3 end  #end 

    # ori $s4 $zero 10 # val 

    #  TO store $ra
    addi $sp $sp -4
    sw $ra 0($sp)

    jal binarysearch

    # Storing the result value from function
    ori $s5 $v0 0 

    # Displaying string and the value 
    li	$v0, 4 ; 
	la	$a0, prompt2 ; 
    syscall ;

    li $v0 , 1 ;
    move $a0, $s5 ; 
	syscall ; 

    # Restoring stacks
    lw $ra 0($sp)
    addi $sp $sp 4

    jr $ra 

binarysearch:
    # Base case
    beq $s1 $zero EXIT

    # Storing in stack
    addi $sp $sp -36
    sw $ra 20($sp)
    sw $s0 16($sp)
    sw $s1 12($sp)
    sw $s2 8($sp)
    sw $s3 4($sp)
    sw $s4 0($sp)
    sw $s6 24($sp)
    sw $s7 28($sp)
    sw $s8 32($sp)

    # t0=s6 for mid , v0 for result  

    # t1=s7 -> (start + end)/2 index 
    add $s7 $s2 $s3 
    srl $s7 $s7 1

    # t2=s8 -> arr[mid] , s8 -> mid address 
    sll $s8 $s7 2
    add $s8 $s8 $s0 
    lw $s6 0($s8)

    # if value at mid and val is same
    beq $s6 $s4 return_true

    # if mid is less than val then branch out to change start to increase start
    slt $s8 $s6 $s4 
    beq $s8 1 change_start

    # If val < arr[mid] we land here
    ori $s3 $s7 0
    srl $s1 $s1 1
    # ABove updating end and length and then again calling 
    jal binarysearch

    # restoring stack pointer
    lw $ra 20($sp)
    lw $s0 16($sp)
    lw $s1 12($sp)
    lw $s2 8($sp)
    lw $s3 4($sp)
    lw $s4 0($sp)
    lw $s6 24($sp)
    lw $s7 28($sp)
    lw $s8 32($sp)

    addi $sp $sp 36 
    jr $ra

EXIT:
    addi $v0 $zero -1 
    # above returning -1 
    lw $ra 20($sp)
    lw $s0 16($sp)
    lw $s1 12($sp)
    lw $s2 8($sp)
    lw $s3 4($sp)
    lw $s4 0($sp)
    lw $s6 24($sp)
    lw $s7 28($sp)
    lw $s8 32($sp)

    addi $sp $sp 36 
    jr $ra

change_start:
    # chaing start to mid and len = len/2
    ori $s2 $s7 0
    srl $s1 $s1 1
    # Now falling the binarysearch
    jal binarysearch

    lw $ra 20($sp)
    lw $s0 16($sp)
    lw $s1 12($sp)
    lw $s2 8($sp)
    lw $s3 4($sp)
    lw $s4 0($sp)
    lw $s6 24($sp)
    lw $s7 28($sp)
    lw $s8 32($sp)

    addi $sp $sp 36 
    jr $ra

return_true:
    # If element found returning index of mid 
    addi $v0 $s7 0

    lw $ra 20($sp)
    lw $s0 16($sp)
    lw $s1 12($sp)
    lw $s2 8($sp)
    lw $s3 4($sp)
    lw $s4 0($sp)
    lw $s6 24($sp)
    lw $s7 28($sp)
    lw $s8 32($sp)

    addi $sp $sp 36 
    jr $ra

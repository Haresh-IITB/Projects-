.data

#.align 2
len : .word 4 ; # stores 4 in the len  


#.align 2 # Specifies that the follwing data stores in the memeory of 8-bytes . 
complex : .word 0 ;
          .word 0 ;
          .word -1 ;
          .word 2 ;
          .word 0 ;
          .word 2 ;
          .word -1 ;
          .word -1 ;

prompt1:	.asciiz "Enter real part: " ; 
prompt2:	.asciiz "Enter imaginary part: " ; 
result: .asciiz "count is : " ;

.text

isLessThan: 
    # Here $a0 stores the value of e1.real , $a1 -> e1.im , $a2-> e2.real , $a3 , will store e2.im
    addi  $sp , $sp , -8 ; 
    sw $ra , 4($sp) ;
    sw $t0 , 0($sp) ; 
    slt $t0 , $a0 , $a2 ;
    beq $t0 , 1 , Return_True ;
    # Not chaning $a0 and $a2 in check_im that's why not storing them 
    # This part depicts that if the real part is same then , check for the imaginary part 
    # Otherwise return 0 
    beq $a0 , $a2 , check_im ; 
    andi $v0 ,  $zero , 0 ; 
    lw $t0 , 0($sp) ;
    lw $ra , 4($sp) ; 
    addi $sp , $sp , 8 ; 
    jr $ra ; 

Return_True:
    # If the the 1st one is less than the 2nd one , then this part returns1
    addi $v0 , $zero , 1;
    lw $t0 , 0($sp) ;
    lw $ra , 4($sp) ; 
    addi $sp , $sp , 8 ; 
    jr $ra ; 

check_im:
    # Passes two arguments $a1 , $a3 , representing imagrinary parts of e1 and e2 
    # Now if a1<s3 , it reutrns 1 , otherwise it returns 0 
    slt $t0 , $a1 , $a3 ;
    beq $t0 , 1 , Return_True ; 
    addi $v0 , $zero  , 0; 
    lw $t0 , 0($sp) ;
    lw $ra , 4($sp) ; 
    addi $sp , $sp , 8 ; 
    jr $ra ;  


numLessThan:
    # This stores all the values in the stack Pointers 
    addi $sp , $sp , -24 ;
    sw $ra , 20($sp) ;
    sw $s0 , 16($sp);
    sw $s1 , 12($sp);
    sw $s2 , 8($sp);
    sw $s3 , 4($sp);
    sw $s4 , 0($sp);

    # stores count of number which are less than
    addi $v1 , $zero , 0 ; 
    
    # s3 -> start (i of for loop) 
    # s4 -> end 
    # s0 -> real part of the num which we want to we who are less than this 
    # s1 -> imaginary part of the num which we want to we who are less than this 

    BEGIN:
    # Now this is check Condition for the for loop that is if, s3<s4 , then continue , otherwise exit 
    slt $t0 , $s3 , $s4 ; 
    beq $t0 , $zero , EXIT ;
    # This stores t1 = 8*i 
    sll $t1 , $s3 , 3 ;
    add $t1 , $t1 , $s2 ;
    # 
    lw $a0 , 0($t1) ;
    addi $t1 , $t1 , 4 ;  
    lw $a1 , 0($t1) ;
    or $a2 , $zero , $s0 ;
    or $a3 , $zero , $s1 ;
    jal isLessThan ;
    add $v1 , $v1 , $v0  ;
    addi $s3 , $s3 , 1 ; 
    j BEGIN;

    EXIT :
    lw $ra , 20($sp) ; 
    lw $s0 , 16($sp) ; 
    lw $s1 , 12($sp) ; 
    lw $s2 , 8($sp) ; 
    lw $s3 , 4($sp) ; 
    lw $s4 , 0($sp) ; 
    addi $sp , $sp , 24 ; 
    jr $ra ; 


main: 
    #real part 
    li	$v0, 4 ; 
	la	$a0, prompt1 ; # la load address of the prompt1 , so that it output the strings
    syscall ;

    # real part
    li $v0 , 5 ; # 5 for Reading the string value as integer 
    syscall
    or $s0 , $zero , $v0 ; # This stores the real value in $s0

    #imaginary part
    li $v0 , 4 ; 
    la $a0 , prompt2 ; 
    syscall ;

    #imaginary part
    li $v0 , 5 ; # 5 for Reading the string value as integer 
    syscall
    or $s1 , $zero , $v0 ; # This stores the complex value in $s1
    
    la $s2 , complex ; 

    # start 
    li $s3 , 0 ;
    # end 
    li $s4 , 4 ;

    addi $sp , $sp , -4 ;
    sw $ra , 0($sp) ;

    jal numLessThan ;

    #Print the result 
    li $v0 , 4 ; 
    la $a0 , result ; 
    syscall 

    li $v0 , 1 ;
    move $a0, $v1 ; 
	syscall ; 

    lw $ra , 0($sp) ;
    addi $sp , $sp , 4 ;

    jr $ra ; 


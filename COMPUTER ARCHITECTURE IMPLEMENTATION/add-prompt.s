.data

#prompt1 and promt2 are message to be prompted  
prompt1:	.asciiz "Enter in first integer: "
prompt2:	.asciiz "Enter in second integer: "
result:     .asciiz "Sum is : "

.text

main:

    #input number 1 
    li	$v0, 4 ; 
	la	$a0, prompt1 ; # la load address of the prompt1 , so that it output the strings
    syscall ;

    # read integer 1 
    li $v0 , 5 ; # 5 for Reading the string value as integer 
    syscall
    or $s0 , $zero , $v0 ; # This stores the integer value in $s0

    #input number 2
    li $v0 , 4 ; 
    la $a0 , prompt2 ; 
    syscall ;

    # read integer 2 
    li $v0 , 5 ; # 5 for Reading the string value as integer 
    syscall
    or $s1 , $zero , $v0 ; # This stores the integer value in $s0

    add $s2 , $s1 , $s0 ;  # Adds the integer 

    #Print the result 
    li $v0 , 4 ; 
    la $a0 , result ; 
    syscall 

    li $v0 , 1 ;
    move $a0, $s2 ; 
	syscall ; 

    jr $ra ; 

    
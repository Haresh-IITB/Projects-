.text

main:
    # read integer 1 
    li $v0 , 5 ; # 5 for Reading integer 
    syscall
    or $s0 , $zero , $v0 ; # This stores the integer value in $s0

    # read integer 2 
    li $v0 , 5 ; # 5 for Reading integer 
    syscall
    or $s1 , $zero , $v0 ; # This stores the integer value in $s0

    add $s2 , $s1 , $s0 ;  # Adds the integer 

    # Prints the integer 
    li $v0 , 1 ;
    move $a0, $s2 ; 
	syscall ; 

    jr $ra ; 


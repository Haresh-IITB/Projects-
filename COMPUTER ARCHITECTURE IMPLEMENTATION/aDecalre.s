.data

len : .word 4 ; # stores 4 in the len  
pad : .space 1 
new_word : .space 4 

.align 2 # Specifies that the follwing data stores in the memeory of 8-bytes . 
complex : .word 0 ;
          .word 0 ;
          .word -1 ;
          .word 2 ;
          .word 0 ;
          .word 2 ;
          .word -1 ;
          .word -1 ;

result: .asciiz "Sum is : " ;

.text 
 
main: 
    la $t2 , complex ; 
    lw $t0 , 12($t2) ; 
    lw $t1 , 16($t2) ; 
    add $s0 , $t0 , $t1 ; 
    la $t0 , new_word 
    sw $s0 , 0($t0) ; 
    #Print the result 
    li $v0 , 4 ; 
    la $a0 , result ; 
    syscall 

    li $v0 , 1 ;
    move $a0, $s0 ; 
	syscall ; 

    jr $ra ; 


        

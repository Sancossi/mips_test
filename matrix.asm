.data
	
	#Matrix
	matrix:	.space 400
	size: .word 5
	#Messages
	msg_matrix:     .asciiz "Matrix: "
	msg_input:	.asciiz "Enter element "
	msg_space:	.asciiz " : "
	msg_comma:	.asciiz " "
	msg_tab:	.asciiz "\n"
	msq_input_size: .asciiz "Please input M: "
		
.text

	.globl	main
	
main:	

	
	#print promt 
	li 	$v0, 4
	la 	$a0, msq_input_size
	syscall
	
	#read one interger from user
	li 	$v0, 5
	syscall
 	
	 #save user input to size
 	la 	$t6, size
 	sw 	$v0, 0($t6)
 	
	#load data from manipulition	
        #element size
        addi $a1,$zero, 4
        #matrix size (M)
        #addi $a2,$zero, 4
        lw $a2, size
        
        jal input_matrix
        #matrix before changes
        jal print_matrix
        
	jal change_matrix
	#matrix after changes        
	jal print_matrix        
        
        #end
	li	$v0,10	
	syscall

input_matrix:
	#input array from user
	#amount of matrix elements
	mul $t4,$a2,$a2
	#size of memory for matrix
	mul $t3,$t4,$a1
	#current array index
	addi $t0,$zero,0
	addi $t9,$zero, 1
	while_input:
		beq $t0,$t3,exit_input
		
		li	$v0,4		
		la	$a0, msg_input	
		syscall
		
		li $v0,1
		add $a0,$t9,$zero
		syscall
		
		li	$v0,4		
		la	$a0, msg_space
		syscall
		li	$v0,5		
		syscall
		
		sw $v0, matrix($t0)
		
		li	$v0,4		
		la	$a0, msg_tab	
		syscall
		
		add $t0,$t0,$a1
		
		addi $t9,$t9,1
		
		j while_input
	exit_input:
	jr $ra

print_matrix:

	li	$v0,4		
	la	$a0, msg_matrix
	syscall
	
	addi $t0,$zero,0
	#input array from user
	#amount of matrix elements
	mul $t4,$a2,$a2
	#size of memory for matrix
	mul $t3,$t4,$a1
	#size of one row
	mul $t7, $a1,$a2
	while_print:
        	beq $t0, $t3, exit_print
        	div $t8,$t0,$t7
        	mfhi $t9
        	beqz $t9, add_enter
		j continue
		add_enter:       	
        		li	$v0,4		
			la	$a0, msg_tab
			syscall
		continue:
        
    		lw $t8, matrix($t0)
    		
    		li $v0,1
		addi  $a0,$t8,0
		syscall
		
		li	$v0,4		
		la	$a0, msg_comma	
		syscall
		
        	add $t0,$t0,$a1
        	j while_print
        exit_print:
        li	$v0,4		
	la	$a0, msg_tab
	syscall
        jr $ra

change_matrix:

	#matrix index
    addi $t0,$zero, 0 
    
    #matrix row_index
    addi $t5, $zero, 0
	
    #matrix column_index
	addi $t6, $zero, 0
	
    #left board
	addi $t3,$zero, 0
	
    #right board
	addi $t4,$a2,0
        
	#check if M is even
	addi $t7,$zero,2                    # size_row = 2
	div $t7,$a2,$t7                     # size_row = size / 2
	mfhi $t7                            # size_row <— hi.  Move From Hi
        beqz $t7, row_border_if_even    # if size_row >= 0 then row_border_if_even()
        j row_border_if_odd             # else row_border_if_odd()
	
    row_border_if_even:	
		#row_border
		addi $t7,$zero,2                #size_row = 2             
		div $t7,$a2,$t7                 #size_row = size / 2
		j row_border_end
	
	row_border_if_odd:
		#row_border
		addi $t8,$zero,2
		addi $t7,$a2,1
		div $t7,$t7,$t8
	
	row_border_end:                 
##################################################################################################
	upper_part: 
		beq $t5,$t7,upper_part_end      # if(row_index == size_row) then upper_part_end()
		addi $t6,$t3,0                  # column_index = left_board 
	
    change_row:	
		beq $t6,$t4,end_change_row      # if(column_index == right_board) then end_change_row 
		mul $t8,$t6,$a1                 # t8 = column_index * element_size
		mul $t9,$a1,$a2                 # t9 = element_size * M 
		mul $t9,$t5,$t9                 # t9 += row_index 
		add $t8,$t8,$t9                 # t8 += t9
		addi $t9,$zero,0                # t9 = 0
		sw $t9, matrix($t8)             # t9 = *(matrix + t8)
		addi $t6,$t6,1                  # column_index++
		j change_row
	
    end_change_row:	
		addi $t3,$t3,1                  # left_board++       
		subi $t4,$t4,1                  # right_board--
		addi $t5,$t5,1                  # row_index++
		j upper_part                    

	upper_part_end:
		subi $t4,$t4,1                  # right_board--
###############################################################################################
        # column_index = M
        addi $t6, $a2
        #left board
	    addi $t3,$zero, 0
	
        #right board
	    addi $t4,$a2,0 #
##############################################################################################
        lower_part:
            beq $t6, $t7, lower_part_end	#if(collumn_index == row_border) then lower_part_end()
            addi $t6,$t3,0                  # collumn_index = left_board

        change_lower_row:
            beq $t6,$t4,end_change_lower_row      # if(column_index == right_board) then end_change_lower_row 
            mul $t8,$t6,$a1                 # t8 = column_index * element_size
            mul $t9,$a1,$a2                 # t9 = element_size * M 
            mul $t9,$t5,$t9                 # t9 += row_index 
            add $t8,$t8,$t9                 # t8 += t9
            addi $t9,$zero,0                # t9 = 0
            sw $t9, matrix($t8)             # t9 = *(matrix + t8)
            addi $t6,$t6,1                  # column_index++
            j change_lower_row

        end_change_lower_row:
            addi $t3,$t3,1                  # left_board++       
            subi $t4,$t4,1                  # right_board--
            subi $t5,$t5,1                  # row_index--
            j lower_part
        lower_part_end:
###################################################################################################					
	jr $ra

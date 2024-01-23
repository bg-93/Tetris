########################################################################
# COMP1521 23T3 -- Assignment 1 -- Tetris!
#
#
# !!! IMPORTANT !!!
# Before starting work on the assignment, make sure you set your tab-width to 8!
# It is also suggested to indent with tabs only.
# Instructions to configure your text editor can be found here:
#   https://cgi.cse.unsw.edu.au/~cs1521/23T3/resources/mips-editors.html
# !!! IMPORTANT !!!
#
#
# This program was written by ADITYA SHRIVASTAVA ()
# on 9 - 12/10/2023
#
# Version 1.0 (2023-09-25): Team COMP1521 <cs1521@cse.unsw.edu.au>
#
########################################################################

#![tabsize(8)]

# ##########################################################
# ####################### Constants ########################
# ##########################################################

# C constants
FIELD_WIDTH  = 9
FIELD_HEIGHT = 15
PIECE_SIZE   = 4
NUM_SHAPES   = 7

FALSE = 0
TRUE  = 1

EMPTY = ' '

# NULL is defined in <stdlib.h>
NULL  = 0

# Other useful constants
SIZEOF_INT = 4

COORDINATE_X_OFFSET = 0
COORDINATE_Y_OFFSET = 4
SIZEOF_COORDINATE = 8

SHAPE_SYMBOL_OFFSET = 0
SHAPE_COORDINATES_OFFSET = 4
SIZEOF_SHAPE = SHAPE_COORDINATES_OFFSET + SIZEOF_COORDINATE * PIECE_SIZE


	.data
# ##########################################################
# #################### Global variables ####################
# ##########################################################

# !!! DO NOT ADD, REMOVE, OR MODIFY ANY OF THESE DEFINITIONS !!!

shapes:				# struct shape shapes[NUM_SHAPES] = ...
	.byte 'I'
	.word -1,  0,  0,  0,  1,  0,  2,  0
	.byte 'J'
	.word -1, -1, -1,  0,  0,  0,  1,  0
	.byte 'L'
	.word -1,  0,  0,  0,  1,  0,  1, -1
	.byte 'O'
	.word  0,  0,  0,  1,  1,  1,  1,  0
	.byte 'S'
	.word  0,  0, -1,  0,  0, -1,  1, -1
	.byte 'T'
	.word  0,  0,  0, -1, -1,  0,  1,  0
	.byte 'Z'
	.word  0,  0,  1,  0,  0, -1, -1, -1

# Note that semantically global variables without
# an explicit initial value should be be zero-initialised.
# However to make testing earlier functions in this
# assignment easier, some global variables have been
# initialised with other values. Correct translations
# will always write to those variables befor reading,
# meaning the difference shouldn't matter to a finished
# translation.

next_shape_index:		# int next_shape_index = 0;
	.word 0

shape_coordinates:		# struct coordinate shape_coordinates[PIECE_SIZE];
	.word -1,  0,  0,  0,  1,  0,  2,  0

piece_symbol:			# char piece_symbol;
	.byte	'I'

piece_x:			# int piece_x;
	.word	3

piece_y:			# int piece_y;
	.word	1

piece_rotation:			# int piece_rotation;
	.word	0

score:				# int score = 0;
	.word	0

game_running:			# int game_running = TRUE;
	.word	TRUE

field:				# char field[FIELD_HEIGHT][FIELD_WIDTH];
	.byte	0:FIELD_HEIGHT * FIELD_WIDTH


# ##########################################################
# ######################### Strings ########################
# ##########################################################

# !!! DO NOT ADD, REMOVE, OR MODIFY ANY OF THESE STRINGS !!!

str__print_field__header:
	.asciiz	"\n/= Field =\\    SCORE: "
str__print_field__next:
	.asciiz	"     NEXT: "
str__print_field__footer:
	.asciiz	"\\=========/\n"

str__new_piece__game_over:
	.asciiz	"Game over :[\n"
str__new_piece__appeared:
	.asciiz	"A new piece has appeared: "

str__compute_points_for_line__tetris:
	.asciiz	"\n*** TETRIS! ***\n\n"

str__choose_next_shape__prompt:
	.asciiz	"Enter new next shape: "
str__choose_next_shape__not_found:
	.asciiz	"No shape found for "

str__main__welcome:
	.asciiz	"Welcome to 1521 tetris!\n"

str__show_debug_info__next_shape_index:
	.asciiz	"next_shape_index = "
str__show_debug_info__piece_symbol:
	.asciiz	"piece_symbol     = "
str__show_debug_info__piece_x:
	.asciiz	"piece_x          = "
str__show_debug_info__piece_y:
	.asciiz	"piece_y          = "
str__show_debug_info__game_running:
	.asciiz	"game_running     = "
str__show_debug_info__piece_rotation:
	.asciiz	"piece_rotation   = "
str__show_debug_info__coordinates_1:
	.asciiz	"coordinates["
str__show_debug_info__coordinates_2:
	.asciiz	"]   = { "
str__show_debug_info__coordinates_3:
	.asciiz	", "
str__show_debug_info__coordinates_4:
	.asciiz	" }\n"
str__show_debug_info__field:
	.asciiz	"\nField:\n"
str__show_debug_info__field_indent:
	.asciiz	":  "

str__game_loop__prompt:
	.asciiz	"  > "
str__game_loop__quitting:
	.asciiz	"Quitting...\n"
str__game_loop__unknown_command:
	.asciiz	"Unknown command!\n"
str__game_loop__goodbye:
	.asciiz	"\nGoodbye!\n"

# !!! Reminder to not not add to or modify any of the above !!!
# !!! strings or any other part of the data segment.        !!!



############################################################
####                                                    ####
####   Your journey begins here, intrepid adventurer!   ####
####                                                    ####
############################################################

################################################################################
#
# Implement the following functions,
# and check these boxes as you finish implementing each function.
#
#  SUBSET 0
#  - [ ] main
#  - [ ] rotate_left
#  - [ ] move_piece
#  SUBSET 1
#  - [ ] compute_points_for_line
#  - [ ] setup_field
#  - [ ] choose_next_shape
#  SUBSET 2
#  - [ ] print_field
#  - [ ] piece_hit_test
#  - [ ] piece_intersects_field
#  - [ ] rotate_right
#  SUBSET 3
#  - [ ] place_piece
#  - [ ] new_piece
#  - [ ] consume_lines
#  PROVIDED
#  - [X] show_debug_info
#  - [X] game_loop
#  - [X] read_char


################################################################################
# .TEXT <main>
        .text
main:
        # Subset:   0
        #
        # Args:     None
        #
        # Returns:  $v0: int
        #
        # Frame:    [$ra, $s0]
        # Uses:     [$ra, $s0, $a0, $v0]
        # Clobbers: [$v0, $a0, $v0]
        #
        # Locals:
        #   - $s0 : int should_announce
        #
        # Structure:
        #   main
        #   -> [prologue]
        #       -> body
        #   -> [epilogue]

main__prologue:
	# set up stack frame
	begin
	push	$ra
	push	$s0

main__body:

	li	$v0, 4									# syscall 4: print_string		
	la	$a0, str__main__welcome							#
	syscall										# printf("Welcome to 1521 tetris!")

	jal	setup_field								# setup_field()
	
	li	$s0, FALSE								#
	move	$a0, $s0								#			
	jal	new_piece								# new_piece(/* should_announce = */ FALSE);

	jal	game_loop								# game_loop()

	li	$v0, 0									# return 0;
main__epilogue:
	# tear down stack frame
	pop	$s0
	pop	$ra
	end
        jr      $ra


################################################################################
# .TEXT <rotate_left>
        .text
rotate_left:
        # Subset:   0
        #
        # Args:     None
        #
        # Returns:  None
        #
        # Frame:    [none]
        # Uses:     [none]
        # Clobbers: [none]
        #
        # Locals:
        #   - none
        #
        # Structure:
        #   rotate_left
        #   -> [prologue]
        #       -> body
        #   -> [epilogue]

rotate_left__prologue:
	#set up stack frame
	begin
	push	$ra

rotate_left__body:

	jal	rotate_right			# rotate_right();

	jal	rotate_right			# rotate_right();

	jal	rotate_right			# rotate_right();

rotate_left__epilogue:
	#tear down stack frame
	pop	$ra
	end
        jr      $ra



################################################################################
# .TEXT <move_piece>
        .text
move_piece:
        # Subset:   0
        #
        # Args:
        #    - $a0: int dx
        #    - $a1: int dy
        #
        # Returns:  $v0: int
        #
        # Frame:    [$ra, $s0, $s1, $s2, $s3]
        # Uses:     [$ra, $s0, $s1, $s2, $s3, $v0, $a0, $a1]
        # Clobbers: [$v0, $a0, $a1]
        #
        # Locals:
        #	- $s0: piece_x
	#	- $s1: piece_y
        #	- $s2: dx
	#	- $s3: dy
        # Structure:
        #   move_piece
        #	-> [prologue]
        #       	-> body
	#			->piece_intersect_field
        #  	-> [epilogue]

move_piece__prologue:
	#set up stack frame
	begin
	push	$ra
	push	$s0
	push	$s1
	push	$s2
	push	$s3

move_piece__body:
	move	$s2, $a0						# becasue we assume after the jal that all registers get clobbered
	move	$s3, $a1

	lw	$s0, piece_x
	lw	$s1, piece_y

	add 	$s0, $s0, $s2						#piece_x += dx;
	add 	$s1, $s1, $s3						#piece_y += dy;

	sw	$s0, piece_x
	sw	$s1, piece_y	

	jal	piece_intersects_field

	beq	$v0, TRUE, move_piece__body__piece_intersect_field		# if (piece_intersects_field() == TRUE) goto move_piece__body__piece_intersect_field;

	li	$v0, TRUE							# return TRUE;

	j	move_piece__epilogue

move_piece__body__piece_intersect_field:
	sub	$s0, $s0, $s2
	sub 	$s1, $s1, $s3

	sw	$s0, piece_x						#piece_x -= dx;
	sw	$s1, piece_y						#piece_y -= dy;


	li	$v0, FALSE						#  return FALSE;



move_piece__epilogue:
	# tear down stack frame
	pop	$s3
	pop	$s2
	pop	$s1
	pop	$s0
	pop	$ra
	end
        jr      $ra



################################################################################
# .TEXT <compute_points_for_line>
        .text
compute_points_for_line:
        # Subset:   1
        #
        # Args:
        #    - $a0: int bonus
        #
        # Returns:  $v0: int
        #
        # Frame:    [$ra]
        # Uses:     [$ra, $t0, $a0, $v0]
        # Clobbers: [$t0, $a0, $v0]
        #
        # Locals:
        #   	-  $t0: points
        #
        # Structure:
        #   compute_points_for_line
        #   -> [prologue]
        #       -> body
	#		->calculate_score:
	#		->cbonus_eq_4:
        #   -> [epilogue]

compute_points_for_line__prologue:
	begin
	push	$ra

compute_points_for_line__body:

	

	beq	$a0, 4, compute_points_for_line__body__bonus_eq_4		#if (bonus == 4) goto compute_points_for_line__body__bonus_eq_4;
	
compute_points_for_line__body__calculate_score:
	sub	$t0, $a0, 1							#score = bonus - 1;
	mul	$t0, $t0, $t0							#score = score*score ;
	mul	$t0, $t0, 40							#score = score*40;
	add	$t0, $t0, 100							#score = score+100;
	move	$v0, $t0							#return score;

	j	compute_points_for_line__epilogue

compute_points_for_line__body__bonus_eq_4:
	la	$a0, str__compute_points_for_line__tetris
	li	$v0, 4							#syscall_4: print_string
	syscall								#printf("\n*** TETRIS! ***\n\n");
	
	li	$a0, 4							#bonus == 4;
	j	compute_points_for_line__body__calculate_score	


	
compute_points_for_line__epilogue:

	pop	$ra
	end
        jr      $ra



################################################################################
# .TEXT <setup_field>
        .text
setup_field:
        # Subset:   1
        #
        # Args:     None
        #
        # Returns:  None
        #
        # Frame:    [$ra]
        # Uses:     [$t0, $t1, $t2, $t3, $ra]
        # Clobbers: [$t0, $t1, $t2, $t3]
        #
        # Locals:
        #   - $t0: row
	#   - $t1: col
	#   - $t2: temp
	#   - $t3: EMPTY
        #
        # Structure:
        #   setup_field
        # 	 -> [prologue]
        #       	-> body
	#			->row_loop__init
	#			->row_loop__cond
	#			->row_loop__body
	#				->col_loop__init
	#				->col_loop__cond
	#				->col_loop__body
	#				->col_loop__step
	#				->col_loop__end
	#			->row_loop__step
	#			->row_loop__end
        #  	 -> [epilogue]

setup_field__prologue:
	#set up stack frame
	begin
	push	$ra

setup_field__body:

	li	$t3, EMPTY
setup_field__body__row_loop__init:
	li	$t0, 0 							#int row = 0
setup_field__body__row_loop__cond:
	bge	$t0, FIELD_HEIGHT, setup_field__body__row_loop__end 	# if (row >= FIELD_HEIGHT) goto setup_field__body__row_loop_end;
setup_field__body__row_loop__body:
	

setup_field__body__col_loop__init:
	li	$t1, 0							#int col = 0
setup_field__body__col_loop__cond:
	bge	$t1, FIELD_WIDTH, setup_field__body__col_loop__end  	# if (col >= FIELD_WIDTH) goto setup_field__body__col_loop_end;
setup_field__body__col_loop__body:
	mul	$t2, $t0, FIELD_WIDTH					
	add	$t2, $t2, $t1
	mul	$t2, $t2, 1						# $t2 = 1*(row * FIELD_WIDTH + col)

	

	sb	$t3, field($t2)						#field[row][col] = EMPTY;


setup_field__body__col_loop__step:
	add	$t1, 1							# col = col + 1
	j	setup_field__body__col_loop__cond			# goto setup_field__body__col_loop_cond;


setup_field__body__col_loop__end:


setup_field__body__row_loop__step:	
	add	$t0, 1							#row = row + 1
	j	setup_field__body__row_loop__cond			# goto setup_field__body__row_loop_cond;

setup_field__body__row_loop__end:



setup_field__epilogue:
	#tear down stack frame
	pop	$ra
	end
        jr      $ra



################################################################################
# .TEXT <choose_next_shape>
        .text
choose_next_shape:
        # Subset:   1
        #
        # Args:     None
        #
        # Returns:  None
        #
        # Frame:    [ $ra, $s0, $s1]
        # Uses:     [$a0, $v0, $t0, $t1, $ra, $s0, $s1 , $a0]
        # Clobbers: [$a0, $v0, $t0, $t1, $a0]
        #
        # Locals:
        #   	- $s0: char symbol
        #	- $s1: int i
	#	- $t0: &shapes[i].symbol
	# 	- $t1: shapes[i].symbol
        # Structure:
        #   choose_next_shape
        #   -> [prologue]
        #       -> body
	#		->choose_next_shape__body__find_index__init
	#		->choose_next_shape__body__find_index__cond
	#		->choose_next_shape__body__find_index__body
	#		->choose_next_shape__body__find_index__step
	#		->choose_next_shape__body__find_index__end
	#		->choose_next_shape__body__no_shape
        #   -> [epilogue]

choose_next_shape__prologue:
	#setting up stack frame
	begin
	push	$ra
	push	$s0
	push	$s1

choose_next_shape__body:
	# Hint for translating shapes[i].symbol:
	#    You can compute the address of shapes[i] by using
	#      `i`, the address of `shapes`, and SIZEOF_SHAPE.
	#    You can then use that address to find the address of
	#      shapes[i].symbol with SHAPE_SYMBOL_OFFSET.
	#    Once you have the address of shapes[i].symbol you
	#      can use a memory load instruction to find its value.

	li	$v0, 4									# syscall4: print_string
	la	$a0, str__choose_next_shape__prompt	
	syscall										#printf("Enter new next shape: ");

	jal	read_char
	move	$s0, $v0								#char symbol = read_char();


choose_next_shape__body__find_index__init:
	li	$s1, 0									#int i = 0;
choose_next_shape__body__find_index__cond:

	beq	$s1, NUM_SHAPES, choose_next_shape__body__find_index__end		# if (i == NUM_SHAPES) goto choose_next_shape__body__find_index__end;

	mul	$t0, $s1, SIZEOF_SHAPE
	la	$t0, shapes($t0)							# $t0  =  shapes + i * SIZEOF_SHAPE
	add	$t0, SHAPE_SYMBOL_OFFSET						# $t0 =  &shapes[i].symbol
	lb	$t1, ($t0)								# $t1 =  shapes[i].symbol	

	beq	$t1, $s0, choose_next_shape__body__find_index__end 			# if (shapes[i].symbol == symbol) goto choose_next_shape__body__find_index__end

	

choose_next_shape__body__find_index__body:


choose_next_shape__body__find_index__step:
	add 	$s1, 1									# i++;
	j	choose_next_shape__body__find_index__cond				# goto choose_next_shape__body__find_index__cond

choose_next_shape__body__find_index__end:


	beq	$s1, NUM_SHAPES, choose_next_shape__body__no_shape

	sw	$s1, next_shape_index							#next_shape_index = i;

	j	choose_next_shape__epilogue	

choose_next_shape__body__no_shape:	
	li	$v0, 4
	la	$a0, str__choose_next_shape__not_found
	syscall										#printf("No shape found for ");

	li	$v0, 11
	move	$a0, $s0
	syscall										#printf("%c", symbol);

	li	$v0, 11
	li	$a0, '\n'
	syscall										#putchar('\n');









choose_next_shape__epilogue:
	#tearing down stack frame
	pop	$s1
	pop	$s0
	pop	$ra
	end
        jr      $ra



################################################################################
# .TEXT <print_field>
        .text
print_field:
        # Subset:   2
        #
        # Args:     None
        #
        # Returns:  None
        #
        # Frame:    [$ra, $s0, $s1]
        # Uses:     [$ra, $s0, $s1, $v0, $a0, $t0, $t1, $t2, $t3, $t4, $a0]
        # Clobbers: [$v0, $a0, $t0, $t1, $t2, $t3, $t4, $a0]
        #
        # Locals:
        #   - $s0: int row
	#   - $s1: int col
	#   - $t0: temporary
        #   - $t1: field[row][col]
	#   - $t2: next_shape_index
	#   - $t3: shapes[next_shape_index]	
	#   - $t4: temporary
        # Structure:
        #   print_field
        #   -> [prologue]
        #       -> body
	#		->print_field__body__row_loop__init
	#		->print_field__body__row_loop__cond
	#		->print_field__body__row_loop__body
	#			->print_field__body__col_loop__init
	#			->print_field__body__col_loop__cond
	#			->print_field__body__col_loop__body
	#				->print_field__body__col_loop__body__piece_hit
	#			->print_field__body__col_loop__step
	#			->print_field__body__col_loop__end
	#			->print_field__body__row_loop__body__n_first_row
	#		->print_field__body__row_loop__step
	#		->print_field__body__row_loop__end
	#
        #   -> [epilogue]

print_field__prologue:
	# setting up stack frame
	begin
	push	$ra
	push	$s0
	push	$s1

print_field__body:

	li	$v0, 4								#syscall4: print_string
	la	$a0, str__print_field__header
	syscall									#printf("\n/= Field =\\    SCORE: %d\n", score);


	li	$v0, 1
	lw	$a0, score
	syscall									#printf("%d", score);

	li	$v0, 11
	li	$a0, '\n'
	syscall									#printf("\n");

print_field__body__row_loop__init:
	li	$s0, 0								# int row = 0;


print_field__body__row_loop__cond:
	bge	$s0, FIELD_HEIGHT, print_field__body__row_loop__end; 		#if (row>= FIELD_HEIGHT) goto print_field__body__row_loop__end;
print_field__body__row_loop__body:
	li	$v0, 11
	li	$a0, '|'
	syscall									#putchar("|");

print_field__body__col_loop__init:
	li	$s1, 0								#int col = 0;
print_field__body__col_loop__cond:
	bge	$s1, FIELD_WIDTH, print_field__body__col_loop__end		# if (col>= FIELD_WIDTH) goto print_field__body__col_loop__end;

print_field__body__col_loop__body:
	la	$a0, shape_coordinates
	move	$a1, $s0
	move	$a2, $s1
	jal	piece_hit_test

	bnez	$v0, print_field__body__col_loop__body__piece_hit		#if (piece_hit_test(shape_coordinates, row, col)) goto print_field__body__col_loop__body__piece_hit;


	mul	$t0, FIELD_WIDTH, $s0
	add	$t0, $t0, $s1
	mul	$t0, $t0, 1

	lb	$t2, field($t0)

	li	$v0, 11
	move	$a0, $t2
	syscall									#putchar(field[row][col]);



	j	print_field__body__col_loop__step
print_field__body__col_loop__body__piece_hit:
	li	$v0, 11
	lb	$a0, piece_symbol
	syscall									#putchar(piece_symbol);

print_field__body__col_loop__step:
	add	$s1, 1     							#col = col+1;

	j	print_field__body__col_loop__cond


print_field__body__col_loop__end:
	li	$v0, 11
	li	$a0, '|'
	syscall									#putchar("|");


	bne	$s0, 1, print_field__body__row_loop__body__n_first_row

	li	$v0, 4								#syscall4: print_string
	la	$a0, str__print_field__next
	syscall									#printf("    NEXT: ")


	lw	$t2, next_shape_index

	mul	$t4, $t2, SIZEOF_SHAPE
	add	$t4, $t4, SHAPE_SYMBOL_OFFSET

	lb	$t3, shapes($t4)						# shapes[next_shape_index].symbol

	li	$v0, 11
	move	$a0, $t3
	syscall									# printf("%c", shapes[next_shape_index].symbol);





print_field__body__row_loop__body__n_first_row:
	li	$v0, 11
	li	$a0, '\n'
	syscall									#printf("\n");

	j	print_field__body__row_loop__step



print_field__body__row_loop__step:
	add	$s0, 1
	j	print_field__body__row_loop__cond



print_field__body__row_loop__end:
	li	$v0, 4								#syscal4: print_string
	la	$a0, str__print_field__footer
	syscall									#printf("\\=========/\n");




print_field__epilogue:
	#tearing down stack frame

	pop	$s1
	pop	$s0
	pop	$ra
	end
        jr      $ra



################################################################################
# .TEXT <piece_hit_test>
        .text
piece_hit_test:
        # Subset:   2
        #
        # Args:
        #    - $a0: struct coordinate coordinates[PIECE_SIZE]
        #    - $a1: int row
        #    - $a2: int col
        #
        # Returns:  $v0: struct coordinate *
        #
        # Frame:    [$ra]
        # Uses:     [$t0, $t1, $t2, $t3, $t4, $t5, $t6, $t7, $ra, $a0, $a1, $a2, $v0]
        # Clobbers: [$t0, $t1, $t2, $t3, $t4, $t5, $t6, $t7, $a0, $a1, $a2, $v0]
        #
        # Locals:
        #   - $t0: int i
        #   - $t1: coordinates[i].x
	#   - $t2: coordinates[i].y
	#   - $t3: temporary
	#   - $t4: piece_x
	#   - $t5: piece_y
	#   - $t6: coordiantes[i]
	#   - $t7: temporary
        # Structure:
        #   piece_hit_test
        #   -> [prologue]
        #	-> body
	#		->piece_hit_test__body__board_loop_init
	#		->piece_hit_test__body__board_loop_cond
	#		->piece_hit_test__body__board_loop_body
	#		->piece_hit_test__body__board_loop_step
	#		->piece_hit_test__body__board_loop_end
        #   -> [epilogue]

piece_hit_test__prologue:
	#setting up stack frame
	begin
	push	$ra

piece_hit_test__body:

piece_hit_test__body__board_loop_init:
	li	$t0, 0 							#int i = 0;

piece_hit_test__body__board_loop_cond:
	bge	$t0, PIECE_SIZE, piece_hit_test__body__board_loop_end 	# if(i>= PIECE_SIZE) goto piece_hit_test__body__board_loop_end;

piece_hit_test__body__board_loop_body:


	mul	$t3, $t0, SIZEOF_COORDINATE
	add	$t6, $a0, $t3						#$t6 = coordinates + SIZEOF_COORDINATE * i
	lw	$t1, COORDINATE_X_OFFSET($t6)				#$t1 = coordinates[i].x
	lw	$t2, COORDINATE_Y_OFFSET($t6)				#$t2 = coordinates[i].y

	lw	$t4, piece_x						#piece_x
	lw	$t5, piece_y						#piece_y

	add	$t7, $t1, $t4						#$t7 = coordinates[i].x + piece_x 
	add	$t3, $t2, $t5						#$t3 = coordinates[i].y + piece_y

	bne	$t7, $a2, piece_hit_test__body__board_loop_step
	bne	$t3, $a1, piece_hit_test__body__board_loop_step		#if (coordinates[i].x + piece_x != col || coordinates[i].y + piece_y != row) goto piece_hit_test__body__board_loop_step


	move	$v0, $t6						# return coordinates + i;

	j	piece_hit_test__epilogue



piece_hit_test__body__board_loop_step:
	add	$t0, 1							#i = i+1
	j	piece_hit_test__body__board_loop_cond			#goto  piece_hit_test__body__board_loop_cond


piece_hit_test__body__board_loop_end:
	li	$v0, NULL						# return NULL;



piece_hit_test__epilogue:
	#tearing down stack frame
	pop	$ra
	end
        jr      $ra



################################################################################
# .TEXT <piece_intersects_field>
        .text
piece_intersects_field:
        # Subset:   2
        #
        # Args:     None
        #
        # Returns:  $v0: int
        #
        # Frame:    [$ra, $s0, $s1, $s2]
        # Uses:     [$ra, $s0, $s1, $s2, $t0, $t1, $t2, $t3, $t4, $t5, $t6, $t7, $v0]
        # Clobbers: [$t0, $t1, $t2, $t3, $t4, $t5, $t6, $t7, $v0]
        #
        # Locals:
        #   	- $t0: int i
	#	- $t1: int x
        #	- $t2: int y
	#	- $t3: temporary register
	#	- $t4: &shape_coordinates[i]
	#	- $t5: piece_x
	# 	- $t6: piece_y
	#	- $t7: temporary register
	#	- $s0: shape_coordinates[i].x
	#	- $s1: shape_coordinates[i].y
	#	- $s2: field[x][y]
        # Structure:
        #   piece_intersects_field
        #   -> [prologue]
        #     	  -> body
	#		->piece_intersects_field__body__piece_loop_init
	#		->piece_intersects_field__body__piece_loop_cond
	#		->piece_intersects_field__body__piece_loop_main
	#			->piece_intersects_field__body__piece_loop_main__intersection_exists
	#		->piece_intersects_field__body__piece_loop_step
	#		->piece_intersects_field__body__piece_loop_end:
        #   -> [epilogue]

piece_intersects_field__prologue:
	#setting up stack frame
	begin
	push	$ra
	push	$s0
	push	$s1
	push	$s2

piece_intersects_field__body:

piece_intersects_field__body__piece_loop_init:
	li	$t0, 0 													#int i = 0

piece_intersects_field__body__piece_loop_cond:
	bge 	$t0, PIECE_SIZE, piece_intersects_field__body__piece_loop_end

piece_intersects_field__body__piece_loop_main:
	mul	$t3, $t0, SIZEOF_COORDINATE
	la	$t7, shape_coordinates
	add	$t4, $t3, $t7												# &shape_coordinates[i]

	lw	$s0, COORDINATE_X_OFFSET($t4)
	lw	$s1, COORDINATE_Y_OFFSET($t4)

	lw	$t5, piece_x
	lw	$t6, piece_y

	add	$t1, $s0, $t5												# int x = shape_coordinates[i].x + piece_x;
	add	$t2, $s1, $t6												# int y = shape_coordinates[i].y + piece_y;
	
	
	bltz	$t1, piece_intersects_field__body__piece_loop_main__intersection_exists
	bge	$t1, FIELD_WIDTH, piece_intersects_field__body__piece_loop_main__intersection_exists			#if (x < 0 || x >= FIELD_WIDTH){...}
	

	bltz	$t2, piece_intersects_field__body__piece_loop_main__intersection_exists
	bge	$t2, FIELD_HEIGHT, piece_intersects_field__body__piece_loop_main__intersection_exists			# if (y < 0 || y >= FIELD_HEIGHT) {...}

	
	mul	$t7, $t2, FIELD_WIDTH
	add	$t7, $t7, $t1
	mul	$t7, $t7, 1
	lb	$s2, field($t7)												#$s2 = field[y][x]

	bne	$s2, EMPTY, piece_intersects_field__body__piece_loop_main__intersection_exists				#if (field[y][x] != EMPTY) {...}



	j	piece_intersects_field__body__piece_loop_step

piece_intersects_field__body__piece_loop_main__intersection_exists:
	li	$v0, TRUE

	j	piece_intersects_field__epilogue
	

piece_intersects_field__body__piece_loop_step:
	add	$t0, $t0,  1												#i++;
	j	piece_intersects_field__body__piece_loop_cond


piece_intersects_field__body__piece_loop_end:
	li	$v0, FALSE												# return FALSE




	
piece_intersects_field__epilogue:
	#tearing down stack frame
	pop	$s2
	pop	$s1
	pop	$s0
	pop	$ra
	end
        jr      $ra



################################################################################
# .TEXT <rotate_right>
        .text
rotate_right:
        # Subset:   2
        #
        # Args:     None
        #
        # Returns:  None
        #
        # Frame:    [$ra]
        # Uses:     [$t0, $t1, $t2, $t3, $t4, $t5, $t6, $t7. $ra]
        # Clobbers: [$t0, $t1, $t2, $t3, $t4, $t5, $t6, $t7]
        #
        # Locals:
        #   	- $t0: shape_coordinates[i].x
	#	- $t1: shape_coordinates[i].y
	#	- $t3: temp 
        #	- $t4: &shape_coordinates[i]
	#	- $t5: temporary resiter
	#	- $t6: int i
	#	- $t7: piece_symbol
        # Structure:
        #   rotate_right
        #   -> [prologue]
        #       -> body
	#		->rotate_right__body__regular_swap_loop_init
	#		->rotate_right__body__regular_swap_loop_cond
	#		->rotate_right__body__regular_swap_loop_body
	#		->rotate_right__body__regular_swap_loop_step
	#		->rotate_right__body__regular_swap_loop_end
	#
	#		->rotate_right__body__uncentered_letter
	#			->rotate_right__body__uncentered_letter__loop_init
	#			->rotate_right__body__uncentered_letter__loop_cond
	#			->rotate_right__body__uncentered_letter__loop_body
	#			->rotate_right__body__uncentered_letter__loop_step
	#			->rotate_right__body__uncentered_letter__loop_end
        #   -> [epilogue]

rotate_right__prologue:
	#setting up stack frame
	begin
	push	$ra

rotate_right__body:
	# The following 3 instructions are provided, although you can
	# discard them if you want. You still need to add appropriate
	# comments.
	lw	$t0, piece_rotation
	addi	$t0, $t0, 1
	sw	$t0, piece_rotation							#piece_rotation++

rotate_right__body__regular_swap_loop_init:
	li	$t6, 0									#int i = 0

rotate_right__body__regular_swap_loop_cond:
	bge	$t6, PIECE_SIZE, rotate_right__body__regular_swap_loop_end


rotate_right__body__regular_swap_loop_body:
	mul	$t4, $t6, SIZEOF_COORDINATE
	la	$t5, shape_coordinates
	add	$t4, $t4, $t5								# &shape_coordinates[i]
	lw	$t0, COORDINATE_X_OFFSET($t4)						#shape_coordinates[i].x;
	lw	$t1, COORDINATE_Y_OFFSET($t4)						#shape_coordinates[i].y;
	move	$t3, $t0								#int temp = shape_coordinates[i].x;

	mul	$t1, -1
	sw	$t1, COORDINATE_X_OFFSET($t4) 						#shape_coordinates[i].x = -shape_coordinates[i].y;
	sw	$t3, COORDINATE_Y_OFFSET($t4)						#shape_coordinates[i].y = temp;



rotate_right__body__regular_swap_loop_step:
	add	$t6, 1									#i++;
	j	rotate_right__body__regular_swap_loop_cond


rotate_right__body__regular_swap_loop_end:



	lb	$t7, piece_symbol
	beq	$t7, 'I', rotate_right__body__uncentered_letter
	beq	$t7, 'O', rotate_right__body__uncentered_letter				#if (piece_symbol == 'I' || piece_symbol == 'O'){...}

	j	rotate_right__epilogue


rotate_right__body__uncentered_letter:


rotate_right__body__uncentered_letter__loop_init:
	li	$t6, 0	# int i = 0
rotate_right__body__uncentered_letter__loop_cond:
	bge	$t6, PIECE_SIZE, rotate_right__body__uncentered_letter__loop_end

rotate_right__body__uncentered_letter__loop_body:
	mul	$t4, $t6, SIZEOF_COORDINATE
	la	$t5, shape_coordinates
	add	$t4, $t4, $t5				
	lw	$t0, COORDINATE_X_OFFSET($t4)						#$t0 = shape_coordinates[i].x

	add	$t0, 1
	sw	$t0, COORDINATE_X_OFFSET($t4)						#shape_coordinates[i].x += 1;

rotate_right__body__uncentered_letter__loop_step:
	add	$t6, 1									#i++;
	j	rotate_right__body__uncentered_letter__loop_cond

rotate_right__body__uncentered_letter__loop_end:





rotate_right__epilogue:
	#tearing down stack frame
	pop	$ra
	end
        jr      $ra



################################################################################
# .TEXT <place_piece>
        .text
place_piece:
        # Subset:   3
        #
        # Args:     None
        #
        # Returns:  None
        #
        # Frame:    [$ra, $s0, $s1, $s2]
        # Uses:     [$ra, $s0, $s1, $s2]
        # Clobbers: [$t0, $t2, $t3, $t4, $t5, $t6, $t7]
        #
        # Locals:
        #  	- $t0: int i
	#	- $t1: int col
        #	- $t2: int row
	#	- $t3: temporary register
	#	- $t4: shape_coordinates[i]
	#	- $t5: piece_x
	# 	- $t6: piece_y
	#	- $t7: temporary register
	#	- $s0: shape_coordinates[i].x
	#	- $s1: shape_coordinates[i].y
	#	- $s2: piece_symbol
        #
        # Structure:
        #   place_piece
        #   -> [prologue]
        #       -> body
	#		->place_piece__body__piece_loop_init
	#		->place_piece__body__piece_loop_body
	#		->place_piece__body__piece_loop_step
	#		->place_piece__body__piece_loop_end
        #   -> [epilogue]

place_piece__prologue:
	#seting up stack frame
	begin
	push	$ra
	push	$s0
	push	$s1
	push	$s2

place_piece__body:

place_piece__body__piece_loop_init:
	li	$t0, 0		#int i = 0


place_piece__body__piece_loop_cond:
	bge 	$t0, PIECE_SIZE, place_piece__body__piece_loop_end

place_piece__body__piece_loop_body:
	mul	$t3, $t0, SIZEOF_COORDINATE
	la	$t7, shape_coordinates
	add	$t4, $t3, $t7						# &shape_coordinates[i]

	lw	$s0, COORDINATE_X_OFFSET($t4)				# &shape_coordinates[i]
	lw	$s1, COORDINATE_Y_OFFSET($t4) 				# &shape_coordinates[i]

	lw	$t5, piece_x
	lw	$t6, piece_y
	add	$t1, $s0, $t5						# int col = shape_coordinates[i].x + piece_x;
	add	$t2, $s1, $t6						# int row = shape_coordinates[i].y + piece_y;
	
	mul	$t7, $t2, FIELD_WIDTH
	add	$t7, $t7, $t1
	mul	$t7, $t7, 1
	lb	$s2, piece_symbol
	sb	$s2, field($t7)						# field[row][col] = piece_symbol;

place_piece__body__piece_loop_step:
	add	$t0, 1
	j	place_piece__body__piece_loop_cond


place_piece__body__piece_loop_end:

	
	jal	consume_lines						#consume_lines();

	li	$a0, TRUE
	jal	new_piece						#new_piece(/* should_announce = */ TRUE);


place_piece__epilogue:
	#tear down stack frame
	pop	$s2
	pop	$s1
	pop	$s0
	pop	$ra
	end
        jr      $ra



################################################################################
# .TEXT <new_piece>
        .text
new_piece:
        # Subset:   3
        #
        # Args:
        #    - $a0: int should_announce
        #
        # Returns:  None
        #
        # Frame:    [$ra, $s0, $s1, $s2, $s3, $s4, $s5, $s6]
        # Uses:     [$a0, $v0, $t0, $t1, $t2, $t3, $t4, $t5, $t6, $t7, $ra, $s0, $s1, $s2, $s3, $s4, $s5, $s6 ]
        # Clobbers: [$t0, $t1, $t2, $t3, $t4, $t5, $t6, $t7, $a0, $v0]
        #
        # Locals:
        #  	 - $t0: int i
        #	 - $t1: piece_x
	#	 - $t2: piece_y
	#	 - $t3: piece_rotation
	#	 - $t4: next_shape_index
	#	 - $s0: game_running
	#	 - $s1: piece_symbol
	#	 - $t5: shape_coordinates
	#	 - $t6: temporary register
	#	 - $t7: temporary register
	#	 - $s2: shapes[next_shape_index].coordinates[i].x
	#	 - $s3: &shape_coordinates[i].x
	#	 - $s4: int should_announce
	#	 - $s5: shapes[next_shape_index].coordinates[i].y
	#	 - $s6:  &shape_coordinates[i].y
        # Structure:
        #   new_piece
        #   -> [prologue]
        #       -> body
	#		->new_piece__body__symbol_O
	#		->new_piece__body__symbol_I
	#		
	#		->new_piece__body__piece_loop_init
	#		->new_piece__body__piece_loop_cond
	#		->new_piece__body__piece_loop_body
	#		->new_piece__body__piece_loop_step
	#		->new_piece__body__piece_loop_end
	#			
	#		->new_piece__body__piece_intersect
	#		->new_piece__body_announce:
        #   -> [epilogue]

new_piece__prologue:
	#setting up stack frame
	begin
	push	$ra
	push	$s0
	push	$s1
	push	$s2
	push	$s3
	push	$s4
	push	$s5
	push	$s6


new_piece__body:
	move	$s4, $a0

	li	$t6, 4
	li	$t7, 1
	sw	$t6, piece_x						#piece_x = 4;
	sw	$t7, piece_y						#piece_y = 1;
	li	$t6, 0
	sw	$t6, piece_rotation					#piece_rotation = 0;

	lw	$t4, next_shape_index
	mul	$t6, $t4, SIZEOF_SHAPE
	la	$t7, shapes
	add	$t7, $t7, $t6 

	lb	$s1, SHAPE_SYMBOL_OFFSET($t7)				#shapes[next_shape_index].symbol;
	sb	$s1, piece_symbol					#piece_symbol = shapes[next_shape_index].symbol;


	li	$t6, 'O'
	beq	$s1, $t6, new_piece__body__symbol_O			#if (piece_symbol == 'O') {...}
	
	li	$t6, 'I'
	beq	$s1, $t6, new_piece__body__symbol_I			#else if (piece_symbol == 'I') {...}

	j	new_piece__body__piece_loop_init


new_piece__body__symbol_O:
	lw	$t6, piece_x
	lw	$t7, piece_y
	sub	$t6, $t6, 1
	sub	$t7, $t7, 1
	sw	$t6, piece_x						#piece_x -= 1;
	sw	$t7, piece_y						#piece_y -= 1;

	j	new_piece__body__piece_loop_init

new_piece__body__symbol_I:
	lw	$t7, piece_y
	sub	$t7, $t7, 1						
	sw	$t7, piece_y						#piece_y -= 1;




new_piece__body__piece_loop_init:
	li	$t0, 0							# int i = 0

new_piece__body__piece_loop_cond:
	bge	$t0, PIECE_SIZE, new_piece__body__piece_loop_end

new_piece__body__piece_loop_body:
	lw	$t4, next_shape_index
	mul	$t6, $t4, SIZEOF_SHAPE
	la	$t7, shapes
	add	$t7, $t7, $t6 						#&shapes[next_shape_index]
	add 	$t7, $t7, SHAPE_COORDINATES_OFFSET			#&shapes[next_shape_index].coordinates
	mul	$t6, $t0, SIZEOF_COORDINATE
	add	$t7, $t6, $t7						# &shapes[next_shape_index].coordinates[i];

	add	$t6, $t7, COORDINATE_X_OFFSET				#&shapes[next_shape_index].coordinates[i].x
	lw	$s2, ($t6)						#shapes[next_shape_index].coordinates[i].x;

	add	$t6, $t7, COORDINATE_Y_OFFSET				#&shapes[next_shape_index].coordinates[i].y
	lw	$s5, ($t6)						#shapes[next_shape_index].coordinates[i].y;


	la	$t7, shape_coordinates
	mul	$t6, $t0, SIZEOF_COORDINATE
	add	$t6, $t6, $t7						#&shape_coordinates[i]
	add	$s3, $t6, COORDINATE_X_OFFSET				#&shape_coordinates[i].x
	add	$s6, $t6, COORDINATE_Y_OFFSET				#&shape_coordinates[i].y
	
	
	sw	$s2,($s3)						# shape_coordinates[i].x = shapes[next_shape_index].coordinates[i].x;
	sw	$s5, ($s6)						# shape_coordinates[i].y = shapes[next_shape_index].coordinates[i].y;
new_piece__body__piece_loop_step:
	add	$t0, 1
	j	new_piece__body__piece_loop_cond

new_piece__body__piece_loop_end:


	lw	$t4, next_shape_index
	add	$t4,$t4, 1
	sw	$t4, next_shape_index					# next_shape_index += 1;

	lw	$t4, next_shape_index
	rem	$t4, $t4, NUM_SHAPES
	sw	$t4, next_shape_index					# next_shape_index %= NUM_SHAPES;


	jal	piece_intersects_field

	beq	$v0, TRUE, new_piece__body__piece_intersect		#if (piece_intersects_field()) {...}
	beq	$s4, TRUE, new_piece__body_announce			#else if (should_announce) {...}

	j	new_piece__epilogue

new_piece__body__piece_intersect:
	jal	print_field

	li	$v0, 4							#syscall4: print_string
	la	$a0, str__new_piece__game_over
	syscall								#printf("Game over :[\n");

	li	$t6, FALSE
	sw	$t6, game_running

	j	new_piece__epilogue


new_piece__body_announce:

	li	$v0, 4							#syscall4: print_string
	la	$a0, str__new_piece__appeared
	syscall								# printf("A new piece has appeared: ")

	lb	$s1, piece_symbol

	li	$v0, 11							#syscall11: print_character
	move	$a0, $s1
	syscall								# printf("%c", piece_symbol)

	li	$v0, 11							#syscall11: print_character
	li	$a0, '\n'
	syscall								#printf("\n")



	
	








new_piece__epilogue:
	#tearing down stack frame
	pop	$s6
	pop	$s5
	pop	$s4
	pop	$s3
	pop	$s2
	pop	$s1
	pop	$s0
	pop	$ra
	end
        jr      $ra



################################################################################
# .TEXT <consume_lines>
        .text
consume_lines:
        # Subset:   3
        #
        # Args:     None
        #
        # Returns:  None
        #
        # Frame:    [$ra, $s0, $s1, $s2, $s3, $s4]
        # Uses:     [$ra, $s0, $s1, $s2, $s3, $s4, $t0, $t1, $t2, $t3, $t4, $t5]
        # Clobbers: [$t0, $t1, $t2, $t3, $t4, $t5]
        #
        # Locals:
        #  	- $s0: int lines_cleared
        #	- $s1: int row
	#	- $t0: int line_is_full
	#	- $t1: int col
	#	- $s2: field[row][col]
	#	- $t2: int row_to_copy 
	#	- $s3: &field[row_to_copy][col]
	#	- $s4: field[row_to_copy-1][col]
	#	- $t3: temporary register
	#	- $t4: temporary register
	#	- $t5: temporary register
	#
        # Structure:
        #   consume_lines
        #   -> [prologue]
        #       -> body
	#		->consume_lines__body__over_all_rows_loop__init
	#		->consume_lines__body__over_all_rows_loop__cond
	#		->consume_lines__body__over_all_rows_loop__body
	#			->consume_lines__body__over_all_rows_loop__body__col_loop__init
	#			->consume_lines__body__over_all_rows_loop__body__col_loop__cond
	#			->consume_lines__body__over_all_rows_loop__body__col_loop__body
	#			->consume_lines__body__over_all_rows_loop__body__col_loop__step
	#			->consume_lines__body__over_all_rows_loop__body__col_loop__end
	#			
	#			->consume_lines__body__over_all_rows_loop__body__line_is_not_full
	#			->consume_lines__body__over_all_rows_loop__body__line_is_full
	#
	#			->consume_lines__body__over_all_rows__row_to_copy_loop__init
	#			->consume_lines__body__over_all_rows__row_to_copy_loop__cond
	#			->consume_lines__body__over_all_rows__row_to_copy_loop__body
	#				->consume_lines__body__over_all_rows__row_to_copy_loop_body__col_loop_init
	#				->consume_lines__body__over_all_rows__row_to_copy_loop_body__col_loop_cond
	#				->consume_lines__body__over_all_rows__row_to_copy_loop_body__col_loop_body
	#					->consume_lines__body__over_all_rows__row_to_copy_loop_body__col_loop_body__rtc_equal_0:
	#				->consume_lines__body__over_all_rows__row_to_copy_loop_body__col_loop_step
	#				->consume_lines__body__over_all_rows__row_to_copy_loop_body__col_loop_end
	#			->consume_lines__body__over_all_rows__row_to_copy_loop__step
	#			-> consume_lines__body__over_all_rows__row_to_copy_loop__step
	#		->consume_lines__body__over_all_rows_loop__step
	#		->consume_lines__body__over_all_rows_loop__end
        #   -> [epilogue]

consume_lines__prologue:
	#creeating stack frame 
	begin
	push	$ra
	push	$s0
	push	$s1
	push	$s2
	push	$s3
	push	$s4


consume_lines__body:
	li	$s0, 0													# int lines_cleared = 0;

consume_lines__body__over_all_rows_loop__init:
	li	$t3, FIELD_HEIGHT
	sub	$s1, $t3, 1												#int row = FIELD_HEIGHT-1;
consume_lines__body__over_all_rows_loop__cond:
	bltz	$s1,	 consume_lines__body__over_all_rows_loop__end							# if (row<0) goto consume_lines__body__over_all_rows_loop__end;


consume_lines__body__over_all_rows_loop__body:
	li	$t0, TRUE 												#int line_is_full = TRUE;

consume_lines__body__over_all_rows_loop__body__col_loop__init:
	li	$t1, 0		#int col = 0;

consume_lines__body__over_all_rows_loop__body__col_loop__cond:
	bge	$t1, FIELD_WIDTH, consume_lines__body__over_all_rows_loop__body__col_loop__end




consume_lines__body__over_all_rows_loop__body__col_loop__body:
	mul	$t4, FIELD_WIDTH, $s1
	add	$t4,$t4, $t1
	mul	$t4, $t4, 1
	lb	$s2, field($t4)												#field[row][col]

	bne	$s2, EMPTY, consume_lines__body__over_all_rows_loop__body__col_loop__step				# if (field[row][col] != EMPTY) goto consume_lines__body__over_all_rows_loop__body__col_loop__cond

	li	$t0, FALSE												#line_is_full = FALSE;

consume_lines__body__over_all_rows_loop__body__col_loop__step:
	add	$t1, 1													#++col
	j	consume_lines__body__over_all_rows_loop__body__col_loop__cond

consume_lines__body__over_all_rows_loop__body__col_loop__end:

	beq	$t0, FALSE,  consume_lines__body__over_all_rows_loop__body__line_is_not_full

	j	consume_lines__body__over_all_rows_loop__body__line_is_full

consume_lines__body__over_all_rows_loop__body__line_is_not_full:

	j	consume_lines__body__over_all_rows_loop__step

consume_lines__body__over_all_rows_loop__body__line_is_full:


consume_lines__body__over_all_rows__row_to_copy_loop__init:
	move	$t2, $s1												# int row_to_copy = row;

consume_lines__body__over_all_rows__row_to_copy_loop_cond:
	bltz	$t2, consume_lines__body__over_all_rows__row_to_copy_loop_end						#if (row_to_copy <0) {...}



consume_lines__body__over_all_rows__row_to_copy_loop_body:

consume_lines__body__over_all_rows__row_to_copy_loop_body__col_loop_init:
	li	$t1, 0													#int col = 0


consume_lines__body__over_all_rows__row_to_copy_loop_body__col_loop_cond:
	bge	$t1, FIELD_WIDTH, consume_lines__body__over_all_rows__row_to_copy_loop_body__col_loop_end



consume_lines__body__over_all_rows__row_to_copy_loop_body__col_loop_body:
	mul	$t4, FIELD_WIDTH, $t2
	add	$t4, $t4, $t1
	la	$s3, field($t4)												#&field[row_to_copy][col]

	sub	$t5, $t2, 1												#row_to_copy-1
	mul	$t4, FIELD_WIDTH,$t5 
	add	$t4, $t4, $t1		
	lb	$s4, field($t4)												#field[row_to_copy-1][col]

	beqz	$t2, consume_lines__body__over_all_rows__row_to_copy_loop_body__col_loop_body__rtc_equal_0		#if row_to_copy ==0: goto consume_lines__body__over_all_rows__row_to_copy_loop_body__col_loop_body__rtc_equal_0

	sb	$s4, ($s3)
	j	consume_lines__body__over_all_rows__row_to_copy_loop_body__col_loop_step

consume_lines__body__over_all_rows__row_to_copy_loop_body__col_loop_body__rtc_equal_0:
	li	$t3, EMPTY			
	sb	$t3, ($s3)												#field[row_to_copy][col] = EMPTY;
	j	consume_lines__body__over_all_rows__row_to_copy_loop_body__col_loop_step

consume_lines__body__over_all_rows__row_to_copy_loop_body__col_loop_step:
	add	$t1,$t1, 1												#++col
	j	consume_lines__body__over_all_rows__row_to_copy_loop_body__col_loop_cond

consume_lines__body__over_all_rows__row_to_copy_loop_body__col_loop_end:


consume_lines__body__over_all_rows__row_to_copy_loop_step:
	sub	$t2, $t2, 1												#--row_to_copy	
	j	consume_lines__body__over_all_rows__row_to_copy_loop_cond


consume_lines__body__over_all_rows__row_to_copy_loop_end:


	add	$s1, $s1, 1												# row++
	add	$s0, $s0, 1												# lines_cleared++

	move	$a0, $s0
	jal	compute_points_for_line											#compute_points_for_line(lines_cleared);

	lw	$t4, score
	add	$t4, $t4, $v0
	sw	$t4, score												# score += compute_points_for_line(lines_cleared);

consume_lines__body__over_all_rows_loop__step:
	sub	$s1, 1													#--row
	j	consume_lines__body__over_all_rows_loop__cond


consume_lines__body__over_all_rows_loop__end:


consume_lines__epilogue:
	#tearing down stack frame
	pop	$s4
	pop	$s3
	pop	$s2
	pop	$s1
	pop	$s0
	pop	$ra
        end
	jr      $ra


################################################################################
################################################################################
###                   PROVIDED FUNCTIONS — DO NOT CHANGE                     ###
################################################################################
################################################################################

################################################################################
# .TEXT <show_debug_info>
        .text
show_debug_info:
	# Args:     None
        #
        # Returns:  None
	#
	# Frame:    []
	# Uses:     [$a0, $v0, $t0, $t1, $t2, $t3]
	# Clobbers: [$a0, $v0, $t0, $t1, $t2, $t3]
	#
	# Locals:
	#   - $t0: i
	#   - $t1: coordinates address calculations
	#   - $t2: row
	#   - $t3: col
	#   - $t4: field address calculations
	#
	# Structure:
	#   print_board
	#   -> [prologue]
	#   -> body
	#     -> coord_loop
	#       -> coord_loop__init
	#       -> coord_loop__cond
	#       -> coord_loop__body
	#       -> coord_loop__step
	#       -> coord_loop__end
	#     -> row_loop
	#       -> row_loop__init
	#       -> row_loop__cond
	#       -> row_loop__body
	#         -> col_loop
	#           -> col_loop__init
	#           -> col_loop__cond
	#           -> col_loop__body
	#           -> col_loop__step
	#           -> col_loop__end
	#       -> row_loop__step
	#       -> row_loop__end
	#   -> [epilogue]

show_debug_info__prologue:

show_debug_info__body:
	li	$v0, 4				# syscall 4: print_string
	la	$a0, str__show_debug_info__next_shape_index
	syscall					# printf("next_shape_index = ");

	li	$v0, 1				# sycall 1: print_int
	lw	$a0, next_shape_index		# next_shape_index
	syscall					# printf("%d", next_shape_index);

	li	$v0, 11				# syscall 11: print_char
	li	$a0, '\n'
	syscall					# putchar('\n');


	li	$v0, 4				# syscall 4: print_string
	la	$a0, str__show_debug_info__piece_symbol
	syscall					# printf("piece_symbol     = ");

	li	$v0, 1				# sycall 1: print_int
	lb	$a0, piece_symbol		# piece_symbol
	syscall					# printf("%d", piece_symbol);

	li	$v0, 11				# syscall 11: print_char
	li	$a0, '\n'
	syscall					# putchar('\n');


	li	$v0, 4				# syscall 4: print_string
	la	$a0, str__show_debug_info__piece_x
	syscall					# printf("piece_x          = ");

	li	$v0, 1				# sycall 1: print_int
	lw	$a0, piece_x			# piece_x
	syscall					# printf("%d", piece_x);

	li	$v0, 11				# syscall 11: print_char
	li	$a0, '\n'
	syscall					# putchar('\n');


	li	$v0, 4				# syscall 4: print_string
	la	$a0, str__show_debug_info__piece_y
	syscall					# printf("piece_y          = ");

	li	$v0, 1				# sycall 1: print_int
	lw	$a0, piece_y			# piece_y
	syscall					# printf("%d", piece_y);

	li	$v0, 11				# syscall 11: print_char
	li	$a0, '\n'
	syscall					# putchar('\n');


	li	$v0, 4				# syscall 4: print_string
	la	$a0, str__show_debug_info__game_running
	syscall					# printf("game_running     = ");

	li	$v0, 1				# sycall 1: print_int
	lw	$a0, game_running		# game_running
	syscall					# printf("%d", game_running);

	li	$v0, 11				# syscall 11: print_char
	li	$a0, '\n'
	syscall					# putchar('\n');


	li	$v0, 4				# syscall 4: print_string
	la	$a0, str__show_debug_info__piece_rotation
	syscall					# printf("piece_rotation   = ");

	li	$v0, 1				# sycall 1: print_int
	lw	$a0, piece_rotation		# piece_rotation
	syscall					# printf("%d", piece_rotation);

	li	$v0, 11				# syscall 11: print_char
	li	$a0, '\n'
	syscall					# putchar('\n');


show_debug_info__coord_loop:
show_debug_info__coord_loop__init:
	li	$t0, 0				# int i = 0;

show_debug_info__coord_loop__cond:		# while (i < PIECE_SIZE) {
	bge	$t0, PIECE_SIZE, show_debug_info__coord_loop__end

show_debug_info__coord_loop__body:
	li	$v0, 4				#   syscall 4: print_string
	la	$a0, str__show_debug_info__coordinates_1
	syscall					#   printf("coordinates[");

	li	$v0, 1				#   syscall 1: print_int
	move	$a0, $t0
	syscall					#   printf("%d", i);

	li	$v0, 4				#   syscall 4: print_string
	la	$a0, str__show_debug_info__coordinates_2
	syscall					#   printf("]   = { ");

	mul	$t1, $t0, SIZEOF_COORDINATE	#   i * sizeof(struct coordinate)
	addi	$t1, $t1, shape_coordinates	#   &shape_coordinates[i]

	li	$v0, 1				#   syscall 1: print_int
	lw	$a0, COORDINATE_X_OFFSET($t1)	#   shape_coordinates[i].x
	syscall					#   printf("%d", shape_coordinates[i].x);

	li	$v0, 4				#   syscall 4: print_string
	la	$a0, str__show_debug_info__coordinates_3
	syscall					#   printf(", ");

	li	$v0, 1				#   syscall 1: print_int
	lw	$a0, COORDINATE_Y_OFFSET($t1)	#   shape_coordinates[i].y
	syscall					#   printf("%d", shape_coordinates[i].y);

	li	$v0, 4				#   syscall 4: print_string
	la	$a0, str__show_debug_info__coordinates_4
	syscall					#   printf(" }\n");

show_debug_info__coord_loop__step:
	addi	$t0, $t0, 1			#   i++;
	b	show_debug_info__coord_loop__cond

show_debug_info__coord_loop__end:		# }

	li	$v0, 4				# syscall 4: print_string
	la	$a0, str__show_debug_info__field
	syscall					# printf("\nField:\n");

show_debug_info__row_loop:
show_debug_info__row_loop__init:
	li	$t2, 0				# int row = 0;

show_debug_info__row_loop__cond:		# while (row < FIELD_HEIGHT) {
	bge	$t2, FIELD_HEIGHT, show_debug_info__row_loop__end

show_debug_info__row_loop__body:
	bge	$t2, 10, show_debug_info__print_row
	li	$v0, 11				#  if (row < 10) {
	li	$a0, ' '
	syscall					#     putchar(' ');

show_debug_info__print_row:			#   }
	li	$v0, 1				#   syscall 1: print_int
	move	$a0, $t2
	syscall					#   printf("%d", row);


	li	$v0, 4				#   syscall 4: print_string
	la	$a0, str__show_debug_info__field_indent
	syscall					#   printf(":  ");

show_debug_info__col_loop:
show_debug_info__col_loop__init:
	li	$t3, 0				#   int col = 0;

show_debug_info__col_loop__cond:		#   while (col < FIELD_WIDTH) {
	bge	$t3, FIELD_WIDTH, show_debug_info__col_loop__end

show_debug_info__col_loop__body:
	mul	$t4, $t2, FIELD_WIDTH		#     row * FIELD_WIDTH
	add	$t4, $t4, $t3			#     row * FIELD_WIDTH + col
	addi	$t4, $t4, field			#     &field[row][col]

	li	$v0, 1				#     syscall 1: print_int
	lb	$a0, ($t4)			#     field[row][col]
	syscall					#     printf("%d", field[row][col]);

	li	$v0, 11				#     syscall 11: print_char
	li	$a0, ' '
	syscall					#     putchar(' ');

	lb	$a0, ($t4)			#     field[row][col]
	syscall					#     printf("%c", field[row][col]);

	li	$v0, 11				#     syscall 11: print_char
	li	$a0, ' '
	syscall					#     putchar(' ');

show_debug_info__col_loop__step:
	addi	$t3, $t3, 1			#     i++;
	b	show_debug_info__col_loop__cond

show_debug_info__col_loop__end:			#   }

	li	$v0, 11				#   syscall 11: print_char
	li	$a0, '\n'
	syscall					#   putchar('\n');

show_debug_info__row_loop__step:
	addi	$t2, $t2, 1			#   row++;
	b	show_debug_info__row_loop__cond

show_debug_info__row_loop__end:			# }

	li	$v0, 11				# syscall 11: print_char
	li	$a0, '\n'
	syscall					# putchar('\n');

show_debug_info__epilogue:
	jr	$ra


################################################################################
# .TEXT <game_loop>
        .text
game_loop:
        # Args:     None
        #
        # Returns:  None
        #
        # Frame:    [$ra]
        # Uses:     [$t0, $t1, $v0, $a0]
        # Clobbers: [$t0, $t1, $v0, $a0]
        #
        # Locals:
        #   - $t0: copy of game_running
        #   - $t1: char command
        #
        # Structure:
        #   game_loop
        #   -> [prologue]
        #       -> body
	#         -> big_loop
	#         -> big_loop__cond
	#         -> big_loop__body
	#           -> game_loop__command_r
	#           -> game_loop__command_R
	#           -> game_loop__command_n
	#           -> game_loop__command_s
	#           -> game_loop__command_S
	#           -> game_loop__command_a
	#           -> game_loop__command_d
	#           -> game_loop__command_p
	#           -> game_loop__command_c
	#           -> game_loop__command_question
	#           -> game_loop__command_q
	#           -> game_loop__unknown_command
	#         -> big_loop__step
	#         -> big_loop__end
        #   -> [epilogue]

game_loop__prologue:
	begin
	push	$ra

game_loop__body:
game_loop__big_loop__cond:
	lw	$t0, game_running
	beqz	$t0, game_loop__big_loop__end		# while (game_running) {

game_loop__big_loop__body:
	jal	print_field				#   print_field();

	li	$v0, 4					#   syscall 4: print_string
	la	$a0, str__game_loop__prompt
	syscall						#   printf("  > ");

	jal	read_char
	move	$t1, $v0				#   command = read_char();

	beq	$t1, 'r', game_loop__command_r		#   if (command == 'r') { ...
	beq	$t1, 'R', game_loop__command_R		#   } else if (command == 'R') { ...
	beq	$t1, 'n', game_loop__command_n		#   } else if (command == 'n') { ...
	beq	$t1, 's', game_loop__command_s		#   } else if (command == 's') { ...
	beq	$t1, 'S', game_loop__command_S		#   } else if (command == 'S') { ...
	beq	$t1, 'a', game_loop__command_a		#   } else if (command == 'a') { ...
	beq	$t1, 'd', game_loop__command_d		#   } else if (command == 'd') { ...
	beq	$t1, 'p', game_loop__command_p		#   } else if (command == 'p') { ...
	beq	$t1, 'c', game_loop__command_c		#   } else if (command == 'c') { ...
	beq	$t1, '?', game_loop__command_question	#   } else if (command == '?') { ...
	beq	$t1, 'q', game_loop__command_q		#   } else if (command == 'q') { ...
	b	game_loop__unknown_command		#   } else { ... }

game_loop__command_r:					#   if (command == 'r') {
	jal	rotate_right				#     rotate_right();

	jal	piece_intersects_field			#     call piece_intersects_field();
	beqz	$v0, game_loop__big_loop__cond		#     if (piece_intersects_field())
	jal	rotate_left				#       rotate_left();

	b	game_loop__big_loop__cond		#   }

game_loop__command_R:					#   else if (command == 'R') {
	jal	rotate_left				#     rotate_left();

	jal	piece_intersects_field			#     call piece_intersects_field();
	beqz	$v0, game_loop__big_loop__cond		#     if (piece_intersects_field())
	jal	rotate_right				#       rotate_right();

	b	game_loop__big_loop__cond		#   }

game_loop__command_n:					#   else if (command == 'n') {
	li	$a0, FALSE				#     argument 0: FALSE
	jal	new_piece				#     new_piece(FALSE);

	b	game_loop__big_loop__cond		#   }

game_loop__command_s:					#   else if (command == 's') {
	li	$a0, 0					#     argument 0: 0
	li	$a1, 1					#     argument 1: 1
	jal	move_piece				#     call move_piece(0, 1);

	bnez	$v0, game_loop__big_loop__cond		#     if (!piece_intersects_field())
	jal	place_piece				#       rotate_left();

	b	game_loop__big_loop__cond		#   }

game_loop__command_S:					#   else if (command == 'S') {
game_loop__hard_drop_loop:
	li	$a0, 0					#     argument 0: 0
	li	$a1, 1					#     argument 1: 1
	jal	move_piece				#     call move_piece(0, 1);
	bnez	$v0, game_loop__hard_drop_loop		#     while (move_piece(0, 1));

	jal	place_piece				#     place_piece();

	b	game_loop__big_loop__cond		#   }

game_loop__command_a:					#   else if (command == 'a') {
	li	$a0, -1					#     argument 0: -1
	li	$a1, 0					#     argument 1: 0
	jal	move_piece				#     move_piece(-1, 0);

	b	game_loop__big_loop__cond		#   }

game_loop__command_d:					#   else if (command == 'd') {
	li	$a0, 1					#     argument 0: 1
	li	$a1, 0					#     argument 1: 0
	jal	move_piece				#     move_piece(1, 0);

	b	game_loop__big_loop__cond		#   }

game_loop__command_p:					#   else if (command == 'p') {
	jal	place_piece				#     place_piece();

	b	game_loop__big_loop__cond		#   }

game_loop__command_c:					#   else if (command == 'c') {
	jal	choose_next_shape			#     choose_next_shape();

	b	game_loop__big_loop__cond		#   }

game_loop__command_question:				#   else if (command == '?') {
	jal	show_debug_info				#     show_debug_info();

	b	game_loop__big_loop__cond		#   }

game_loop__command_q:					#   else if (command == 'q') {
	li	$v0, 4					#     syscall 4: print_string
	la	$a0, str__game_loop__quitting
	syscall						#     printf("Quitting...\n");

	b	game_loop__big_loop__end		#     break;

game_loop__unknown_command:				#   } else {
	li	$v0, 4					#     syscall 4: print_string
	la	$a0, str__game_loop__unknown_command
	syscall						#     printf("Unknown command!\n");

game_loop__big_loop__step:				#   }
	b	game_loop__big_loop__cond

game_loop__big_loop__end:				# }
	li	$v0, 4					# syscall 4: print_string
	la	$a0, str__game_loop__goodbye
	syscall						# printf("\nGoodbye!\n");

game_loop__epilogue:
	pop	$ra
	end

	jr	$ra					# return;


################################################################################
# .TEXT <show_debug_info>
        .text
read_char:
	# NOTE: The implementation of this function is
	#       DIFFERENT from the C code! This is
	#       because mipsy handles input differently
	#       compared to `scanf`. You do not need to
	#       worry about this difference as you will
	#       only be calling this function.
	#
        # Args:     None
        #
        # Returns:  $v0: char
        #
        # Frame:    []
        # Uses:     [$v0]
        # Clobbers: [$v0]
        #
        # Locals:
	#   - $v0: char command
        #
        # Structure:
        #   read_char
        #   -> [prologue]
        #       -> body
        #   -> [epilogue]

read_char__prologue:

read_char__body:
	li	$v0, 12				# syscall 12: read_char
	syscall					# scanf("%c", &command);

read_char__epilogue:
	jr	$ra				# return command;

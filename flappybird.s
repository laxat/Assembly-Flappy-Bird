#####################################################################
#
# CSC258H5S Winter 2020 Assembly Programming Project
# University of Toronto Mississauga
#
# Group members:
# - Student 1: Richard Mba, 1005383764
# - Student 2: Mohammad Tahvili, 1005308926
#
# Bitmap Display Configuration:
# - Unit width in pixels: 8					     
# - Unit height in pixels: 8
# - Display width in pixels: 256
# - Display height in pixels: 256
# - Base Address for Display: 0x10008000 ($gp)
#
# Which milestone is reached in this submission?
# (See the assignment handout for descriptions of the milestones)
# - Milestone 5 
#
# Which approved additional features have been implemented?
# (See the assignment handout for the list of additional features)
# 1. Changing the game difficulty. As the game progresses further, 
#  gradually increase the moving speed of the obstacles to make the game more challenging.
# 2. Day and Night Cycle
# 3. Update Score ingame and display score in the end 
# ... (add more if necessary)
#
# Any additional information that the TA needs to know:
# - The best we could get to was 30, it gets too hard after
#
#####################################################################
.data
#Game Stuff
newline: .asciiz "\n"

#Screen Dimenstions 
screenWidth: .word 32
screenHeight: .word 32

#Colors
backgroundColor: .word 0x03fcfc
playerColor: .word 0xdffc03
pipeColor: .word 0x05e308

SkyBackgroud: .word 0x03fcfc
NightBackground: .word 0x011669

scoreBackColor: .word 0x121212
scoreColor: .word 0xffffff

lvl2Color: .word 0xfc2c03
lvl3Color: .word 0x0d36db
lvl4Color: .word 0x740ddb
lvl5Color: .word 0xdb0d77
lvlMaxColor: .word 0xf55105

#player body array 
playerBodyX: .word  4, 4, 4, 3, 2, 2, 2
playerBodyY: .word  15, 16, 14, 15, 15, 14, 16

#Player Position(relative-to-game)
playerX: .word 5
playerY: .word 15

Level: .word 1

#Pipe Position(relative-to-game)
PipeX: .word 20
PipeY: .word 20

#player direction(up-or-down)
direction: .word 119

#score Variable
score: .word 0

#sleep timer
frameSpeed: .word 200

.text 

main:

	lw $a0, screenWidth
	lw $a1, backgroundColor
	mul $a2, $a0, $a0
	mul $a2, $a2, 4
	add $a2,$a2 $gp
	add $a0, $gp, $zero
	
FillScreen: 
	beq $a0, $a2, Init
	sw $a1, 0($a0)
	addiu $a0, $a0, 4
	j FillScreen

Init: 
	li $t0, 5
	sw $t0, playerX
	li $t0, 15
	sw $t0, playerY
	li $t0, 119
	sw $t0, direction
	li $t0, 200
	sw $t0, frameSpeed
	li $t0, 0
	sw $t0, score
	li $t0, 1
	sw $t0, Level
	jal DrawScoreBorder
	jal DrawScore
	jal DrawSecondScore

##############################
#Draw initial player position
##############################

DrawPlayer:
	lw $a0, playerX
	lw $a1 playerY
	jal CoordinateOnScreen 
	move $a0, $v0
	lw $a2, playerColor
	jal DrawSprite
	
	la $t0, playerBodyX
	la $t1, playerBodyY
	
	lw $a0, playerX 
	lw $a1, playerY 
	add $a0, $a0, -1
	sw $a0, 0($t0)
	sw $a1, 0($t1)
	jal CoordinateOnScreen 
	move $a0, $v0 
	lw $a2, playerColor 
	jal DrawSprite	
	
	
	lw $a0, playerX
	lw $a1, playerY
	add $a0, $a0, -1
	add $a1, $a1, 1
	sw $a0, 4($t0)
	sw $a1, 4($t1)
	jal CoordinateOnScreen
	move $a0, $v0 
	lw $a2, playerColor
	jal DrawSprite
	
	
	lw $a0, playerX
	lw $a1, playerY
	add $a0, $a0, -1
	add $a1, $a1, -1
	sw $a0, 8($t0)
	sw $a1, 8($t1)
	jal CoordinateOnScreen
	move $a0, $v0 
	lw $a2, playerColor
	jal DrawSprite
	
	
	lw $a0, playerX
	lw $a1, playerY
	add $a0, $a0, -2
	sw $a0, 12($t0)
	sw $a1, 12($t1)
	jal CoordinateOnScreen
	move $a0, $v0 
	lw $a2, playerColor
	jal DrawSprite
	
	
	lw $a0, playerX
	lw $a1, playerY
	add $a0, $a0, -3
	sw $a0, 16($t0)
	sw $a1, 16($t1)
	jal CoordinateOnScreen
	move $a0, $v0 
	lw $a2, playerColor
	jal DrawSprite
	
	
	lw $a0, playerX
	lw $a1, playerY
	add $a0, $a0, -3
	add $a1, $a1, -1
	sw $a0, 20($t0)
	sw $a1, 20($t1)
	jal CoordinateOnScreen
	move $a0, $v0 
	lw $a2, playerColor
	jal DrawSprite
	
	
	lw $a0, playerX
	lw $a1, playerY
	add $a0, $a0, -3
	add $a1, $a1, 1
	sw $a0, 24($t0)
	sw $a1, 24($t1)	
	jal CoordinateOnScreen
	move $a0, $v0 
	lw $a2, playerColor
	jal DrawSprite
		
			
#####################
# Get key Input 
#####################

KeyInput: 
	lw $a0, frameSpeed
	li $v0, 32
	syscall
	
	jal SetDifficulty
	jal ClearScore
	jal DrawScoreBorder
	jal DrawScore
	jal DrawSecondScore
	
	lw $a0, playerX
	lw $a1, playerY
	jal CoordinateOnScreen
	add $a2, $v0, $zero 
	
	#get Key input
	li $t0, 0xffff0000
	lw $t1, ($t0)
	andi $t1, $t1, 1
	beqz $t1, DrawDirection
	lw $a1, 4($t0)
	
	
FlyCheck: 

	beqz $v0, KeyInput 
	sw $a1, direction 
	lw $t7, direction 

############################
# Update bird position 
############################

DrawDirection:  # Pressing flap key flap 
	beq $t7, 102, Flap
	jal Fall #not pressing flap key fall 
	j KeyInput #If the input is invalid
			
Flap:
	lw $a0, playerX
	lw $a1, playerY
	lw $a2, direction
	# Gonna check collision here 
	jal CheckCollision
	lw $t0, playerX
	lw $t1, playerY
	addiu $t1, $t1, -1
	add $a0, $t0, $zero
	add $a1, $t1, $zero
	jal CoordinateOnScreen 
	add $a0, $v0, $zero
	lw  $a2, playerColor
	jal DrawSprite 
	
	sw $t1, playerY
	
	lw $t0, playerX
	lw $t1, playerY
	addiu $t1, $t1, 1
	add $a0, $t0, $zero
	add $a1, $t1, $zero
	jal CoordinateOnScreen
	add $a0, $v0, $zero
	lw $a2, backgroundColor
	jal DrawSprite
	
	la $t3, playerBodyX
	la $t4, playerBodyY
	
	lw $t0, 0($t3)
	lw $t1, 0($t4)
	addiu $t1, $t1, -1
	add $a0, $t0, $zero
	add $a1, $t1, $zero
	jal CoordinateOnScreen 
	add $a0, $v0, $zero
	lw  $a2, playerColor
	jal DrawSprite
	
	sw $t1, 0($t4)
	
	lw $t0, 0($t3)
	lw $t1, 0($t4)
	addiu $t1, $t1, 1
	add $a0, $t0, $zero
	add $a1, $t1, $zero
	jal CoordinateOnScreen
	add $a0, $v0, $zero
	lw $a2, backgroundColor
	jal DrawSprite 
	
	
	lw $a0, 4($t3)
	lw $a1, 4($t4)
	lw $a2, direction
	jal CheckCollision
	lw $t0, 4($t3)
	lw $t1, 4($t4)
	addiu $t1, $t1, -1
	add $a0, $t0, $zero
	add $a1, $t1, $zero
	jal CoordinateOnScreen 
	add $a0, $v0, $zero
	lw  $a2, playerColor
	jal DrawSprite
	
	sw $t1, 4($t4)
	
	lw $t0, 4($t3)
	lw $t1, 4($t4)
	addiu $t1, $t1, 1
	add $a0, $t0, $zero
	add $a1, $t1, $zero
	jal CoordinateOnScreen
	add $a0, $v0, $zero
	lw $a2, backgroundColor
	jal DrawSprite 
	
	
	
	lw $a0, 8($t3)
	lw $a1, 8($t4)
	lw $a2, direction
	jal CheckCollision
	lw $t0, 8($t3)
	lw $t1, 8($t4)
	addiu $t1, $t1, -1
	add $a0, $t0, $zero
	add $a1, $t1, $zero
	jal CoordinateOnScreen 
	add $a0, $v0, $zero
	lw  $a2, playerColor
	jal DrawSprite
	
	sw $t1, 8($t4)
	
	lw $t0, 12($t3)
	lw $t1, 12($t4)
	
	addiu $t1, $t1, -1
	add $a0, $t0, $zero
	add $a1, $t1, $zero
	jal CoordinateOnScreen 
	add $a0, $v0, $zero
	lw  $a2, playerColor
	jal DrawSprite
	
	sw $t1, 12($t4)
	
	lw $t0, 12($t3)
	lw $t1, 12($t4)
	addiu $t1, $t1, 1
	add $a0, $t0, $zero
	add $a1, $t1, $zero
	jal CoordinateOnScreen
	add $a0, $v0, $zero
	lw $a2, backgroundColor
	jal DrawSprite 
	
	lw $t0, 16($t3)
	lw $t1, 16($t4)
	
	addiu $t1, $t1, -1
	add $a0, $t0, $zero
	add $a1, $t1, $zero
	jal CoordinateOnScreen 
	add $a0, $v0, $zero
	lw  $a2, playerColor
	jal DrawSprite
	
	sw $t1, 16($t4)
	
	lw $t0, 16($t3)
	lw $t1, 16($t4)
	addiu $t1, $t1, 1
	add $a0, $t0, $zero
	add $a1, $t1, $zero
	jal CoordinateOnScreen
	add $a0, $v0, $zero
	lw $a2, backgroundColor
	jal DrawSprite 
	
	lw $a0, 20($t3)
	lw $a1, 20($t4)
	lw $a2, direction
	jal CheckCollision
	lw $t0, 20($t3)
	lw $t1, 20($t4)
	addiu $t1, $t1, -1
	add $a0, $t0, $zero
	add $a1, $t1, $zero
	jal CoordinateOnScreen 
	add $a0, $v0, $zero
	lw  $a2, playerColor
	jal DrawSprite
	
	sw $t1, 20($t4)
	
	lw $a0, 24($t3)
	lw $a1, 24($t4)
	lw $a2, direction
	jal CheckCollision
	
	lw $t0, 24($t3)
	lw $t1, 24($t4)
	addiu $t1, $t1, -1
	add $a0, $t0, $zero
	add $a1, $t1, $zero
	jal CoordinateOnScreen 
	add $a0, $v0, $zero
	lw  $a2, playerColor
	jal DrawSprite
	
	sw $t1, 24($t4)
	
	lw $t0, 24($t3)
	lw $t1, 24($t4)
	addiu $t1, $t1, 1
	add $a0, $t0, $zero
	add $a1, $t1, $zero
	jal CoordinateOnScreen
	add $a0, $v0, $zero
	lw $a2, backgroundColor
	jal DrawSprite 
	
Continue:	
	j KeyInput
	
Fall:	
	
	jal CoordinateOnScreen
	lw $t1, 0($v0)
	lw $t2, pipeColor
	beq $t1, $t2, GameOver
	jal CheckCollision
	lw $t0, playerX
	lw $t1, playerY
	addiu $t1, $t1, 1
	
	add $a0, $t0, $zero
	add $a1, $t1, $zero
	jal CoordinateOnScreen 
	add $a0,$v0, $zero
	lw $a2, playerColor
	jal DrawSprite
	
	sw $t1, playerY
	
	lw $t0, playerX
	lw $t1, playerY
	addiu $t1, $t1, -1
	
	add $a0, $t0, $zero
	add $a1, $t1, $zero
	jal CoordinateOnScreen
	add $a0, $v0, $zero
	lw $a2, backgroundColor
	jal DrawSprite
	
	la $t3, playerBodyX
	la $t4, playerBodyY
	
	lw $a0, 0($t3)
	lw $a1, 0($t4)
	lw $a2, direction
	jal CheckCollision
	lw $t0, 0($t3)
	lw $t1, 0($t4)
	
	addiu $t1, $t1, 1
	add $a0, $t0, $zero
	add $a1, $t1, $zero
	jal CoordinateOnScreen 
	add $a0, $v0, $zero
	lw  $a2, playerColor
	jal DrawSprite
	
	sw $t1, 0($t4)
	
	lw $t0, 0($t3)
	lw $t1, 0($t4)
	addiu $t1, $t1, -1
	add $a0, $t0, $zero
	add $a1, $t1, $zero
	jal CoordinateOnScreen
	add $a0, $v0, $zero
	lw $a2, backgroundColor
	jal DrawSprite 
	
	
	
	lw $a0, 4($t3)
	lw $a1, 4($t4)
	lw $a2, direction
	jal CheckCollision
	
	lw $t0, 4($t3)
	lw $t1, 4($t4)
	addiu $t1, $t1, 1
	add $a0, $t0, $zero
	add $a1, $t1, $zero
	jal CoordinateOnScreen 
	add $a0, $v0, $zero
	lw  $a2, playerColor
	jal DrawSprite
	
	sw $t1, 4($t4)


	lw $a0, 8($t3)
	lw $a1, 8($t4)
	lw $a2, direction
	jal CheckCollision
	lw $t0, 8($t3)
	lw $t1, 8($t4)
	
	addiu $t1, $t1, 1
	add $a0, $t0, $zero
	add $a1, $t1, $zero
	jal CoordinateOnScreen 
	add $a0, $v0, $zero
	lw  $a2, playerColor
	jal DrawSprite
	
	sw $t1, 8($t4)
	
		
	lw $t0, 8($t3)
	lw $t1, 8($t4)
	addiu $t1, $t1, -1
	add $a0, $t0, $zero
	add $a1, $t1, $zero
	jal CoordinateOnScreen
	add $a0, $v0, $zero
	lw $a2, backgroundColor
	jal DrawSprite 
	
	lw $a0, 12($t3)
	lw $a1, 12($t4)
	lw $a2, direction
	jal CheckCollision
	lw $t0, 12($t3)
	lw $t1, 12($t4)
	
	addiu $t1, $t1, 1
	add $a0, $t0, $zero
	add $a1, $t1, $zero
	jal CoordinateOnScreen 
	add $a0, $v0, $zero
	lw  $a2, playerColor
	jal DrawSprite
	
	sw $t1, 12($t4)
	
	lw $t0, 12($t3)
	lw $t1, 12($t4)
	addiu $t1, $t1, -1
	add $a0, $t0, $zero
	add $a1, $t1, $zero
	jal CoordinateOnScreen
	add $a0, $v0, $zero
	lw $a2, backgroundColor
	jal DrawSprite 
	
	lw $a0, 16($t3)
	lw $a1, 16($t4)
	lw $a2, direction
	jal CheckCollision
	lw $t0, 16($t3)
	lw $t1, 16($t4)
	
	addiu $t1, $t1, 1
	add $a0, $t0, $zero
	add $a1, $t1, $zero
	jal CoordinateOnScreen 
	add $a0, $v0, $zero
	lw  $a2, playerColor
	jal DrawSprite
	
	sw $t1, 16($t4)
	
	lw $t0, 16($t3)
	lw $t1, 16($t4)
	addiu $t1, $t1, -1
	add $a0, $t0, $zero
	add $a1, $t1, $zero
	jal CoordinateOnScreen
	add $a0, $v0, $zero
	lw $a2, backgroundColor
	jal DrawSprite 
	
	lw $a0, 20($t3)
	lw $a1, 20($t4)
	lw $a2, direction
	jal CheckCollision
	lw $t0, 20($t3)
	lw $t1, 20($t4)
	
	addiu $t1, $t1, 1
	add $a0, $t0, $zero
	add $a1, $t1, $zero
	jal CoordinateOnScreen 
	add $a0, $v0, $zero
	lw  $a2, playerColor
	jal DrawSprite
	
	sw $t1, 20($t4)
	
	lw $t0, 20($t3)
	lw $t1, 20($t4)
	addiu $t1, $t1, -1
	add $a0, $t0, $zero
	add $a1, $t1, $zero
	jal CoordinateOnScreen
	add $a0, $v0, $zero
	lw $a2, backgroundColor
	jal DrawSprite
	
	lw $a0, 24($t3)
	lw $a1, 24($t4)
	lw $a2, direction
	jal CheckCollision
	lw $t0, 24($t3)
	lw $t1, 24($t4)
	
	addiu $t1, $t1, 1
	add $a0, $t0, $zero
	add $a1, $t1, $zero
	jal CoordinateOnScreen 
	add $a0, $v0, $zero
	lw  $a2, playerColor
	jal DrawSprite
	
	sw $t1, 24($t4)
	
	j KeyInput
		
############################
# Check Collision 
############################
CheckCollision: 
	add $t7, $a0, $zero
	add $t8, $a1, $zero
	sw  $ra, 0($sp)
	
	beq $a2, 102, FlapCheck
	bne $a2, 102, FallCheck
	jal LeftCheck
	jal RightCheck
	
	
FlapCheck: 
	addiu $a1, $a1, -1
	jal UpBound
	jal CoordinateOnScreen
	lw $t1, 0($v0)
	lw $t2, pipeColor
	beq $t1, $t2, GameOver
	#lw $a1, playerY
	jal CoordinateOnScreen
	lw $t1, 0($v0)
	lw $t2, pipeColor
	beq $t1, $t2, GameOver
	jal LeftCheck
	jal RightCheck
	j CollisionDone 
	
FallCheck: 
	
	jal DownBound
	jal CoordinateOnScreen
	lw $t1, 0($v0)
	lw $t2, pipeColor
	beq $t1, $t2, GameOver
	move $t8, $a1
	addiu $a1, $a1, 2
	#lw $a1, playerY
	#jal DownBound 
	jal CoordinateOnScreen
	lw $t1, 0($v0)
	lw $t2, pipeColor
	beq $t1, $t2, GameOver
	j CollisionDone
	
LeftCheck:
	addiu $a0, $a0, -1
	jal CoordinateOnScreen
	lw $t1, 0($v0)
	lw $t2, pipeColor
	beq $t1, $t2, GameOver
	j CollisionDone 

RightCheck:
	addiu $a0, $a0, 1
	jal CoordinateOnScreen
	lw $t1, 0($v0)
	lw $t2, pipeColor
	beq $t1, $t2, GameOver
	j CollisionDone 	
CollisionDone: 
	lw $ra 0($sp)
	jr $ra 

UpBound:
	li $t1, -3
	beq $t1, $a1, GameOver

DownBound:
	lw, $t1, screenHeight
	add, $t1, $t1, 3
	beq $a1, $t1, GameOver
	
############################################
# Get addriess of the reference coordinates
############################################	

CoordinateOnScreen: 
	lw $v0, screenWidth
	mul $v0, $v0, $a1
	add $v0, $v0, $a0
	mul $v0, $v0, 4
	add $v0, $v0, $gp
	jr $ra
	
###############################
# Draw Pixel on Screen
###############################
DrawSprite:
	sw $a2, ($a0)
	jr $ra

#############################
# Draw Game Over Screen
#############################
SetDifficulty:
	
	lw $t1, score
	
	#beq $t1, 100, GameOver
	blt  $t1, 10, LevelOne
	blt $t1, 30, LevelTwo
	blt $t1, 50, LevelThree
	blt $t1, 70, LevelFour
	blt $t1, 90, LevelFive
	bge $t1, 90, LevelMax
	
LevelOne:
	
	sw $ra 16($sp)
	
	li $t1, -2
	move $t1, $a3
	jal DrawPipe
	
	j EndLevel

LevelTwo:
	sw $ra 16($sp)
	
	lw $t1, lvl2Color
	sw $t1, pipeColor
	
	lw $t2, Level
	li $t3, 2
	move $t2, $t3
	sw $t2, Level
	
	jal DrawLevel
	
	jal DrawPipe
	jal DrawPipe
	j EndLevel

LevelThree:
	sw $ra 16($sp)
	
	lw $t1, lvl3Color
	sw $t1, pipeColor
	
	lw $t2, Level
	li $t3, 3
	move $t2, $t3
	sw $t2, Level
	
	jal DrawLevel
	
	jal DrawPipe
	jal DrawPipe
	jal DrawPipe
	j EndLevel	

LevelFour:
	sw $ra 16($sp)
	
	lw $t1, lvl4Color
	sw $t1, pipeColor
	
	lw $t2, Level
	li $t3, 4
	move $t2, $t3
	sw $t2, Level
	
	jal DrawLevel
	
	jal DrawPipe
	jal DrawPipe
	jal DrawPipe
	jal DrawPipe
	j EndLevel

LevelFive:

	sw $ra 16($sp)
	
	lw $t1, lvl5Color
	sw $t1, pipeColor
	
	lw $t2, Level
	li $t3, 5
	move $t2, $t3
	sw $t2, Level
	
	jal DrawLevel
	
	jal DrawPipe
	jal DrawPipe
	jal DrawPipe
	jal DrawPipe
	jal DrawPipe
	j EndLevel
	
LevelMax:

	sw $ra 16($sp)
	
	lw $t1, lvlMaxColor
	sw $t1, pipeColor
	
	lw $t2, Level
	li $t3, 5
	move $t2, $t3
	sw $t2, Level
	
	jal DrawLevel
	
	jal DrawPipe
	jal DrawPipe
	jal DrawPipe
	jal DrawPipe
	jal DrawPipe
	j EndLevel

EndLevel:
	lw $ra 16($sp)
	jr $ra


DrawLevel:
	
	lw $t3, Level 
	
	beq $t3, 1, DrawlvlOne
	beq $t3, 2, DrawlvlTwo
	beq $t3, 3, DrawlvlThree 
	beq $t3, 4, DrawlvlFour
	beq $t3, 5, DrawlvlFive

DrawlvlOne:
	 sw $ra 20($sp)
	 
	 lw $t1, SkyBackgroud
	 sw $t1, backgroundColor
	 jal ClearBoard
	 
	 lw $ra 20($sp)
	 jr $ra

DrawlvlTwo:
	
	sw $ra 20($sp)
	 
	lw $t1, NightBackground
	sw $t1, backgroundColor
	jal ClearBoard
	 
	lw $ra 20($sp)
	jr $ra

DrawlvlThree:
	sw $ra 20($sp)
	 
	lw $t1, SkyBackgroud
	sw $t1, backgroundColor
	jal ClearBoard
	 
	lw $ra 20($sp)
	jr $ra

DrawlvlFour:
	
	sw $ra 20($sp)
	 
	lw $t1, NightBackground
	sw $t1, backgroundColor
	jal ClearBoard
	 
	lw $ra 20($sp)
	jr $ra
	
DrawlvlFive:
	
	sw $ra 20($sp)
	 
	lw $t1, NightBackground
	sw $t1, backgroundColor
	jal ClearBoard
	 
	lw $ra 20($sp)
	jr $ra
		
GameOver:
	jal ClearBoard
	jal DrawScore
	jal DrawSecondScore
	
	li $a0, 7
	li $a1, 13
	lw $a2, playerColor
	li $a3, 20
	jal DrawY
	
	li $a0, 7
	li $a1, 20
	li $a3, 10
	jal DrawX
	
	li $a0, 10
	li $a1, 17
	li $a3, 20
	jal DrawY
	
	li $a0, 7
	li $a3, 10
	jal DrawX
	
	li $a0, 13
	li $a1, 17
	li $a3, 20
	jal DrawY
	
	li $a0, 13
	li $a1, 20
	li $a3, 16
	jal DrawX
	
	li $a0, 16
	li $a1, 17
	li $a3, 25
	jal DrawY
	
	li $a0, 13
	li $a1, 25
	li $a3, 16
	jal DrawX
	
	li $a0, 19
	li $a1, 13
	li $a3, 20
	jal DrawY
	
	li $a0, 19
	li $a1, 13
	li $a3, 22
	jal DrawX
	
	li $a0, 19
	li $a1, 16
	li $a3, 22
	jal DrawX
	
	li $a0, 19
	li $a1, 20
	li $a3, 22
	jal DrawX
	
	li $a0, 25
	li $a1, 13
	li $a3, 18
	jal DrawY
	
	li $a0, 25
	li $a1, 20
	li $a3, 20
	jal DrawY
	
	j Exit	


DrawY:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	sub $t9, $a3, $a1
	move $t1, $a1
	move $t2, $a0
	
	YLoop:
		move $a0, $t2
		add $a1, $t1, $t9
		
		jal CoordinateOnScreen
		move $a0, $v0
		jal DrawSprite
		
		addi $t9, $t9, -1
		
		bge $t9, 0, YLoop
		
		lw $ra, 0($sp)
		addi $sp, $sp, 4
		jr $ra
DrawX:

	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	sub $t9, $a3, $a0
	move $t1, $a0
	move $t2, $a0
	
	XLoop:
		move $a0, $t2
		add $a0, $t1, $t9
		
		jal CoordinateOnScreen
		move $a0, $v0
		jal DrawSprite
		
		addi $t9, $t9, -1
		
		bge $t9, 0, XLoop
		
		lw $ra, 0($sp)
		addi $sp, $sp, 4
		jr $ra
				
#######################
#Clear Game Board
#######################
ClearBoard:
	lw $t0, screenWidth
	lw $t1, backgroundColor
	mul $t2, $t0, $t0
	mul $t2, $t2, 4
	add $t2,$t2 $gp
	add $t0, $gp, $zero	
FillLoop: 
	beq $t0, $t2, EndLoop
	sw $t1, 0($t0)
	addiu $t0, $t0, 4
	j FillLoop
EndLoop:
	jr $ra
	
DrawScoreBorder:

	sw $ra 24($sp)
	
	li $a0, 19
	li $a1, 3
	lw $a2, pipeColor
	li $a3, 29
	jal DrawX
	
	li $a0, 19
	li $a1, 9
	li $a3, 29
	jal DrawX
	
	li $a0, 19
	li $a1, 3
	li $a3, 9
	jal DrawY
	
	li $a0, 29
	li $a1, 3
	li $a3, 9
	jal DrawY
	
	lw $ra 24($sp)
	jr $ra
	
DrawScore:
	
	sw $ra 0($sp)
	lw $t1, score
	#beq $t1, 100, DrawNine
	li $t2, 10
	div $t1, $t2
	mflo $t3
	
	
	beqz $t3, DrawZero
	beq $t3, 1, DrawOne
	beq $t3, 2, DrawTwo
	beq $t3, 3, DrawThree 
	beq $t3, 4, DrawFour
	beq $t3, 5, DrawFive
	beq $t3, 6, DrawSix
	beq $t3, 7, DrawSeven
	beq $t3, 8, DrawEight
	bge $t3, 9, DrawNine 
	
	
DrawSecondScore:
	
	sw $ra 16($sp)
	lw $t1, score
	li $t2, 10
	div $t1, $t2
	mfhi $t3
	
	bge  $t1, 100, DrawNine2
	
	beqz $t3, DrawZero2
	beq $t3, 1, DrawOne2
	beq $t3, 2, DrawTwo2
	beq $t3, 3, DrawThree2 
	beq $t3, 4, DrawFour2
	beq $t3, 5, DrawFive2
	beq $t3, 6, DrawSix2
	beq $t3, 7, DrawSeven2
	beq $t3, 8, DrawEight2
	beq $t3, 9, DrawNine2 
	
ClearScore:
	sw $ra 4($sp)
	li $a0, 20
	li $a1, 4
	lw $a2, scoreBackColor
	li $a3, 28
	jal DrawX
	
	li $a0, 20
	li $a1, 5
	li $a3, 28
	jal DrawX
	
	li $a0, 20
	li $a1, 6
	li $a3, 28
	jal DrawX
	
	li $a0, 20
	li $a1, 7
	li $a3, 28
	jal DrawX
	
	li $a0, 20
	li $a1, 8
	li $a3, 28
	jal DrawX
	
	j FinDraw
FinDraw:
	lw $ra 4($sp)
	jr $ra 

#################################
# Draw First Numbers for Score
#################################
DrawZero:
	sw $ra 12($sp)
	li $a0, 20
	li $a1, 4
	lw $a2, scoreColor
	li $a3, 23
	jal DrawX
	
	li $a0, 20
	li $a1, 8
	li $a3, 23
	jal DrawX
	
	li $a0, 20
	li $a1, 4
	li $a3, 8
	jal DrawY
	
	li $a0, 23
	li $a1, 4
	li $a3, 8
	jal DrawY
	
	j EndDraw

DrawOne:
	sw $ra 12($sp)
	
	li $a0, 21
	li $a1, 4
	lw $a2, scoreColor
	li $a3, 8
	jal DrawY 
	
	li $a0, 20
	li $a1, 8
	li $a3, 22
	jal DrawX
	
	li $a0, 20
	li $a1, 4
	li $a3, 21
	jal DrawX
	
	j EndDraw
	
DrawTwo:
	sw $ra 12($sp)
	
	li $a0, 20
	li $a1, 4
	lw $a2, scoreColor
	li $a3, 23
	jal DrawX
	
	li $a0, 23
	li $a1, 4
	li $a3, 6
	jal DrawY
	
	li $a0, 20
	li $a1, 6
	li $a3, 23
	jal DrawX
	
	li $a0, 20
	li $a1, 6
	li $a3, 8
	jal DrawY
	
	li $a0, 20
	li $a1, 8
	li $a3, 23
	jal DrawX
	
	j EndDraw
	

DrawThree:
	
	sw $ra 12($sp)
	
	li $a0, 20
	li $a1, 4
	lw $a2, scoreColor
	li $a3, 23
	jal DrawX
	
	li $a0, 23
	li $a1, 4
	li $a3, 8
	jal DrawY
	
	li $a0, 20
	li $a1, 6
	li $a3, 23
	jal DrawX
	
	li $a0, 20
	li $a1, 8
	li $a3, 23
	jal DrawX
	
	j EndDraw

DrawFour:
	
	sw $ra 12($sp)
	
	li $a0, 20
	li $a1, 4
	lw $a2, scoreColor
	li $a3, 7
	jal DrawY
	
	li $a0, 20
	li $a1, 7
	li $a3, 23
	jal DrawX
	
	li $a0, 22
	li $a1, 6
	li $a3, 8
	jal DrawY
	
	j EndDraw
	
	
DrawFive:

	sw $ra 12($sp)
	
	li $a0, 20
	li $a1, 4
	lw $a2, scoreColor
	li $a3, 23
	jal DrawX
	
	li $a0, 20
	li $a1, 4
	li $a3, 6
	jal DrawY
	
	li $a0, 20
	li $a1, 6
	li $a3, 23
	jal DrawX
	
	li $a0, 23
	li $a1, 6
	li $a3, 8
	jal DrawY
	
	li $a0, 20
	li $a1, 8
	li $a3, 23
	jal DrawX
	
	j EndDraw
	

DrawSix:
	sw $ra 12($sp)
	
	li $a0, 20
	li $a1, 4
	lw $a2, scoreColor
	li $a3, 23
	jal DrawX
	
	li $a0, 20
	li $a1, 4
	li $a3, 8
	jal DrawY
	
	li $a0, 20
	li $a1, 6
	li $a3, 23
	jal DrawX
	
	li $a0, 23
	li $a1, 6
	li $a3, 8
	jal DrawY
	
	li $a0, 20
	li $a1, 8
	li $a3, 23
	jal DrawX
	
	j EndDraw	

DrawSeven:
	
	sw $ra 12($sp)
	
	li $a0, 20
	li $a1, 4
	lw $a2, scoreColor
	li $a3, 23
	jal DrawX
	
	li $a0, 20
	li $a1, 4
	li $a3, 8
	jal DrawY
	
	j EndDraw
	
DrawEight:
	sw $ra 12($sp)
	
	li $a0, 20
	li $a1, 4
	lw $a2, scoreColor
	li $a3, 23
	jal DrawX
	
	li $a0, 20
	li $a1, 6
	li $a3, 23
	jal DrawX
	
	li $a0, 20
	li $a1, 8
	li $a3, 23
	jal DrawX
	
	li $a0, 20
	li $a1, 4
	li $a3, 8
	jal DrawY
	
	li $a0, 23
	li $a1, 4
	li $a3, 8
	jal DrawY
	
	j EndDraw

DrawNine:
	sw $ra 12($sp)
	
	li $a0, 20
	li $a1, 4
	lw $a2, scoreColor
	li $a3, 23
	jal DrawX
	
	li $a0, 20
	li $a1, 6
	li $a3, 23
	jal DrawX
	
	li $a0, 20
	li $a1, 8
	li $a3, 23
	jal DrawX
	
	li $a0, 20
	li $a1, 4
	li $a3, 6
	jal DrawY
	
	li $a0, 23
	li $a1, 4
	li $a3, 8
	jal DrawY
	
	j EndDraw

EndDraw:
	lw $ra 12($sp)
	jr $ra
	
################################
# Draw Second Number For Score
################################

DrawZero2:
	sw $ra 20($sp)
	
	li $a0, 25
	li $a1, 4
	lw $a2, scoreColor
	li $a3, 28
	jal DrawX
	
	li $a0, 25
	li $a1, 8
	li $a3, 28
	jal DrawX
	
	li $a0, 25
	li $a1, 4
	li $a3, 8
	jal DrawY
	
	li $a0, 28
	li $a1, 4
	li $a3, 8
	jal DrawY
	
	j EndDraw2

DrawOne2:
	sw $ra 20($sp)
	
	li $a0, 26
	li $a1, 4
	lw $a2, scoreColor
	li $a3, 8
	jal DrawY 
	
	li $a0, 25
	li $a1, 8
	li $a3, 27
	jal DrawX
	
	li $a0, 25
	li $a1, 4
	li $a3, 26
	jal DrawX
	
	j EndDraw2

DrawTwo2:
	sw $ra 20($sp)
	
	li $a0, 25
	li $a1, 4
	lw $a2, scoreColor
	li $a3, 28
	jal DrawX
	
	li $a0, 28
	li $a1, 4
	li $a3, 6
	jal DrawY
	
	li $a0, 25
	li $a1, 6
	li $a3, 28
	jal DrawX
	
	li $a0, 25
	li $a1, 6
	li $a3, 8
	jal DrawY
	
	li $a0, 25
	li $a1, 8
	li $a3, 28
	jal DrawX
	
	j EndDraw2
	
	
DrawThree2:
	
	sw $ra 20($sp)
	
	li $a0, 25
	li $a1, 4
	lw $a2, scoreColor
	li $a3, 28
	jal DrawX
	
	li $a0, 28
	li $a1, 4
	li $a3, 8
	jal DrawY
	
	li $a0, 25
	li $a1, 6
	li $a3, 28
	jal DrawX
	
	li $a0, 25
	li $a1, 8
	li $a3, 28
	jal DrawX
	
	j EndDraw2

DrawFour2:
	
	sw $ra 20($sp)
	
	li $a0, 25
	li $a1, 4
	lw $a2, scoreColor
	li $a3, 7
	jal DrawY
	
	li $a0, 25
	li $a1, 7
	li $a3, 28
	jal DrawX
	
	li $a0, 27
	li $a1, 6
	li $a3, 8
	jal DrawY
	
	j EndDraw2
	
DrawFive2:

	sw $ra 20($sp)
	
	li $a0, 25
	li $a1, 4
	lw $a2, scoreColor
	li $a3, 28
	jal DrawX
	
	li $a0, 25
	li $a1, 4
	li $a3, 6
	jal DrawY
	
	li $a0, 25
	li $a1, 6
	li $a3, 28
	jal DrawX
	
	li $a0, 28
	li $a1, 6
	li $a3, 8
	jal DrawY
	
	li $a0, 25
	li $a1, 8
	li $a3, 28
	jal DrawX
	
	j EndDraw2

DrawSix2:
	sw $ra 20($sp)
	
	li $a0, 25
	li $a1, 4
	lw $a2, scoreColor
	li $a3, 28
	jal DrawX
	
	li $a0, 25
	li $a1, 4
	li $a3, 8
	jal DrawY
	
	li $a0, 25
	li $a1, 6
	li $a3, 28
	jal DrawX
	
	li $a0, 28
	li $a1, 6
	li $a3, 8
	jal DrawY
	
	li $a0, 25
	li $a1, 8
	li $a3, 28
	jal DrawX
	
	j EndDraw2	

DrawSeven2:
	
	sw $ra 20($sp)
	
	li $a0, 25
	li $a1, 4
	lw $a2, scoreColor
	li $a3, 28
	jal DrawX
	
	li $a0, 28
	li $a1, 4
	li $a3, 8
	jal DrawY
	
	j EndDraw2

DrawEight2:
	sw $ra 20($sp)
	
	li $a0, 25
	li $a1, 4
	lw $a2, scoreColor
	li $a3, 28
	jal DrawX
	
	li $a0, 25
	li $a1, 6
	li $a3, 28
	jal DrawX
	
	li $a0, 25
	li $a1, 8
	li $a3, 28
	jal DrawX
	
	li $a0, 25
	li $a1, 4
	li $a3, 8
	jal DrawY
	
	li $a0, 28
	li $a1, 4
	li $a3, 8
	jal DrawY
	
	j EndDraw2

DrawNine2:
	sw $ra 20($sp)
	
	li $a0, 25
	li $a1, 4
	lw $a2, scoreColor
	li $a3, 28
	jal DrawX
	
	li $a0, 25
	li $a1, 6
	li $a3, 28
	jal DrawX
	
	li $a0, 25
	li $a1, 8
	li $a3, 28
	jal DrawX
	
	li $a0, 25
	li $a1, 4
	li $a3, 6
	jal DrawY
	
	li $a0, 28
	li $a1, 4
	li $a3, 8
	jal DrawY
	
	j EndDraw2

EndDraw2:
	lw $ra 20($sp)
	jr $ra

##############################
#Draw pipe position
##############################

DrawPipe:
	f: addi $sp, $sp, -12 
	sw $ra, 8($sp)
	
	lw $t0, PipeY
	lw $t1, PipeX
	lw $t2, screenHeight
	lw $t3, screenWidth
	
	li $t4, 0 # y coordination counter
		
	Y_AXIS:	
		
		li $t5, 0 # x coordination counter
		
		X_AXIS:	
			
			#making sure the new line would not pass screenWidth
			add $t6, $t1, $t5
			beq $t3, $t6, OUTBOUND
			
			beq  $t4, $t0, SKIP
			
			#if we reached the y-coordinate of pipe openning then we want to skip 8 unit
			bgez $t0, NORMAL
			SKIP:
				add $t4, $t4, 8

			NORMAL: 
				
				#removing the previous last column
				beq $t5, 3, REMOVE
				bltz  $t1, ERASE
				j ADD
				
				REMOVE:
					#jal DrawZero
					lw $a0, PipeX
					li $a1, 0
					add $a0, $a0, $t5
					add $a1, $a1, $t4
					jal CoordinateOnScreen 
					move $a0, $v0 
					lw $a2, backgroundColor
					jal DrawSprite
					j OUTBOUND
					
				ADD:
					lw $a0, PipeX
					li $a1, 0
					add $a0, $a0, $t5
					add $a1, $a1, $t4
					jal CoordinateOnScreen 
					move $a0, $v0 
					lw $a2, pipeColor
					jal DrawSprite
					
					add $t5, $t5, 1 #add to x-coordinate counter
					beq $t5, 4, OUTBOUND #check to see if this is the last column of pipe line
					j X_AXIS
					
				ERASE:
					
					lw $a0, PipeX
					li $a1, 0
					add $a0, $a0, 3
					add $a1, $a1, $t4
					jal CoordinateOnScreen 
					move $a0, $v0 
					lw $a2, backgroundColor
					jal DrawSprite
					j OUTBOUND

		OUTBOUND:
			
			add $t4, $t4, 1
			beq $t4, $t3, DONE
			j Y_AXIS

	DONE:
	add $t1, $t1, -1
	
	lw $t7, playerX
	addi $t8, $t1, 3
	bne  $t7, $t8, ScoreFin
	
	AddScore:
				
	lw $t9, score
	addi $t9, $t9, 1
	sw $t9, score
	
	jal Ring	
	j ScoreFin
		
	ScoreFin:
	
	sw $t1, PipeX
	beq $t1, -4, RESET
	j NOCHANGE
	
	RESET:
	
	addiu $t1, $t1, 32
	sw $t1, PipeX
	
	#Create a random number
	sub $a1, $t2, 8
    	li $v0, 42 
    	add $a0, $a0, 8
    	syscall 
	sw $a0, PipeY
    	
	lw $ra, 8($sp)
	addi $sp, $sp, 12
	jr $ra
	
	NOCHANGE:
	
	lw $ra, 8($sp)
	addi $sp, $sp, 12
		
	jr $ra	
	
Ring:
	
	li $v0, 31
	li $a0, 79
	li $a1, 120
	li $a2, 7
	li $a3, 50
	syscall	
	
	li $v0, 1
	jr $ra
	
############################################
# Increase Difficulty
############################################	

Exit: 
	li $v0, 10
	syscall 

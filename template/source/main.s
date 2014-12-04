/*
	When linking to 'gpio' pass arguments for
	'r0 <= address / pinNum'
	'r1 <= function / value'
*/

.section .init
.globl main

main:
	b program_init
	nop
	
.section .text

program_init:
	mov sp,#0x8000			@;setup stack pointer
	mov r0,#1024
	mov r1,#768
	mov r2,#16				@;set up messsages to frame func
	bl Init_Frame_Buffer
	teq r0, #0				@;test the return value
	bne Frame_Buffer_OK		@;If branch, we have frame buffer OK'd
	mov r0, #16
	mov r1, #1
	bl SetGpioFunction
	mov r0, #16
	mov r1, #0
	bl SetGpio
	ERROR$:				@;If we hit this, then there
		b ERROR$		@;Was some kind of error, check gdb
Frame_Buffer_OK:
	fbInfoAddr .req r4
	mov fbInfoAddr,r0
	bl SetGraphicsAddress
	
	lastRandom .req r7
	lastX .req r8
	lastY .req r9
	color .req r10
	x .req r5
	y .req r6
	mov lastRandom,#0
	mov lastX,#0
	mov r9,#0
	mov r10,#0
render$:
	mov r0,lastRandom
	bl Random
	mov x,r0
	bl Random
	mov y,r0
	mov lastRandom,r0

	mov r0,color
	add color,#1
	lsl color,#16
	lsr color,#16
	bl SetForeColor
		
	mov r0,lastX
	mov r1,lastY
	lsr r2,x,#22
	lsr r3,y,#22

	cmp r3,#768
	bhs render$
	
	mov lastX,r2
	mov lastY,r3
	 
	bl DrawLine

	b render$

	.unreq x
	.unreq y
	.unreq lastRandom
	.unreq lastX
	.unreq lastY
	.unreq color
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	//SAVE THE FOLLOWING FOR FUTURE
	Frame_Buffer_Info .req r4
	mov Frame_Buffer_Info, r0	@;
	Screen_Draw:
		Frame_Addres .req r3
		ldr Frame_Addres,[Frame_Buffer_Info,#32]
		pixle .req r0
		y .req r1
		x .req r2
		mov y, #768
		ROW$:
			mov x, #1024
			PIX$:							@;This loop will draw the coloum
				strh pixle,[Frame_Addres]	@; of pixels as it moves across the x vector
				add Frame_Addres,#2			@; then test if its at the end, and decriment y
				sub x, #1					@; then start again
				teq x, #0
				bne PIX$					
			sub y, #1
			add pixle, #1
			teq y, #0
			bne ROW$
		b Screen_Draw

	.unreq Frame_Addres
	.unreq Frame_Buffer_Info
	nop
	pinNum .req r0		@;alias these two pins
	pinFunc .req r1		
	mov pinNum,#16		@;select pin number 16
	mov pinFunc,#1		@;set pin function number 1
	bl SetGpioFunction	@;link to set function
	.unreq pinNum		@;unalias these two pins
	.unreq pinFunc

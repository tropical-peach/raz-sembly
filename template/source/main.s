/*
	When linking to 'gpio' pass arguments for
	'r0 <= address / pinNum'
	'r1 <= function / value'
*/

.section .init
.globl _start

_start:
	b main
	nop
	
.section .text

main:
	mov sp,#0x8000		@;setup stack pointer
	mov r0,#1024
	mov r1,#768
	mov r2,#16			@;set up messsages to frame func
	bl Init_Frame_Buffer
	teq r0, #0			@;test the return value
	bne N
	pinNum .req r0		@;alias these two pins
	pinFunc .req r1		
	mov pinNum,#16		@;select pin number 16
	mov pinFunc,#1		@;set pin function number 1
	bl SetGpioFunction	@;link to set function
	.unreq pinNum		@;unalias these two pins
	.unreq pinFunc
loop$:
	pinNum .req r0		@;alias these two pins
	pinVal .req r1		@;
	mov pinNum,#16		@;set pin 16
	mov pinVal,#0		@;select function 0
	bl SetGpio
	.unreq pinNum		@;unalias
	.unreq pinVal
	nop					@;nops
	nop

	ldr r0,=100000		@;delay of 100000us
	bl TimeDelay		@;timedelay link
	nop

	mov r0, #16			@;set pin 16
	mov r1, #1			@;set to high
	bl SetGpio 			@;pass to GPIO
	nop					@;to turn LED on

	ldr r0,=100000		@;delay of 100000us
	bl TimeDelay 		@;execute delay
	

	@'Repeat program'
	b loop$
	nop




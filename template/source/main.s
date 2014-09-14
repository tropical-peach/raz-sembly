/*
	When linking to 'gpio' pass arguments for
	'r0 <= address / pinNum'
	'r1 <= function / value'
*/

.section .init
.globl _start
_start:
	b main

.section .text
main:
	mov sp,#0x8000		@setup stack pointer
	pinNum .req r0		@alias these two pins
	pinFunc .req r1		
	mov pinNum,#16		@select pin number 16
	mov pinFunc,#1		@set pin function number 1
	bl SetGpioFunction	@link to set function
	.unreq pinNum		@unalias these two pins
	.unreq pinFunc
	
	
loop$:
	pinNum .req r0		@alias these two pins
	pinVal .req r1		@
	mov pinNum,#16		@set pin 16
	mov pinVal,#0		@select function 0
	bl SetGpio
	.unreq pinNum		@unalias
	.unreq pinVal
	nop					@nops
	nop

	decr .req r0		@'this is a pointless function'
	mov decr,#0x3F0000	@'that kills time by looping'
wait1$: 
	sub decr,#1
	teq decr,#0
	bne wait1$
	.unreq decr

	pinNum .req r0
	pinVal .req r1
	mov pinNum,#16
	mov pinVal,#1
	bl SetGpio
	.unreq pinNum
	.unreq pinVal

	/*
	* Wait once more.
	*/
	decr .req r0
	mov decr,#0x3F0000
wait2$:
	sub decr,#1
	teq decr,#0
	bne wait2$
	.unreq decr

	@'Repeat program'
	b loop$
	nop

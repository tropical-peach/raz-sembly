.globl GetGpioAddress
GetGpioAddress:
	ldr r0,=0x20200000	;GPIO starting adress
	mov pc,lr			;lr always contains the return adress, (link register)
	
.globl SetGpioFunction
SetGpioFunction:		
	cmp r0,#53			;compares r0 to 53, if true then next command runs
	cmpls r1,#7			;only runs if previous is true
	movhi pc,lr			;if pc > lr then pc = lr
	nop					;HI C set and Z clear Higher (unsigned >)
	push {lr}			;puts lr to top of the stack
	mov r2,r0			;move right to left (r0 -> r2)
	bl GetGpioAddress	
	
	
functionLoop$:
	cmp r2,#9			;compare r2 = 9
	subhi r2,#10		;if r2>9, r2-10
	addhi r0,#4			;r0 + 4
	bhi functionLoop$	;This would be the same as GPIO Controller Address + 4 × (GPIO Pin Number ÷ 10).
	add r2, r2,lsl #1	;One of the very useful features of the ARMv6 assembly code language is the ability to shift an argument before using it. 
	nop					;In this case, I add r2 to the result of shifting the binary representation of r2 to the left by one place.
	lsl r1,r2			;
	str r1,[r0]			;
	pop {pc}			;Only general purpose registers and pc can be popped.

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
	push {lr}			
	mov r2,r0
	bl GetGpioAddress

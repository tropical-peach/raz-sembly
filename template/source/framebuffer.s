@;This function will be our fram buffer for the screen
@; There is not much documentation on what the GPU should 
@; return, other than that it will return '0' if the
@; information is in the correct syntax/ able to be processed
@;This function will be our fram buffer for the screen
@; There is not much documentation on what the GPU should 
@; return, other than that it will return '0' if the
@; information is in the correct syntax/ able to be processed

.section
.data
.align 4

.globl GPU_Frame_Buffer_Data
GPU_Frame_Buffer_Data:	
	.int 1024	@; physical width
	.int 768	@; physical height
	.int 1024	@; frame width
	.int 768	@; frame height
	.int 0		@; GPU Pitch
	.int 16		@; Bit Depth
	.int 0		@; X
	.int 0		@; Y
	.int 0		@;GPU Pointer
	.int 0		@;GPU SIZE

.section 
.text

.globl Init_Frame_Buffer
Init_Frame_Buffer:
	wdith .req r0
	height .req r1
	bitDepth .req r3
	cmp width,#4096			@;Compares w,h, and bD to their 
	cmpls height, #4096		@; wanted values to ensure that they are at least less than
	cmpls bitDepth, #32		@; the value given. 
	result .req r0
	movhi result, #0		@;Using the conditional Execution
	movhi pc, lr			@; we can ensure that they are all correct
	nop						@; and return if not
	FrameInfo .req r4
	push {r4, lr}			@; push r4 and the link register on to the stack
	ldr FrameInfo, =GPU_Frame_Buffer_Data
	str width, [r4,#0]
	str height,[r4,#4]
	str width, [r4,#8]
	str height,[r4,#12]
	str bidDepth,[r4,#20]	@;this will write into the frame data struct
	nop						@;the values that we pass into this function
	.unreq height
	.unreq width
	.unreq bitDepth
	nop
	mov r0, FrameInfo
	add r0, #0x40000000 	@;adding this to r0 tells the GPU to give us all of the data
	mov r1,#1				@;these two registers are the mailbox value and the Lane arguments
	bl MailboxWrite
	mov r0, #1				@;same as above, but to read
	bl MailboxRead			
	teq result, #0			@;checsk to see if the GPU "likes" our data
	movne	result, #0		@;if not we return zero and return
	popne	{r4, pc}		@; pop in same order that was pushed (sends lr to pc)
	mov result, FrameInfo	@;returns the FrameInfo struct if equal
	.unreq result
	.unreq FrameInfo	
	pop {r4, pc}			@;pop off in same order, and send lr to pc


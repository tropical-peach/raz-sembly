/* 
* According to the EABI, all method calls should use r0-r3 for passing
* parameters, should preserve registers r4-r8,r10-r11,sp between calls, and 
* should return values in r0 (and r1 if needed). 
* It does also stipulate many things about how methods should use the registers
* and stack during calls, but we're using hand coded assembly. All we need to 
* do is obey the start and end conditions, and if all our methods do this, they
* would all work from C.
*/

/* 
* GetGpioAddress returns the base address of the GPIO region as a physical address
* in register r0.
* C++ Signature: void* GetGpioAddress()
*/
.globl GetGpioAddress
GetGpioAddress: 
	gpioAddr .req r0
	ldr gpioAddr,=0x20200000
	mov pc,lr
	.unreq gpioAddr

/* 
* SetGpioFunction sets the function of the GPIO register addressed by r0 to the
* low  3 bits of r1.
* C++ Signature: void SetGpioFunction(u32 gpioRegister, u32 function)
*/
.globl SetGpioFunction
SetGpioFunction:
    pinNum .req r0
    pinFunc .req r1
	cmp pinNum,#53
	cmpls pinFunc,#7
	movhi pc,lr

	push {lr}
	mov r2,pinNum
	.unreq pinNum
	pinNum .req r2
	bl GetGpioAddress
	gpioAddr .req r0

	functionLoop$:
		cmp pinNum,#9
		subhi pinNum,#10
		addhi gpioAddr,#4
		bhi functionLoop$

	add pinNum, pinNum,lsl #1
	lsl pinFunc,pinNum

	mask .req r3
	mov mask,#7					@;r3 = 111 in binary */
	lsl mask,pinNum				@;r3 = 11100..00 where the 111 is in the 
	nop 						@;same position as the function in r1 */
	.unreq pinNum

	mvn mask,mask				@;r3 = 11..1100011..11 where the 000 is in 
	nop 						@;the same poisiont as the function in r1 */
	oldFunc .req r2
	ldr oldFunc,[gpioAddr]		@;r2 = existing code */
	and oldFunc,mask			@;r2 = existing code with bits for this pin all 0 */
	.unreq mask

	orr pinFunc,oldFunc			@;r1 = existing code with correct bits set */
	.unreq oldFunc

	str pinFunc,[gpioAddr]
	.unreq pinFunc
	.unreq gpioAddr
	pop {pc}

/* 
* SetGpio sets the GPIO pin addressed by register r0 high if r1 != 0 and low
* otherwise. 
* C++ Signature: void SetGpio(u32 gpioRegister, u32 value)
*/
.globl SetGpio
SetGpio:	
    pinNum .req r0
    pinVal .req r1

	cmp pinNum,#53
	movhi pc,lr
	push {lr}
	mov r2,pinNum	
    .unreq pinNum	
    pinNum .req r2
	bl GetGpioAddress
    gpioAddr .req r0

	pinBank .req r3
	lsr pinBank,pinNum,#5
	lsl pinBank,#2
	add gpioAddr,pinBank
	.unreq pinBank

	and pinNum,#31
	setBit .req r3
	mov setBit,#1
	lsl setBit,pinNum
	.unreq pinNum

	teq pinVal,#0
	.unreq pinVal
	streq setBit,[gpioAddr,#40]
	strne setBit,[gpioAddr,#28]
	.unreq setBit
	.unreq gpioAddr
	pop {pc}


.globl GetMailBoxLocation
GetMailBoxLocation:
	ldr r0, =0x2000B880
	mov pc,lr

@;This function  takes input from
@;register r0 and a mailbox to write to from 
@;register r1.
@;It must validate the mailbox by checking the low 4 bits
@;are zero.
@; 	Gets mailbox base; read status field, check top bit is
@;		zero. write it to the channel after validating.

.globl MailboxWrite
MailboxWrite:
	tst r0, #0b1111 	@;tst => and reg,#val and compare with 0
	movne pc, lr 		@;Go back if it fails
	cmp r1, #15 		@;check r1 for = 15
	movhi pc, lr  		@;
	nop					
	Lane .req r1
	Value .req r2
	mov Value, r0		@;send r0 to the value
	push {lr}			@;save link register 
	bl GetGpioAddress	@;get the gpio adress
	mailbox .req r0		@;alias r0 to mailbox
DeltaT:					@;Make sure that the top bit is zero
	status .req r3		@;alias r3 to status
	ldr status,[mailbox,#0x18]	@;load register mailbox w/ 0x18 offset to status
	tst status,#0x80000000		@;test status to value
	.unreq status				@;if not equal loop
	bne DeltaT						
	add Value, Lane				@;sum value with lane
	.unreq Lane							
	str Value,[mailbox,#0x20]	@;write the value into the mailbox lane
	.unreq mailbox
	pop {pc}					@; return from the function

@; This function is similar in that it reads from a 
@;	mailbox (r0) and must be validated
@; It reads the status field and validsates the 30th bit to ensure
@; that it is zero. It then wil read the field and check if it is the
@;  correct mailbox, ottherwise loop.

.globl MailboxRead
MailboxRead:
	cmp r0, #15
	movhi pc,lr 			@;validates, otherwise return
	Lane .req r1			@;alias Lane to r1
	mov Lane, r0			@;coppies r0 to lane
	push {lr}				@;save link register
	bl GetMailBoxLocation 	@;Go and get mailbox memory lock
	mailbox .req r0			@;r0 should now contain mem lock, so alias it
Correct_Mailbox:
	nop
DeltaT2:
	status .req r2 				@;alias r2
	ldr status,[mailbox,#0x18]	@;load register with mailbox,#0x18
	tst status,#0x40000000		@;test if status has correct value
	.unreq status 				@;unalias
	bne DeltaT2 				@;if its not correct, loop back
	mail_inbox .req r2
	ldr mail_inbox,[mailbox,#0]	@;get the mail
	in_Lane .req r2
	and in_Lane,mail_inbox,#0b1111	@;and mail with b'1111
	teq in_Lane, Lane 			@;test if resule is equal to Lane
	.unreq in_Lane				
	bne Correct_Mailbox			@;if its not, loop back and try again
	.unreq mailbox
	.unreq Lane
	and r0,mail_inbox,#0xfffffff0	@;take the mail and put it into the result reg
	.unreq mail_inbox
	pop {pc}

	

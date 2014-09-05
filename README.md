						Steven Rad- Seppala
						Raz-semmbly project


Install the toolchain from the tar file included.

Inside the template folder is the assembly code and make file to compile it into a kernel 
to be used with the r-pi.

	Make sure to export the path so the makefile can be used correctly.
-----------------------------------------------------------------------------------------


Reference PDF's are included, ARM reference manuel seems to be more helpful than the ARM-ARM.

The documentation is written from the perspective of the gpu where the base address in that processors address space
for peripherals starts at 0x7E000000. The arm and gpu share quite a bit, memory and peripheral access, but the
peripherals are mapped into the ARM's address space starting at 0x20000000.

Basically wherever in that document you see 0x7Exxxxxx for some thing you want to program from the ARM replace that 
with 0x20xxxxxx. It is that simple


-----------------------------------------------------------------------------------------



	The following is borowed from 
	https://github.com/dwelch67/raspberrypi/blob/master/README


---- connecting to the uart pins ----

On the raspberry pi, the connector with two rows of a bunch of pins is
P1.  Starting at that corner of the board, the outside corner pin is
pin 2.  From pin 2 heading toward the yellow rca connector the pins
are 2, 4, 6, 8, 10.  Pin 6 connect to gnd on the usb to serial board
pin 8 is TX out of the raspi connect that to RX on the usb to serial
board.  pin 10 is RX into the raspi, connect that to TX on the usb to
serial board.  Careful not to have metal items on the usb to serial
board touch metal items on the raspberry pi (other than the three
connections described).  On your host computer you will want to use
some sort of dumb terminal program, minicom, putty, etc.  Set the
serial port (usb to serial board) to 115200 baud, 8 data bits, no
parity, 1 stop bit.  NO flow control.  With minicom to get no flow
control you normally have to save the config, exit minicom, then
restart minicom and load the config in order for flow control
changes to take effect.  Once you have a saved config you dont have
to mess with it any more.

	2  outer corner
	4
	6  ground
	8  TX out
	10 RX in

ground is not necessarily needed if both the raspberry pi and the
usb to serial board are powered by the same computer (I recommend
you do that) as they will ideally have the same ground.

	The above is borowed from 
	https://github.com/dwelch67/raspberrypi/blob/master/README

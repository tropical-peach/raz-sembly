						Steven Rad- Seppala
						Raz-semmbly project


Install the toolchain from the tar file included.

Inside the template folder is the assembly code and make file to compile it into a kernel 
to be used with the r-pi.

Make sure to export the path so the makefile can be used correctly.
-----------------------------------------------------------------------------------------


Reference PDF's are included, ARM reference manuel seems to be more helpful than the ARM-ARM.

	The documentation is written from the perspective of the gpu where the base address in that processors address space for peripherals starts at 0x7E000000. The arm and gpu share quite a bit, memory and peripheral access, but the peripherals are mapped into the ARM's address space starting at 0x20000000.

	Basically wherever in that document you see 0x7Exxxxxx for some thing you want to program from the ARM replace that with 0x20xxxxxx. It is that simple

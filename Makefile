#------------------------------------------------------------------------------>
#
#	Filename:	Makefile#
# 	Author: 	Jacob Petriella 
# 	Email: 		aeycos@gmail.com
# 	Desfription:	--
# 	Last Updated:	06/21/2017
#
#------------------------------------------------------------------------------>
#----------------------------/ Build Settings /-------------------------------->

	#----------/ Assembler Settings /-----
	AS	:= nasm
	AFLAGS	:= -f elf -o

	#----------/ C Compiler Settings /----
	CC	:= gcc
	CFLAGS	:= -Wall -nostdlib -c -m32 -o

	#----------/ C++ Compiler Settigs /---
	CXX	:= g++
	CXXFLAGS:= -Wall -nostdlib -I$(INCDIR) -c -m32 -o

	#----------/ Linker Settings /--------
	LD 	:= ld
	LFLAGS	:= -T linker.ld -m elf_i386 -o

#
#----------------------------/ I/O Settings /---------------------------------->
#

	TARGET	:= aesycos
	
	#----------/ Directories /------------
	OBJDIR	:= build
	INC	:= include
	FOLDERS := boot fs include
	
	#----------/ Files /------------------
	SRCS	:= $(wildcard */*.s) $(wildcard */*.cpp)
	OBJS	:= $(SRCS:%.s=%.o) $(SRCS:%.cpp=%.o)

all: floppy.img stage1.bin stage1_5.bin $(OBJS)
	@echo "|----|     Complete     |---->"


floppy.img: stage1.bin stage1_5.bin
	@echo "Installing bootstrap to disk image..."
	@dd if=stage1.bin of=floppy.img bs=512 conv=notrunc
	@echo "Installing stage 1.5 loader..."
	@dd if=stage1_5.bin of=floppy.img bs=512 seek=1 conv=notrunc


clean: $(OBJS) stage1.bin stage1_5.bin
	rm -rf $<
stage1.bin: boot/boot.o
	@echo "|----| Building STAGE 1 |---->"
	@echo "Linking" $<
	@$(LD) $(LFLAGS) $@ $< 

stage1_5.bin: boot/stage1_5.o
	@echo "|---| Building STAGE 1.5 |--->"
	@$(LD) $(LFLAGS) $@ $<
	
%.o: %.s
	@echo "Assembling " $<
	@$(AS) $(AFLAGS) $@ $<


%.o: %.c
	@echo "Compiling " $<
	@$(CC) $(CFLAGS) $@ $<
	
%.o: %.cpp
	@echo "Compiling " $<
	@$(CXX) $(CXXFLAGS) $@ $<

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
	AFLAGS	:= -f elf

	#----------/ Linker Settings /--------
	LD 	:= ld
	LFLAGS	:= -T ../linker.ld -m elf_i386

#
#----------------------------/ I/O Settings /---------------------------------->
#

	PARTS	:= stage1 stage1_5
	#----------/ Directories /------------
	OBJDIR	:= ../build/boot
	INCDIR	:= ../include

	#----------/ Input Files /------------
	SRCS	:= $(wildcard *.s)

	#----------/ Output /-----------------
	OBJS	:=  $(SRCS:%.s=$(OBJDIR)/%.o)

#
#----------------------------/ Build All /------------------------------------->
#

all: stage1 stage1_5

tidy: all
	rm -rf $(OBJDIR)/*.o

clean:
	@echo 'Cleaning up...'
	rm -rf $(OBJDIR)/*

remake: clean all

$(OBJDIR)/%.o: %.s
	@echo 'AS ' $<
	@$(AS) $(AFLAGS) $< -o $@

stage1: $(OBJDIR)/boot.o
	@echo '### Linking stage1    ###'
	@echo 'LD ' $<
	@$(LD) $(LFLAGS) $< -o $(OBJDIR)/$@

stage1_5: $(OBJDIR)/stage1_5.o
	@echo '### Linking stage1_5  ###'
	@echo 'LD ' $<
	@$(LD) $(LFLAGS) $< -o $(OBJDIR)/$@

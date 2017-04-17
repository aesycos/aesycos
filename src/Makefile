# Makefile for Aesycos
# Author: Jacob Petriella 
# Email: aeycos@gmail.com
#

TARGET  = aesycos

AS	= nasm
AFLAGS	= -f elf

CC	= gcc
CFLAGS 	= -Wall -nostdlib -c

LD	= ld
LFLAGS 	= -T linker.ld -m elf_i386

SOURCES	= boot.s stage1_5.s
OBJECTS	= boot.o floppy.img stage1 stage1_5.o stage1_5
VPATH 	= boot

all: $(TARGET)
	@true

clean:
	@echo "Cleaning build files..."
	@echo "RM " $(OBJECTS)
	@rm -f $(OBJECTS) stage1
	@sudo losetup -d /dev/loop0

aesycos: floppy.img stage1 stage1_5 loop0

stage1: boot.s
	@echo "AS " $<
	@$(AS) $(AFLAGS) -o boot.o $<
	@$(LD) $(LFLAGS) -o $@ boot.o
	@echo "Installing stage1 into bootsector of floppy.img..."
	@dd if=$@ of=floppy.img conv=notrunc

stage1_5: stage1_5.s
	@echo "AS " $<
	@$(AS) $(AFLAGS) -o stage1_5.o $<
	@$(LD) $(LFLAGS) -o $@ stage1_5.o
	@echo "Installing stage1_5 into bootsector of floppy.img..."
	@dd if=$@ of=floppy.img seek=1 conv=notrunc

floppy.img:
	@echo "Creating floppy image..."
	@dd if=/dev/zero of=$@ bs=512 count=2880
	@sudo mkfs.vfat -R 3 -F 12 -h 0 -f 2 -v -n "AESYCOS    " -r 244 -s 1 -S 512 $@

loop0: floppy.img
	@echo "Setting up loopback device " $< " as /dev/" $@
	@sudo losetup /dev/$@ $<
	@echo
	@echo "Creating mount diretory..." 
	@mkdir -p mnt
	@echo "Mounting image..."
	@sudo mount /dev/$@ -o loop mnt/
	@echo "Creating boot directory..."
	@sudo mkdir mnt/boot
	@echo "Copying stage2 into boot directory..."
	@sudo cp stage2 mnt/boot/
	@echo "Unmounting filesystem..."
	@sudo umount mnt
	@echo "Cleaning up..."
	@sudo rm -rf mnt
	@sudo losetup -d /dev/$@



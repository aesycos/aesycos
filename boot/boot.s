bits 16

global start
start:  jmp loader


;###############################################################################
;
; Boot Parameter Block
;
;###############################################################################
;db 0x00
bpbOEM:			db "AesycOS "
bpbSectorSize:		dw 0x200	; 512 bytes per sector
bpbClusterSize:		db 0x01		;
bpbReservedSectors:	dw 0x0003	; 1 reserved sector for boot code
bpbNumberOfFATs:	db 0x02		; main fat and 1 copy
bpbRootEntries:		dw 0x00e0	; 224 entries		
bpbTotalSectors:	dw 0x0b40	; 2880 sectors
bpbMedia:		db 0xf0
bpbFATSize:		dw 0x0009
bpbTrackSize:		dw 0x0012	; 18 sectors per track
bpbHeads:		dw 0x0002
bpbHidden:		dd 0x00000000
bpbBigSectors:		dd 0x00000000

bsDrive:		db 0x00
bsUnused:		db 0x00
bsExtBootSignature:	db 0x29		; DOS 4.1+ Fat12
bsSerialNumber:		dd 0x10061cff
bsVolumeLabel:		db "AesycOS    "
bsFileSystem:		db "Fat12   "

;###############################################################################
;
; Local Functions
;
;###############################################################################

;
; printString() - prints a null terminated string ponted to by DS:SI
;
;-------------------------------------------------------------------------------

printString:
	lodsb			; load one byte of msg pointed to by SI
	or	al, al		; check for null terminator
	jz	.done		; if end of string return to caller
	mov	ah, 0x0e	; 
	int	0x10
	jmp	printString
	.done:
		ret

;
; readSector() - reads sectors from disk
;		CX = # of sectors to read
;		AX = Starting Sector
;		ES:BX = Buffer to read to
;
;-------------------------------------------------------------------------------
readSectors:
	.main:
		mov	di, 0x0005
	.sectorloop:
		push	ax
		push	bx
		push	cx
		call	lbaCHS		; convert starting sector to CHS
		mov	ax, 0x0201	; BIOS Read sector, 1 sectors
		mov	ch, byte [absTrack]
		mov	cl, byte [absSect]
		mov	dh, byte [absHead]
		mov	dl, byte [bsDrive]
		int	0x13
		jnc	.success
		xor	ax, ax
		int	0x13
		dec	di
		pop	cx
		pop	bx
		pop	ax
		jnz	.sectorloop
		int	0x18
	.success:
		mov	si, msgProgress
		call	printString
		pop	cx
		pop	bx
		pop	ax
		add	bx, word [bpbSectorSize]	; queue next buffer
		inc	ax			; queue nexxt sector
		loop	.main			; read next sector
		ret

;
; lbaCHS() - converts LBA to CHS
;           AX = LBA
;
;-------------------------------------------------------------------------------

lbaCHS:
    xor dx,dx
    div word [bpbTrackSize] ; divide by sectors per track
    inc dl                  ; add 1 (abs sector formula)
    mov byte [absSect], dl  
    
    xor dx, dx
    div word [bpbHeads]     ; modulus by number of heads
    mov byte [absHead], dl  ; quotient is absHead
    mov byte [absTrack], al ; remainder is absTrack
    ret

dataseg:  	dw 0x07c0
stackseg: 	dw 0x07e0
stacksize: 	dw 0x0400
stage15: 	dw 0x0500

loader:
    cli
    xor		ax, ax
    mov		ax, 0x7c00	
    mov 	ds, ax
    mov		es, ax
    mov 	fs, ax
    mov 	gs, ax
    
    mov		ax, ax
    mov		ss, ax

    mov 	ax, 0xffff
    mov 	sp, ax
    sti
    
    mov 	si, msgStage1
    call 	printString

    mov		bx, word [stage15]
    call 	readSectors
    mov 	si, msg2
    call 	printString
   
    push	word 0x0000
    push	word [stage15]
    retf

cluster  dw 0x0000
absTrack db 0x00
absSect  db 0x00
absHead  db 0x00
msgStage1 db "Stage1 Loaded!", 0x0d, 0x0a, 0x00
msg2 db "!!!", 0x0d, 0x0a, 0x00
msgProgress db ".", 0x00
times 510-($-$$)	db 0x00
bootSignature		dw 0xAA55

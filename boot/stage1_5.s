[bits 16h]
global start

start:
jmp main

;---------------------------------------+
; puts( word string.address )		|
; Input: Stack				|
; push location os string on stack	|
;---------------------------------------+

puts:
	push	bp
	mov	bp, sp
	mov	si, [bp+4]
	.mloop:
		lodsb			; load byte at SI in al
		or al, al		; check for null terminator
		jz .done			; exit
		mov	ah, 0x0e	; set print chr function 0Eh
		int	0x10		; call video bios
		jmp	.mloop
		.done:
			pop bp
			ret 2

;-----------------------+
; putc( byte char ) :	|
; Input: Stack		|
; push char on stack	|
;-----------------------+

putc:
	push	bp
	mov	bp, sp
	
	push	ax
	mov	al, [bp+4]
	mov	ah, 0x0e
	int	0x10
	
	pop	ax
	pop	bp
	ret 2

cmd_buf	dd 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0 

cmd_prompt: db "> ", 0x00

main:
	cli
	mov	ax, 0x0050
	mov	ds, ax
	mov	es, ax
	mov	fs, ax
	mov	gs, ax
	sti

	mov  ax, string
	push ax
	call puts

	mov	ax, cmd_prompt
	push	ax
	call puts

	jmp $

exclude:
	call EnableVGAmode

	; push length and height
	mov	ax, 128	; length
	mov	bx, 32	; height
	push	ax
	push	bx
	
	;set x, y, color
	mov	ax, 20
	mov	bx, 20
	mov	dx, 10100b
	call	DrawBox

	mov	ax, 50
	mov	bx, 50
	mov	dx, 0
	call 	DrawPalette
	
	mov	ax, 0	; xpos
	mov	bx, 0	; ypos
	mov	cx, 320	; length
	push	cx
	mov	cx, 8	; height
	push	cx
	mov	dx, 1
	call 	DrawFilledBox

	jmp $

DrawFilledBox:
	push	bp
	mov	bp, sp
	mov	cx, [bp+4] ; height
	.fill:
		push	bx
		push	cx
		mov	cx, [bp+6]	
		call	DrawHoriz
		pop	cx
		pop	bx
		loop	.fill
	pop	bp
	ret 4

DrawBox:
	push	bp
	mov	bp, sp
	
	push	ax	; xpos
	push	bx	; ypos
	
	; draw top line
	mov	cx, [bp+6] ; length
	call	DrawHoriz

	
	; draw right line
	dec	ax
	mov	cx, [bp+4] ; height
	call	DrawVert

	; return to top-left corner
	pop	ax
	pop	bx
	
	; draw left
	mov	cx, [bp+4] ; height
	call	DrawVert

	; draw bottom
	mov	cx, [bp+6]
	call 	DrawHoriz
	
	pop	bp
	ret	4


	

DrawHoriz:
	push	ax
	push	bx
	push	dx
	call	DrawPixel
	inc	ax
	loop	DrawHoriz
	ret

DrawVert:	
	push	ax		; xpos
	push	bx		; ypos
	push	dx		; color
	call	DrawPixel	;
	inc	bx
	loop	DrawVert
	ret


	

DrawPalette:
	push	ax
	mov cx, 0x10
	.drawRow:
		push ax
		push bx
		push dx
		call DrawPixel
		inc dx	; color
		inc ax	; xpos
		loop .drawRow
	
	pop ax
	inc bx		; ypos
	cmp dx, 0x100	; color
	jb DrawPalette
	ret

AllColors dw 0x0100
ColorsPerRow dw 0x0010

EnableVGAmode:
	mov ax,0x13            	; vga mode 320x200x8bit
	int 0x10               	; callBios( 0x10 )
	ret                    	; return

DrawPixel:                    	; 3 Variables on Stack
	push bp                	; Save Stack
	mov bp,sp              	;

	push ax                	;
	push bx                	;
	push cx                	;
	push dx                	; Save Stack

	mov ah,0x0C 	       	; writePixel Function
	mov al,[bp+4] 	       	; al = colorIndex
	mov bh,0x00 	       	; page number
	mov cx,[bp+8]	       	; cx = x
	mov dx,[bp+6]	       	; dx = y pos
	int 0x10	        ; callBIOS( 0x10 )

	pop dx                 	; Restore Stack
	pop cx                 	;
	pop bx                 	;
	pop ax                 	;

	pop bp                 	; Restore Stack
	ret 6                  	; return

string: db "Welcome to Bootloader Stage 1.5.1", 0x0D, 0x0A, "Assembled September 17th 2017 by aesycos", 0x0D, 0x0A, 0x00

Pad:
    times (0x2000 - ($ - $$)) db 0x00

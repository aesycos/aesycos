bits 16
global start
jmp start

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

start:
    cli
    push cs
    pop ds
    mov ax, ds ;0x0050
    mov es, ax
    mov fs, ax
    mov gs, ax
    sti
    
    mov si, msgStage15
    call printString

	mov bx,cs         ;put codesegment to bx
        add bh,0x20       ;add 2000 to bx
        mov ds,bx         ;and put it to ds
        mov ax,0x13       ;set ax to videomode 13
        int 10h           ;and do that
Main:   push ds           ;put buffer seg to stack
        pop es            ;and put that into es
        in ax,0x40        ;generate "random" number (timer)
        shl ax,4          ;multiply random # with 16
        mov di,ax         ;box offset (random)
        mov al,255        ;color of the box
        mov bx,50         ;height=50
pl:     add di,270        ;di+270 (320-width(50))
        mov cx,50         ;# bytes to copy to buffer
        rep stosb         ;and do it
        dec bx            ;decrement bx
        jnz pl            ;jump if bx not zero
        mov bh,0xFA       ;assume bl = 0 (-> bx = FA00)
Smudge: mov al,[bx+1]     ;right color to al
        mov cl,[bx-1]     ;left color to cl
        add ax,cx         ;and add it to ax
        mov cl,[bx-320]   ;upper color to cl
        add ax,cx         ;and add it to ax
        mov cl,[bx+320]   ;lower color to cl
        add ax,cx         ;and add it to ax
        shr ax,2          ;divide with 4
        mov [bx],al       ;and but the avarage color to buffer
        dec bx            ;decrement bx
        jnz Smudge        ;jump if bx not zero
        mov ax,0xA000     ;vga seg
        mov es,ax         ;put it to es
        mov ch,0xFA       ;# bytes to copy to vga
        xor di,di         ;zero vga offset
        xor si,si         ;zero buffer offset
        rep movsb         ;and do that
        in al,0x60        ;check for keys
        dec al            ;was it esc?
        jnz Main          ;nope, continue
        mov ax,3          ;text mode
        int 10h           ;get back into text mode
        xor ah,ah         ;yes, return to OS
        int 0x18          ;back to good old kernel

msgStage15 db "In the beginning God created the Heaven and the Earth.", 0x0d, 0x0a, 0x00

times 1024-($-$$) db 0x00
    

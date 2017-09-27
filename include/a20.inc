;*******************************************************************************
;
;	filename:	a20.inc
;	description:	Enable the A20 gate
;	date:		June-4-2017
;
;*******************************************************************************

%ifndef __A20_INC_1234567890ABCDEF1234_INCLUDED__
%define __A20_INC_1234567890ABCDEF1234_INCLUDED__

bits	16

enableA20:

; test a20
    call   testA20
    mov    ax, [a20]
    cmp    ax, 0x01

; methods
    je     .success
    cmp     cx, 0x0000
    je      a20bios
    cmp     cx, 0x0001
    je      a20KbCtrl
    cmp     cx, 0x0002
    je      fastA20
    cmp     cx, 0x0003
    je      a20Fail
    jmp     .main
    
    call a20bios
    mov     ax, [a20]
    cmp     ax, 0x01
    je      .success

    call testa20

    call
 
check_a20:
    pushf
    push ds
    push es
    push di
    push si
 
    cli
 
    xor ax, ax ; ax = 0
    mov es, ax
 
    not ax ; ax = 0xFFFF
    mov ds, ax
 
    mov di, 0x0500
    mov si, 0x0510
 
    mov al, byte [es:di]
    push ax
 
    mov al, byte [ds:si]
    push ax
 
    mov byte [es:di], 0x00
    mov byte [ds:si], 0xFF
 
    cmp byte [es:di], 0xFF
 
    pop ax
    mov byte [ds:si], al
 
    pop ax
    mov byte [es:di], al
 
    mov ax, 0
    je check_a20__exit
 
    mov ax, 1
 
check_a20__exit:
    pop si
    pop di
    pop es
    pop ds
    popf
 
    ret
    
enable_A20:
        cli
 
        call    a20wait
        mov     al,0xAD
        out     0x64,al
 
        call    a20wait
        mov     al,0xD0
        out     0x64,al
 
        call    a20wait2
        in      al,0x60
        push    eax
 
        call    a20wait
        mov     al,0xD1
        out     0x64,al
 
        call    a20wait
        pop     eax
        or      al,2
        out     0x60,al
 
        call    a20wait
        mov     al,0xAE
        out     0x64,al
 
        call    a20wait
        sti
        ret
 
a20wait:
        in      al,0x64
        test    al,2
        jnz     a20wait
        ret
 
 
a20wait2:
        in      al,0x64
        test    al,1
        jz      a20wait2
        ret

in al, 0x92
or al, 2
out 0x92, al

use16
mov     ax,2403h                ;--- A20-Gate Support ---
int     15h
jb      a20_ns                  ;INT 15h is not supported
cmp     ah,0
jnz     a20_ns                  ;INT 15h is not supported
 
mov     ax,2402h                ;--- A20-Gate Status ---
int     15h
jb      a20_failed              ;couldn't get status
cmp     ah,0
jnz     a20_failed              ;couldn't get status
 
cmp     al,1
jz      a20_activated           ;A20 is already activated
 
mov     ax,2401h                ;--- A20-Gate Activate ---
int     15h
jb      a20_failed              ;couldn't activate the gate
cmp     ah,0
jnz     a20_failed              ;couldn't activate the gate
 
a20_activated:                  ;go on



enabled db 0x00

%endif ;__A20_INC_1234567890ABCDEF1234_INCLUDED__

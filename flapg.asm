%define WIDTH     320
%define HEIGHT    200
%define VGA_MEM   0xA000
%define VGA_SIZE  64000 ; 320*200
%define GRAVITY   1
%define JUMP_POW  20
%define BIRD_SIZE 10
%define BIRD_X    30
%define BIRD_COL  0
%define BG_COL    2

; Enter VGA mode
; 320x200x8-bits/pixel
mov ax, 0x13
int 0x10

game_loop:
	; TODO: handle keyboard, just loop forever for now
    call clear_screen
	call draw_bird
	jmp game_loop

clear_screen:
    mov ax, VGA_MEM
    mov es, ax
    mov bx, 0
	clear_screen_inner:
        mov BYTE [es:bx], BG_COL
        inc bx
        cmp bx, VGA_SIZE
        jb clear_screen_inner
    ret

; TODO: drawing single pixel atm, need to loop for BIRD_SIZE
draw_bird:
    mov ax, VGA_MEM
    mov es, ax
    mov BYTE [es:10*WIDTH+BIRD_X], BIRD_COL
	ret

bird_y: dw 100 ; starting bird y position
bird_dy: dw 0  ; starting bird y velocity

times 510 - ($-$$) db 0
dw 0xaa55

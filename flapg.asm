org 0x7C00 ; offset to bootloader address range

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

; Enter VGA mode, 320x200 x 8-bits per pixel
mov ax, 0x13
int 0x10

; Store VGA memory address in es segment register
mov ax, VGA_MEM
mov es, ax

game_loop:
	; TODO: handle keyboard, just loop forever for now
    call clear_screen
	call draw_bird
	jmp game_loop

clear_screen:
    mov bx, 0
	clear_screen_inner:
        mov BYTE [es:bx], BG_COL
        inc bx
        cmp bx, VGA_SIZE
        jb clear_screen_inner
    ret

; TODO: drawing single row atm, need to loop for BIRD_SIZE
draw_bird:
	mov word [x], 0
    
	draw_bird_row:
    	mov bx, WIDTH
    	mov ax, [bird_y]
    	mul bx
		add ax, [x]
    	mov bx, ax
        mov BYTE [es:bx+BIRD_X], BIRD_COL
    
    	inc word [x]
    	cmp word [x], BIRD_SIZE
    	jl  draw_bird_row
	ret

; global variables
x:       dw   0  ; used whenever we want to loop over x
y:       dw   0  ; used whenever we want to loop over y
bird_y:  db 100  ; starting bird y position
bird_dy: db   0  ; starting bird y velocity

; pad to 510 bytes and output bootloader magic value
times 510 - ($-$$) db 0
dw 0xaa55

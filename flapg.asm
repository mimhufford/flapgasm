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

; Make game run using the system timer
; by pointing interrupt 1C to game_loop
mov dword [0x70], game_loop

; Stay here forever, game_loop will run on timer
jmp $

game_loop:
    ; Store VGA memory address in segment register
    mov ax, VGA_MEM
    mov es, ax

	; TODO: handle keyboard - int 16
    ; TODO: collide with floor

    ; Apply gravity
	mov ax, GRAVITY
	add word [bird_dy], ax
	mov ax, [bird_dy]
	add word [bird_y], ax

	; TODO: can maybe weld these in now?
    call clear_screen
	call draw_bird
    iret ; return from interrupt

clear_screen:
    mov bx, 0
	clear_screen_inner:
        mov byte [es:bx], BG_COL
        inc bx
        cmp bx, VGA_SIZE
        jb clear_screen_inner
    ret

draw_bird:
	mov word [y], 0
	draw_bird_row:
	    mov word [x], 0
		draw_bird_col:
        	mov bx, WIDTH
        	mov ax, [bird_y]
			add ax, [x]
        	mul bx
    		add ax, [y]
        	mov bx, ax
            mov byte [es:bx+BIRD_X], BIRD_COL

			inc word [x]
			cmp word [x], BIRD_SIZE
			jl  draw_bird_col
    
    	inc word [y]
    	cmp word [y], BIRD_SIZE
    	jl  draw_bird_row
	ret

; global variables
x:       dw   0  ; used whenever we want to loop over x
y:       dw   0  ; used whenever we want to loop over y
bird_y:  dw 100  ; starting bird y position
bird_dy: dw   0  ; starting bird y velocity

; pad to 510 bytes and output bootloader magic value
times 510 - ($-$$) db 0
dw 0xaa55

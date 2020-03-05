org 0x7C00 ; offset to bootloader address range

%define WIDTH        320
%define HEIGHT       200
%define VGA_MEM      0xA000
%define VGA_SIZE     64000 ; 320*200
%define GRAVITY      2
%define JUMP_POW     20
%define BIRD_START_Y 75
%define BIRD_SIZE    10
%define BIRD_X       30
%define BIRD_COL     0
%define BG_COL       2

; Enter VGA mode, 320x200 x 8-bits per pixel
mov ax, 0x13
int 0x10

; Make game run using the system timer
; by pointing interrupt 1C to game_loop
mov dword [0x70], game_loop

; Stay here forever, game_loop will run on timer
input_loop:
	; Check if key was pressed
    mov ah, 1
    int 0x16
	; If no key was pressed loop back around
    jz input_loop
	; Otherwise, remove the event from the buffer
	mov ah, 0
	int 0x16
	; FLAP!
    sub word [bird_dy], JUMP_POW
    jmp input_loop

game_loop:
    ; Store VGA memory address in segment register
    mov ax, VGA_MEM
    mov es, ax

    ; Apply gravity
	mov ax, GRAVITY
	add word [bird_dy], ax
	mov ax, [bird_dy]
	add word [bird_y], ax

	;TODO: obstacles

    ; Check for collision with top and bottom
	cmp word [bird_y], HEIGHT
	jg  did_collide
    cmp word [bird_y], 0
	jl  did_collide
	jmp didnt_collide

	did_collide:
        mov word [bird_y], BIRD_START_Y
    	mov word [bird_dy], 0
    didnt_collide:

    ; Clear screen
    xor bx, bx
	clear_screen_inner:
        mov byte [es:bx], BG_COL
        inc bx
        cmp bx, VGA_SIZE
        jb clear_screen_inner
    
    ; Draw bird
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
            ; Advance col loop
            inc word [x]
            cmp word [x], BIRD_SIZE
            jl  draw_bird_col
        ; Advance row loop
        inc word [y]
        cmp word [y], BIRD_SIZE
        jl  draw_bird_row

    ; Return from interrupt
    iret

; Global variables
x:       dw   0          ; used whenever to loop over x
y:       dw   0          ; used whenever to loop over y
bird_y:  dw BIRD_START_Y ; starting bird y position
bird_dy: dw   0          ; starting bird y velocity

; Pad to 510 bytes and output bootloader magic value
times 510 - ($-$$) db 0
dw 0xaa55

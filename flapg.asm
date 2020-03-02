mov ah, 0x0e

mov al, 'F'
int 0x10
mov al, 'l'
int 0x10
mov al, 'a'
int 0x10
mov al, 'p'
int 0x10
mov al, 'G'
int 0x10

jmp $

times 510 - ($-$$) db 0
dw 0xaa55

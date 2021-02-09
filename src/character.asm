IDEAL
MODEL small
DATASEG

include "pizza.inc"

CODESEG

; draws a character on the screen
; character: character
; sp + 6: y
; sp + 4: x
PUBLIC draw_character
PROC draw_character
    push bp
    mov bp, sp
    add sp, -6h

    mov si,0h   ; offset in the array
    mov ax,[bp+4h]
    mov [bp-4h],ax
    mov ax,[bp+6h]
    mov [bp-2h],ax
    mov ax,[character_width]
    mul [character_height]
    mov [bp-6h],ax

draw_char_loop:
    mov bx,offset character  ; the offset of the array
    mov al,[byte ptr bx+si]

    mov bh,0h
    mov cx,[bp-4h]  ; x
    mov dx,[bp-2h]  ; y
    mov ah,0Ch
    int 10h	; drawing the pixel

    inc [word ptr bp-4h]	; increment x
    mov ax,[bp-4h]
    sub ax,[bp+4h]
    cmp ax,[character_width]
    jge draw_char_inc_y
    jmp draw_char_next_iter
draw_char_inc_y:
    inc [word ptr bp-2h]
    mov ax,[bp+4h]
    mov [bp-4h],ax
draw_char_next_iter:
    inc si
    cmp si,[bp-6h]
    jl draw_char_loop

end_draw_character:
    add sp, 6h
    pop bp
    ret

endp draw_character

END

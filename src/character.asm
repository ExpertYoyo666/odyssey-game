IDEAL
MODEL small
DATASEG

character_width dw 10h
character_height dw 10h

CODESEG
EXTRN draw_pixel:proc

; draws a character on the screen
; sp + 8: character offset
; sp + 6: y
; sp + 4: x
PUBLIC draw_character
proc draw_character
    push bp
    mov bp, sp
    add sp,-6h
    push ax
    push bx
    push si

    mov si,0h   ; offset in the array
    mov ax,[bp+4h]
    mov [bp-4h],ax
    mov ax,[bp+6h]
    mov [bp-2h],ax
    mov ax,[character_width]
    mul [character_height]
    mov [bp-6h],ax

draw_char_loop:
    mov ax,0
    cmp [bp-4h],ax
    jl draw_char_loop_x
    mov ax,319
    cmp [bp-4h],ax
    jg draw_char_loop_x

    mov bx,[bp+8h]  ; the offset of the array
    push [bx+si]
    push [bp-2h]
    push [bp-4h]
    call draw_pixel
    add sp,6

draw_char_loop_x:
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
    pop si
    pop bx
    pop ax
    add sp, 6h
    pop bp
    ret

endp draw_character

END

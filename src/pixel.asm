IDEAL
MODEL small
STACK 100h
DATASEG

videoBuffer db 64000 dup (0)

CODESEG
; draws a pixel in buffer.
; sp + 4: color
; sp + 6: y
; sp + 8: x
PUBLIC draw_pixel
proc draw_pixel
    push bp
    mov bp,sp

    push ax
    push bx
    push dx
    push di
    push es

    mov ax,[bp+6]
    mov dx,320
    mul dx
    mov di,[bp+4]
    add di,ax
    mov bx,offset videoBuffer
    add bx,di
    mov al,[bp+8]
    mov [ds:bx],al

    pop es
    pop di
    pop dx
    pop bx
    pop ax
    pop bp
    ret

endp draw_pixel

; copies buffer to display memory.
PUBLIC updateScreenBuffer
proc updateScreenBuffer
    push ax
    push bx
    push cx
    push dx
    push di
    push si
    push es

    mov dx,03DAh
wait_retrace:
    in al,dx
    and al,08h
    jnz wait_retrace

wait_retrace2:
    in al,dx
    and al,08h
    jz wait_retrace2

    mov si,0A000h
    mov es,si
    mov di,offset videoBuffer
    mov bx,0
    mov cx,32000
copy_loop:
    mov ax,[di+bx]
    mov [es:bx],ax
    add bx,2
    dec cx
    jnz copy_loop

    pop es
    pop si
    pop di
    pop dx
    pop cx
    pop bx
    pop ax
    ret

endp updateScreenBuffer

END

IDEAL
MODEL small
DATASEG


include "coin.inc"

character_width dw 10h
character_height dw 10h
;seconds_since_start dw 0

CODESEG

PUBLIC draw_coin
proc draw_coin
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

  draw_char_loop_c:

  mov bx, offset coin_array  ; the offset of the array
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
  jge draw_char_inc_y_c
  jmp draw_char_next_iter_c
  draw_char_inc_y_c:
  inc [word ptr bp-2h]
  mov ax,[bp+4h]
  mov [bp-4h],ax
  draw_char_next_iter_c:
  inc si
  cmp si,[bp-6h]
  jl draw_char_loop_c

  end_draw_character_c:
  add sp, 6h
  pop bp
  ret

endp draw_coin


PUBLIC draw_coin2
proc draw_coin2
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

  draw_char_loop_c2:

  mov bx, offset coin_array2  ; the offset of the array
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
  jge draw_char_inc_y_c2
  jmp draw_char_next_iter_c2
  draw_char_inc_y_c2:
  inc [word ptr bp-2h]
  mov ax,[bp+4h]
  mov [bp-4h],ax
  draw_char_next_iter_c2:
  inc si
  cmp si,[bp-6h]
  jl draw_char_loop_c2

  end_draw_character_c2:
  add sp, 6h
  pop bp
  ret

endp draw_coin2



END

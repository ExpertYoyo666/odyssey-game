IDEAL
MODEL small
STACK 100h
DATASEG

game_over_array db "G","A","M","E",20h,"O","V","E","R",0bh,0bh
								db "p","r","e","s","s",02dh,"e",20h,"t","o",20h
								db "e","x","i","t",$   ;27 items  include $
include "pizza.inc"
character_width dw 10h
character_height dw 10h
character_speed dw 10h
character_color dw 28h
character_loc_x dw 0h
character_loc_y dw 0h
screen_width dw 140h
screen_height dw 0c8h
CODESEG

; draws a character on the screen
; character: character
; sp + 6: y
; sp + 4: x
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
	mov cx,[bp-4h]	; x
	mov dx,[bp-2h]	; y
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

; removes the character from the screen
; character: character
; sp + 6: y
; sp + 4: x
PROC remove_character
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

remove_char_loop:
	mov al,00h
	mov bh,0h
	mov cx,[bp-4h]	; x
	mov dx,[bp-2h]	; y
	mov ah,0Ch
	int 10h	; drawing the pixel

	inc [word ptr bp-4h]
	mov ax,[bp-4h]
	sub ax,[bp+4h]
	cmp ax,[character_width]
	jge remove_char_inc_y
	jmp remove_char_next_iter
remove_char_inc_y:
	inc [word ptr bp-2h]
	mov ax,[bp+4h]
	mov [bp-4h],ax
remove_char_next_iter:
	inc si
	cmp si,[bp-6h]
	jl remove_char_loop

end_remove_character:
	add sp, 6h
	pop bp
	ret

endp remove_character

start:
	mov ax,@data
	mov ds,ax

	mov ax, 0013h	; set video mode 13h (320x200 256 colors)
	int 10h

	push [character_loc_y]
	push [character_loc_x]
	call draw_character
	add sp,4h

movement_loop:
	mov ah,07h	; check which key is pressed
	int 21h

	cmp al,77h	; check if 'w' was pressed
	je move_up

	cmp al,73h	; check if 's' was pressed
	je move_down

	cmp al,61h	; check if 'a' was pressed
	je move_right

	cmp al,64h	; check if 'd' was pressed
	je move_left
	jmp movement_loop

move_up:
	cmp [character_loc_y],0h
	je movement_loop

	push [character_loc_y]
	push [character_loc_x]
  	call remove_character
	add sp,4h

	mov ax,[character_speed]
  	sub [character_loc_y],ax
  	jmp call_draw_character

move_down:
	cmp [character_loc_y],0B0h
	je movement_loop

	push [character_loc_y]
	push [character_loc_x]
  	call remove_character
	add sp,4h

	mov ax,[character_speed]
  	add [character_loc_y],ax
  	jmp call_draw_character

move_right:
	cmp [character_loc_x],0h
	je movement_loop

	push [character_loc_y]
	push [character_loc_x]
  	call remove_character
	add sp,4h

	mov ax,[character_speed]
  	sub [character_loc_x],ax
  	jmp call_draw_character

move_left:
	cmp [character_loc_x],130h
	jl move_left_continue
	jmp movement_loop
move_left_continue:

	push [character_loc_y]
	push [character_loc_x]
  	call remove_character
	add sp,4h

	mov ax,[character_speed]
  	add [character_loc_x],ax

call_draw_character:
	push [character_loc_y]
	push [character_loc_x]
	call draw_character
	add sp,4h

	jmp movement_loop

exit:
    mov ax, 4C00h
    int 21h
END start

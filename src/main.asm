IDEAL
MODEL small
STACK 100h
DATASEG

include "pizza.inc"

v_min dw 7
v_max dw -7
character_velocity dw 0
character_loc_x dw 20
character_loc_y dw 50
character_width dw 10h
character_height dw 10h

;remove_character db 0
offset_character dw 0
offset_jump_process dw 0
time_counter db 0

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

main_loop:
    mov ah,2ch
    int 21h
    cmp dl,[time_counter] 
    je main_loop
    mov [time_counter],dl

    mov ah,1h
    int 16h
	mov bl,al
	mov ah,0ch
	mov al,0
	int 21h
    cmp bl,20h ; space
    je jump
    jmp check_dec_velocity

jump:
    mov ax,[v_max]
    mov [character_velocity],ax
	jmp continue1

check_dec_velocity:
    mov ax,[v_min]
    cmp [character_velocity],ax
    jl dec_velocity
    jmp continue1
    
dec_velocity:
    inc [character_velocity]

continue1:
    push [character_loc_y]
	push [character_loc_x]
  	call remove_character
	add sp,4h

    mov ax,[character_velocity]
    add [character_loc_y],ax

    cmp [character_loc_y],0
    jl exit

    cmp [character_loc_y],199
    jg exit

    push [character_loc_y]
	push [character_loc_x]
	call draw_character
	add sp,4h

    jmp main_loop

exit:
    mov ax, 4c00h
    int 21h
END start

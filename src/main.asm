IDEAL
MODEL small
STACK 100h
DATASEG

include "pizza.inc"
include "gameover.inc"

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
sec_counter db 0
time_since_start dw 0
reminder db 0
result_min db 0
result_sec db 0
CODESEG
include "ini_var.inc"
EXTRN plotfilledrect:proc

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
	cmp dh,[sec_counter]
	je same_sec
	mov dl,020h
	mov ah,02h
	int 21h

	mov [sec_counter],dh
	inc [time_since_start]
	mov ax,[time_since_start]
	mov cl,60
	div cl
	mov [reminder],ah      ; the reminder of the divede
	mov [result_min],al           ; the rusult of the divede
	mov dl,[result_min]											;put the result of the int in dl
	add dl,30h     ;the ascii of dl value
	mov ah,02h
	int 21h

	mov dl,03Ah      ;ascii of ":"
	mov ah,02h
	int 21h

	xor ax,ax         ;ax=0
	mov al,[reminder]
	mov cl,10
	div cl

	mov [reminder],ah     ;the result of the reminder

	mov [result_sec],al
	mov dl,[result_sec]													;the result of the int in dl
	add dl,30h     ;the ascii of dl value
	mov ah,02h
	int 21h

	mov dl,[reminder]     ;the result of the reminder dl
	add dl,30h     ;the ascii of dl value
	mov ah,02h
	int 21h

	mov dl,0dh        ;returns to the front of the line
	mov ah,02h
	int 21h

	same_sec:

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
	push 0
	push [character_loc_y]
	mov ax,[character_loc_x]
	add ax,[character_width]
	push ax
    mov ax,[character_loc_y]
	add ax,[character_height]
	push ax
	push [character_loc_x]
  	call plotfilledrect
	add sp,0Ah

    mov ax,[character_velocity]
    add [character_loc_y],ax

    cmp [character_loc_y],0
    jl game_over

    mov ax,200
    sub ax,[character_height]
    cmp [character_loc_y],ax   ;ax=200 - character_height
    jg game_over

    push [character_loc_y]
	push [character_loc_x]
	call draw_character
	add sp,4h

    jmp main_loop

game_over:
	mov dl,020h
	mov ah,02h
	int 21h

	mov dl,[result_min]
	add dl,30h
	int 21h

	mov dl,03Ah
	int 21h

	mov dl,[result_sec]
	add dl,30h
	int 21h

	mov dl,[reminder]
	add dl,30h
	int 21h

	mov dx,OFFSET game_over_array
	mov ah,9
	int 21h

	mov dx,OFFSET score_array
	mov ah,9
	int 21h

	mov dl,[result_min]
	mov ah,02h
	add dl,30h
	int 21h

	mov dl,03Ah
	mov ah,02h
	int 21h

	mov dl,[result_sec]
	mov ah,02h
	add dl,30h
	int 21h

	mov dl,[reminder]
	mov ah,02h
	add dl,30h
	int 21h

	mov dx,OFFSET press_array
	mov ah,9
	int 21h


wait_for_response:
	;jmp start
	mov ah,01h
	int 16h
	jnz wait_for_response

	mov ah,00h
	int 16h
	cmp al,65h ;e
	je exit
	;jmp wait_for_response
	cmp al,70h ;p
	je restart
	jmp wait_for_response

	restart:
	call try_again
	jmp start

exit:
    mov ax,0
    int 10h
    mov ax, 4c00h
    int 21h
END start

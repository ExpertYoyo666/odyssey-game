IDEAL
MODEL small
STACK 100h
DATASEG

include "gameover.inc"
include "wall.inc"

; Character variables.
v_min dw 7
v_max dw -7
character_velocity dw 0
character_loc_x dw 20
character_loc_y dw 50
character_width dw 10h
character_height dw 10h

; Time keeping variables
lastHundredthOfSecond db 0
lastSecond db 0
seconds_since_start dw 0
reminder db 0
minutes db 0
seconds db 0

CODESEG
EXTRN plotfilledrect:proc
EXTRN draw_character:proc
EXTRN print_num:proc
EXTRN draw_wall:proc
EXTRN random:proc
EXTRN init_seed:proc
EXTRN init_wall_gap:proc
EXTRN wall_gap_ceil:word
EXTRN wall_gap_floor:word

include "math.inc"

; reset all variable to restart the game.
proc reset_variables
    push ax

    mov ax,0
    mov [character_velocity],ax

    mov ax,20
    mov [character_loc_x],ax

    mov ax,50
    mov [character_loc_y],ax

    mov al,0
    mov [lastHundredthOfSecond],al

    mov al,0
    mov [lastSecond],al

    mov ax,0
    mov [seconds_since_start],ax

    mov al,0
    mov [reminder],al

    mov al,0
    mov [minutes],al

    mov al,0
    mov [seconds],al

    mov ax,13Fh
    mov [wall_loc_x],ax

    pop ax
    ret

endp reset_variables


start:
    mov ax,@data
    mov ds,ax

    mov ax,0013h	; set video mode 13h (320x200 256 colors)
    int 10h

    push [character_loc_y]
    push [character_loc_x]
    call draw_character
    add sp,4h

    call init_seed
    call init_wall_gap

main_loop:
    ; Get elapsed time since the beginning of the game
    mov ah,2ch
    int 21h
    cmp dl,[lastHundredthOfSecond]
    je main_loop

    mov [lastHundredthOfSecond],dl
    cmp dh,[lastSecond]
    je same_sec
    mov dl," "
    mov ah,02h
    int 21h

    mov [lastSecond],dh
    inc [seconds_since_start]
    mov ax,[seconds_since_start]
    mov cl,60
    div cl
    mov [reminder],ah      ; the reminder of the division
    mov [minutes],al       ; the result of the division
    mov dl,[minutes]	   ; put the result of the int in dl
    add dl,"0"             ; The number of minutes since start
    mov ah,02h
    int 21h

    mov dl,":"
    mov ah,02h
    int 21h

    xor ax,ax
    mov al,[reminder]
    mov cl,10
    div cl

    mov [reminder],ah     ; the result of the division
    mov [seconds],al
    mov dl,[seconds]   ; the result of int 21h in dl
    add dl,"0"
    mov ah,02h
    int 21h

    mov dl,[reminder]     ; the result of the reminder in dl
    add dl,"0"
    mov ah,02h
    int 21h

    mov dl,0dh        ; returns to the start of the line
    mov ah,02h
    int 21h

same_sec:
    mov ah,1h
    int 16h
    mov bl,al
    mov ah,0ch
    mov al,0
    int 21h
    cmp bl," "
    je jump
    jmp check_dec_velocity

jump:
    mov ax,[v_max]
    mov [character_velocity],ax
    jmp remove_char

check_dec_velocity:
    mov ax,[v_min]
    cmp [character_velocity],ax
    jl dec_velocity
    jmp remove_char

dec_velocity:
    inc [character_velocity]

remove_char:
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

remove_wall:
    mov ax,[wall_gap_ceil]
    push ax
    add ax,[wall_gap_floor]
    push ax 
    mov ax,[wall_velocity]
    max ax,[wall_width]
    push ax
    push 0
    add ax,[wall_loc_x]
    push ax 
    call draw_wall
    add sp,0Ah

    mov ax,[character_velocity]
    add [character_loc_y],ax

    mov ax,[wall_velocity]
    sub [wall_loc_x],ax

check_in_gap_1:
    mov ax,[character_loc_x]
    add ax,[character_width]
    cmp [wall_loc_x],ax
    jle check_in_gap_2
    jmp no_wall_character_collision

check_in_gap_2:
    mov bx,[wall_loc_x]
    add bx,[wall_width]
    cmp ax,bx
    jle check_in_gap_3
    jmp no_wall_character_collision

check_in_gap_3:
    mov ax,[character_loc_y]
    cmp ax,[wall_gap_ceil]
    jg check_in_gap_4
    mov [seconds_since_start],0
    jmp game_over

check_in_gap_4:
    add ax,[character_height]
    cmp [wall_gap_floor],ax
    jg no_wall_character_collision
    mov [seconds_since_start],10
    jmp game_over

no_wall_character_collision:
    cmp [character_loc_y],0
    jge not_hit_ceil
    jmp game_over
not_hit_ceil:

    mov ax,200
    sub ax,[character_height]
    cmp [character_loc_y],ax   ; ax=200 - character_height
    jg game_over

    push [character_loc_y]
    push [character_loc_x]
    call draw_character
    add sp,4h

    push [wall_gap_floor]
    push [wall_gap_ceil]
    push [wall_width]
    push [wall_color]
    push [wall_loc_x]
    call draw_wall
    add sp,0Ah

    mov ax,[wall_loc_x]
    mov bx,[wall_width]
    neg bx
    cmp ax,bx
    jle reset_wall

    jmp main_loop

reset_wall:
    mov ax,[wall_gap_ceil]
    push ax
    add ax,[wall_gap_floor]
    push ax 
    mov ax,[wall_velocity]
    max ax,[wall_width]
    push ax
    push 0
    add ax,[wall_loc_x]
    push ax 
    call draw_wall
    add sp,0Ah

    mov [wall_loc_x],13Fh
    call init_wall_gap
    jmp main_loop

game_over:
    mov dx,OFFSET game_over_array
    mov ah,9
    int 21h

    mov dx,OFFSET score_array
    mov ah,9
    int 21h

    ; prints score.
    mov ax,[seconds_since_start]
    call print_num

    mov dx,OFFSET press_array
    mov ah,9
    int 21h

game_over_wait_for_response:
    mov ah,01h
    int 16h
    jnz game_over_wait_for_response

    mov ah,00h
    int 16h

    cmp al,"e"
    je exit

    cmp al,"p"
    je restart
    jmp game_over_wait_for_response

restart:
    call reset_variables
    jmp start

exit:
    mov ax,0
    int 10h
    mov ax,4c00h
    int 21h
END start

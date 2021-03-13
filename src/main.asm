IDEAL
MODEL small
STACK 100h
DATASEG

include "gameover.inc"
include "wall.inc"
include "coinsvar.inc"
include "pizza.inc"
include "coins.inc"
include "math.inc"
include "timer.inc"

; Character variables.
v_min dw 6
v_max dw -6
character_velocity dw 0
character_loc_x dw 20
character_loc_y dw 50
character_width equ 10h
character_height equ 10h

; Coin Variables
coin_loc_y dw 100
coin_loc_x dw 304
coin_width equ 16
coin_height equ 16
do_reset_coin db 0
wait_to_draw_coin dw 50
coins_counter dw 0
switch_coin db 0
coin_velocity dw 6

; Time keeping variables
lastHundredthOfSecond db 0
lastSecond db 0
seconds_since_start dw 0
reminder db 0
minutes db 0
seconds db 0

EXTRN wall_gap_ceil:word
EXTRN wall_gap_floor:word
EXTRN wall_loc_x:word

CODESEG
EXTRN plotfilledrect:proc
EXTRN draw_character:proc
EXTRN print_num:proc
EXTRN draw_wall:proc
EXTRN random:proc
EXTRN init_seed:proc
EXTRN init_wall_gap:proc
EXTRN updateScreenBuffer:proc

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

    mov ax,100
    mov [coin_loc_y],ax

    mov ax,304 
    mov [coin_loc_x],ax
    
    mov al,0
    mov [do_reset_coin],al

    mov ax,50
    mov [wait_to_draw_coin],ax

    mov ax,0
    mov [coins_counter],ax

    mov al,0
    mov [switch_coin],al

    mov ax,6
    mov [coin_velocity],ax

    mov ax,4
    mov [wall_velocity],ax

    pop ax
    ret

endp reset_variables

start:
    mov ax,@data
    mov ds,ax

    mov ax,0013h	; set video mode 13h (320x200 256 colors)
    int 10h

    call init_seed

restart_game:    
    ; Move cursor to 0,0
    mov dx,0
    mov bh,0
    mov ah,02h
    int 10h
    
    call init_wall_gap
    
    mov [wait_to_draw_coin],25
    mov [do_reset_coin],1

    push 184
    call random
    add sp,2
    mov [coin_loc_y],ax

main_loop:
    ; Get elapsed time since the beginning of the game
    mov ah,2ch
    int 21h
    cmp dl,[lastHundredthOfSecond]
    je main_loop

    mov [lastHundredthOfSecond],dl
    cmp dh,[lastSecond]
    je same_sec

    push dx
    inc [seconds_since_start]
    mov [lastSecond],dh

same_sec:
    mov ah,1h
    int 16h
    mov bl,al
    mov ah,0ch
    mov al,0
    int 21h
    cmp bl," "
    jne check_dec_velocity

jump:
    mov ax,[v_max]
    mov [character_velocity],ax
    jmp remove_char

check_dec_velocity:
    mov ax,[v_min]
    cmp [character_velocity],ax
    jge remove_char

dec_velocity:
    inc [character_velocity]

remove_char:
    push 0
    push [character_loc_y]
    mov ax,[character_loc_x]
    add ax,character_width
    push ax
    mov ax,[character_loc_y]
    add ax,character_height
    push ax
    push [character_loc_x]
    call plotfilledrect
    add sp,0Ah

remove_wall:
    mov ax,[wall_gap_ceil]
    push ax
    mov ax,[wall_gap_floor]
    push ax 
    mov ax,wall_velocity
    max ax,wall_width
    push ax
    push 0
    add ax,[wall_loc_x]
    push ax 
    call draw_wall
    add sp,0Ah

    mov ax,[character_velocity]
    add [character_loc_y],ax

    mov ax,wall_velocity
    sub [wall_loc_x],ax

check_in_gap_1:
    mov ax,[character_loc_x]
    add ax,character_width
    cmp [wall_loc_x],ax
    jg no_wall_character_collision

check_in_gap_2:
    mov ax,[character_loc_y]
    cmp ax,[wall_gap_ceil]
    jg  check_in_gap_3
    jmp game_over

check_in_gap_3:
    add ax,character_height
    cmp [wall_gap_floor],ax    
    jg  no_wall_character_collision
    jmp game_over

no_wall_character_collision:
    cmp [character_loc_y],0
    jg  not_hit_ceil
    jmp game_over

not_hit_ceil:
    mov ax,200
    sub ax,character_height
    cmp [character_loc_y],ax   ; ax=200 - character_height
    jle not_hit_floor
    jmp game_over

not_hit_floor:
    cmp [do_reset_coin],1
    jne coin_main

dec_reset_counter:
    dec [wait_to_draw_coin]
    cmp [wait_to_draw_coin],0
    jle reset_coin
    jmp draw_char

reset_coin:
    ; Check if coin is on wall
    mov ax,304
    sub ax,wall_width
    cmp [wall_loc_x],ax
    jle coin_is_not_on_wall
    add [wait_to_draw_coin],50
    jmp draw_char

coin_is_not_on_wall:
    mov [do_reset_coin],0

    mov [coin_loc_x],304

    push 184
    call random
    add sp,2
    mov [coin_loc_y],ax

    jmp draw_coin

coin_main:
    push 0
    push [coin_loc_y]
    mov ax,[coin_loc_x]
    add ax,coin_width
    push ax
    mov ax,[coin_loc_y]
    add ax,coin_height
    push ax
    push [coin_loc_x]
    call plotfilledrect
    add sp,0Ah

    mov ax,[coin_velocity]
    sub [coin_loc_x],ax

check_character_coin_collision_1:
    mov ax,[coin_loc_x]
    add ax,coin_width
    cmp ax,[character_loc_x]
    jle no_character_coin_collision

check_character_coin_collision_2:
    mov ax,[character_loc_x]
    add ax,character_width
    cmp ax,[coin_loc_x]
    jle no_character_coin_collision
 
check_character_coin_collision_3:
    mov ax,[coin_loc_y]
    add ax,coin_height
    cmp ax,[character_loc_y]
    jle no_character_coin_collision

check_character_coin_collision_4:
    mov ax,[character_loc_y]
    add ax,character_height
    cmp ax,[coin_loc_y]
    jle no_character_coin_collision

character_coin_collision:
    inc [coins_counter]
    jmp init_coin_reset

no_character_coin_collision:
    mov ax,[coin_loc_x]
    mov bx,coin_width
    neg bx
    cmp ax,bx
    jg draw_coin
init_coin_reset:    
    push 75
    call random
    add sp,2
    add ax,75 
    mov [wait_to_draw_coin],ax
    mov [do_reset_coin],1
    mov [coin_loc_x],304
    jmp draw_char
  
draw_coin:
    push OFFSET coin1
    push [coin_loc_y]
    push [coin_loc_x]
    call draw_character
    add sp,6h

draw_char:
    push OFFSET character
    push [character_loc_y]
    push [character_loc_x]
    call draw_character
    add sp,6h

    push [wall_gap_floor]
    push [wall_gap_ceil]
    push wall_width
    push wall_color
    push [wall_loc_x]
    call draw_wall
    add sp,0Ah

    mov ax,[wall_loc_x]
    mov bx,wall_width
    neg bx
    cmp ax,bx
    jle reset_wall

    call updateScreenBuffer

    pop dx
    mov dl,0dh        ; returns to the start of the line
    mov ah,02h
    int 21h
    ;mov dl," "
    ;mov ah,02h
    ;int 21h
    mov dx,OFFSET timer_array
    mov ah,9
    int 21h
    mov ax,[seconds_since_start]
    mov cl,60
    div cl
    mov [reminder],ah    ; the reminder of the division
    mov ax,[word ptr minutes]
    call print_num
    mov dl,":"
    mov ah,02h
    int 21h
    mov ax,10
    cmp [reminder],10
    jge timer_no_zero_fill

    mov dl,"0"
    mov ah,02h
    int 21h

timer_no_zero_fill:
    mov ax,[word ptr reminder]
    call print_num

    mov dx,OFFSET coins_count_array
    mov ah,9
    int 21h
    mov ax,[coins_counter]
    call print_num

    jmp main_loop    

reset_wall:
    mov ax,[wall_gap_ceil]
    push ax
    mov ax,[wall_gap_floor]
    push ax 
    mov ax,wall_velocity
    max ax,wall_width
    push ax
    push 0
    add ax,[wall_loc_x]
    push ax 
    call draw_wall
    add sp,0Ah

    mov [wall_loc_x],13Fh
    call init_wall_gap

    ;call updateScreenBuffer
    jmp main_loop

game_over:
    push 0
    push 199
    push 319
    push 0
    push 0
    call plotfilledrect
    add sp,0Ah

    call updateScreenBuffer

    mov dx,0
    mov bh,0
    mov ah,02h
    int 10h 

    mov dx,OFFSET game_over_array
    mov ah,9
    int 21h

    mov dx,OFFSET score_array
    mov ah,9
    int 21h

    ; prints score.
    mov bx,[seconds_since_start]
    mov ax,[coins_counter]
    xor dx,dx
    mov cx,3
    mul cx
    add ax,bx
    call print_num

    mov dx,OFFSET press_array
    mov ah,9
    int 21h

game_over_wait_for_response:
    ; Read key from keyboard (blocks)
    mov ah,00h
    int 16h

    cmp al,"e"
    je exit

    cmp al,"p"
    je restart
    jmp game_over_wait_for_response

restart:
    call reset_variables

    push 0
    push 199
    push 319
    push 0
    push 0
    call plotfilledrect
    add sp,10

    call updateScreenBuffer

    jmp restart_game

exit:
    mov ax,0003h	; set video mode 03h (text mode)
    int 10h
    mov ax,4c00h
    int 21h
END start

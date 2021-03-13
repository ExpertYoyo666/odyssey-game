IDEAL
MODEL small
DATASEG

include "wall.inc"
PUBLIC wall_gap_ceil
wall_gap_ceil dw 0

PUBLIC wall_gap_floor
wall_gap_floor dw 0

PUBLIC wall_loc_x
wall_loc_x dw 13Fh

CODESEG
EXTRN plotfilledrect:proc
EXTRN init_seed:proc
EXTRN random:proc

include "math.inc"

; draws the wall at a location.
; sp + 0Ch: y2 (lower y cord of the opening)
; sp + 0Ah: y1 (upper y cord of the opening)
; sp + 8: width
; sp + 6: color
; sp + 4: x cord of the left side of the wall
PUBLIC draw_wall
proc draw_wall 
    push bp
    mov bp,sp

    push [bp+6]
    push [bp+0Ah]

    mov ax,[bp+4]
    add ax,[bp+8]
    min ax,screen_width
    push ax
    push 0
    mov ax,[bp+4]
    max ax,0
    push ax 
    call plotfilledrect
    add sp,0Ah  

    push [bp+6]
    push [bp+0Ch]
    mov ax,[bp+4]
    add ax,[bp+8]
    min ax,screen_width
    push ax 
    push screen_height
    mov ax,[bp+4]
    max ax,0
    push ax 
    call plotfilledrect
    add sp,0Ah

    pop bp
    ret

endp draw_wall

PUBLIC init_wall_gap
proc init_wall_gap
    push ax
    mov ax,screen_height
    sub ax,minimum_gap
    push ax
    call random
    add sp,2
    
    mov [wall_gap_ceil],ax

    push maximum_gap
    call random
    add sp,2

    max ax,minimum_gap
    add ax,[wall_gap_ceil]
    min ax,screen_height
    mov [wall_gap_floor],ax

    pop ax
    ret

endp init_wall_gap
END
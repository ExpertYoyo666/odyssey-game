IDEAL 
MODEL small
DATASEG

CODESEG
EXTRN draw_pixel:proc

; Draw a line between two points using Bresenham's line algorithm
; parameters:
; sp+0Ch: color
; sp+0Ah: y1 coordinate
; sp+8: x1 coordinate
; sp+6: y0 coordinate
; sp+4: x0 coordinate
PUBLIC plotLine
proc plotLine
    push bp
    mov	bp,sp
    add	sp,-0ch
    push ax
    push bx
    push cx
    push dx

    ; dx = if (x1>x0) (x1-x0) else (x0-x1)
    mov	ax,[bp+8]
    cmp	ax,[bp+4]
    jle calc_dx_case2
    mov	ax,[bp+8]
    sub	ax,[bp+4]
    jmp save_dx
calc_dx_case2:
    mov	ax,[bp+4]
    sub	ax,[bp+8]
save_dx:
    mov	[bp-02h],ax

    ; sx = if (x0<x1) 1 else -1
    mov	ax,[bp+4]
    cmp	ax,[bp+8]
    jge calc_sx_case2
    mov	ax,1
    jmp save_sx
calc_sx_case2:
    mov	ax,-1
save_sx: 
    mov	[bp-06h],ax

    ; dy = if (y1>y0) (y0-y1) else (y1-y0)
    mov ax,[bp+0Ah]
    cmp ax,[bp+6]
    jle calc_dy_y1_le_y0  
    mov	ax,[bp+6]
    sub	ax,[bp+0Ah]
    jmp save_dy
calc_dy_y1_le_y0:
    mov	ax,[bp+0Ah]
    sub	ax,[bp+6]
save_dy:
    mov	[bp-04h],ax

    ; sy = if (y0<y1) 1 else -1
    mov	ax,[bp+6]
    cmp	ax,[bp+0Ah]
    jge calc_sy_case2
    mov	ax,1
    jmp save_sy
calc_sy_case2:
    mov	ax,-1
save_sy:
    mov	[bp-08h],ax

    ; err = dx+dy 
    mov	ax,[bp-02h]
    add	ax,[bp-04h]
    mov	[bp-06h],ax

draw_line_loop:
    ; draw pixel
    push [bp+0Ch]
    push [bp+6]
    push [bp+4]
    call draw_pixel
    add sp,6

    ; if (x0 == x1 and y0 == y1) break
    mov	ax,[bp+4]
    cmp	ax,[bp+8]
    jne error_check_setup
    mov	ax,[bp+6]
    cmp	ax,[bp+0Ah]
    jne error_check_setup

    ; break from loop
    jmp end_plot_line
    
    ; e2 = 2*err
error_check_setup:
    mov	ax,[bp-06h]
    shl	ax,1
    mov	[bp-0ah],ax

    ; if (e2 >= dy)  
    mov	ax,[bp-0ah]
    cmp	ax,[bp-04h]
    jl error_check_dx

    ; err += dy
    mov	ax,[bp-06h]
    add	ax,[bp-04h]
    mov	[bp-06h],ax

    ; x0 += sx
    mov	ax,[bp+4]
    add	ax,[bp-06h]
    mov	[bp+4],ax
    
    ; if (e2 <= dx)  
error_check_dx:
    mov	ax,[bp-0ah]
    cmp	ax,[bp-02h]
    jg next_loop_iteration

inc_y_cord:
    ; err += dx
    mov	ax,[bp-06h]
    add	ax,[bp-02h]
    mov	[bp-06h],ax
    ; y0 += sy
    mov	ax,[bp+6]
    add	ax,[bp-08h]
    mov	[bp+6],ax

next_loop_iteration:
    jmp draw_line_loop
    
end_plot_line:
    pop dx
    pop cx
    pop bx
    pop ax
    add	sp,0ch
    pop	bp
    ret

endp plotLine

END

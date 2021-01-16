IDEAL
MODEL small
DATASEG

CODESEG
EXTRN plotLine:proc

; draw a filled rectangle
; parameters:
; sp+0Ch: color
; sp+0Ah: y1 coordinate
; sp+8: x1 coordinate
; sp+6: y0 coordinate
; sp+4: x0 coordinate
; Note: assuming x0 <= x1
PUBLIC plotfilledrect
proc plotfilledrect
    push bp
    mov bp, sp
    push cx
    
    mov cx, [bp+4h] ; set cx to x0

filled_rect_loop:
    push [bp+0Ch]   ; color
    push [bp+0Ah]   ; y1
    push cx         ; x1
    push [bp+6h]    ; y0
    push cx         ; x0
    call plotLine   ; plot the cx-x0th row
    pop cx
    add sp, 8h

    inc cx
    cmp cx, [bp+8h]
    jle filled_rect_loop

    pop cx
    pop bp
    ret

endp plotfilledrect

; draw a non-filled quadrilateral
; parameters:
; sp+14h: color
; sp+12h: y3 coordinate
; sp+10h: x3 coordinate
; sp+0Eh: y2 coordinate
; sp+0Ch: x2 coordinate
; sp+0Ah: y1 coordinate
; sp+8: x1 coordinate
; sp+6: y0 coordinate
; sp+4: x0 coordinate
PUBLIC plotquadrilateral
proc plotquadrilateral
    push bp
    mov bp, sp
    
    push [bp+14h]   ; color
    push [bp+0Ah]   ; y1
    push [bp+8h]    ; x1
    push [bp+6h]    ; y0
    push [bp+4h]    ; x0
    call plotLine
    add sp, 0Ah

    push [bp+14h]   ; color
    push [bp+0Eh]   ; y2
    push [bp+0Ch]   ; x2
    push [bp+0Ah]   ; y1
    push [bp+8h]    ; x1
    call plotLine
    add sp, 0Ah

    push [bp+14h]   ; color
    push [bp+12h]   ; y3
    push [bp+10h]   ; x3
    push [bp+0Eh]   ; y2
    push [bp+0Ch]   ; x2
    call plotLine
    add sp, 0Ah

    push [bp+14h]   ; color
    push [bp+6h]    ; y0
    push [bp+4h]    ; x0
    push [bp+12h]   ; y3
    push [bp+10h]   ; x3
    call plotLine
    add sp, 0Ah

    pop bp
    ret

endp plotquadrilateral

END

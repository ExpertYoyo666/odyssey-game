IDEAL
MODEL small
DATASEG

seed dw 0

CODESEG
; returns dx:ax mod m in ax.
; sp + 4: m
proc modulu
    push bp
    mov bp,sp
    push dx

    push dx
    mov bx,[word ptr bp+4]
    xor dx,dx
    div bx
    mov ax,dx
    pop dx

    pop dx
    pop bp
    ret

endp modulu

; returns a pseudorandom integer in the range [0,a-1] in ax using a LCG.
; seed: the seed.
; sp + 4: a
PUBLIC random
proc random
    push bp
    mov bp,sp
    push bx
    push dx

    mov ax,[seed]
    mov bx,257
    mul bx
    add ax,673
    mov [seed],ax
    
    push [bp+4] 
    call modulu
    add sp,2 

    pop dx
    pop bx
    pop bp
    ret 
    
endp random
    
; init the seed to the 16 lower bits of the # of clock ticks since midnight.
PUBLIC init_seed
proc init_seed
    push cx
    push dx
    mov ah,00h 
   	int 1Ah  

    mov [seed],dx
    pop dx
    pop cx
    ret 

endp init_seed

END
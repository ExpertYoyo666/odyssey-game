IDEAL
model small
DATASEG

num db 123

CODESEG
; print a 16-bit in ax on the screen.
PUBLIC print_num
proc print_num
    push ax
    push bx
    push cx
    push dx

    mov cx,0 
    mov dx,0 

get_digit_loop: 
    cmp ax,0 
    je print_loop       
        
    mov bx,10         
        
    div bx                   
        
    push dx               
        
    inc cx               
        
    xor dx,dx 
    jmp get_digit_loop 

print_loop: 
    cmp cx,0 
    je exit_print_num
        
    pop dx 
        
    add dx,"0"
        
    mov ah,02h 
    int 21h 
        
    dec cx 
    jmp print_loop 

exit_print_num:
    pop dx
    pop cx
    pop bx
    pop ax
    ret

endp print_num

END
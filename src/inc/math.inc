; gets 2 numbers and return the maximum in ax.
macro max x,y
    local x_greater
    mov ax,x
    cmp ax,y
    jge x_greater
    mov ax,y
x_greater:

endm max

; gets 2 numbers and return the minimum in ax.
macro min x,y
    local y_greater
    mov ax,x
    cmp ax,y
    jle y_greater
    mov ax,y
y_greater:

endm min
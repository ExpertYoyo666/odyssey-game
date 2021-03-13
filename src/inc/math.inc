; gets 2 numbers and returns the maximum in ax.
macro max x,y
    local x_greater
    mov ax,x
    cmp ax,y
    jge x_greater
    mov ax,y
x_greater:

endm max

; gets 2 numbers and returns the minimum in ax.
macro min x,y
    local y_greater
    mov ax,x
    cmp ax,y
    jle y_greater
    mov ax,y
y_greater:

endm min

; gets a number and returns its absolute value in ax.
macro absolute x
    local negative 
    mov ax,x
    cmp x,0
    jl negative

negative:
    neg ax

endm absolute
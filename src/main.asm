IDEAL
MODEL small
STACK 100h
DATASEG


CODESEG
EXTRN plotquadrilateral:proc
EXTRN plotfilledrect:proc

start:
    mov ax, @data
    mov ds, ax

    mov ax, 000Dh   ; set video mode 0Dh (320x200 16 colors)
    int 10h

    mov ax, 0501h
    int 10h

    push 2h    ; color
    push 10h    ; y3
    push 20h    ; x3
    push 40h    ; y2
    push 50h    ; x2
    push 50h    ; y1
    push 40h    ; x1
    push 10h    ; y0
    push 10h    ; x0
    call plotquadrilateral
    add sp, 12h
    
    push 1h    ; color
    push 0C8h   ; y1
    push 13Fh   ; x1
    push 60h    ; y0
    push 60h    ; x0
    call plotfilledrect
    add sp, 0Ah

    mov ax, 0500h
    int 10h

    ; wait for a keystroke to exit the program
    mov ah, 0h 
    int 16h
    mov ax, 0003h 
    int 10h
exit:
    ; exit the program safely
    mov ax, 4c00h
	int 21h

END start 
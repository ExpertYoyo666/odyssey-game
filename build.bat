path=%path%;c:\tasm\bin

tasm.exe /zi /c src\line.asm, obj\line.obj
tasm.exe /zi /c src\rect.asm, obj\rect.obj
tasm.exe /zi /c src\main.asm, obj\main.obj

tlink.exe /v obj\line.obj obj\rect.obj obj\main.obj, game.exe
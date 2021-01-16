REM Change the path according to your installation of TASM
path=%path%;c:\tasm\bin

tasm.exe /zi /c src\line.asm, obj\
tasm.exe /zi /c src\rect.asm, obj\
tasm.exe /zi /c src\main.asm, obj\

tlink.exe /v obj\line.obj obj\rect.obj obj\main.obj, game.exe
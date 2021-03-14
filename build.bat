REM Change the path according to your installation of TASM
path=%path%;c:\tasm\bin

tasm.exe /zi /c src\line.asm obj\
tasm.exe /zi /c src\rect.asm obj\
tasm.exe /zi /c src\str.asm obj\
tasm.exe /zi /c src\rand.asm obj\
tasm.exe /zi /c /isrc\inc src\charac~1.asm obj\
tasm.exe /zi /c /isrc\inc src\wall.asm obj\
tasm.exe /zi /c /isrc\inc src\main.asm obj\

tasm.exe /zi /c src\pixel.asm obj\
tlink.exe /v obj\line.obj obj\rect.obj obj\str.obj obj\rand.obj obj\pixel.obj obj\charac~1.obj obj\wall.obj obj\main.obj, game2.exe

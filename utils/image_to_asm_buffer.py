from PIL import Image
from json import load
import numpy as np

N = 2

def img_to_asm(img_name, output_name):
    img = np.array(Image.open(img_name))

    with open("vga_pallete.json", "r+") as palette:
        vga = load(palette)
        for i, color in enumerate(vga):
            new_color = (int(color[0:2], 16), int(color[2:4], 16), int(color[4:6], 16))
            vga[i] = new_color

    for j, row in enumerate(img):
        for i, pxl in enumerate(row):
            if pxl[3] == 0:
                new_color = tuple([0]*3 + [255])
            else:
                new_color = min(vga,
                                key=lambda x: ((x[0] - pxl[0]) ** N + (x[1] - pxl[1]) ** N + (x[2] - pxl[2]) ** N)**(1/N))
                new_color += (255,)
            img[j, i] = new_color

    img = Image.fromarray(img)
    img.save("new_character.png")
    img = np.array(img)

    with open(output_name, "w") as asm:
        asm.write("character ")
        for i in range(img.shape[0]):
            if i != 0:
                asm.write("          ")
            asm.write("db ")
            for j in range(img.shape[1]):
                if j != 0:
                    asm.write(", ")
                asm.write(f"{str(hex(vga.index(tuple(img[i, j][:3])))[2:]).zfill(3)}h")
            asm.write("\n")

img_to_asm(r"..\resources\pizza.png", r"..\src\inc\pizza.inc")

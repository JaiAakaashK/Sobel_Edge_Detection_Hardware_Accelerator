
import sys
import subprocess

subprocess.check_call([sys.executable, "-m", "pip", "install", "numpy"])

from PIL import Image
import numpy as np

# Load grayscale image
img = Image.open("input_2.jpg").convert("L")
img = img.resize((640, 480))   # ensure correct size

pixels = np.array(img, dtype=np.uint8)

# Save as text file (one pixel per line)
with open("input_2_image.txt", "w") as f:
    for row in pixels:
        for val in row:
            f.write(f"{val}\n")

print("Saved input_image.txt with", pixels.size, "pixels")
with open("input_2_image.txt") as f:
    pixels = [int(x.strip()) for x in f]

with open("input_2_image_hex.txt", "w") as f:
    for p in pixels:
        f.write(f"{p:02X}\n")


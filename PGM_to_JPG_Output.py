from PIL import Image

# Load PGM image
img = Image.open("sobel_output_4.pgm")

# Save as JPG
img.save("sobel_output_4.jpg")

print("Converted sobel_output.pgm to sobel_output.jpg")

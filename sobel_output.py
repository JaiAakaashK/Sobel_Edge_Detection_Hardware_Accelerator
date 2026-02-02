from PIL import Image
img = Image.open("sobel_output_4.pgm")
img.save("sobel_output_4.jpg")
print("Converted sobel_output.pgm to sobel_output.jpg")


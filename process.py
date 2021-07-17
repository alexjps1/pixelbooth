# This script makes a photomosiac out of an image using the images contained within the CollageImages folder
# The script is designed and tested to work with PNGs, but it seems to do fine with JPGs. Using other file formats may crash the script

from PIL import Image
import glob
import math
import random


def getColorAverage(imageObject):
    # Crushes the input image into a single pixel and returns the color value of that pixel.
    return imageObject.resize((1, 1)).getcolors()[0][1]


def squareCrop(imageObject):  # Crops the image towards the center into a square
    imx, imy = imageObject.size
    if imx > imy:  # True if the width of the image is larger than it's hight
        # Makes a square box that is as large as the image's hight since hight is the limiting factor
        # PIL's crop is anchored to the top left so we need to also offset the square box so that it crops the middle of the image instead of the left side of the image.
        offset = (imx // 2) - (imy // 2)
        box = (0 + offset, 0, imy + offset, imy)
    elif imy > imx:  # True if the hight of the image is larger than it's width
        # Same deal as above, but this time the square box is made of the width and offset is used to move the square down to the center of the image
        offset = (imy // 2) - (imx // 2)
        box = (0, 0 + offset, imx, imx + offset)
    else:  # The image's x and y resolution are the same, meaning the image is already square
        box = (0, 0, imx, imy)
    return imageObject.crop(box)


# Returns a list of tuples that has a square cropped version of every image in the CollageImages folder and the square cropped image's average color
def main():
    for imageFile in sorted(glob.iglob("CollageImages/*")):
        imageObject = Image.open(imageFile)
        imageFilename = imageObject.filename.lstrip("CollageImages/")
        imageObject = squareCrop(imageObject)
        color = getColorAverage(imageObject)

        # Rescales the image according to the squareSize and scale the user wants it to be in
        imageObject.save("Processed/" + str(color) + "|" + imageFilename)
        print(f"Proccessed {imageFilename}")

if __name__ == "__main__":
    main()

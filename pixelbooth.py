# This script makes a photomosiac out of an image using the images contained within the CollageImages folder
# The script is designed and tested to work with PNGs, but it seems to do fine with JPGs. Using other file formats may crash the script

from PIL import Image
import glob
import math
import random
import sys


def getColorAverage(imageObject):
    # Crushes the input image into a single pixel and returns the color value of that pixel.
    return imageObject.resize((1, 1)).getcolors()[0][1]

# Returns a list of tuples that has a square cropped version of every image in the CollageImages folder and the square cropped image's average color
def processCollageImages():
    processedCollageImages = []
    for imageFile in sorted(glob.iglob("Processed/*")):
        imageObject = Image.open(imageFile)
        imageFilename = imageObject.filename.lstrip("Processed/")
        # The color for the image is already in it's filename
        # This just extracts it
        color = imageFilename.split('|')[0] # Tuple in string form "(1, 2, 3)"
        color = color.strip("()") # No more parenthesis "1, 2, 3"
        color = tuple(map(int, (color.split(", "))))

        processedCollageImages.append((imageObject, color))
    return processedCollageImages


def main():
    inputImageName = sys.argv[1]
    outputImageName = sys.argv[2]
    squareSize = int(sys.argv[3])
    scale = int(sys.argv[4])
    threshold = int(sys.argv[5])

    imageObject = Image.open(inputImageName)
    processedCollageImages = processCollageImages()
    print(f"Creating {outputImageName}...   (This may take some time).")

    # Gets the input image's x and y resolution and puts it into two variables
    imx, imy = imageObject.size

    # Calculates the amout of squares of squareSize that can fit in the image's x and y axis
    # If a square cannot fit, the pixels are discared essentially making the new image have a resolution that is a multiple of squareSize
    xsquares = imx // squareSize
    ysquares = imy // squareSize
    newim = Image.new("RGB", (xsquares * squareSize * scale, ysquares * squareSize * scale))

    # Lazy to comment what everything does
    # Essentially it creates loops to go row by row across the input image and crops out squares based on user input.
    # It takes the square's average color and tries to find the collage image with the closest average color
    # Once it finds the closest image, it resizes and pastes the collage image onto a new image in the same place as where we were taking that square and moves on to that next square.
    for yindex in range(ysquares):
        yoffset = yindex * squareSize
        for xindex in range(xsquares):
            xoffset = xindex * squareSize

            region = (xoffset, yoffset, squareSize +
                      xoffset, squareSize + yoffset)
            cropim = imageObject.resize((1, 1), box=region)

            croprgb = getColorAverage(cropim)

            distance = -1
            # Shuffles the images in case there are multiple images that have the same average
            random.shuffle(processedCollageImages)
            for pic in processedCollageImages:
                picrgb = pic[1]
                newdistance = math.sqrt(  # Color distance calculation. Basically calculates the distance between two points in 3d space.
                    (picrgb[0] - croprgb[0])**2 + (picrgb[1] - croprgb[1])**2 + (picrgb[2] - croprgb[2])**2)
                if distance == 0:  # If the distance to a color is 0, the average RGB of the two images are the same so we stop looking for a better image to use
                    break
                elif distance == -1 or newdistance < distance:
                    distance = newdistance
                    closestimage = pic[0]
                    if distance < threshold:
                        distance = 0

            closestimage = closestimage.resize((squareSize * scale, squareSize * scale), Image.NEAREST)
            newim.paste(closestimage, (xoffset * scale, yoffset * scale))

    newim.save(outputImageName)
    print(f"Finished creating {outputImageName}!")


if __name__ == "__main__":
    main()

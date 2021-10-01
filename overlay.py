# Overlays a random image from 'overlay-images' directory over image to create output.png
# Arguments: input resizex resizey

from PIL import Image
import random
import sys
import numpy as np
import os

# Grab overlay and background images
overlay_path = ".info"
while (overlay_path == ".info"):
    overlay_path = random.choice(os.listdir("./overlay-images"))
overlay = Image.open("./overlay-images/" + overlay_path)
background = Image.open(str(sys.argv[1]))

# Resize image based on given argument
size = (int(sys.argv[2]), int(sys.argv[3]))
background = background.resize(size, resample=0, box=None)

# Overlay and save new file
background.paste(overlay, (0, 0), overlay)
background.save("./workspace/output.png", "PNG")
#!/bin/sh

[ "$1" = "python3-pillow" ] || exit 0

python3 - << EOF
import sys
from PIL import Image, ImageDraw

if (Image.__version__ != "$2"):
    print("Wrong version: " + Image.__version__)
    sys.exit(1)

from PIL import Image, ImageDraw
img = Image.new('RGB', (100, 30), color = (73, 109, 137))
d = ImageDraw.Draw(img)
d.text((10,10), "Hello World", fill=(255,255,0))

# Getting here means we did not get exceptions
sys.exit(0)
EOF

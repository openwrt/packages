#!/bin/sh

case "$1" in
graphicsmagick)
	# Version check
	gm version | grep -F "$2"

	# Create a small test image
	gm convert -size 32x32 xc:white /tmp/gm-white.png
	[ -f /tmp/gm-white.png ] || { echo "FAIL: PNG creation"; exit 1; }

	# Identify the created image; verify format and dimensions
	gm identify /tmp/gm-white.png | grep -E "PNG.*32x32"

	# Convert to JPEG
	gm convert /tmp/gm-white.png /tmp/gm-white.jpg
	gm identify /tmp/gm-white.jpg | grep "JPEG"

	# Resize: create a 64x64 image, resize to 16x16, confirm dimensions
	gm convert -size 64x64 xc:blue -resize 16x16! /tmp/gm-small.png
	gm identify /tmp/gm-small.png | grep -E "PNG.*16x16"

	# Color: create a 1x1 red pixel, sample it back
	gm convert -size 1x1 xc:red /tmp/gm-red.png
	gm convert /tmp/gm-red.png -format '%[pixel:p{0,0}]' info: | grep -iE "red|ff0000"

	# Draw: add text/annotate (exercises the font/draw engine)
	gm convert -size 64x16 xc:white -font Helvetica -pointsize 10 \
		-draw "text 2,12 'gm'" /tmp/gm-text.png 2>/dev/null || \
	gm convert -size 64x16 xc:white \
		-draw "text 2,12 'gm'" /tmp/gm-text.png
	gm identify /tmp/gm-text.png | grep "PNG"

	# Composite: overlay one image on another
	gm composite -compose Over /tmp/gm-red.png /tmp/gm-white.png /tmp/gm-composite.png
	gm identify /tmp/gm-composite.png | grep "PNG"

	# TIFF round-trip: encode, then decode back to PNG at the same geometry
	gm convert /tmp/gm-white.png /tmp/gm-white.tiff
	gm identify /tmp/gm-white.tiff | grep "TIFF"
	gm convert /tmp/gm-white.tiff /tmp/gm-back.png
	gm identify /tmp/gm-back.png | grep -E "PNG.*32x32"

	# PPM and GIF encoders (built-in codecs)
	gm convert /tmp/gm-white.png /tmp/gm-white.ppm
	gm identify /tmp/gm-white.ppm | grep -E "PNM|PPM"
	gm convert /tmp/gm-white.png /tmp/gm-white.gif
	gm identify /tmp/gm-white.gif | grep "GIF"

	# Crop a sub-region and confirm the new geometry
	gm convert /tmp/gm-white.png -crop 10x10+0+0 /tmp/gm-crop.png
	gm identify /tmp/gm-crop.png | grep -E "PNG.*10x10"

	# Rotate 90 degrees swaps width and height
	gm convert -size 40x20 xc:white -rotate 90 /tmp/gm-rot.png
	gm identify /tmp/gm-rot.png | grep -E "PNG.*20x40"

	# Horizontal append of two images
	gm convert /tmp/gm-white.png /tmp/gm-small.png +append /tmp/gm-app.png
	gm identify /tmp/gm-app.png | grep "PNG"

	# mogrify rewrites the file in place
	cp /tmp/gm-white.png /tmp/gm-mog.png
	gm mogrify -resize 20x20! /tmp/gm-mog.png
	gm identify /tmp/gm-mog.png | grep -E "PNG.*20x20"

	rm -f /tmp/gm-white.png /tmp/gm-white.jpg /tmp/gm-small.png \
	      /tmp/gm-red.png /tmp/gm-text.png /tmp/gm-composite.png \
	      /tmp/gm-white.tiff /tmp/gm-back.png /tmp/gm-white.ppm \
	      /tmp/gm-white.gif /tmp/gm-crop.png /tmp/gm-rot.png /tmp/gm-app.png \
	      /tmp/gm-mog.png
	;;
esac

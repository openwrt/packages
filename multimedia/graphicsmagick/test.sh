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

	rm -f /tmp/gm-white.png /tmp/gm-white.jpg /tmp/gm-small.png \
	      /tmp/gm-red.png /tmp/gm-text.png /tmp/gm-composite.png
	;;
esac

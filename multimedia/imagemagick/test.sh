#!/bin/sh

# $2 is PKG_VERSION which uses dots: e.g. "7.1.2.21"
# convert --version reports with a dash: "7.1.2-21"
# Build the dash form for grep.
_imver=$(echo "$2" | sed 's/\.\([0-9]*\)$/-\1/')

case "$1" in
imagemagick)
	# Version check; convert and magick are both installed
	convert --version | grep -F "ImageMagick"
	convert --version | grep -F "$_imver"

	# Create a test image via the ImageMagick convert command
	convert -size 32x32 xc:white /tmp/im-white.png
	[ -f /tmp/im-white.png ] || { echo "FAIL: PNG creation"; exit 1; }

	# Identify: confirm format and geometry
	identify /tmp/im-white.png | grep -E "PNG.*32x32"

	# Convert to JPEG
	convert /tmp/im-white.png /tmp/im-white.jpg
	identify /tmp/im-white.jpg | grep "JPEG"

	# Resize: exact geometry
	convert -size 64x64 xc:blue -resize 16x16! /tmp/im-small.png
	identify /tmp/im-small.png | grep -E "PNG.*16x16"

	# Color sampling: create a known red pixel, read it back
	convert -size 1x1 xc:'rgb(255,0,0)' /tmp/im-red.png
	# fx/info: query exercises the pixel engine
	convert /tmp/im-red.png -format '%[fx:p{0,0}.r*255]' info: | grep -E "^255$"

	# BMP round-trip (exercises a different codec path)
	convert /tmp/im-white.png /tmp/im-white.bmp
	identify /tmp/im-white.bmp | grep "BMP"

	# Grayscale conversion
	convert /tmp/im-red.png -colorspace Gray /tmp/im-gray.png
	identify -verbose /tmp/im-gray.png | grep -i "gray"

	# Composite two images (exercises MagickCore composite engine)
	convert /tmp/im-white.png /tmp/im-red.png \
		-gravity Center -composite /tmp/im-comp.png
	identify /tmp/im-comp.png | grep "PNG"

	rm -f /tmp/im-white.png /tmp/im-white.jpg /tmp/im-small.png \
	      /tmp/im-red.png /tmp/im-white.bmp /tmp/im-gray.png /tmp/im-comp.png
	;;
esac

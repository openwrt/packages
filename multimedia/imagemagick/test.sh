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

	# TIFF round-trip: encode, then decode back to PNG at the same geometry
	convert /tmp/im-white.png /tmp/im-white.tiff
	identify /tmp/im-white.tiff | grep "TIFF"
	convert /tmp/im-white.tiff /tmp/im-back.png
	identify /tmp/im-back.png | grep -E "PNG.*32x32"

	# PPM and GIF encoders (built-in codecs)
	convert /tmp/im-white.png /tmp/im-white.ppm
	identify /tmp/im-white.ppm | grep -E "PNM|PPM"
	convert /tmp/im-white.png /tmp/im-white.gif
	identify /tmp/im-white.gif | grep "GIF"

	# Crop a sub-region; +repage drops the virtual canvas offset
	convert /tmp/im-white.png -crop 10x10+0+0 +repage /tmp/im-crop.png
	identify /tmp/im-crop.png | grep -E "PNG.*10x10"

	# Rotate 90 degrees swaps width and height
	convert -size 40x20 xc:white -rotate 90 /tmp/im-rot.png
	identify /tmp/im-rot.png | grep -E "PNG.*20x40"

	# Horizontal append of two images
	convert /tmp/im-white.png /tmp/im-small.png +append /tmp/im-app.png
	identify /tmp/im-app.png | grep "PNG"

	# The IM7 'magick' driver must work as well as the legacy tools
	magick -size 24x24 xc:green /tmp/im-magick.png
	identify /tmp/im-magick.png | grep -E "PNG.*24x24"

	# mogrify rewrites the file in place
	cp /tmp/im-white.png /tmp/im-mog.png
	mogrify -resize 20x20! /tmp/im-mog.png
	identify /tmp/im-mog.png | grep -E "PNG.*20x20"

	rm -f /tmp/im-white.png /tmp/im-white.jpg /tmp/im-small.png \
	      /tmp/im-red.png /tmp/im-white.bmp /tmp/im-gray.png /tmp/im-comp.png \
	      /tmp/im-white.tiff /tmp/im-back.png /tmp/im-white.ppm \
	      /tmp/im-white.gif /tmp/im-crop.png /tmp/im-rot.png /tmp/im-app.png \
	      /tmp/im-magick.png /tmp/im-mog.png
	;;
esac

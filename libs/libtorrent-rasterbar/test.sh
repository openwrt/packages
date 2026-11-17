#!/bin/sh

case "$1" in
python3-libtorrent)
	python3 -c "import libtorrent; print(libtorrent.__version__)" | grep -F "$2"
	;;
esac

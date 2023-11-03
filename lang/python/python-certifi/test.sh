#!/bin/sh

case "$1" in
	*-src)
		;;
	python3-certifi)
		BUNDLE=$(python3 -m certifi) || {
			echo "Failed to run the certfi module script.  Exit status=$?." >&2
			echo "Output='$BUNDLE'" >&2
			exit 1
		}
		ls -l "$BUNDLE"
		;;
	*)
		echo "Unexpected package '$1'" >&2
		exit 1
		;;
esac

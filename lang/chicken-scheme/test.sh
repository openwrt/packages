#!/bin/sh

case "$1" in
	chicken-scheme-full)
		# Send an S-expression to its standard input
		if ! echo '(+ 2 3)' | csc -; then
			echo 'csc cannot compile a S-expression from standard input'
			exit 1
		fi
		;;

	chicken-scheme-interpreter)
		csi -version 2>&1 | grep -F "$2"
		;;
esac

#!/bin/sh

case "$1" in
	vim|vim-full|vim-fuller)
		vim --version | grep -F "$2"
		;;
	xxd)
		xxd --version 2>&1 | grep -F "${2//./-}"
		;;
esac

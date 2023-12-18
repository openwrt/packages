#!/bin/sh

case "$1" in
	sudo)
		sudo --version | grep "$2"
		;;
esac

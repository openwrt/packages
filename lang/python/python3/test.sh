#!/bin/sh

case "$1" in
python3|python3-base|python3-light)
	python3 --version | grep -Fx "Python $2"
	;;
esac

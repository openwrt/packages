#!/bin/sh

case "$1" in
	"yggdrasil-ng")
		yggdrasil --version 2>&1 | grep "$2"
		;;
esac

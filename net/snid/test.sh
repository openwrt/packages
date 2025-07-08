#!/bin/sh

case "$1" in
	"snid")
		snid -help 2>&1 | grep "Usage of snid:"
		;;
esac

#!/bin/sh

case "$1" in
	"openelp")
		openelpd -V | grep "$2"
		;;
esac

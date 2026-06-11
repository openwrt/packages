#!/bin/sh

case "$1" in
	"catatonit")
		test $(/usr/bin/catatonit -V | grep '^tini version' | wc -l) -gt 0
		;;
esac

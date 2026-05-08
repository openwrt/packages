#!/bin/sh

# checksec reported version doesn't match package version as of 3.1.0

case "$1" in
checksec)
	checksec --version 2>&1 | grep -qF "2.7.1"
	;;
esac

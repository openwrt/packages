#!/bin/sh

swgp-go -version 2>&1
swgp-go -version 2>&1 | grep "$2"
[ $? == 0 ] || {
	echo "Problem or incorrect version for '$1'"
	exit 1
}

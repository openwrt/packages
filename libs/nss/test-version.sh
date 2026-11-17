#!/bin/sh

if [ "$PKG_NAME" = "nss" ]; then
	# nss package does not build any binaries that emit a version, so
	# override the version check and indicate success
	exit 0
fi

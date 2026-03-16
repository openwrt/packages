#!/bin/sh

if [ "$1" = 'quickjs' ]; then
	qjs --help | grep -F "${PKG_VERSION//./-}"
fi

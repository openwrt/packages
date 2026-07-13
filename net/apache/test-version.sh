#!/bin/sh

if [ "$PKG_NAME" = "apache" ]; then
	if apache2 -V 2>&1 | grep -F "${PKG_VERSION}" && apachectl -V 2>&1 | grep -F "${PKG_VERSION}"; then
		exit 0
	else
		exit 1
	fi
fi

EXEC="${PKG_NAME#apache-}"

case "$EXEC" in
ab | \
utils)
	exit 0
	;;
*)
	if command -v "$EXEC" >/dev/null 2>&1; then
		if "$EXEC" -V 2>&1 | grep -F "${PKG_VERSION}"; then
			exit 0
		else
			exit 1
		fi
	else
		exit 0
	fi
	;;
esac

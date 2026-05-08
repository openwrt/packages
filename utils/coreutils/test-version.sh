#!/bin/sh

if [ "$PKG_NAME" = 'coreutils' ]; then
	exit 0
fi

EXEC=${PKG_NAME#coreutils-}

case "$EXEC" in
echo|false|kill|printf|pwd|test|true)
	exit 0
	;;
*)
	"$EXEC" --version 2>&1 | grep -qF "$PKG_VERSION"
	;;
esac

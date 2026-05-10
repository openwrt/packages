#!/bin/sh

# shellckeck shell=busybox

case "$PKG_NAME" in
python3|\
python3-base|\
python3-light)
	python3 --version | grep -Fx "Python $PKG_VERSION"
	;;

python3-asyncio|\
python3-base-src|\
python3-codecs|\
python3-ctypes|\
python3-dbm|\
python3-decimal|\
python3-dev|\
python3-light-src|\
python3-logging|\
python3-lzma|\
python3-multiprocessing|\
python3-ncurses|\
python3-openssl|\
python3-pydoc|\
python3-readline|\
python3-sqlite3|\
python3-unittest|\
python3-urllib|\
python3-uuid|\
python3-venv|\
python3-xml)
	exit 0
	;;

*)
	echo "Untested package: $PKG_NAME" >&2
	exit 1
	;;
esac

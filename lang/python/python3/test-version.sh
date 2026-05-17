#!/bin/sh

# shellckeck shell=busybox

case "$PKG_NAME" in
python3|\
python3-base|\
python3-light)
	python3 --version | grep -Fx "Python $PKG_VERSION"
	;;

libpython3-3.14|\
python3-asyncio|\
python3-asyncio-src|\
python3-base-src|\
python3-codecs|\
python3-codecs-src|\
python3-ctypes|\
python3-ctypes-src|\
python3-dbm|\
python3-dbm-src|\
python3-decimal|\
python3-decimal-src|\
python3-dev|\
python3-dev-src|\
python3-light-src|\
python3-logging|\
python3-logging-src|\
python3-lzma|\
python3-lzma-src|\
python3-multiprocessing|\
python3-multiprocessing-src|\
python3-ncurses|\
python3-ncurses-src|\
python3-openssl|\
python3-openssl-src|\
python3-pydoc|\
python3-pydoc-src|\
python3-readline|\
python3-readline-src|\
python3-sqlite3|\
python3-sqlite3-src|\
python3-unittest|\
python3-unittest-src|\
python3-urllib|\
python3-urllib-src|\
python3-uuid|\
python3-uuid-src|\
python3-venv|\
python3-venv-src|\
python3-xml|\
python3-xml-src)
	exit 0
	;;

*)
	echo "Untested package: $PKG_NAME" >&2
	exit 1
	;;
esac

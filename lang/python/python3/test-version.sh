#!/bin/sh

# shellcheck shell=busybox

# PYTHON3_VERSION from python3-version.mk, for example 3.13
PYTHON3_VERSION="${PKG_VERSION%.*}"

case "$PKG_NAME" in
python3|\
python3-base|\
python3-light)
	"python$PYTHON3_VERSION" --version | grep -Fx "Python $PKG_VERSION" &&
		python3 --version | grep -Fx "Python $PKG_VERSION"
	;;

python3-dev)
	# python3-config prints no version, so check that it points to the
	# headers of this version
	"python$PYTHON3_VERSION-config" --includes |
		grep -F -e "-I/usr/include/python$PYTHON3_VERSION" &&
		grep '^#define PY_VERSION ' "/usr/include/python$PYTHON3_VERSION/patchlevel.h" |
		grep -F "\"$PKG_VERSION\""
	;;

libpython3-*)
	# The package name carries the ABI version
	[ "$PKG_NAME" = "libpython3-$PYTHON3_VERSION" ]
	;;

python3-*)
	# Standard library modules and -src packages ship no executables
	exit 0
	;;

*)
	echo "Untested package: $PKG_NAME" >&2
	exit 1
	;;
esac

#!/bin/sh
# libpam's only versioned artefact is libpam.so (covered by the SONAME checks);
# its helper binaries have no version flag, so accept the version here.
case "$1" in
libpam) exit 0 ;;
esac
exit 1

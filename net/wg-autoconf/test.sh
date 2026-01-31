#!/bin/sh
# CI Test for wg-autoconf 1.0.0-r6

case "$1" in
    wg-autoconf)
        /usr/bin/wg-autoconf --help >/dev/null 2>&1
        ;;
esac

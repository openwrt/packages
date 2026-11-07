#!/bin/sh

# shellcheck shell=busybox

case "$PKG_NAME" in
shine)
    # shineenc does not report its version
    exit 0
    ;;
*)
    echo "Untested package: $PKG_NAME" >&2
    exit 1
    ;;
esac

#!/bin/sh

# shellcheck shell=busybox

# The generic version check runs every installed executable looking for
# PKG_VERSION, and the package also ships nettest, a diagnostic that reports no
# version. Check the one binary that does.
case "$PKG_NAME" in
librespeed-cli-rust)
    librespeed-cli --version | grep -F "$PKG_VERSION"
    ;;
*)
    echo "Untested package: $PKG_NAME" >&2
    exit 1
    ;;
esac

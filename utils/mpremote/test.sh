#!/bin/sh

[ "$1" = mpremote ] || exit 0

mpremote version | grep -Fx "mpremote $PKG_VERSION"

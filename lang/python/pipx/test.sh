#!/bin/sh

[ "$1" = pipx ] || exit 0

pipx --version | grep -Fx "$PKG_VERSION"

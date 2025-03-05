#!/bin/sh

[ "$1" = python3-userpath ] || exit 0

userpath --version | grep -Fx "userpath, version $PKG_VERSION"

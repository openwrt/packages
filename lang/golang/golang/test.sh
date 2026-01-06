#!/bin/sh

[ "$1" = golang ] || exit 0

go version | grep -F " go$PKG_VERSION "

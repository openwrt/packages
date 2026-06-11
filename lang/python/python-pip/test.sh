#!/bin/sh

[ "$1" = python3-pip ] || exit 0

pip --version | grep -F "pip $PKG_VERSION "

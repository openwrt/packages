#!/bin/sh

[ "$1" = unixodbc-tools ] || exit 0

isql --version | grep -Fx "unixODBC $PKG_VERSION"

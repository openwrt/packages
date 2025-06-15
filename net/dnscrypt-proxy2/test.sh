#!/bin/sh

[ "$1" = dnscrypt-proxy2 ] || exit 0

dnscrypt-proxy -version | grep "$PKG_VERSION"

#!/bin/sh

"$1" -v 2>&1 | grep "$PKG_VERSION"

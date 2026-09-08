#!/bin/sh

"$1" -h 2>&1 | grep "$PKG_VERSION"

#!/bin/sh

"$1" --version | grep -F "$PKG_VERSION"

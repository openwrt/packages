#!/bin/sh

$1 -v 2>&1 | grep -F "$PKG_VERSION"

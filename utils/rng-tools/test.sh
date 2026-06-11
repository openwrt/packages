#!/bin/sh

rngd -v 2>&1 | grep "$PKG_VERSION"

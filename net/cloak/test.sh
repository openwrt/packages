#!/bin/sh
set -ex

ck-server -v | grep "$PKG_VERSION"
ck-client -v | grep "$PKG_VERSION"

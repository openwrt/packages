#!/bin/sh

PKG=$1
ver=$2

"$PKG" --version | grep "$ver"

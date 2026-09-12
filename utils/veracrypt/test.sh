#!/bin/sh
veracrypt --text --version 2>&1 | grep -F "$PKG_VERSION"

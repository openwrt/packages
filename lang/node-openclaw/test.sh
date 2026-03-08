#!/bin/sh

openclaw --version 2>&1 | grep -F "$PKG_VERSION"

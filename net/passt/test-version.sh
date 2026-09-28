#!/bin/sh
passt --version | grep -F "$(echo "$PKG_VERSION" | tr . _)"

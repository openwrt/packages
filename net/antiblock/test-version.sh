#!/bin/sh
set -eu

# shellcheck disable=SC2154
antiblock --help | grep -F "AntiBlock $PKG_VERSION"

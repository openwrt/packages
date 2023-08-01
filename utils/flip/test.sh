#!/bin/sh
PKG_NAME="${1}"
PKG_VERSION="${2}"

toix -h 2>&1 | grep -q "${PKG_NAME} version ${PKG_VERSION}\\."

#!/bin/sh
iozone -v | grep -F "${PKG_VERSION}"

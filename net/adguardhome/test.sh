#!/bin/sh

AdGuardHome --version 2>&1 | cut -d' ' -f4 | grep "${PKG_VERSION}"

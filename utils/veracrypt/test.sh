#!/bin/sh
# SPDX-License-Identifier: GPL-2.0-only
veracrypt --text --version 2>&1 | grep -F "$PKG_VERSION"

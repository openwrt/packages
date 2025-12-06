#!/bin/sh
#
# SPDX-License-Identifier: GPL-2.0-only

AdGuardHome --version | grep -F "$PKG_VERSION"

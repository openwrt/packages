#!/bin/sh
#
# Generic version-check override.
#
# Shadow's tools accept --help but not --version, so the framework's generic
# version probe (--version / -v / -V / --help) doesn't find the PKG_VERSION
# string in any of them and would otherwise mark every sub-package as missing
# a version match. The companion test.sh exercises actual functionality of
# each applet (pwck, grpck, chage, useradd, passwd, faillog, ...), so the
# generic version check has no value here.

exit 0

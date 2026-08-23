#!/bin/sh
# shunt has no version output by design: the runtime version comes from
# rpc-sys packagelist via ubus, which is not available in the CI
# container. The forced generic version check can therefore never match
# PKG_VERSION in the output of the daemon.

[ "$1" = "shunt" ] || exit 1

exit 0

#!/bin/sh
# travelmate has no version output by design: the runtime version comes from
# rpc-sys packagelist via ubus, which is not available in the CI container.

[ "$1" = "travelmate" ] || exit 1

exit 0

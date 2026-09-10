#!/bin/sh

# socat gives the runtime test a UDP echo peer and a UDP client. BusyBox nc is
# built without NC_SERVER and NC_EXTRA, so it can neither listen nor exec.
apk add socat

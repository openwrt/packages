#!/bin/sh

[ "$1" = atlas-probe ] || exit 0

PROBE_DIR=/usr/libexec/atlas-probe

# Check the main busybox binary is present and executable
[ -x "$PROBE_DIR/bin/busybox" ] || { echo "Missing: $PROBE_DIR/bin/busybox"; exit 1; }

# Check key measurement applets are installed as symlinks/binaries
for applet in eperd eooqd evping evtraceroute evtdig evntp evhttpget; do
    [ -e "$PROBE_DIR/bin/$applet" ] \
        || { echo "Missing applet: $applet"; exit 1; }
done

# Check the version file was written correctly
[ -f "$PROBE_DIR/state/VERSION" ] || { echo "Missing: $PROBE_DIR/state/VERSION"; exit 1; }
version=$(cat "$PROBE_DIR/state/VERSION")
[ "$version" = "2.6.4" ] || { echo "Unexpected version: $version"; exit 1; }

echo "atlas-probe OK"

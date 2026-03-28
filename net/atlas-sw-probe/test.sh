#!/bin/sh

[ "$1" = atlas-sw-probe ] || exit 0

SCRIPTS_DIR=/usr/libexec/atlas-probe-scripts

# Check key scripts are installed
for f in \
    "$SCRIPTS_DIR/bin/ATLAS" \
    "$SCRIPTS_DIR/bin/resolvconf" \
    "$SCRIPTS_DIR/bin/config.sh" \
    "$SCRIPTS_DIR/bin/arch/openwrt-sw-probe/openwrt-sw-probe-ATLAS.sh" \
    "$SCRIPTS_DIR/state/FIRMWARE_APPS_VERSION" \
    "$SCRIPTS_DIR/state/mode" \
    "$SCRIPTS_DIR/state/config.txt"
do
    [ -e "$f" ] || { echo "Missing: $f"; exit 1; }
done

# Check firmware version matches PKG_VERSION
version=$(cat "$SCRIPTS_DIR/state/FIRMWARE_APPS_VERSION")
[ "$version" = "5120" ] || { echo "Unexpected version: $version"; exit 1; }

# Check probe mode is prod
mode=$(cat "$SCRIPTS_DIR/state/mode")
[ "$mode" = "prod" ] || { echo "Unexpected mode: $mode"; exit 1; }

# Check RXTXRPT is enabled
grep -q "RXTXRPT=yes" "$SCRIPTS_DIR/state/config.txt" \
    || { echo "RXTXRPT=yes not found in config.txt"; exit 1; }

# Check device name is set correctly
grep -q "DEVICE_NAME=openwrt-sw-probe" "$SCRIPTS_DIR/bin/config.sh" \
    || { echo "DEVICE_NAME not set correctly"; exit 1; }

echo "atlas-sw-probe OK"

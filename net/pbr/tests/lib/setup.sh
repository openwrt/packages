#!/bin/bash
# Common test setup for pbr shell tests (shunit2-based)
# Source this at the top of each test file before defining test functions.
# Each test file should end with: . shunit2

TESTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PKG_DIR="$(cd "$TESTS_DIR/.." && pwd)"

# Create mock sysroot
MOCK_ROOT="$(mktemp -d)"
export IPKG_INSTROOT="$MOCK_ROOT"

# Install mock libraries into sysroot
mkdir -p "$MOCK_ROOT/lib/functions"
mkdir -p "$MOCK_ROOT/usr/share/libubox"
cp "$TESTS_DIR/lib/mocks/functions.sh" "$MOCK_ROOT/lib/functions.sh"
cp "$TESTS_DIR/lib/mocks/network.sh" "$MOCK_ROOT/lib/functions/network.sh"
cp "$TESTS_DIR/lib/mocks/jshn.sh" "$MOCK_ROOT/usr/share/libubox/jshn.sh"

# Install mock config files
mkdir -p "$MOCK_ROOT/etc/config"
if [ -d "$TESTS_DIR/mocks/etc/config" ]; then
	cp "$TESTS_DIR/mocks/etc/config/"* "$MOCK_ROOT/etc/config/" 2>/dev/null || true
fi

# Install mock binaries and add to PATH
mkdir -p "$MOCK_ROOT/bin"
if [ -d "$TESTS_DIR/mocks/bin" ]; then
	cp "$TESTS_DIR/mocks/bin/"* "$MOCK_ROOT/bin/" 2>/dev/null || true
	chmod +x "$MOCK_ROOT/bin/"*
fi
export PATH="$MOCK_ROOT/bin:$PATH"

# Create required directories
mkdir -p "$MOCK_ROOT/var/run"
mkdir -p "$MOCK_ROOT/dev/shm"
mkdir -p "$MOCK_ROOT/usr/share/nftables.d/ruleset-post"
mkdir -p "$MOCK_ROOT/etc/iproute2"
cat > "$MOCK_ROOT/etc/iproute2/rt_tables" <<'RT'
255	local
254	main
253	default
0	unspec
RT

# Stub out OpenWrt rc.common / procd functions
extra_command() { :; }
rc_procd() { "$@"; }
service_started() { :; }
procd_open_instance() { :; }
procd_set_param() { :; }
procd_close_instance() { :; }
procd_open_data() { :; }
procd_close_data() { :; }
procd_add_reload_trigger() { :; }
procd_add_interface_trigger() { :; }
procd_open_trigger() { :; }
procd_close_trigger() { :; }

# Stub external commands
logger() { :; }
resolveip() { echo "127.0.0.1"; }
jsonfilter() { echo ""; }
pidof() { return 1; }
sync() { :; }

# Prepare a test-friendly copy of the pbr script:
# 1. Strip 'readonly' keyword to avoid collision with shunit2 internals
#    (pbr defines readonly _FAIL_, _OK_ etc. that clash with shunit2)
# 2. Redirect file paths to temp directories we control
_PBR_TEST_SCRIPT="$MOCK_ROOT/pbr_test.sh"
sed 's/^readonly //' "$PKG_DIR/files/etc/init.d/pbr" > "$_PBR_TEST_SCRIPT"

# Source the modified pbr script
. "$_PBR_TEST_SCRIPT"

# Override file paths to use test-friendly temp locations
nftTempFile="$MOCK_ROOT/var/run/pbr.nft"
nftMainFile="$MOCK_ROOT/usr/share/nftables.d/ruleset-post/30-pbr.nft"
nftNetifdFile="$MOCK_ROOT/usr/share/nftables.d/ruleset-post/20-pbr-netifd.nft"
rtTablesFile="$MOCK_ROOT/etc/iproute2/rt_tables"
runningStatusFile="$MOCK_ROOT/dev/shm/pbr.status.json"
packageLockFile="$MOCK_ROOT/var/run/pbr.lock"
packageDnsmasqFile="$MOCK_ROOT/var/run/pbr.dnsmasq"
packageDebugFile="$MOCK_ROOT/var/run/pbr.debug"
packageConfigFile="$MOCK_ROOT/etc/config/pbr"

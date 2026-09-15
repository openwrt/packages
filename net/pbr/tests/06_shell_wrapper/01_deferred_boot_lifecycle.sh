#!/bin/bash

TEST_DIR="$(mktemp -d)"
trap 'rm -rf "$TEST_DIR"' EXIT

# Create mock ucode binary to intercept calls
cat << EOF > "$TEST_DIR/mock_ucode"
#!/bin/bash
# Shift away the -S -L arguments if they exist
while [[ "\$1" == -* ]]; do
    if [ "\$1" = "-L" ]; then shift 2; else shift; fi
done
cmd="\$1"
param="\$2"
arg_passed="\$3"

if [ "\$cmd" = "start_service" ]; then
    echo "_pbr_deferred_to_boot=1"
    exit 0
elif [ "\$cmd" = "service_started" ]; then
    if [ "\$arg_passed" = "1" ]; then
        echo "PASS_VIA_ARGUMENT" > "$TEST_DIR/test_result"
    elif [ -f "$TEST_DIR/var_run/pbr.boot" ]; then
        echo "PASS_VIA_FILE" > "$TEST_DIR/test_result"
    else
        echo "FAIL_MISSING_STATE" > "$TEST_DIR/test_result"
        touch "$TEST_DIR/var_run/pbr.lock"
    fi
    exit 0
fi
EOF
chmod +x "$TEST_DIR/mock_ucode"

mkdir -p "$TEST_DIR/var_run"
echo "FAIL_UNSET" > "$TEST_DIR/test_result"

# Copy and patch init.d/pbr to use our isolated directories and mocked ucode
cp files/etc/init.d/pbr "$TEST_DIR/pbr_mock.sh"
sed -i "s|/var/run|$TEST_DIR/var_run|g" "$TEST_DIR/pbr_mock.sh"
sed -i "s|readonly _ucode=.*|readonly _ucode=\"$TEST_DIR/mock_ucode\"|g" "$TEST_DIR/pbr_mock.sh"

# Remove OpenWrt source lines to prevent errors
sed -i 's|^\. /lib/functions.sh|# . /lib/functions.sh|' "$TEST_DIR/pbr_mock.sh"
sed -i 's|^\. /lib/functions/network.sh|# . /lib/functions/network.sh|' "$TEST_DIR/pbr_mock.sh"
sed -i 's|^\. "${IPKG_INSTROOT}/usr/share/libubox/jshn.sh"|# . /usr/share/libubox/jshn.sh|' "$TEST_DIR/pbr_mock.sh"

(
    # Mock OpenWrt rc.common environment
    rc_procd() {
        "$@"
        if type service_triggers >/dev/null 2>&1; then
            service_triggers
        fi
    }
    config_load() { :; }
    config_get() { eval "$1=\"$4\""; }
    config_get_bool() { eval "$1=\"$4\""; }
    procd_add_raw_trigger() { return 0; }
    stop_forward() { :; }
    enable_forward() { :; }
    procd_open_validate() { :; }
    procd_close_validate() { :; }
    procd_open_trigger() { :; }
    procd_close_trigger() { :; }
    procd_add_config_trigger() { :; }
    uci_load_validate() { :; }

    start() {
        rc_procd start_service "$@"
        if type service_started >/dev/null 2>&1; then
            service_started "$@"
        fi
    }

    # Source the patched init.d script
    . "$TEST_DIR/pbr_mock.sh"

    # Execute the boot lifecycle natively
    start "on_start"
)

RESULT=$(cat "$TEST_DIR/test_result")
if [ "$RESULT" = "PASS_VIA_ARGUMENT" ]; then
    exit 0
else
    echo "Expected PASS_VIA_ARGUMENT, but got: $RESULT" >&2
    exit 1
fi

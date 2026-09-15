#!/bin/bash
TEST_DIR="$(mktemp -d)"
trap 'rm -rf "$TEST_DIR"' EXIT

cat << EOF > "$TEST_DIR/mock_ucode"
#!/bin/bash
# If mock_ucode is called during boot(), it's a FAILURE because boot() should bypass ucode completely!
echo "YES" > "$TEST_DIR/ucode_called"
exit 1
EOF
chmod +x "$TEST_DIR/mock_ucode"

mkdir -p "$TEST_DIR/var_run"
echo "NO" > "$TEST_DIR/ucode_called"
echo "NO" > "$TEST_DIR/trigger_added"

cp files/etc/init.d/pbr "$TEST_DIR/pbr_mock.sh"
sed -i "s|/var/run|$TEST_DIR/var_run|g" "$TEST_DIR/pbr_mock.sh"
sed -i "s|readonly _ucode=.*|readonly _ucode=\"$TEST_DIR/mock_ucode\"|g" "$TEST_DIR/pbr_mock.sh"

sed -i 's|^\. /lib/functions.sh|# . /lib/functions.sh|' "$TEST_DIR/pbr_mock.sh"
sed -i 's|^\. /lib/functions/network.sh|# . /lib/functions/network.sh|' "$TEST_DIR/pbr_mock.sh"
sed -i 's|^\. "${IPKG_INSTROOT}/usr/share/libubox/jshn.sh"|# . /usr/share/libubox/jshn.sh|' "$TEST_DIR/pbr_mock.sh"

(
    rc_procd() {
        "$@"
        if type service_triggers >/dev/null 2>&1; then
            service_triggers
        fi
    }
    config_load() { :; }
    config_get() { eval "$1=\"$4\""; }
    config_get_bool() { eval "$1=1"; } # enabled=1
    procd_add_raw_trigger() {
        if [ "$1" = "interface.*.up" ]; then
            echo "YES" > "$TEST_DIR/trigger_added"
        fi
        return 0
    }
    procd_add_config_trigger() { :; }
    procd_add_interface_trigger() { :; }
    procd_open_validate() { :; }
    procd_close_validate() { :; }
    procd_open_trigger() { :; }
    procd_close_trigger() { :; }
    uci_load_validate() { :; }
    stop_forward() { :; }
    enable_forward() { :; }

    . "$TEST_DIR/pbr_mock.sh"
    boot
)

UCODE_CALLED="$(cat "$TEST_DIR/ucode_called")"
TRIGGER_ADDED="$(cat "$TEST_DIR/trigger_added")"

if [ "$UCODE_CALLED" = "YES" ]; then
    echo "FAIL: ucode was called during boot!" >&2
    exit 1
fi
if [ "$TRIGGER_ADDED" = "NO" ]; then
    echo "FAIL: interface.*.up trigger was not added!" >&2
    exit 1
fi
if [ -f "$TEST_DIR/var_run/pbr.boot" ]; then
    echo "FAIL: pbr.boot file was left on disk (not cleaned up by service_triggers)!" >&2
    exit 1
fi

exit 0

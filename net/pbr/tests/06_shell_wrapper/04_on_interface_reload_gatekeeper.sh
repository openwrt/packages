#!/bin/bash
TEST_DIR="$(mktemp -d)"
trap 'rm -rf "$TEST_DIR"' EXIT

cat << EOF > "$TEST_DIR/mock_ucode"
#!/bin/bash
echo "\$1" >> "$TEST_DIR/ucode_calls"
if [ "\$1" = "should_skip_reload" ]; then
    exit 0 # return 0 so it skips reload, simplifies the test
fi
exit 0
EOF
chmod +x "$TEST_DIR/mock_ucode"

mkdir -p "$TEST_DIR/var_run"
touch "$TEST_DIR/ucode_calls"

cp files/etc/init.d/pbr "$TEST_DIR/pbr_mock.sh"
sed -i "s|/var/run|$TEST_DIR/var_run|g" "$TEST_DIR/pbr_mock.sh"
sed -i "s|readonly _ucode=.*|readonly _ucode=\"$TEST_DIR/mock_ucode\"|g" "$TEST_DIR/pbr_mock.sh"
sed -i 's|^\. /lib/functions.sh|# . /lib/functions.sh|' "$TEST_DIR/pbr_mock.sh"
sed -i 's|^\. /lib/functions/network.sh|# . /lib/functions/network.sh|' "$TEST_DIR/pbr_mock.sh"
sed -i 's|^\. "${IPKG_INSTROOT}/usr/share/libubox/jshn.sh"|# . /usr/share/libubox/jshn.sh|' "$TEST_DIR/pbr_mock.sh"

(
    rc_procd() { :; }
    stop_forward() { :; }
    enable_forward() { :; }

    . "$TEST_DIR/pbr_mock.sh"

    # Test 1: No lock file
    if on_interface_reload "wg0"; then
        echo "FAIL: Should have returned 1 when lock missing!" > "$TEST_DIR/result"
        exit 1
    fi
    if [ -s "$TEST_DIR/ucode_calls" ]; then
        echo "FAIL: ucode was called despite missing lock!" > "$TEST_DIR/result"
        exit 1
    fi

    # Test 2: With lock file
    touch "$TEST_DIR/var_run/pbr.lock"
    if ! on_interface_reload "wg0"; then
        echo "FAIL: Should have returned 0!" > "$TEST_DIR/result"
        exit 1
    fi
    if ! grep -q "should_skip_reload" "$TEST_DIR/ucode_calls"; then
        echo "FAIL: ucode should_skip_reload was not called!" > "$TEST_DIR/result"
        exit 1
    fi

    echo "PASS" > "$TEST_DIR/result"
) >/dev/null 2>&1

if [ "$(cat "$TEST_DIR/result")" = "PASS" ]; then
    exit 0
else
    cat "$TEST_DIR/result" >&2
    exit 1
fi

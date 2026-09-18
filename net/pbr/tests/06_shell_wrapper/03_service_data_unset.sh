#!/bin/bash
TEST_DIR="$(mktemp -d)"
trap 'rm -rf "$TEST_DIR"' EXIT

cat << EOF > "$TEST_DIR/mock_ucode"
#!/bin/bash
echo "_pbr_svc_data=''"
exit 0
EOF
chmod +x "$TEST_DIR/mock_ucode"

cp files/etc/init.d/pbr "$TEST_DIR/pbr_mock.sh"
sed -i "s|readonly _ucode=.*|readonly _ucode=\"$TEST_DIR/mock_ucode\"|g" "$TEST_DIR/pbr_mock.sh"
sed -i 's|^\. /lib/functions.sh|# . /lib/functions.sh|' "$TEST_DIR/pbr_mock.sh"
sed -i 's|^\. /lib/functions/network.sh|# . /lib/functions/network.sh|' "$TEST_DIR/pbr_mock.sh"
sed -i 's|^\. "${IPKG_INSTROOT}/usr/share/libubox/jshn.sh"|# . /usr/share/libubox/jshn.sh|' "$TEST_DIR/pbr_mock.sh"

(
    stop_forward() { :; }
    enable_forward() { :; }

    . "$TEST_DIR/pbr_mock.sh"

    if ! type service_data >/dev/null 2>&1; then
        echo "FAIL: service_data not found initially!" > "$TEST_DIR/result"
        exit 1
    fi

    start_service "on_start"

    if type service_data >/dev/null 2>&1; then
        echo "FAIL: service_data was NOT unset!" > "$TEST_DIR/result"
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

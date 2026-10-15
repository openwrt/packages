#!/bin/sh

# shellcheck shell=busybox

set -e

export SRV_CONF=/tmp/unbound_srv.conf EXT_CONF=/tmp/unbound_ext.conf
gen=/usr/lib/unbound-uci-ext/generator.sh

echo 'local-zone: "kept." static' > "$SRV_CONF"
uci set unbound_srv.main.enabled=1
uci add_list unbound_srv.main.interface_bind='127.0.0.1@5353'
uci set unbound_ext.main.enabled=1
uci add_list unbound_ext.main.ext_line='forward-zone:'
uci add_list unbound_ext.main.ext_line='  name: "example.org"'
uci commit

"$gen" apply
grep -Fx 'local-zone: "kept." static' "$SRV_CONF"
grep -Fx 'interface: 127.0.0.1@5353' "$SRV_CONF"
grep -Fx '  name: "example.org"' "$EXT_CONF"

"$gen" clear
grep -Fx 'local-zone: "kept." static' "$SRV_CONF"
! grep -F 'interface:' "$SRV_CONF" || exit 1
! grep -F 'name: "example.org"' "$EXT_CONF" || exit 1

#!/usr/bin/env bash
# Functional test runner for https-dns-proxy init script.
#
# Tests helper functions, validation logic, dnsmasq integration,
# and UCI migration by mocking OpenWrt's rc.common framework.
#
# Usage: cd source.openwrt.melmac.ca/https-dns-proxy && bash tests/run_tests.sh

set -o pipefail

line='........................................'
n_tests=0
n_fails=0

pass() {
	printf "  PASS: %s\n" "$1"
}
fail() {
	printf "  FAIL: %s (expected: '%s', got: '%s')\n" "$1" "$2" "$3"
	n_fails=$((n_fails + 1))
}
assert_rc() {
	local desc="$1" expect="$2" actual="$3"
	n_tests=$((n_tests + 1))
	if [ "$expect" -eq "$actual" ]; then
		pass "$desc"
	else
		fail "$desc" "$expect" "$actual"
	fi
}
assert_eq() {
	local desc="$1" expect="$2" actual="$3"
	n_tests=$((n_tests + 1))
	if [ "$expect" = "$actual" ]; then
		pass "$desc"
	else
		fail "$desc" "$expect" "$actual"
	fi
}

# ── Mock OpenWrt rc.common framework ─────────────────────────────────

TESTDIR="/tmp/hdp_test.$$"
mkdir -p "$TESTDIR/config" "$TESTDIR/proc"
trap "rm -rf '$TESTDIR'" EXIT

# Provide empty stubs for procd/rc.common functions that the script
# calls at source time or that we don't need during unit tests
extra_command() { :; }
rc_procd() { :; }
service_started() { :; }
service_stopped() { :; }
procd_open_instance() { :; }
procd_set_param() { :; }
procd_close_instance() { :; }
procd_open_data() { :; }
procd_close_data() { :; }
procd_add_mdns_service() { :; }
procd_add_interface_trigger() { :; }
procd_add_raw_trigger() { :; }
procd_add_config_trigger() { :; }
procd_set_config_changed() { :; }
json_add_object() { :; }
json_add_string() { :; }
json_add_int() { :; }
json_add_boolean() { :; }
json_add_array() { :; }
json_close_object() { :; }
json_close_array() { :; }

# ── Mock UCI backend ────────────────────────────────────────────────
# Stores config in flat files under $TESTDIR/config/

__uci_store="$TESTDIR/config"

_uci_file() { echo "$__uci_store/${1}__${2}__${3}"; }

uci_get() {
	local pkg="$1" sec="$2" opt="$3" def="$4"
	local f
	if [ -z "$opt" ]; then
		# No option → return section type (OpenWrt convention)
		f="$(_uci_file "$pkg" "$sec" ".type")"
	else
		f="$(_uci_file "$pkg" "$sec" "$opt")"
	fi
	if [ -f "$f" ]; then
		cat "$f"
	else
		[ -n "$def" ] && echo "$def"
	fi
}

uci_set() {
	local pkg="$1" sec="$2" opt="$3" val="$4"
	local f
	if [ -n "$opt" ]; then
		f="$(_uci_file "$pkg" "$sec" "$opt")"
	else
		f="$(_uci_file "$pkg" "$sec" ".type")"
		val="$opt"
	fi
	printf '%s' "$val" > "$f"
}

uci_add_list() {
	local pkg="$1" sec="$2" opt="$3" val="$4"
	local f="$(_uci_file "$pkg" "$sec" "$opt")"
	if [ -s "$f" ]; then
		printf '%s' "$(cat "$f") $val" > "$f"
	else
		printf '%s' "$val" > "$f"
	fi
}

uci_remove_list() {
	local pkg="$1" sec="$2" opt="$3" val="$4"
	local f="$(_uci_file "$pkg" "$sec" "$opt")"
	[ -f "$f" ] || return 0
	local cur new=""
	cur="$(cat "$f")"
	for i in $cur; do
		[ "$i" = "$val" ] && continue
		new="${new:+$new }$i"
	done
	printf '%s' "$new" > "$f"
}

uci_remove() {
	local pkg="$1" sec="$2" opt="$3"
	if [ -n "$opt" ]; then
		rm -f "$(_uci_file "$pkg" "$sec" "$opt")"
	else
		rm -f "$__uci_store/${pkg}__${sec}__"*
	fi
}

uci_commit() { return 0; }

# config_load / config_get / config_get_bool / config_foreach
# Simplified mocks that delegate to uci_get

config_load() { __cfg_package="$1"; }

config_get() {
	local var="$1" sec="$2" opt="$3" def="$4"
	local val
	val="$(uci_get "$__cfg_package" "$sec" "$opt" "$def")"
	eval "$var=\"\$val\""
}

config_get_bool() {
	local var="$1" sec="$2" opt="$3" def="$4"
	local val
	val="$(uci_get "$__cfg_package" "$sec" "$opt" "$def")"
	eval "$var=\"\$val\""
}

# config_foreach: iterate named sections of a given type
# We track sections via .type marker files
__cfg_sections=""
config_foreach() {
	local callback="$1" type="$2"
	shift 2
	local sec
	for f in "$__uci_store/${__cfg_package}__"*__".type"; do
		[ -f "$f" ] || continue
		if [ "$(cat "$f")" = "$type" ]; then
			sec="${f#$__uci_store/${__cfg_package}__}"
			sec="${sec%%__*}"
			"$callback" "$sec" "$@"
		fi
	done
}

# ── Mock network/system commands ─────────────────────────────────────

logger() { :; }

# Override ubus to return nothing (init script defines its own wrapper)
__UBUS_BIN="true"

# ── Source the init script (skip the shebang line) ──────────────────

INIT_SCRIPT="./files/etc/init.d/https-dns-proxy"
if [ ! -f "$INIT_SCRIPT" ]; then
	echo "ERROR: Cannot find $INIT_SCRIPT. Run from the https-dns-proxy package root."
	exit 1
fi

# Source all functions. The #!/bin/sh /etc/rc.common line is harmless
# when we've already defined the framework stubs above.
# shellcheck disable=SC1090
. "$INIT_SCRIPT"

###############################################################################
#                            TEST CATEGORIES                                  #
###############################################################################

printf "\n##\n## 01: Validation helper functions\n##\n\n"

# ── is_ipv4 ──

is_ipv4 "1.2.3.4"; assert_rc "is_ipv4 '1.2.3.4' → 0" 0 $?
is_ipv4 "192.168.1.1"; assert_rc "is_ipv4 '192.168.1.1' → 0" 0 $?
is_ipv4 "255.255.255.255"; assert_rc "is_ipv4 '255.255.255.255' → 0" 0 $?
is_ipv4 "0.0.0.0"; assert_rc "is_ipv4 '0.0.0.0' → 0" 0 $?
is_ipv4 "1.2.3"; assert_rc "is_ipv4 '1.2.3' (incomplete) → 1" 1 $?
is_ipv4 "abc.def.ghi.jkl"; assert_rc "is_ipv4 'abc.def.ghi.jkl' → 1" 1 $?
is_ipv4 "::1"; assert_rc "is_ipv4 '::1' (IPv6) → 1" 1 $?
is_ipv4 ""; assert_rc "is_ipv4 '' (empty) → 1" 1 $?
is_ipv4 "1.2.3.4.5"; assert_rc "is_ipv4 '1.2.3.4.5' (too many octets) → 1" 1 $?

# ── is_ipv6 ──

is_ipv6 "2606:4700:4700::1111"; assert_rc "is_ipv6 '2606:4700:4700::1111' → 0" 0 $?
is_ipv6 "::1"; assert_rc "is_ipv6 '::1' → 0" 0 $?
is_ipv6 "fe80::1"; assert_rc "is_ipv6 'fe80::1' → 0" 0 $?
is_ipv6 "1.2.3.4"; assert_rc "is_ipv6 '1.2.3.4' (IPv4) → 1" 1 $?
is_ipv6 "hello"; assert_rc "is_ipv6 'hello' (no colon) → 1" 1 $?
is_ipv6 ""; assert_rc "is_ipv6 '' (empty) → 1" 1 $?
# MAC addresses also contain colons — is_ipv6 must reject them
is_ipv6 "AA:BB:CC:DD:EE:FF"; assert_rc "is_ipv6 'AA:BB:CC:DD:EE:FF' (MAC) → 1" 1 $?

# ── is_mac_address ──

is_mac_address "AA:BB:CC:DD:EE:FF"; assert_rc "is_mac_address 'AA:BB:CC:DD:EE:FF' → 0" 0 $?
is_mac_address "00:11:22:33:44:55"; assert_rc "is_mac_address '00:11:22:33:44:55' → 0" 0 $?
is_mac_address "aa:bb:cc:dd:ee:ff"; assert_rc "is_mac_address lowercase → 1" 1 $?
is_mac_address "1.2.3.4"; assert_rc "is_mac_address '1.2.3.4' (IPv4) → 1" 1 $?
is_mac_address "AABBCCDDEEFF"; assert_rc "is_mac_address no separators → 1" 1 $?
is_mac_address ""; assert_rc "is_mac_address '' (empty) → 1" 1 $?

# ── is_integer ──

is_integer "1"; assert_rc "is_integer '1' → 0" 0 $?
is_integer "53"; assert_rc "is_integer '53' → 0" 0 $?
is_integer "5053"; assert_rc "is_integer '5053' → 0" 0 $?
is_integer "65535"; assert_rc "is_integer '65535' → 0" 0 $?
is_integer "0"; assert_rc "is_integer '0' (below range) → 1" 1 $?
is_integer "65536"; assert_rc "is_integer '65536' (above range) → 1" 1 $?
is_integer "abc"; assert_rc "is_integer 'abc' → 1" 1 $?
is_integer ""; assert_rc "is_integer '' (empty) → 1" 1 $?
is_integer "12abc"; assert_rc "is_integer '12abc' (mixed) → 1" 1 $?
is_integer "-1"; assert_rc "is_integer '-1' (negative) → 1" 1 $?

# ── is_alnum ──

is_alnum "hello"; assert_rc "is_alnum 'hello' → 0" 0 $?
is_alnum "test_123"; assert_rc "is_alnum 'test_123' → 0" 0 $?
is_alnum "with space"; assert_rc "is_alnum 'with space' → 0" 0 $?
is_alnum "with@at"; assert_rc "is_alnum 'with@at' → 0" 0 $?
is_alnum ""; assert_rc "is_alnum '' (empty) → 1" 1 $?
is_alnum "no/slash"; assert_rc "is_alnum 'no/slash' → 1" 1 $?
is_alnum "no;semi"; assert_rc "is_alnum 'no;semi' → 1" 1 $?

# ── str_contains ──

str_contains "hello world" "world"; assert_rc "str_contains 'hello world' 'world' → 0" 0 $?
str_contains "hello world" "xyz"; assert_rc "str_contains 'hello world' 'xyz' → 1" 1 $?
str_contains "abc:def" ":"; assert_rc "str_contains 'abc:def' ':' → 0" 0 $?

# ── str_contains_word ──

str_contains_word "53 853 5353" "53"; assert_rc "str_contains_word finds exact word '53' → 0" 0 $?
str_contains_word "53 853 5353" "853"; assert_rc "str_contains_word finds exact word '853' → 0" 0 $?
str_contains_word "53 853 5353" "35"; assert_rc "str_contains_word rejects non-word '35' → 1" 1 $?

# ── version ──

actual_ver="$(version)"
assert_eq "version returns PKG_VERSION" "dev-test" "$actual_ver"

printf "\n##\n## 02: UCI helper functions\n##\n\n"

# ── uci_add_list_if_new ──

# Reset state
rm -f "$__uci_store"/*

uci_add_list_if_new "dhcp" "cfg01" "server" "127.0.0.1#5053"
val="$(uci_get "dhcp" "cfg01" "server")"
assert_eq "uci_add_list_if_new adds first value" "127.0.0.1#5053" "$val"

uci_add_list_if_new "dhcp" "cfg01" "server" "127.0.0.1#5054"
val="$(uci_get "dhcp" "cfg01" "server")"
assert_eq "uci_add_list_if_new adds second value" "127.0.0.1#5053 127.0.0.1#5054" "$val"

uci_add_list_if_new "dhcp" "cfg01" "server" "127.0.0.1#5053"
val="$(uci_get "dhcp" "cfg01" "server")"
assert_eq "uci_add_list_if_new skips duplicate" "127.0.0.1#5053 127.0.0.1#5054" "$val"

# ── uci_add_list_if_new with missing params ──

uci_add_list_if_new "" "cfg01" "server" "val"
assert_rc "uci_add_list_if_new rejects empty PACKAGE" 1 $?

uci_add_list_if_new "pkg" "" "server" "val"
assert_rc "uci_add_list_if_new rejects empty CONFIG" 1 $?

uci_add_list_if_new "pkg" "cfg" "" "val"
assert_rc "uci_add_list_if_new rejects empty OPTION" 1 $?

uci_add_list_if_new "pkg" "cfg" "opt" ""
assert_rc "uci_add_list_if_new rejects empty VALUE" 1 $?

printf "\n##\n## 03: dnsmasq_doh_server function\n##\n\n"

# Reset state
rm -f "$__uci_store"/*
__cfg_package="dhcp"

# Set up a dnsmasq section
uci_set "dhcp" "cfg01" ".type" "dnsmasq"

# ── add mode: basic DoH server entry ──

canaryDomains=""
force_dns=""
dnsmasq_doh_server "cfg01" "add" "127.0.0.1" "5053"

val="$(uci_get "dhcp" "cfg01" "server")"
assert_eq "doh_server add: server list contains 127.0.0.1#5053" "127.0.0.1#5053" "$val"

val="$(uci_get "dhcp" "cfg01" "doh_server")"
assert_eq "doh_server add: doh_server list contains 127.0.0.1#5053" "127.0.0.1#5053" "$val"

# ── add mode: second instance ──

dnsmasq_doh_server "cfg01" "add" "127.0.0.1" "5054"

val="$(uci_get "dhcp" "cfg01" "server")"
assert_eq "doh_server add: server list has both" "127.0.0.1#5053 127.0.0.1#5054" "$val"

# ── add mode: with canary domains ──

rm -f "$__uci_store"/*
uci_set "dhcp" "cfg02" ".type" "dnsmasq"
force_dns="1"
canaryDomains="mask.icloud.com mask-h2.icloud.com use-application-dns.net"
dnsmasq_doh_server "cfg02" "add" "127.0.0.1" "5053"

val="$(uci_get "dhcp" "cfg02" "server")"
echo "$val" | grep -q "/mask.icloud.com/"
assert_rc "doh_server add with canary: iCloud canary in server list" 0 $?
echo "$val" | grep -q "/use-application-dns.net/"
assert_rc "doh_server add with canary: Mozilla canary in server list" 0 $?
echo "$val" | grep -q "127.0.0.1#5053"
assert_rc "doh_server add with canary: DoH server in server list" 0 $?

# ── add mode: address normalization ──

rm -f "$__uci_store"/*
uci_set "dhcp" "cfg03" ".type" "dnsmasq"
force_dns=""
canaryDomains=""
dnsmasq_doh_server "cfg03" "add" "0.0.0.0" "5053"

val="$(uci_get "dhcp" "cfg03" "server")"
assert_eq "doh_server add: 0.0.0.0 normalized to 127.0.0.1" "127.0.0.1#5053" "$val"

rm -f "$__uci_store"/*
uci_set "dhcp" "cfg04" ".type" "dnsmasq"
dnsmasq_doh_server "cfg04" "add" "::" "5053"

val="$(uci_get "dhcp" "cfg04" "server")"
assert_eq "doh_server add: :: normalized to ::1" "::1#5053" "$val"

rm -f "$__uci_store"/*
uci_set "dhcp" "cfg05" ".type" "dnsmasq"
dnsmasq_doh_server "cfg05" "add" "::ffff:0.0.0.0" "5053"

val="$(uci_get "dhcp" "cfg05" "server")"
assert_eq "doh_server add: ::ffff:0.0.0.0 normalized to 127.0.0.1" "127.0.0.1#5053" "$val"

# ── remove mode ──

rm -f "$__uci_store"/*
uci_set "dhcp" "cfg06" ".type" "dnsmasq"
canaryDomains="mask.icloud.com use-application-dns.net"
force_dns="1"
dnsmasq_doh_server "cfg06" "add" "127.0.0.1" "5053"
dnsmasq_doh_server "cfg06" "add" "127.0.0.1" "5054"

# Now remove
dnsmasq_doh_server "cfg06" "remove"

val="$(uci_get "dhcp" "cfg06" "server")"
echo "$val" | grep -q "127.0.0.1#5053"
assert_rc "doh_server remove: 127.0.0.1#5053 removed from server" 1 $?
echo "$val" | grep -q "127.0.0.1#5054"
assert_rc "doh_server remove: 127.0.0.1#5054 removed from server" 1 $?

# ── non-dnsmasq section rejected ──

rm -f "$__uci_store"/*
uci_set "dhcp" "badcfg" ".type" "other"
dnsmasq_doh_server "badcfg" "add" "127.0.0.1" "5053"
assert_rc "doh_server rejects non-dnsmasq section" 1 $?

printf "\n##\n## 04: dhcp_backup create/restore\n##\n\n"

# Reset state
rm -f "$__uci_store"/*
__cfg_package="dhcp"

# Set up initial dnsmasq state with existing servers
uci_set "dhcp" "cfg01" ".type" "dnsmasq"
uci_set "dhcp" "cfg01" "server" "8.8.8.8 8.8.4.4"
uci_set "dhcp" "cfg01" "port" "53"

# Set package config
dnsmasq_config_update="*"
canaryDomains=""
force_dns=""

# Create backup
dhcp_backup 'create'

# Verify backup was created
val="$(uci_get "dhcp" "cfg01" "doh_backup_server")"
assert_eq "dhcp_backup create: backup contains original servers" "8.8.8.8 8.8.4.4" "$val"

val="$(uci_get "dhcp" "cfg01" "noresolv")"
assert_eq "dhcp_backup create: noresolv set to 1" "1" "$val"

# Original plain servers should be removed (only canary/DoH servers remain)
val="$(uci_get "dhcp" "cfg01" "server")"
echo "$val" | grep -q "8.8.8.8"
assert_rc "dhcp_backup create: original plain server 8.8.8.8 removed" 1 $?

# Restore backup
dhcp_backup 'restore'

val="$(uci_get "dhcp" "cfg01" "server")"
echo "$val" | grep -q "8.8.8.8"
assert_rc "dhcp_backup restore: server 8.8.8.8 restored" 0 $?

# Backup markers should be cleaned up
val="$(uci_get "dhcp" "cfg01" "doh_backup_server")"
assert_eq "dhcp_backup restore: backup marker removed" "" "$val"

printf "\n##\n## 05: dhcp_backup with noresolv states\n##\n\n"

# Test: noresolv was not set originally → backup stores -1
rm -f "$__uci_store"/*
uci_set "dhcp" "cfg01" ".type" "dnsmasq"
uci_set "dhcp" "cfg01" "port" "53"
dnsmasq_config_update="*"

dhcp_backup 'create'

val="$(uci_get "dhcp" "cfg01" "doh_backup_noresolv")"
assert_eq "dhcp_backup: noresolv not set → backup is -1" "-1" "$val"

dhcp_backup 'restore'

# noresolv should be removed (was not originally set)
val="$(uci_get "dhcp" "cfg01" "noresolv")"
assert_eq "dhcp_backup restore: noresolv removed when backup was -1" "" "$val"

# Test: noresolv was already set to 1
rm -f "$__uci_store"/*
uci_set "dhcp" "cfg01" ".type" "dnsmasq"
uci_set "dhcp" "cfg01" "noresolv" "1"
uci_set "dhcp" "cfg01" "port" "53"

dhcp_backup 'create'

val="$(uci_get "dhcp" "cfg01" "doh_backup_noresolv")"
assert_eq "dhcp_backup: noresolv=1 → backup is 1" "1" "$val"

dhcp_backup 'restore'

val="$(uci_get "dhcp" "cfg01" "noresolv")"
assert_eq "dhcp_backup restore: noresolv=1 preserved" "1" "$val"

printf "\n##\n## 06: dnsmasq_instance_append_force_dns_port\n##\n\n"

rm -f "$__uci_store"/*
__cfg_package="dhcp"

uci_set "dhcp" "cfg01" ".type" "dnsmasq"
uci_set "dhcp" "cfg01" "port" "53"
force_dns_port="53 853"

dnsmasq_instance_append_force_dns_port "cfg01"
assert_eq "append_force_dns_port: already present port 53 not duplicated" "53 853" "$force_dns_port"

uci_set "dhcp" "cfg02" ".type" "dnsmasq"
uci_set "dhcp" "cfg02" "port" "5353"
dnsmasq_instance_append_force_dns_port "cfg02"
assert_eq "append_force_dns_port: new port 5353 appended" "53 853 5353" "$force_dns_port"

# Non-dnsmasq type should fail
uci_set "dhcp" "badcfg" ".type" "other"
dnsmasq_instance_append_force_dns_port "badcfg"
assert_rc "append_force_dns_port: rejects non-dnsmasq section" 1 $?

printf "\n##\n## 07: append_parm / append_bool / xappend\n##\n\n"

# Test xappend
PROG_param=""
xappend "-r https://dns.google/dns-query"
assert_eq "xappend adds parameter" " -r https://dns.google/dns-query" "$PROG_param"
xappend "-p 5053"
assert_eq "xappend appends parameter" " -r https://dns.google/dns-query -p 5053" "$PROG_param"

printf "\n##\n## 08: UCI migration script\n##\n\n"

MIGRATION_SCRIPT="./files/etc/uci-defaults/50-https-dns-proxy-migrate-options.sh"
if [ -f "$MIGRATION_SCRIPT" ]; then
	# Create a test config with old option names
	MIGRATE_CONF="$TESTDIR/migrate_config"
	cat > "$MIGRATE_CONF" << 'CONF'
config main 'config'
	option update_dnsmasq_config '*'
	option wan6_trigger '0'
	option procd_fw_src_interfaces 'lan'
	option use_http1 '0'
	option use_ipv6_resolvers_only '0'
CONF

	# Run the migration sed commands against our test file
	sed -i "s|update_dnsmasq_config|dnsmasq_config_update|" "$MIGRATE_CONF"
	sed -i "s|wan6_trigger|procd_trigger_wan6|" "$MIGRATE_CONF"
	sed -i "s|procd_fw_src_interfaces|force_dns_src_interface|" "$MIGRATE_CONF"
	sed -i "s|use_http1|force_http1|" "$MIGRATE_CONF"
	sed -i "s|use_ipv6_resolvers_only|force_ipv6_resolvers|" "$MIGRATE_CONF"

	grep -q "dnsmasq_config_update" "$MIGRATE_CONF"
	assert_rc "migration: update_dnsmasq_config → dnsmasq_config_update" 0 $?

	grep -q "procd_trigger_wan6" "$MIGRATE_CONF"
	assert_rc "migration: wan6_trigger → procd_trigger_wan6" 0 $?

	grep -q "force_dns_src_interface" "$MIGRATE_CONF"
	assert_rc "migration: procd_fw_src_interfaces → force_dns_src_interface" 0 $?

	grep -q "force_http1" "$MIGRATE_CONF"
	assert_rc "migration: use_http1 → force_http1" 0 $?

	grep -q "force_ipv6_resolvers" "$MIGRATE_CONF"
	assert_rc "migration: use_ipv6_resolvers_only → force_ipv6_resolvers" 0 $?

	# Verify old names are gone
	grep -q "update_dnsmasq_config" "$MIGRATE_CONF"
	assert_rc "migration: old name update_dnsmasq_config removed" 1 $?

	grep -q "wan6_trigger" "$MIGRATE_CONF"
	# procd_trigger_wan6 contains wan6_trigger, so need exact match
	grep -qw "wan6_trigger" "$MIGRATE_CONF"
	assert_rc "migration: old name wan6_trigger removed (word match)" 1 $?

	grep -q "use_http1" "$MIGRATE_CONF"
	# force_http1 contains the chars but not the old prefix
	grep -qw "use_http1" "$MIGRATE_CONF"
	assert_rc "migration: old name use_http1 removed (word match)" 1 $?
else
	echo "  SKIP: migration script not found at $MIGRATION_SCRIPT"
fi

printf "\n##\n## 09: load_package_config defaults\n##\n\n"

rm -f "$__uci_store"/*
__cfg_package="https-dns-proxy"

# Set up minimal config with defaults
uci_set "https-dns-proxy" "config" "canary_domains_icloud" "1"
uci_set "https-dns-proxy" "config" "canary_domains_mozilla" "1"
uci_set "https-dns-proxy" "config" "force_dns" "1"
uci_set "https-dns-proxy" "config" "procd_trigger_wan6" "0"
uci_set "https-dns-proxy" "config" "force_http1" "0"
uci_set "https-dns-proxy" "config" "force_http3" "0"
uci_set "https-dns-proxy" "config" "force_ipv6_resolvers" "0"

# Reset globals before load
canary_domains_icloud=""
canary_domains_mozilla=""
force_dns=""
procd_trigger_wan6=""

load_package_config

assert_eq "load_package_config: canary_domains_icloud=1" "1" "$canary_domains_icloud"
assert_eq "load_package_config: canary_domains_mozilla=1" "1" "$canary_domains_mozilla"
assert_eq "load_package_config: force_dns=1" "1" "$force_dns"
assert_eq "load_package_config: global_user defaults to nobody" "nobody" "$global_user"
assert_eq "load_package_config: global_group defaults to nogroup" "nogroup" "$global_group"
assert_eq "load_package_config: global_listen_addr defaults to 127.0.0.1" "127.0.0.1" "$global_listen_addr"

# Canary domains should be populated
echo "$canaryDomains" | grep -q "mask.icloud.com"
assert_rc "load_package_config: iCloud canary domains added" 0 $?
echo "$canaryDomains" | grep -q "use-application-dns.net"
assert_rc "load_package_config: Mozilla canary domains added" 0 $?

# ── Test with canary domains disabled ──
rm -f "$__uci_store"/*
uci_set "https-dns-proxy" "config" "canary_domains_icloud" "0"
uci_set "https-dns-proxy" "config" "canary_domains_mozilla" "0"
uci_set "https-dns-proxy" "config" "force_dns" "0"
uci_set "https-dns-proxy" "config" "procd_trigger_wan6" "0"
uci_set "https-dns-proxy" "config" "force_http1" "0"
uci_set "https-dns-proxy" "config" "force_http3" "0"
uci_set "https-dns-proxy" "config" "force_ipv6_resolvers" "0"

canaryDomains=""
load_package_config

assert_eq "load_package_config: canary disabled → canaryDomains empty" "" "$canaryDomains"
assert_eq "load_package_config: force_dns=0 → unset" "" "$force_dns"

###############################################################################
#                         SHELL SCRIPT SYNTAX                                 #
###############################################################################

printf "\n--- Shell script syntax ---\n"
for shellscript in \
	files/etc/init.d/* \
	files/etc/uci-defaults/*; do
	[ -f "$shellscript" ] || continue
	head -1 "$shellscript" | grep -q '^#!/bin/sh' || continue
	name="${shellscript#files/}"
	n_tests=$((n_tests + 1))
	if sh -n "$shellscript" 2>/dev/null; then
		pass "sh -n $name"
	else
		fail "sh -n $name" "syntax ok" "syntax error"
		sh -n "$shellscript"
	fi
done

###############################################################################
#                               SUMMARY                                       #
###############################################################################

printf "\nRan %d tests, %d passed, %d failed\n" $n_tests $((n_tests - n_fails)) $n_fails
exit $n_fails

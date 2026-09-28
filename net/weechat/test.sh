#!/bin/sh
# shellcheck shell=busybox
# shellcheck disable=SC1091,SC2030,SC2031

pkg="${1:-${PKG_NAME:-weechat}}"

test_binary() {
	local bin="$1"
	[ -x "$bin" ] || { echo "FAIL: $bin is not executable"; exit 1; }
	"$bin" --help | grep -i "Usage:" || { echo "FAIL: $bin --help failed"; exit 1; }
	"$bin" --build-info | grep -i "Build options:" || { echo "FAIL: $bin --build-info failed"; exit 1; }
}

test_plugins() {
	local dir=/usr/lib/weechat/plugins
	[ -d "$dir" ] || { echo "FAIL: plugins directory missing"; exit 1; }
	for p in irc relay buflist; do
		[ -f "$dir/$p.so" ] || { echo "FAIL: $p plugin missing"; exit 1; }
	done
}

test_config_generation() {
	local td="$1"
	mkdir -p "$td/uci" "$td/cfg" "$td/data" "$td/cache" "$td/runtime"

	# Valid config with two enabled servers, one disabled, and special characters
	cat <<'UCI' > "$td/uci/weechat"
config weechat 'weechat'
	option enabled '1'
	option relay_enabled '1'
	option relay_address '127.0.0.1'
	option relay_port '9000'
	option relay_tls '0'
	option relay_password 'p"ass\word'
	option log_enabled '1'
	option log_dir '/tmp/weechat_test_log'

config server 'oftc'
	option enabled '1'
	option address 'irc.oftc.net'
	option port '6697'
	option ssl '1'
	option autoconnect '1'
	option nicks 'test"nick'
	option realname 'Foo "bar"'
	option auth_method 'nickserv'
	option password 'nick\pass"456'
	option autojoin '#openwrt'

config server 'libera'
	option enabled '1'
	option address 'irc.libera.chat'
	option port '6697'
	option ssl '1'
	option autoconnect '1'
	option username 'libuser'
	option auth_method 'sasl_scram_sha_256'
	option password 'saslpass789'
	option autojoin '#openwrt,#openwrt-devel'

config server 'disabled'
	option enabled '0'
	option address 'irc.disabled.example'
	option port '6667'
UCI

	(
		export WEECHAT_CONFIG_DIR="$td/cfg"
		export WEECHAT_DATA_DIR="$td/data"
		export WEECHAT_CACHE_DIR="$td/cache"
		export WEECHAT_RUNTIME_DIR="$td/runtime"
		export UCI_CONFIG_DIR="$td/uci"
		. /lib/functions.sh
		# shellcheck disable=SC1091
		. /etc/init.d/weechat
		config_load weechat
		generate_weechat_configs
	) || { echo "FAIL: generate_weechat_configs failed"; exit 1; }

	# Verify relay.conf
	[ -f "$td/cfg/relay.conf" ] || { echo "FAIL: relay.conf not generated"; exit 1; }
	grep -F 'password = "p\"ass\\word"' "$td/cfg/relay.conf" || { echo "FAIL: relay.conf password escaping"; exit 1; }
	grep -F 'weechat = 9000' "$td/cfg/relay.conf" || { echo "FAIL: relay.conf port"; exit 1; }

	# Verify irc.conf
	[ -f "$td/cfg/irc.conf" ] || { echo "FAIL: irc.conf not generated"; exit 1; }
	grep -F 'oftc.addresses = "irc.oftc.net/6697"' "$td/cfg/irc.conf" || { echo "FAIL: irc.conf oftc address"; exit 1; }
	grep -F 'oftc.nicks = "test\"nick"' "$td/cfg/irc.conf" || { echo "FAIL: irc.conf nicks escaping"; exit 1; }
	grep -F 'oftc.realname = "Foo \"bar\""' "$td/cfg/irc.conf" || { echo "FAIL: irc.conf realname escaping"; exit 1; }
	grep -F 'libera.sasl_mechanism = scram-sha-256' "$td/cfg/irc.conf" || { echo "FAIL: irc.conf libera sasl"; exit 1; }
	grep -F 'libera.sasl_password = "saslpass789"' "$td/cfg/irc.conf" || { echo "FAIL: irc.conf libera password"; exit 1; }

	# Verify disabled server is NOT in irc.conf
	if grep 'disabled\.' "$td/cfg/irc.conf"; then
		echo "FAIL: disabled server should not appear in irc.conf"
		exit 1
	fi

	# Verify logger.conf
	[ -f "$td/cfg/logger.conf" ] || { echo "FAIL: logger.conf not generated"; exit 1; }
	grep -F 'auto_log = on' "$td/cfg/logger.conf" || { echo "FAIL: logger.conf auto_log"; exit 1; }
}

test_security_validation() {
	local td="$1"
	mkdir -p "$td/uci_sec"

	# Relay enabled without password must fail
	cat <<'UCI' > "$td/uci_sec/weechat"
config weechat 'weechat'
	option enabled '1'
	option relay_enabled '1'
	option relay_password ''
UCI

	if (
		export WEECHAT_CONFIG_DIR="$td/cfg"
		export UCI_CONFIG_DIR="$td/uci_sec"
		. /lib/functions.sh
		# shellcheck disable=SC1091
		. /etc/init.d/weechat
		start_service
	) 2>/dev/null; then
		echo "FAIL: should refuse relay without password"
		exit 1
	fi

	# Relay TLS enabled without certificate must fail
	cat <<'UCI' > "$td/uci_sec/weechat"
config weechat 'weechat'
	option enabled '1'
	option relay_enabled '1'
	option relay_password 'secret'
	option relay_tls '1'
	option relay_cert_key '/nonexistent/tls/relay.pem'
UCI

	if (
		export WEECHAT_CONFIG_DIR="$td/cfg"
		export UCI_CONFIG_DIR="$td/uci_sec"
		. /lib/functions.sh
		# shellcheck disable=SC1091
		. /etc/init.d/weechat
		start_service
	) 2>/dev/null; then
		echo "FAIL: should refuse relay TLS without certificate"
		exit 1
	fi
}

test_runtime() {
	local td="$1"
	local bin="/usr/bin/weechat-headless"
	[ -x "$bin" ] || bin="/usr/bin/weechat"

	# Clean startup and exit
	"$bin" --stdout --dir "$td" -r "/quit" >/dev/null 2>&1 || {
		echo "FAIL: $bin execution test failed"; exit 1;
	}

	# Startup with generated configs
	if [ -f "$td/cfg/irc.conf" ]; then
		"$bin" --stdout --dir "$td/cfg:$td/data:$td/cache:$td/runtime" -r "/quit" >/dev/null 2>&1 || {
			echo "FAIL: WeeChat failed with generated configs"; exit 1;
		}
	fi
}

# --- Main ---

case "$pkg" in
weechat-minimal)
	test_binary /usr/bin/weechat-headless
	;;
weechat-full)
	test_binary /usr/bin/weechat
	test_binary /usr/bin/weechat-headless
	;;
weechat)
	[ -x /usr/bin/weechat-headless ] && test_binary /usr/bin/weechat-headless
	[ -x /usr/bin/weechat ] && test_binary /usr/bin/weechat
	;;
*)
	exit 0
	;;
esac

test_plugins

[ -x /etc/init.d/weechat ] || { echo "FAIL: init script missing"; exit 1; }
[ -f /etc/config/weechat ] || { echo "FAIL: UCI config missing"; exit 1; }
[ -d /etc/weechat ] || { echo "FAIL: /etc/weechat directory missing"; exit 1; }

TEST_DIR="$(mktemp -d /tmp/weechat_test.XXXXXX)"
[ -d "$TEST_DIR" ] || { echo "FAIL: could not create temp directory"; exit 1; }
trap 'rm -rf "$TEST_DIR"' EXIT

test_runtime "$TEST_DIR"

if [ -s /lib/functions.sh ] && [ -s /etc/rc.common ] && [ -x /etc/init.d/weechat ]; then
	test_security_validation "$TEST_DIR"
	test_config_generation "$TEST_DIR"
	test_runtime "$TEST_DIR"
fi

echo "$pkg: functional tests PASSED"

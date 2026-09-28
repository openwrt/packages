#!/bin/sh
# shellcheck shell=busybox
# shellcheck disable=SC1091,SC2030,SC2031,SC2329

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

# Run start_service from the init script against a test UCI directory.
# procd is not available here, so its helpers are stubbed and only the
# init script's own checks can make it fail. The stubs record the
# instance parameters in $td/procd.args.
run_start_service() {
	local td="$1" uci_dir="$2"
	(
		export WEECHAT_BASE_DIR="$td/etc"
		export WEECHAT_RUN_DIR="$td/run"
		export WEECHAT_LOG_DIR="$td/log/weechat"
		export UCI_CONFIG_DIR="$uci_dir"
		. /lib/functions.sh
		. /etc/init.d/weechat
		procd_open_instance() { : > "$td/procd.args"; }
		procd_set_param() { printf '%s\n' "$*" >> "$td/procd.args"; }
		procd_close_instance() { :; }
		start_service
	) 2>/dev/null
}

check_mode_owner() {
	local path="$1" want="$2" got
	# shellcheck disable=SC2012
	got="$(ls -ld "$path" | awk '{print $1, $3, $4}')"
	[ "$got" = "$want" ] || { echo "FAIL: $path is '$got', expected '$want'"; exit 1; }
}

# Print the value WeeChat sees for an option after evaluation, as hex
run_eval_hex() {
	local bin="$1" dirs="$2" option="$3"
	"$bin" --dir "$dirs" --no-connect \
		-r "/eval /print -stdout HEX=\${base_encode:16,\${eval:\${$option}}}\\n;/quit" 2>/dev/null |
		sed -n 's/.*HEX=\([0-9A-F]*\).*/\1/p'
}

test_config_generation() {
	local td="$1" bin="$2"
	local cfg="$td/etc/config" dirs
	mkdir -p "$td/uci"

	# Valid config with three enabled servers, one disabled, passwords that
	# WeeChat would otherwise split on ';' or evaluate as ${...}, and other
	# values with quotes and backslashes, which WeeChat reads as they are
	cat <<'UCI' > "$td/uci/weechat"
config weechat 'weechat'
	option enabled '1'
	option relay_enabled '1'
	option relay_address '127.0.0.1'
	option relay_port '39013'
	option relay_tls '0'
	option relay_password 'p"ass\word;/print x ${info:version}'
	option log_enabled '1'

config server 'oftc'
	option enabled '1'
	option address 'irc.oftc.net'
	option port '6697'
	option ssl '1'
	option autoconnect '1'
	option nicks 'test"nick\foo'
	option username 'foo"bar\baz'
	option realname 'Foo "bar" \ baz'
	option auth_method 'nickserv'
	option password 'nick\pass;/exec -sh id'
	option autojoin '#foo,#bar k\ey'

config server 'libera'
	option enabled '1'
	option address 'irc.libera.chat'
	option port '6697'
	option ssl '1'
	option autoconnect '1'
	option nicks 'libnick,libnick_'
	option username 'libuser'
	option auth_method 'sasl_scram_sha_256'
	option password 'sasl"pass}${info:version}789'
	option autojoin '#openwrt,#openwrt-devel'

config server 'sasl2'
	option address 'irc.example.net'
	option auth_method 'sasl_plain'
	option sasl_username 'acc"ount\x'
	option password 'secret'

config server 'disabled'
	option enabled '0'
	option address 'irc.disabled.example'
	option port '6667'
UCI

	run_start_service "$td" "$td/uci" || { echo "FAIL: start_service rejected a valid config"; exit 1; }

	# The daemon runs as weechat with the generated directories
	grep -x 'user weechat' "$td/procd.args" || { echo "FAIL: daemon does not run as user weechat"; exit 1; }
	grep -x 'group weechat' "$td/procd.args" || { echo "FAIL: daemon does not run as group weechat"; exit 1; }
	dirs="$(sed -n 's/^command .* --dir \([^ ]*\).*$/\1/p' "$td/procd.args")"
	[ "$dirs" = "$cfg:$td/etc/data:$td/run/cache:$td/run/runtime" ] ||
		{ echo "FAIL: unexpected --dir '$dirs'"; exit 1; }

	# Directory layout and ownership
	check_mode_owner "$td/etc" "drwxr-xr-x root root"
	check_mode_owner "$cfg" "drwxrwx--T root weechat"
	check_mode_owner "$td/etc/data" "drwx------ weechat weechat"
	check_mode_owner "$td/etc/tls" "drwxr-xr-x root root"
	check_mode_owner "$td/run" "drwxr-xr-x root root"
	check_mode_owner "$td/run/cache" "drwx------ weechat weechat"
	check_mode_owner "$td/run/runtime" "drwx------ weechat weechat"
	check_mode_owner "$cfg/irc.conf" "-rw------- weechat weechat"
	check_mode_owner "$td/log" "drwxr-xr-x root root"
	check_mode_owner "$td/log/weechat" "drwxr-x--- weechat weechat"

	# Verify relay.conf
	[ -f "$cfg/relay.conf" ] || { echo "FAIL: relay.conf not generated"; exit 1; }
	grep -F 'ipv4.weechat = 39013' "$cfg/relay.conf" || { echo "FAIL: relay.conf port"; exit 1; }

	# Verify irc.conf
	[ -f "$cfg/irc.conf" ] || { echo "FAIL: irc.conf not generated"; exit 1; }
	grep -F 'oftc.addresses = "irc.oftc.net/6697"' "$cfg/irc.conf" || { echo "FAIL: irc.conf oftc address"; exit 1; }
	grep -F 'libera.sasl_mechanism = scram-sha-256' "$cfg/irc.conf" || { echo "FAIL: irc.conf libera sasl"; exit 1; }
	grep -F 'libera.sasl_username = "libnick"' "$cfg/irc.conf" || { echo "FAIL: SASL account is not the first nick"; exit 1; }

	# WeeChat splits the command on ';' before evaluating it, which the
	# eval checks below cannot see, so the password must be encoded
	# shellcheck disable=SC2016
	grep -xF 'oftc.command = "/msg nickserv identify ${base_decode:16,6e69636b5c706173733b2f65786563202d7368206964}"' "$cfg/irc.conf" ||
		{ echo "FAIL: NickServ password is not encoded"; exit 1; }

	# Verify disabled server is NOT in irc.conf
	if grep 'disabled\.' "$cfg/irc.conf"; then
		echo "FAIL: disabled server should not appear in irc.conf"
		exit 1
	fi

	# Verify logger.conf
	[ -f "$cfg/logger.conf" ] || { echo "FAIL: logger.conf not generated"; exit 1; }
	grep -F 'auto_log = on' "$cfg/logger.conf" || { echo "FAIL: logger.conf auto_log"; exit 1; }
	grep -F "path = \"$td/log/weechat\"" "$cfg/logger.conf" || { echo "FAIL: logger.conf path"; exit 1; }

	# Verify what WeeChat itself reads back, compared as hex of the UCI values
	[ "$(run_eval_hex "$bin" "$dirs" relay.network.password)" = \
	  "70226173735C776F72643B2F7072696E74207820247B696E666F3A76657273696F6E7D" ] ||
		{ echo "FAIL: WeeChat reads a different relay password"; exit 1; }
	[ "$(run_eval_hex "$bin" "$dirs" irc.server.oftc.nicks)" = "74657374226E69636B5C666F6F" ] ||
		{ echo "FAIL: WeeChat reads different nicks"; exit 1; }
	[ "$(run_eval_hex "$bin" "$dirs" irc.server.oftc.username)" = "666F6F226261725C62617A" ] ||
		{ echo "FAIL: WeeChat reads a different username"; exit 1; }
	[ "$(run_eval_hex "$bin" "$dirs" irc.server.oftc.realname)" = "466F6F202262617222205C2062617A" ] ||
		{ echo "FAIL: WeeChat reads a different real name"; exit 1; }
	[ "$(run_eval_hex "$bin" "$dirs" irc.server.oftc.autojoin)" = "23666F6F2C23626172206B5C6579" ] ||
		{ echo "FAIL: WeeChat reads a different autojoin"; exit 1; }
	[ "$(run_eval_hex "$bin" "$dirs" irc.server.sasl2.sasl_username)" = "616363226F756E745C78" ] ||
		{ echo "FAIL: WeeChat reads a different SASL username"; exit 1; }
	[ "$(run_eval_hex "$bin" "$dirs" irc.server.oftc.command)" = \
	  "2F6D7367206E69636B73657276206964656E74696679206E69636B5C706173733B2F65786563202D7368206964" ] ||
		{ echo "FAIL: WeeChat reads a different NickServ command"; exit 1; }
	[ "$(run_eval_hex "$bin" "$dirs" irc.server.libera.sasl_password)" = \
	  "7361736C22706173737D247B696E666F3A76657273696F6E7D373839" ] ||
		{ echo "FAIL: WeeChat reads a different SASL password"; exit 1; }

	# The relay must listen on 127.0.0.1:39013 (0x9865). /proc/net/tcp
	# prints the address in host byte order, and the socket has to belong
	# to the WeeChat started here.
	local pid inode fd tries=10 listening=0
	# Through cat, as grep fails on a missing tcp6 even after a match
	if cat /proc/net/tcp /proc/net/tcp6 2>/dev/null | grep -E ':9865 [0-9A-F]+:0000 0A'; then
		echo "FAIL: port 39013 is already in use, cannot check the relay"
		exit 1
	fi
	"$bin" --dir "$dirs" --no-connect >/dev/null 2>&1 &
	pid=$!
	while [ "$tries" -gt 0 ]; do
		inode="$(awk '$2 ~ /^(0100007F|7F000001):9865$/ && $4 == "0A" { print $10 }' /proc/net/tcp)"
		if [ -n "$inode" ]; then
			for fd in "/proc/$pid/fd/"*; do
				[ "$(readlink "$fd")" = "socket:[$inode]" ] && listening=1
			done
		fi
		[ "$listening" -eq 1 ] && break
		tries=$((tries - 1))
		sleep 1
	done
	kill "$pid"
	wait "$pid"
	[ "$listening" -eq 1 ] || { echo "FAIL: relay does not listen on 127.0.0.1:39013"; exit 1; }

	# A symlink to a directory planted by the daemon must not make root
	# move the generated file into that directory
	mkdir "$td/trap"
	rm -f "$cfg/irc.conf"
	ln -s "$td/trap" "$cfg/irc.conf"
	run_start_service "$td" "$td/uci" || { echo "FAIL: start_service failed after irc.conf was replaced by a symlink"; exit 1; }
	[ -z "$(ls -A "$td/trap")" ] || { echo "FAIL: root moved a generated file into a symlinked directory"; exit 1; }
	[ -f "$cfg/irc.conf" ] && [ ! -L "$cfg/irc.conf" ] || { echo "FAIL: irc.conf was not regenerated"; exit 1; }

	# A file with the right content but a changed mode or owner, and a
	# symlink to a file with the right content, must be replaced
	chmod 0644 "$cfg/relay.conf"
	chown root:root "$cfg/relay.conf"
	cp "$cfg/irc.conf" "$td/irc.copy"
	rm -f "$cfg/irc.conf"
	ln -s "$td/irc.copy" "$cfg/irc.conf"
	run_start_service "$td" "$td/uci" || { echo "FAIL: start_service failed with changed config files"; exit 1; }
	check_mode_owner "$cfg/relay.conf" "-rw------- weechat weechat"
	[ -f "$cfg/irc.conf" ] && [ ! -L "$cfg/irc.conf" ] || { echo "FAIL: symlinked irc.conf was kept"; exit 1; }
	check_mode_owner "$cfg/irc.conf" "-rw------- weechat weechat"
}

# Each config must be refused before start_service touches the filesystem.
# The parent directory exists, so without the check start_service would
# succeed, which the last case below confirms.
expect_refused() {
	local td="$1" msg="$2"

	if run_start_service "$td/sec" "$td/uci_sec"; then
		echo "FAIL: $msg"
		exit 1
	fi
	if [ -e "$td/sec/etc" ] || [ -e "$td/sec/run" ]; then
		echo "FAIL: rejected config still touched the filesystem ($msg)"
		exit 1
	fi
}

test_security_validation() {
	local td="$1"
	mkdir -p "$td/uci_sec" "$td/sec"

	cat <<'UCI' > "$td/uci_sec/weechat"
config weechat 'weechat'
	option enabled '1'
	option relay_enabled '1'
	option relay_password ''
UCI
	expect_refused "$td" "should refuse relay without password"

	cat <<'UCI' > "$td/uci_sec/weechat"
config weechat 'weechat'
	option enabled '1'
	option relay_enabled '1'
	option relay_password 'secret'
	option relay_tls '1'
	option relay_cert_key '/nonexistent/tls/relay.pem'
UCI
	expect_refused "$td" "should refuse relay TLS without certificate"

	# A newline must not be able to add lines to the generated files
	cat <<'UCI' > "$td/uci_sec/weechat"
config weechat 'weechat'
	option enabled '1'

config server 'x'
	option address 'irc.example.org'
	option realname 'a
x.command = "/exec -sh id"'
UCI
	expect_refused "$td" "should refuse a newline in a server option"

	# A valid server after the broken one must not hide the error
	cat <<'UCI' > "$td/uci_sec/weechat"
config weechat 'weechat'
	option enabled '1'

config server 'x'
	option address 'irc.example.org'
	option realname 'a
x.command = "/exec -sh id"'

config server 'y'
	option address 'irc.example.net'
UCI
	expect_refused "$td" "should refuse a broken server followed by a valid one"

	# NickServ without a password must fail instead of silently skipping auth
	cat <<'UCI' > "$td/uci_sec/weechat"
config weechat 'weechat'
	option enabled '1'

config server 'x'
	option address 'irc.example.org'
	option auth_method 'nickserv'
UCI
	expect_refused "$td" "should refuse NickServ without a password"

	cat <<'UCI' > "$td/uci_sec/weechat"
config weechat 'weechat'
	option enabled '1'
	option relay_enabled '1'
	option relay_address '192.168.1.1/24'
	option relay_password 'secret'
UCI
	expect_refused "$td" "should refuse a relay address that is not an IP address"

	# WeeChat cannot bind to this and would silently not listen
	cat <<'UCI' > "$td/uci_sec/weechat"
config weechat 'weechat'
	option enabled '1'
	option relay_enabled '1'
	option relay_address '127.000.000.001'
	option relay_password 'secret'
UCI
	expect_refused "$td" "should refuse an IPv4 address with leading zeros"

	# WeeChat cannot bind to an address with a zone either
	cat <<'UCI' > "$td/uci_sec/weechat"
config weechat 'weechat'
	option enabled '1'
	option relay_enabled '1'
	option relay_address 'fe80::1%br-lan'
	option relay_password 'secret'
UCI
	expect_refused "$td" "should refuse an IPv6 address with a zone"

	local addr
	for addr in ':' '1:' '::::' '1:::2' '1::2::3' '12345::'; do
		cat <<UCI > "$td/uci_sec/weechat"
config weechat 'weechat'
	option enabled '1'
	option relay_enabled '1'
	option relay_address '$addr'
	option relay_password 'secret'
UCI
		expect_refused "$td" "should refuse the relay address '$addr'"
	done

	# Blank passwords count as missing
	cat <<'UCI' > "$td/uci_sec/weechat"
config weechat 'weechat'
	option enabled '1'
	option relay_enabled '1'
	option relay_password '   '
UCI
	expect_refused "$td" "should refuse a relay password made of spaces"

	cat <<'UCI' > "$td/uci_sec/weechat"
config weechat 'weechat'
	option enabled '1'

config server 'x'
	option address 'irc.example.org'
	option auth_method 'nickserv'
	option password '  '
UCI
	expect_refused "$td" "should refuse a NickServ password made of spaces"

	# UCI decides which servers exist, an enabled one needs an address
	cat <<'UCI' > "$td/uci_sec/weechat"
config weechat 'weechat'
	option enabled '1'

config server 'x'
	option enabled '1'
	option nicks 'someone'
UCI
	expect_refused "$td" "should refuse an enabled server without address"

	# WeeChat replaces $nick, $channel and $server in the NickServ command
	cat <<'UCI' > "$td/uci_sec/weechat"
config weechat 'weechat'
	option enabled '1'

config server 'x'
	option address 'irc.example.org'
	option auth_method 'nickserv'
	option password 'pa$nick'
UCI
	expect_refused "$td" "should refuse a NickServ password that WeeChat would alter"

	# WeeChat would evaluate this and send secured data as the real name
	cat <<'UCI' > "$td/uci_sec/weechat"
config weechat 'weechat'
	option enabled '1'

config server 'x'
	option address 'irc.example.org'
	option realname '${sec.data.relay}'
UCI
	expect_refused "$td" "should refuse an expression in a server option"

	# The section name becomes the WeeChat server name
	cat <<'UCI' > "$td/uci_sec/weechat"
config weechat 'weechat'
	option enabled '1'

config server
	option address 'irc.example.org'
UCI
	expect_refused "$td" "should refuse an anonymous server section"

	cat <<'UCI' > "$td/uci_sec/weechat"
config weechat 'weechat'
	option enabled '1'

config server 'x'
	option address 'irc.example.org'
	option auth_method 'sasl_plain'
	option password 'secret'
UCI
	expect_refused "$td" "should refuse SASL without an account name"

	# The account defaults to the first nickname, which is empty here
	cat <<'UCI' > "$td/uci_sec/weechat"
config weechat 'weechat'
	option enabled '1'

config server 'x'
	option address 'irc.example.org'
	option nicks ',second'
	option auth_method 'sasl_plain'
	option password 'secret'
UCI
	expect_refused "$td" "should refuse SASL when the first nickname is empty"

	cat <<'UCI' > "$td/uci_sec/weechat"
config weechat 'weechat'
	option enabled '1'

config server 'x'
	option address 'irc.example.org'
	option nicks 'someone'
	option sasl_username '  '
	option auth_method 'sasl_plain'
	option password 'secret'
UCI
	expect_refused "$td" "should refuse a SASL username made of spaces"

	# Control: the same setup with a valid config must start. Root must not
	# create a log directory other than the default one.
	cat <<UCI > "$td/uci_sec/weechat"
config weechat 'weechat'
	option enabled '1'
	option relay_enabled '1'
	option relay_password 'secret'
	option log_enabled '1'
	option log_dir '$td/sec/logs'

config server 'x'
	option address 'irc.example.org'
	option auth_method 'nickserv'
	option password 'secret'
UCI
	run_start_service "$td/sec" "$td/uci_sec" || { echo "FAIL: start_service rejected a valid config"; exit 1; }
	if [ -e "$td/sec/logs" ]; then
		echo "FAIL: root created a log directory other than the default one"
		exit 1
	fi

	# Valid relay addresses must be accepted
	for addr in '2001:db8::1' '::' '::ffff:192.168.1.1' '192.168.1.1'; do
		mkdir -p "$td/addr"
		cat <<UCI > "$td/uci_sec/weechat"
config weechat 'weechat'
	option enabled '1'
	option relay_enabled '1'
	option relay_address '$addr'
	option relay_password 'secret'
UCI
		run_start_service "$td/addr" "$td/uci_sec" || { echo "FAIL: start_service rejected the relay address '$addr'"; exit 1; }
	done
}

test_runtime() {
	local td="$1" bin="$2"

	# Clean startup and exit
	"$bin" --stdout --dir "$td/plain" -r "/quit" >/dev/null 2>&1 || {
		echo "FAIL: $bin execution test failed"; exit 1;
	}
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

BIN=/usr/bin/weechat-headless
TEST_DIR="$(mktemp -d /tmp/weechat_test.XXXXXX)"
[ -d "$TEST_DIR" ] || { echo "FAIL: could not create temp directory"; exit 1; }
trap 'rm -rf "$TEST_DIR"' EXIT
chmod 0755 "$TEST_DIR"

test_runtime "$TEST_DIR" "$BIN"

if [ -s /lib/functions.sh ] && [ -s /etc/rc.common ]; then
	test_security_validation "$TEST_DIR"
	test_config_generation "$TEST_DIR" "$BIN"
fi

echo "$pkg: functional tests PASSED"

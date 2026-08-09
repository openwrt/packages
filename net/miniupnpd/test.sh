#!/bin/sh
# Functional tests for the miniupnpd IGD/NAT-PMP daemon variants. The package
# version is checked by the build framework, so it is not tested here.

bin=/usr/sbin/miniupnpd

# Binary, runtime linking and the OpenWrt integration files common to both
# firewall variants. "miniupnpd -h" exits non-zero but must print the usage
# banner, which also proves every shared-library dep resolves at runtime.
common_checks() {
	[ -x "$bin" ] || { echo "FAIL: $bin missing or not executable"; exit 1; }
	"$bin" -h 2>&1 | grep -q "^Usage:" \
		|| { echo "FAIL: 'miniupnpd -h' printed no usage banner"; exit 1; }
	[ -x /etc/init.d/miniupnpd ] || { echo "FAIL: init script missing"; exit 1; }
	grep -q "USE_PROCD=1" /etc/init.d/miniupnpd \
		|| { echo "FAIL: init script is not a procd service"; exit 1; }
	grep -q "config upnpd" /etc/config/upnpd \
		|| { echo "FAIL: /etc/config/upnpd is not valid UCI"; exit 1; }
	[ -f /etc/hotplug.d/iface/50-miniupnpd ] \
		|| { echo "FAIL: iface hotplug script missing"; exit 1; }
}

# The config-file parser runs before any firewall or socket setup, so it can be
# exercised inside the CI container. A bogus option must be rejected non-zero
# and a minimal valid config must be accepted without a parse error.
config_checks() {
	good="/tmp/miniupnpd-good.$$.conf"
	bad="/tmp/miniupnpd-bad.$$.conf"
	log="/tmp/miniupnpd.$$.log"
	cat > "$good" <<-EOF
		ext_ifname=lo
		listening_ip=127.0.0.1
		port=5000
		enable_natpmp=yes
		enable_upnp=yes
		notify_interval=60
		uuid=00000000-0000-0000-0000-000000000000
	EOF
	echo "not_a_real_option=1" > "$bad"

	if "$bin" -f "$bad" -d > "$log" 2>&1; then
		echo "FAIL: invalid config option was accepted"
		rm -f "$good" "$bad" "$log"; exit 1
	fi
	grep -qiE "invalid option|Error reading configuration" "$log" \
		|| { echo "FAIL: no parse error reported for bad config"
		     rm -f "$good" "$bad" "$log"; exit 1; }

	# A valid config: launch briefly and confirm the parser accepted it. The
	# daemon may later stop at firewall/socket setup in the container; that is
	# past the parser and irrelevant to this check.
	"$bin" -f "$good" -d > "$log" 2>&1 &
	mpid=$!
	sleep 2
	kill "$mpid" 2>/dev/null
	wait "$mpid" 2>/dev/null
	if grep -qiE "invalid option|Error reading configuration" "$log"; then
		echo "FAIL: valid config was rejected by the parser"
		rm -f "$good" "$bad" "$log"; exit 1
	fi
	rm -f "$good" "$bad" "$log"
}

case "$1" in
miniupnpd-iptables)
	# iptables variant ships the fw3 shell include. Its uci-defaults seeder
	# is not checked here: the postinst sources /etc/uci-defaults/* and
	# deletes each script that succeeds, so it is gone by now.
	common_checks
	[ -f /usr/share/miniupnpd/firewall.include ] || { echo "FAIL: firewall.include missing"; exit 1; }
	sh -n /usr/share/miniupnpd/firewall.include \
		|| { echo "FAIL: firewall.include has a shell syntax error"; exit 1; }
	config_checks
	echo "miniupnpd-iptables: all functional tests passed"
	;;
miniupnpd-nftables)
	# nftables variant ships the nft rule fragments consumed by fw4.
	common_checks
	for f in table-post/20-miniupnpd.nft \
		chain-post/dstnat/20-miniupnpd.nft \
		chain-post/forward/20-miniupnpd.nft \
		chain-post/srcnat/20-miniupnpd.nft; do
		[ -s "/usr/share/nftables.d/$f" ] \
			|| { echo "FAIL: nft fragment $f missing or empty"; exit 1; }
	done
	config_checks
	echo "miniupnpd-nftables: all functional tests passed"
	;;
*)
	echo "Untested package: $1" >&2
	exit 1
	;;
esac

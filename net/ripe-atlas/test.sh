#!/bin/sh

MEAS_DIR=/usr/lib/ripe-atlas/measurement
SCRIPT_DIR=/usr/lib/ripe-atlas/scripts
SHARE_DIR=/usr/share/ripe-atlas
BUSYBOX="$MEAS_DIR/busybox"

# Atlas measurement applets. Standard busybox applets are deliberately not
# built in, so only these plus the patched telnetd are expected.
APPLETS="atlasinit buddyinfo condmv date dfrm eooqd eperd evhttpget evntp \
evping evsslgetcert evtdig evtraceroute httppost onlyuptime perd rchoose \
rptaddrs rptra6 rptuptime rxtxrpt telnetd"

check_applets() {
	for applet in $APPLETS; do
		path="$MEAS_DIR/$applet"
		[ -e "$path" ] || { echo "FAIL: missing applet: $applet"; exit 1; }
		if [ -L "$path" ]; then
			target=$(readlink "$path")
			case "$target" in
			busybox|./busybox|"$BUSYBOX") ;;
			*) echo "FAIL: applet $applet -> unexpected target: $target"; exit 1 ;;
			esac
		elif [ -f "$path" ]; then
			bb_inode=$(ls -i "$BUSYBOX" | awk '{print $1}')
			ap_inode=$(ls -i "$path" | awk '{print $1}')
			[ "$bb_inode" = "$ap_inode" ] || {
				echo "FAIL: applet $applet is not a busybox hardlink"; exit 1; }
		else
			echo "FAIL: applet $applet is neither symlink nor regular file"
			exit 1
		fi
	done

	applet_list=$("$BUSYBOX" --list 2>/dev/null) || {
		echo "FAIL: 'busybox --list' failed"; exit 1; }
	for applet in $APPLETS; do
		echo "$applet_list" | grep -qx "$applet" || {
			echo "FAIL: applet '$applet' missing from 'busybox --list'"; exit 1; }
	done
}

# Catch crash signals (132/134/137/139) and hangs. Output is not asserted
# because the applet CLIs vary across Atlas releases.
run_applet_smoke() {
	name="$1"; shift
	out=$(timeout 5 "$BUSYBOX" "$name" "$@" 2>&1); rc=$?
	case "$rc" in
	124) echo "FAIL: applet $name timed out"; exit 1 ;;
	132|134|137|139)
		echo "FAIL: applet $name crashed (rc=$rc)"; echo "$out"; exit 1 ;;
	esac
}

case "$1" in
ripe-atlas-common)
	[ -x "$BUSYBOX" ] || { echo "FAIL: $BUSYBOX not installed"; exit 1; }
	[ -s "$BUSYBOX" ] || { echo "FAIL: $BUSYBOX is empty"; exit 1; }
	check_applets

	# The probe drops to this user, so it must exist with a matching group.
	uid=$(awk -F: '$1=="ripe-atlas" {print $3}' /etc/passwd)
	[ -n "$uid" ] || { echo "FAIL: user 'ripe-atlas' missing from /etc/passwd"; exit 1; }
	gid=$(awk -F: '$1=="ripe-atlas" {print $3}' /etc/group)
	[ -n "$gid" ] || { echo "FAIL: group 'ripe-atlas' missing from /etc/group"; exit 1; }

	# Exercise the applets that need no network peer.
	run_applet_smoke rptuptime
	run_applet_smoke dfrm -A 9018 /tmp 1 /tmp /tmp
	run_applet_smoke condmv /tmp/atlas-no-such-src /tmp/atlas-no-such-dst
	[ -r /proc/uptime ] && run_applet_smoke onlyuptime
	[ -r /proc/buddyinfo ] && run_applet_smoke buddyinfo 1 /dev/null
	[ -r /proc/net/dev ] && run_applet_smoke rxtxrpt -A 9999

	# The shell libraries the init and reginit source at runtime.
	for f in common.sh config.sh paths.lib.sh json.lib.sh support.lib.sh \
		 linux-functions.sh reginit.sh; do
		[ -s "$SCRIPT_DIR/$f" ] || { echo "FAIL: $SCRIPT_DIR/$f missing or empty"; exit 1; }
	done
	for f in $(ls "$SCRIPT_DIR"/*.sh 2>/dev/null); do
		sh -n "$f" || { echo "FAIL: $f is not valid shell"; exit 1; }
	done

	[ -s "$SHARE_DIR/capabilities.json" ] || {
		echo "FAIL: $SHARE_DIR/capabilities.json missing or empty"; exit 1; }
	jsonfilter -i "$SHARE_DIR/capabilities.json" -e '@.effective' >/dev/null || {
		echo "FAIL: capabilities.json is not valid JSON"; exit 1; }
	jsonfilter -i "$SHARE_DIR/capabilities.json" -e '@.effective[*]' | grep -qx CAP_NET_RAW || {
		echo "FAIL: capabilities.json does not grant CAP_NET_RAW"; exit 1; }

	[ -x /etc/init.d/ripe-atlas ] || { echo "FAIL: /etc/init.d/ripe-atlas not installed"; exit 1; }
	sh -n /etc/init.d/ripe-atlas || { echo "FAIL: init script is not valid shell"; exit 1; }
	[ -s /etc/config/ripe-atlas ] || { echo "FAIL: /etc/config/ripe-atlas missing or empty"; exit 1; }
	uci -q show ripe-atlas >/dev/null || { echo "FAIL: uci cannot parse ripe-atlas config"; exit 1; }

	[ -x /usr/sbin/ripe-atlas ] || { echo "FAIL: /usr/sbin/ripe-atlas not installed"; exit 1; }
	;;

ripe-atlas-probe|ripe-atlas-anchor)
	# Each variant ships the registration servers and host keys for its own
	# environment; without them the probe cannot register.
	[ -s "$SCRIPT_DIR/reg_servers.sh.prod" ] || {
		echo "FAIL: $SCRIPT_DIR/reg_servers.sh.prod missing or empty"; exit 1; }
	sh -n "$SCRIPT_DIR/reg_servers.sh.prod" || {
		echo "FAIL: reg_servers.sh.prod is not valid shell"; exit 1; }
	grep -qE '^REG_[0-9]+_HOST=[^[:space:]]' "$SCRIPT_DIR/reg_servers.sh.prod" || {
		echo "FAIL: reg_servers.sh.prod defines no REG_*_HOST entries"; exit 1; }

	[ -s "$SHARE_DIR/known_hosts.reg" ] || {
		echo "FAIL: $SHARE_DIR/known_hosts.reg missing or empty"; exit 1; }
	grep -q 'ssh-\|ecdsa-' "$SHARE_DIR/known_hosts.reg" || {
		echo "FAIL: known_hosts.reg holds no host keys"; exit 1; }
	;;
esac

exit 0

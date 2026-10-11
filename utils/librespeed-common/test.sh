#!/bin/sh
# The package ships scripts and an rpcd plugin, no binary of its own, so the
# generic --version probe cannot apply; check the installed pieces and their
# behaviour instead. What the test plants uses test-only names and is removed.
# Runs and --links read UCI from a private UCI_CONFIG_DIR. The init script (its
# crontab path is fixed) and the rpcd plugin (ucode's uci cursor reads only
# /etc/config) see the live config with uncommitted changes that cleanup
# reverts, so the test refuses to start while librespeed has changes pending.

RUN=/usr/libexec/librespeed-run
PLUGIN=/usr/share/rpcd/ucode/librespeed.uc
WORK_DIR=/tmp/librespeed-test
STATE_DIR=/tmp/librespeed
CRONTAB=/etc/crontabs/root

fail() { echo "FAIL: $1"; exit 1; }

# expect RC ERE WHAT CMD...: CMD exits RC and prints a line matching ERE.
expect() {
	local rc="$1" re="$2" what="$3" out got

	shift 3
	out=$("$@" 2>&1)
	got=$?
	printf '%s\n' "$out"
	[ "$got" = "$rc" ] || fail "$what (exit $got)"
	printf '%s\n' "$out" | grep -qE -- "$re" || fail "$what"
}

test_install() {
	local line

	echo "== test_install"
	[ -x $RUN ] || fail "librespeed-run not installed"
	[ -x /usr/libexec/librespeed-aggregate ] || fail "librespeed-aggregate not installed"
	[ -f $PLUGIN ] || fail "rpcd plugin not installed"
	[ -f /etc/config/librespeed ] || fail "UCI config not installed"
	[ -x /etc/init.d/librespeed ] || fail "init script not installed"
	sh -n $RUN || fail "librespeed-run does not parse"
	sh -n /etc/init.d/librespeed || fail "init script does not parse"
	expect 0 '^librespeed-common ' "librespeed-run --version" $RUN --version
	expect 0 '^librespeed-common ' "librespeed-aggregate --version" \
		/usr/libexec/librespeed-aggregate --version
	# Run as a file, the way rpcd loads it: include() rejects the module
	# imports the plugin needs. Loading it has no side effects.
	ucode $PLUGIN > /dev/null || fail "rpcd plugin does not load"
	# Retention matches epoch as jshn writes it, with a space after the colon;
	# the line comes from json_dump, so a change on either side breaks this.
	line=$(. /usr/share/libubox/jshn.sh; json_init; json_add_int epoch 1; json_dump) ||
		fail "jshn not usable"
	echo "$line" | awk 'match($0, /"epoch":[[:space:]]*[0-9]+/) { ok = 1 }
		{ print }
		END { exit !ok }' || fail "retention regex does not match jshn output"
}

# Names outside UCI's alphabet and extra arguments are refused.
test_args() {
	echo "== test_args"
	expect 2 '^Usage: librespeed-run \[INTERFACE\]$' "librespeed-run accepted 'a;b'" $RUN 'a;b'
	expect 2 '^Usage: librespeed-run \[INTERFACE\]$' "librespeed-run accepted 'a-b'" $RUN a-b
	expect 2 '^Usage: librespeed-run \[INTERFACE\]$' "librespeed-run accepted two arguments" $RUN a b
	expect 2 '^Usage: librespeed-run --links$' "--links accepted an argument" $RUN --links x
}

# Stubs, first in PATH: ubus prints $WORK_DIR/dump as netifd's dump,
# start-stop-daemon records launches, and grep marks that the runner's client
# probe asked the client, holding it while $WORK_DIR/hold exists. The client
# of a run fails against a closed port.
setup() {
	mkdir -p "$WORK_DIR/bin" "$WORK_DIR/uci" "$STATE_DIR/failed"
	cp "$STATE_DIR/state.json" "$WORK_DIR/" 2>/dev/null
	printf '#!/bin/sh\ncat %s/dump\n' "$WORK_DIR" > "$WORK_DIR/bin/ubus"
	printf '#!/bin/sh\necho "$*" >> %s/launched\n' "$WORK_DIR" \
		> "$WORK_DIR/bin/start-stop-daemon"
	# BusyBox sleep takes whole seconds only.
	cat > "$WORK_DIR/bin/grep" <<-EOF
	#!/bin/sh
	case "\$*" in
	*json-stream*)
		touch $WORK_DIR/asked
		while [ -e $WORK_DIR/hold ]; do sleep 1; done
		;;
	esac
	PATH=\${PATH#*:} exec grep "\$@"
	EOF
	chmod +x "$WORK_DIR/bin/ubus" "$WORK_DIR/bin/start-stop-daemon" "$WORK_DIR/bin/grep"
	: > "$WORK_DIR/uci/network"
	cat > "$WORK_DIR/uci/librespeed" <<-'EOF'
	config librespeed 'main'
		option interface 'lsdown'
		option server_list 'http://127.0.0.1:1/'
	EOF
}

# planted NAME...: records the test-only (ls*) names among NAME; cleanup
# removes the failures of exactly these.
planted() {
	local name

	for name; do
		case "$name" in ls*) echo "$name" >> "$WORK_DIR/planted" ;; esac
	done
}

plant_failure() { # NAME TEXT
	planted "$1"
	echo "$2" > "$STATE_DIR/failed/$1"
}

cleanup() {
	local name

	uci revert librespeed
	resync
	sort -u "$WORK_DIR/planted" 2>/dev/null | while read -r name; do
		rm -f "$STATE_DIR/failed/$name"
	done
	mv "$WORK_DIR/state.json" "$STATE_DIR/" 2>/dev/null || rm -f "$STATE_DIR/state.json"
	rm -rf "$WORK_DIR"
}

resync() { (. /lib/functions.sh; . /etc/init.d/librespeed; sync_cron); }

# One word per interface: NAME:up|down:PROTO:L3_DEVICE:DEVICE[:dyn|:def4],
# def4 holding the IPv4 default route. netifd shows l3_device only while up.
# --links lists as down the interfaces whose link has none up on their device.
fixture() {
	local word

	for word; do planted "${word%%:*}"; done
	echo "$*" | awk '{
		printf "{\"interface\":["
		for (i = 1; i <= NF; i++) {
			split($i, f, ":")
			printf "%s{\"interface\":\"%s\",\"up\":%s,\"dynamic\":%s,\"proto\":\"%s\"",
				(i > 1 ? "," : ""), f[1], (f[2] == "up" ? "true" : "false"),
				(f[6] == "dyn" ? "true" : "false"), f[3]
			if (f[4] != "")
				printf ",\"l3_device\":\"%s\"", f[4]
			if (f[5] != "")
				printf ",\"device\":\"%s\"", f[5]
			if (f[6] == "def4")
				printf ",\"route\":[{\"target\":\"0.0.0.0\",\"mask\":0}]"
			printf "}"
		}
		print "]}"
	}' > "$WORK_DIR/dump"
}

# --links as "RC links=... map=NAME:LINK,... down=...", not as jshn spaces it.
links_are() {
	local out rc

	out=$(PATH="$WORK_DIR/bin:$PATH" UCI_CONFIG_DIR="$WORK_DIR/uci" $RUN --links)
	rc=$?
	out="$rc $(J="$out" ucode -e 'let v = json(getenv("J"));
		print("links=", join(",", v.links), " map=", join(",",
			map(sort(keys(v.interfaces)), (k) => k + ":" + v.interfaces[k])),
			" down=", join(",", sort(v.down ?? [])), "\n");')"
	echo "$out"
	[ "$out" = "$1" ] || fail "--links: $2"
}

test_links() {
	echo "== test_links"
	fixture loopback:up:static:lo:lo lan:up:static:br-lan:br-lan \
		wan:up:dhcp:eth1:eth1:def4 wan6:up:dhcpv6:eth1:eth1
	links_are "0 links=wan map=lan:lan,wan:wan,wan6:wan down=" "wan and wan6, lan not offered"
	fixture wan:up:dhcp:eth1:eth1:def4 wan6:down:dhcpv6::eth1
	links_are "0 links=wan map=wan:wan,wan6:wan down=" "IPv4-only uplink"
	fixture wan:down:dhcp::eth1 wan6:up:dhcpv6:eth1:eth1
	links_are "0 links=wan map=wan:wan,wan6:wan down=" "IPv6-only uplink"
	fixture wan6:up:dhcpv6:eth1:eth1
	links_are "0 links=wan6 map=wan6:wan6 down=" "no IPv4 section"
	fixture wan:up:pppoe:pppoe-wan:eth1:def4 wan6:up:dhcpv6:pppoe-wan:pppoe-wan
	links_are "0 links=wan map=wan:wan,wan6:wan down=" "@wan while wan is up"
	fixture wan:down:dhcp::eth1 wan6:down:dhcpv6::
	links_are "0 links=wan,wan6 map=wan:wan,wan6:wan6 down=wan,wan6" "@wan while wan is down"
	fixture wan:up:pppoe:pppoe-wan:eth1:def4 wan_6:up:dhcpv6:pppoe-wan:pppoe-wan:dyn
	links_are "0 links=wan map=wan:wan,wan_6:wan down=" "PPPoE with wan_6"
	fixture wan:down:pppoe::eth1
	links_are "0 links=wan map=wan:wan down=wan" "PPPoE down"
	fixture lte:up:qmi:wwan0: lte_4:up:dhcp:wwan0:wwan0:dyn wan:up:dhcp:eth1:eth1:def4
	links_are "0 links=lte,wan map=lte:lte,lte_4:lte,wan:wan down=" "qmi with lte_4"
	fixture modem:up:static:eth1:eth1 vpn:up:wireguard:vpn: wan:up:dhcp:eth1:eth1:def4
	links_are "0 links=vpn,wan map=modem:wan,vpn:vpn,wan:wan down=" "modem access, wan up"
	fixture modem:up:static:eth1:eth1 wan:down:dhcp::eth1 wan_4:up:dhcp:eth1:eth1:dyn
	links_are "0 links=wan map=modem:modem,wan:wan down=wan" "modem access, wan down"
	# A static link is offered with a default route in the dump or a gateway
	# in UCI, as the dump shows routes only while an interface is up.
	cat > "$WORK_DIR/uci/network" <<-'EOF'
	config interface 'lan'
		option ip6assign '60'

	config interface 'sgw'
		option gateway '192.0.2.1'

	config interface 'sgw6'
		option ip6gw '2001:db8::1'
	EOF
	fixture lan:up:static:br-lan:br-lan sgw:down:static::eth2 sgw6:down:static::eth3 \
		sup:up:static:eth4:eth4:def4
	links_are "0 links=sgw,sgw6,sup map=lan:lan,sgw:sgw,sgw6:sgw6,sup:sup down=sgw,sgw6" \
		"static links"
	: > "$WORK_DIR/uci/network"
	: > "$WORK_DIR/dump"
	links_are "1 links= map= down=" "netifd unreachable"
}

# ls_run ARG NAME: a run of ARG ('' for the default) with the stubs; prints
# NAME's recorded failure and whether the client was asked, exits as the run.
ls_run() {
	local rc client=asked

	planted "$1" "$2"
	rm -f "$WORK_DIR/asked" "$STATE_DIR/failed/$2"
	PATH="$WORK_DIR/bin:$PATH" UCI_CONFIG_DIR="$WORK_DIR/uci" $RUN ${1:+"$1"}
	rc=$?
	[ -e "$WORK_DIR/asked" ] || client="not asked"
	echo "$2: $(cat "$STATE_DIR/failed/$2" 2>/dev/null), client $client"
	return $rc
}

# A run is bound to the device of its link or measures nothing: a refusal is
# recorded as that name's failure and asks no client, also from cron, which
# runs the default without an argument. Bound, its failure goes under its link.
test_runs() {
	local name

	echo "== test_runs"
	fixture lsup:up:dhcp:eth9:eth9:def4 lsup6:up:dhcpv6:eth9:eth9 \
		lswan:down:dhcp::eth7 lswan6:up:dhcpv6:eth7:eth7 \
		lsv4:up:dhcp:eth6:eth6:def4 lsv6:down:dhcpv6::eth6 \
		lsdown:down:dhcp::eth8 lsdown6:down:dhcpv6::eth8
	expect 1 '^lsgone: [0-9]+ interface disabled or not configured, client not asked$' \
		"an interface netifd does not list was not refused" ls_run lsgone lsgone
	expect 1 '^lsdown: [0-9]+ interface is down, client not asked$' \
		"a down link was not refused" ls_run lsdown lsdown
	expect 1 '^lsdown: [0-9]+ interface is down, client not asked$' \
		"a down default was not refused" ls_run '' lsdown
	# Bound to eth9, eth7, eth6, where an interface of the link is up: lsup6
	# beside lsup, lswan while only lswan6 is up, lsv6 while only lsv4 is.
	expect 1 '^lsup: [0-9]+ .*, client asked$' \
		"a bound run did not fail at its client under its link" ls_run lsup6 lsup
	expect 1 '^lswan: [0-9]+ .*, client asked$' \
		"a down interface was not bound to its link's device" ls_run lswan lswan
	expect 1 '^lsv4: [0-9]+ .*, client asked$' \
		"a down wan6 was not bound to its link's device" ls_run lsv6 lsv4
	for name in lsup6 lswan6 lsv6; do
		[ ! -e "$STATE_DIR/failed/$name" ] ||
			fail "a bound run's failure is not under its link ($name)"
	done
	: > "$WORK_DIR/dump"
	expect 1 '^lsup: [0-9]+ netifd did not answer, client not asked$' \
		"a run went on while netifd gave no dump" ls_run lsup lsup
}

# call METHOD: the plugin's METHOD without arguments. The runner it starts for
# links reads the private UCI; the plugin itself reads the live config.
call() {
	PATH="$WORK_DIR/bin:$PATH" UCI_CONFIG_DIR="$WORK_DIR/uci" P=$PLUGIN M="$1" ucode -e '
		const m = loadfile(getenv("P"))().librespeed;
		printf("%s %J\n", getenv("M"), m[getenv("M")].call({ args: {} }));'
}

# ubus start refuses at once what a run would refuse, and launches nothing
# then; links answers an error for a silent netifd, not an empty map. A down
# interface whose link is up starts. Start without an interface runs the
# default, which the plugin takes from the live config (wan when unset).
test_start() {
	local main

	echo "== test_start"
	main=$(uci -q get librespeed.main.interface)
	[ -n "$main" ] || main=wan
	fixture "$main:up:dhcp:eth9:eth9:def4"
	expect 0 '"started"' "start did not launch a link netifd lists" call start
	[ -s "$WORK_DIR/launched" ] || fail "start launched nothing"
	rm -f "$WORK_DIR/launched"
	fixture "$main:down:dhcp::eth9" "ls${main}6:up:dhcpv6:eth9:eth9"
	expect 0 '"started"' "start did not launch a down interface whose link is up" call start
	[ -s "$WORK_DIR/launched" ] || fail "start launched nothing for a link that is up"
	rm -f "$WORK_DIR/launched"
	fixture "ls$main:up:dhcp:eth9:eth9:def4"
	expect 0 '"interface disabled or not configured"' \
		"start launched a name netifd does not list" call start
	fixture "$main:down:dhcp::eth9"
	expect 0 '"interface is down"' "start launched a down interface" call start
	: > "$WORK_DIR/dump"
	expect 0 '"netifd did not answer"' "start did not refuse while netifd gave no dump" call start
	[ ! -e "$WORK_DIR/launched" ] || fail "start launched a refused run"
	expect 0 '"error"' "links read a silent netifd as no links" call links
}

# A stop is no failure: it records "stopped" and leaves the interface's
# earlier failure as it was. The run is held in its client probe and stopped.
test_stop() {
	local run_pid waited=0

	echo "== test_stop"
	fixture lsstop:up:dhcp:eth9:eth9
	plant_failure lsstop "1 an earlier failure"
	rm -f "$WORK_DIR/asked"
	touch "$WORK_DIR/hold"
	PATH="$WORK_DIR/bin:$PATH" UCI_CONFIG_DIR="$WORK_DIR/uci" $RUN lsstop &
	run_pid=$!
	while [ ! -e "$WORK_DIR/asked" ] && [ "$waited" -lt 10 ]; do
		sleep 1
		waited=$((waited + 1))
	done
	kill -TERM "$run_pid"
	rm -f "$WORK_DIR/hold"
	wait "$run_pid"
	[ $? = 1 ] && [ "$(jsonfilter -i "$STATE_DIR/state.json" -e @.last_error)" = stopped ] &&
		[ "$(jsonfilter -i "$STATE_DIR/state.json" -e @.interface)" = lsstop ] ||
		fail "a stopped run is not recorded as stopped"
	[ "$(cat "$STATE_DIR/failed/lsstop")" = "1 an earlier failure" ] ||
		fail "a stop changed a failure"
}

# A run that never gets the lock gives up after 3 minutes, at once here (a
# sleep stub: BusyBox ash has no builtin sleep), and records that as its
# interface's failure; state.json is the lock holder's.
test_lock() {
	local state_before

	echo "== test_lock"
	printf '#!/bin/sh\n' > "$WORK_DIR/bin/sleep"
	chmod +x "$WORK_DIR/bin/sleep"
	exec 8>/var/lock/librespeed.lock
	flock -n 8 || fail "the lock is taken before the skip test"
	state_before=$(cat "$STATE_DIR/state.json" 2>/dev/null)
	planted lsbusy
	expect 3 '^already running$' "a run that never got the lock" \
		env PATH="$WORK_DIR/bin:$PATH" UCI_CONFIG_DIR="$WORK_DIR/uci" $RUN lsbusy
	exec 8>&-
	rm "$WORK_DIR/bin/sleep"
	grep -E '^[0-9]+ skipped: ' "$STATE_DIR/failed/lsbusy" || fail "a skipped run left no failure"
	[ "$(cat "$STATE_DIR/state.json" 2>/dev/null)" = "$state_before" ] ||
		fail "a skipped run wrote state.json"
}

# row INTERFACE ENABLED INTERVAL [DAYS [HOURS]]: a schedule row.
row() {
	local section

	section=$(uci add librespeed schedule)
	[ -n "$1" ] && uci set "librespeed.$section.interface=$1"
	uci set "librespeed.$section.enabled=$2"
	uci set "librespeed.$section.interval=$3"
	[ -n "$4" ] && uci set "librespeed.$section.days=$4"
	[ -n "$5" ] && uci set "librespeed.$section.hours=$5"
	last_row=$section
}

# The legacy line stays bare, then one line per interface, from its first
# enabled row whose interval is valid.
test_cron() {
	local last_row ifb_row wk_row wwan_row weekly newline interval

	echo "== test_cron"
	uci set librespeed.schedule.enabled=1
	row lte 1 1d 0 3
	row wan2 1 2h
	row ifb 1 1d 1-5 4
	ifb_row=$last_row
	row badiv 1 90m
	row off 0 1d
	row lte 1 15m
	row '' 1 1d
	row a-b 1 1d
	row lsd2 1 90m
	row lsd2 1 2h
	row wk 1 7d 1-5
	wk_row=$last_row
	row wwan 1 7d '' 3
	wwan_row=$last_row
	# Hand-set values for root's crontab: a bad interval or name gives no line,
	# bad days or hours the default field, and no value a line of its own.
	newline='
'
	for interval in 0m 00m 05m 60m 0h 00h 24h 8d; do
		row "i$interval" 1 "$interval"
	done
	row inl 1 "1d$newline* * * * * echo lsinject"
	row dbad 1 1d 1-7,9 3
	row dcomma 1 1d 1,2, 3
	row dnl 1 1d "1$newline* * * * * echo lsinject" 3
	row hbad 1 23h '' 5-25
	row hnl 1 1d '' "2-5$newline* * * * * echo lsinject"
	row "x$newline* * * * * echo lsinject" 1 1d
	resync
	grep -E '^[0-9]+ [2-5] \* \* \* /usr/libexec/librespeed-run$' $CRONTAB || fail "legacy line"
	[ "$(grep -c 'librespeed-run$' $CRONTAB)" = 1 ] || fail "a second bare line"
	grep -E '^[0-9]+ 3 \* \* 0 /usr/libexec/librespeed-run lte$' $CRONTAB || fail "daily line"
	[ "$(grep -c 'librespeed-run lte$' $CRONTAB)" = 1 ] || fail "lte twice"
	grep -E '^0 \*/2 \* \* \* /usr/libexec/librespeed-run wan2$' $CRONTAB || fail "2h line"
	grep -E '^[0-9]+ 4 \* \* 1-5 /usr/libexec/librespeed-run ifb$' $CRONTAB || fail "day range"
	grep -E 'librespeed-run (badiv|off|a-b|i[0-9]+[mhd]|inl)$' $CRONTAB && fail "a skipped row has a line"
	grep -E '^0 \*/2 \* \* \* /usr/libexec/librespeed-run lsd2$' $CRONTAB ||
		fail "an invalid interval kept a later row of its interface out"
	grep -E '^[0-9]+ [0-9]+ \* \* [1-5] /usr/libexec/librespeed-run wk$' $CRONTAB || fail "weekly line"
	grep -E '^[0-9]+ 3 \* \* [0-6] /usr/libexec/librespeed-run wwan$' $CRONTAB || fail "drawn day"
	grep lsinject $CRONTAB && fail "a value became a cron line"
	[ "$(grep -cE '^[0-9]+ 3 \* \* \* /usr/libexec/librespeed-run (dbad|dcomma|dnl)$' $CRONTAB)" = 3 ] ||
		fail "bad days not replaced by every day"
	grep -E '^0 \*/23 \* \* \* /usr/libexec/librespeed-run hbad$' $CRONTAB || fail "bad hours kept"
	grep -E '^[0-9]+ [0-9]+ \* \* \* /usr/libexec/librespeed-run hnl$' $CRONTAB || fail "hours with a newline"

	# Weekly slots survive a sync in another process, so with another seed.
	weekly=$(grep -E 'librespeed-run (wk|wwan)$' $CRONTAB)
	sh -c '. /lib/functions.sh; . /etc/init.d/librespeed; sync_cron'
	[ "$(grep -E 'librespeed-run (wk|wwan)$' $CRONTAB)" = "$weekly" ] || fail "weekly slot drawn anew"

	# A slot the new hours, days or interval leave out is drawn anew in them;
	# one they still hold stays.
	uci set "librespeed.$wwan_row.hours=4"
	uci set "librespeed.$wk_row.days=0"
	uci set "librespeed.$ifb_row.interval=7d"
	resync
	grep -E '^[0-9]+ 4 \* \* [0-6] /usr/libexec/librespeed-run wwan$' $CRONTAB || fail "new hours"
	grep -E '^[0-9]+ [0-9]+ \* \* 0 /usr/libexec/librespeed-run wk$' $CRONTAB || fail "new days"
	grep -E '^[0-9]+ 4 \* \* [1-5] /usr/libexec/librespeed-run ifb$' $CRONTAB || fail "1d to 7d"
	weekly=$(grep -E 'librespeed-run (wk|wwan|ifb)$' $CRONTAB)
	uci set "librespeed.$wwan_row.hours=2-5"
	uci set "librespeed.$wk_row.days=0,6"
	sh -c '. /lib/functions.sh; . /etc/init.d/librespeed; sync_cron'
	[ "$(grep -E 'librespeed-run (wk|wwan|ifb)$' $CRONTAB)" = "$weekly" ] || fail "a fitting slot drawn anew"

	# A changed default moves the legacy line to wan2, so the wan2 row is
	# skipped, unless the legacy interval is invalid.
	uci set librespeed.main.interface=wan2
	resync
	[ "$(grep -c 'librespeed-run$' $CRONTAB)" = 1 ] || fail "bare line after the change"
	[ "$(grep -c 'librespeed-run wan2$' $CRONTAB)" = 0 ] || fail "wan2 twice"
	uci set librespeed.schedule.interval=90m
	resync
	[ "$(grep -c 'librespeed-run$' $CRONTAB)" = 0 ] || fail "a bare line with an invalid interval"
	grep -E '^0 \*/2 \* \* \* /usr/libexec/librespeed-run wan2$' $CRONTAB ||
		fail "an invalid legacy interval kept the wan2 row out"
}

# aggregates FIELD...: one line per archived aggregate, its FIELDs ("-" for
# one it lacks).
aggregates() {
	local line

	while read -r line; do
		J="$line" ucode -e 'const a = json(getenv("J"));
			print(join(" ", map(ARGV, (f) => a[f] ?? "-")), "\n");' "$@"
	done < "$WORK_DIR/archive.jsonl"
}

# A completed day is archived as one line per interface, the unnamed first.
# A day archived before per-interface history names no interface; it is kept
# as it is, neither split nor archived again.
test_history() {
	local epoch line got archived_epoch pending_epoch archived_day pending_day

	echo "== test_history"
	uci set librespeed.history.path="$WORK_DIR/raw.jsonl"
	uci set librespeed.history.archive_path="$WORK_DIR/archive.jsonl"
	epoch=$(( $(date +%s) - 2 * 86400 ))
	for line in '"interface":"wan","download_mbps":100' '"download_mbps":50' \
		'"interface":"lte","download_mbps":30' '"interface":"wan","download_mbps":200'; do
		echo "{\"epoch\":$epoch,$line}"
	done > "$WORK_DIR/raw.jsonl"
	/usr/libexec/librespeed-aggregate
	got=$(aggregates interface samples download_mbps)
	echo "$got"
	[ "$got" = "$(printf '%s\n' '- 1 50' 'lte 1 30' 'wan 2 150')" ] ||
		fail "per-interface aggregates"

	archived_epoch=$(( $(date +%s) - 4 * 86400 )) pending_epoch=$(( $(date +%s) - 2 * 86400 ))
	archived_day=$(date -d "@$archived_epoch" +%Y-%m-%d)
	pending_day=$(date -d "@$pending_epoch" +%Y-%m-%d)
	printf '{"timestamp":"%s","epoch":%s,"samples":2,"download_mbps":65}\n' \
		"$archived_day" "$archived_epoch" > "$WORK_DIR/archive.jsonl"
	printf '{"epoch":%s,"interface":"wan","download_mbps":%s}\n' \
		"$archived_epoch" 100 "$archived_epoch" 30 "$pending_epoch" 40 > "$WORK_DIR/raw.jsonl"
	/usr/libexec/librespeed-aggregate
	got=$(aggregates timestamp interface samples)
	[ "$got" = "$(printf '%s\n' "$archived_day - 2" "$pending_day wan 1")" ] ||
		fail "an aggregate archived before was split or archived again"
}

status() {
	P=$PLUGIN ucode -e 'printf("%J\n", loadfile(getenv("P"))().librespeed.status.call({}));'
}

# status lists the failures of names still configured or scheduled (the
# default, a schedule row, a network interface), not of a removed one. A run
# holding the lock before its first state write is not named after the last.
test_status() {
	local name got

	echo "== test_status"
	uci set librespeed.main.interface=lsmain
	uci set librespeed.lsrow=schedule
	uci set librespeed.lsrow.interface=lsrow
	for name in lsghost lsmain lsrow; do plant_failure "$name" "1 failed"; done
	got=$(status | jsonfilter -e '@.failures[*].interface' | sort | tr '\n' ' ')
	case " $got " in *" lsghost "*) fail "a failure of a gone name is listed: $got" ;; esac
	for name in lsmain lsrow; do
		case " $got " in *" $name "*) ;; *) fail "the failure of $name is not listed: $got" ;; esac
	done

	echo '{ "running": false, "interface": "lsold", "last_error": "x" }' > "$STATE_DIR/state.json"
	(exec 9>/var/lock/librespeed.lock; flock 9; sleep 3) &
	sleep 1
	got=$(status)
	wait
	[ "$(echo "$got" | jsonfilter -e @.running)" = true ] &&
		[ -z "$(echo "$got" | jsonfilter -e @.interface)" ] || fail "status while locked: $got"
}

test_install
test_args
[ -z "$(uci -q changes librespeed)" ] ||
	fail "librespeed has uncommitted changes, which the test's cleanup would revert"
trap cleanup EXIT
setup
test_links
test_runs
test_start
test_stop
test_lock
test_cron
test_history
test_status
echo "librespeed-common: installed files OK"

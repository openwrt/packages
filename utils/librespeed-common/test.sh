#!/bin/sh
# The package ships scripts and an rpcd plugin, no binary of its own, so the
# generic --version probe cannot apply; check the installed pieces instead.

fail() { echo "FAIL: $1"; exit 1; }

[ -x /usr/libexec/librespeed-run ] || fail "librespeed-run not installed"
[ -x /usr/libexec/librespeed-aggregate ] || fail "librespeed-aggregate not installed"
[ -f /usr/share/rpcd/ucode/librespeed.uc ] || fail "rpcd plugin not installed"
[ -f /etc/config/librespeed ] || fail "UCI config not installed"
[ -x /etc/init.d/librespeed ] || fail "init script not installed"

sh -n /usr/libexec/librespeed-run || fail "librespeed-run does not parse"
/usr/libexec/librespeed-run --version | grep librespeed-common \
	|| fail "librespeed-run --version"
/usr/libexec/librespeed-aggregate --version | grep librespeed-common \
	|| fail "librespeed-aggregate --version"
sh -n /etc/init.d/librespeed || fail "init script does not parse"

# The plugin file has no side effects at load time: it defines its methods
# and returns them. Run as a file, the way rpcd loads it -- include() cannot
# be used here, it rejects the module import statements the plugin needs.
ucode /usr/share/rpcd/ucode/librespeed.uc >/dev/null \
	|| fail "rpcd plugin does not load"

# Retention must recognise epoch as jshn actually writes it -- with a space
# after the colon. The fixture comes from json_dump itself, so the check
# breaks if either side changes shape.
line=$(. /usr/share/libubox/jshn.sh; json_init; json_add_int epoch 1; json_dump) \
	|| fail "jshn not usable"
echo "$line" | awk 'match($0, /"epoch":[[:space:]]*[0-9]+/) { ok = 1 }
	{ print }
	END { exit !ok }' || fail "retention regex does not match jshn output"

# An interface name ends up in root's crontab and in jsonfilter expressions,
# so a name outside UCI's alphabet, or a second argument, is refused before
# the runner reads or writes anything.
for arg in 'a;b' 'a-b'; do
	/usr/libexec/librespeed-run "$arg" 2>&1
	[ $? = 2 ] || fail "librespeed-run accepted '$arg'"
done
/usr/libexec/librespeed-run a b 2>&1
[ $? = 2 ] || fail "librespeed-run accepted two arguments"

# The rest changes the configuration uncommitted: a revert restores it.
cleanup() {
	uci revert librespeed
	(. /lib/functions.sh; . /etc/init.d/librespeed; sync_cron)
	rm -rf /tmp/librespeed-test
}
trap cleanup EXIT

# One cron line per automatic test: the legacy section keeps its bare line,
# and a `config schedule` passes the interface it measures -- here weekly,
# on Sundays at 3, and weekly on a day drawn at sync.
uci set librespeed.schedule.enabled=1
uci add librespeed schedule >/dev/null
uci set librespeed.@schedule[-1].interface=lte
uci set librespeed.@schedule[-1].enabled=1
uci set librespeed.@schedule[-1].interval=7d
uci set librespeed.@schedule[-1].days=0
uci set librespeed.@schedule[-1].hours=3
uci add librespeed schedule >/dev/null
uci set librespeed.@schedule[-1].interface=wwan
uci set librespeed.@schedule[-1].enabled=1
uci set librespeed.@schedule[-1].interval=7d
uci set librespeed.@schedule[-1].hours=3
(. /lib/functions.sh; . /etc/init.d/librespeed; sync_cron)
grep -E '^[0-9]+ [2-5] \* \* \* /usr/libexec/librespeed-run$' /etc/crontabs/root \
	|| fail "legacy schedule line"
grep -E '^[0-9]+ 3 \* \* 0 /usr/libexec/librespeed-run lte$' /etc/crontabs/root \
	|| fail "per-interface schedule line"
grep -E '^[0-9]+ 3 \* \* [0-6] /usr/libexec/librespeed-run wwan$' /etc/crontabs/root \
	|| fail "weekly schedule line without a day"
# A weekly test keeps its drawn slot when synced again: another process,
# so another seed, as after a reboot.
weekly=$(grep -F 'librespeed-run wwan' /etc/crontabs/root)
sh -c '. /lib/functions.sh; . /etc/init.d/librespeed; sync_cron'
[ "$(grep -F 'librespeed-run wwan' /etc/crontabs/root)" = "$weekly" ] \
	|| fail "weekly slot drawn anew on sync"

# A completed day is archived as one line per interface; runs of unknown
# path form their own group, sorted first.
d=/tmp/librespeed-test
mkdir -p "$d"
uci set librespeed.history.path="$d/raw.jsonl"
uci set librespeed.history.archive_path="$d/archive.jsonl"
e=$(( $(date +%s) - 2 * 86400 ))
for l in '"interface":"wan","download_mbps":100' '"download_mbps":50' \
	'"interface":"lte","download_mbps":30' '"interface":"wan","download_mbps":200'; do
	echo "{\"epoch\":$e,$l}"
done > "$d/raw.jsonl"
/usr/libexec/librespeed-aggregate
got=$(while read -r l; do
	for f in interface samples download_mbps; do
		printf '%s:' "$(echo "$l" | jsonfilter -e "@.$f")"
	done
done < "$d/archive.jsonl")
echo "$got"
[ "$(echo "$got" | sed 's/\.0:/:/g')" = ':1:50:lte:1:30:wan:2:150:' ] \
	|| fail "per-interface aggregates"

echo "librespeed-common: installed files OK"

#!/bin/sh
# SPDX-License-Identifier: GPL-2.0-only

package_dir=$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd) || exit 1
uci_bin=$(command -v "${1:-uci}") || {
	printf 'uci.sh requires a real UCI CLI (optional first argument: executable path)\n' >&2
	exit 1
}
tmpdir=$(mktemp -d) || exit 1
cleanup() {
	status=$?
	trap - 0
	if [ -d "$tmpdir/config" ]; then
		chmod 700 "$tmpdir/config" || \
			printf 'cleanup: could not restore permissions on %s\n' "$tmpdir/config" >&2
	fi
	rm -f "$tmpdir/config/readsb" "$tmpdir/shared/readsb" "$tmpdir/original" \
		"$tmpdir/calls" "$tmpdir/stages" "$tmpdir/output" \
		"$tmpdir/config/adsbexchange-stats" "$tmpdir/shared/adsbexchange-stats" \
		"$tmpdir/companion-original" "$tmpdir/readsb-uuid" \
		"$tmpdir/readsb-feeder" "$tmpdir/readsb-setup" || \
		printf 'cleanup: could not remove test files in %s\n' "$tmpdir" >&2
	rmdir "$tmpdir/config" "$tmpdir/shared" "$tmpdir/override" "$tmpdir" || \
		printf 'cleanup: could not remove test directories in %s\n' "$tmpdir" >&2
	exit "$status"
}
trap cleanup 0
trap 'exit 1' HUP INT TERM
mkdir "$tmpdir/config" "$tmpdir/shared" "$tmpdir/override" || exit 1
# shellcheck source=/dev/null
. "$package_dir/files/readsb.functions.sh"
_err() { printf 'error: %s\n' "$*" >&2; }
for cli in readsb-uuid readsb-feeder readsb-setup; do
	sed '\|^\. /usr/lib/readsb/functions.sh$|d; \|^\. /lib/functions.sh$|d' \
		"$package_dir/files/$cli" > "$tmpdir/$cli" || exit 1
done
uci_has_override=0
"$uci_bin" -h 2>&1 | grep -q '^[[:space:]]*-C[[:space:]]' && uci_has_override=1

# Model UCI's default shared delta path with an explicitly configured
# directory. An additional -t must not hide this directory from the test.
real_uci() {
	if [ "$uci_has_override" = 1 ]; then
		set -- -C "$tmpdir/override" "$@"
	fi
	"$uci_bin" -c "$tmpdir/config" -t "$tmpdir/shared" "$@"
}
uci() {
	local private='' rc
	if [ "$1" = -t ]; then
		private=$2
		printf '%s\n' "$private" >> "$tmpdir/stages"
		shift 2
	fi
	[ "$1" != -q ] || shift
	printf '%s %s\n' "$1" "$2" >> "$tmpdir/calls"
	case $1 in
		changes) [ "${failure:-}" != changes ] || return 9 ;;
		set)
			[ "${failure:-}" != "$2" ] || return 9
			if [ "${inject_pending:-0}" = 1 ]; then
				real_uci add_list readsb.other.tags=during || return 99
				inject_pending=0
			fi
			;;
		commit)
			[ "${failure:-}" != commit ] || return 9
			if [ "${failure:-}" = commit-io ]; then
				chmod 500 "$tmpdir/config" || return 99
				rc=0
				real_uci -t "$private" "$@" || rc=$?
				chmod 700 "$tmpdir/config" || return 99
				[ "$rc" -ne 0 ] || return 99
				return "$rc"
			fi
			;;
	esac
	if [ -n "$private" ]; then
		real_uci -t "$private" "$@"
	else
		real_uci "$@"
	fi
}
seed_config() {
	rm -f "$tmpdir/shared/readsb"
	printf '%s\n' "config readsb 'main'" "  option device 'old'" \
		"  option device_auto 'old'" "  option lat '51.5'" \
		"config feeder 'other'" "  option enabled '0'" \
		"  list tags 'base'" > "$tmpdir/config/readsb"
	cp "$tmpdir/config/readsb" "$tmpdir/original"
	: > "$tmpdir/calls"
	: > "$tmpdir/stages"
}
assert_clean_staging() {
	while IFS= read -r directory; do
		[ ! -e "$directory" ] || {
			printf 'leaked private staging directory: %s\n' "$directory" >&2
			return 1
		}
	done < "$tmpdir/stages"
}
apply_update() {
	readsb_uci_apply main.device=1090 main.device_auto=1090
}
test_pending() (
	seed_config
	case $1 in
		scalar) real_uci set readsb.other.enabled=1 || return 1 ;;
		list) real_uci add_list readsb.other.tags=operator || return 1 ;;
		same-key) real_uci set readsb.main.device=manual || return 1 ;;
		deletion) real_uci delete readsb.main.lat || return 1 ;;
	esac
	effective=$(real_uci export readsb) || return 1
	pending=$(real_uci changes readsb) || return 1
	rc=0
	apply_update || rc=$?
	[ "$rc" = 1 ] || return 1
	! grep -Eq '^(set|commit|revert)' "$tmpdir/calls" || return 1
	cmp -s "$tmpdir/config/readsb" "$tmpdir/original" || return 1
	[ "$(real_uci export readsb)" = "$effective" ] || return 1
	[ "$(real_uci changes readsb)" = "$pending" ] || return 1
	real_uci commit readsb || return 1
	[ "$(real_uci export readsb)" = "$effective" ] || return 1
	assert_clean_staging
)
test_late_pending() (
	seed_config
	inject_pending=1
	rc=0
	apply_update || rc=$?
	[ "$rc" = 1 ] || return 1
	! grep -Eq '^(commit|revert)' "$tmpdir/calls" || return 1
	cmp -s "$tmpdir/config/readsb" "$tmpdir/original" || return 1
	[ "$(real_uci get readsb.other.tags)" = 'base during' ] || return 1
	real_uci commit readsb || return 1
	[ "$(real_uci get readsb.other.tags)" = 'base during' ] || return 1
	[ "$(real_uci get readsb.main.device)" = old ] || return 1
	assert_clean_staging
)
test_failure() (
	seed_config
	failure=$1
	rc=0
	apply_update || rc=$?
	[ "$rc" = 1 ] || return 1
	cmp -s "$tmpdir/config/readsb" "$tmpdir/original" || return 1
	[ -z "$(real_uci changes readsb)" ] || return 1
	real_uci commit readsb || return 1
	[ "$(real_uci get readsb.main.device)" = old ] || return 1
	assert_clean_staging
)
test_success() (
	seed_config
	apply_update || return 1
	[ "$(real_uci get readsb.main.device)" = 1090 ] || return 1
	[ "$(real_uci get readsb.main.device_auto)" = 1090 ] || return 1
	[ "$(real_uci get readsb.other.tags)" = base ] || return 1
	[ -z "$(real_uci changes readsb)" ] || return 1
	! grep -q '^revert ' "$tmpdir/calls" || return 1
	real_uci add_list readsb.other.tags=operator || return 1
	real_uci commit readsb || return 1
	apply_update || return 1
	[ "$(real_uci get readsb.other.tags)" = 'base operator' ] || return 1
	assert_clean_staging
)
test_companion_package() (
	seed_config
	rm -f "$tmpdir/shared/adsbexchange-stats"
	printf '%s\n' "config adsbexchange-stats 'main'" "  option enabled '0'" \
		"  option feeder 'old'" > "$tmpdir/config/adsbexchange-stats"
	cp "$tmpdir/config/adsbexchange-stats" "$tmpdir/companion-original"
	real_uci add_list readsb.other.tags=operator || return 1
	readsb_pending=$(real_uci changes readsb)
	scenario=$1
	case $scenario in
		fail) failure=adsbexchange-stats.main.enabled=1 ;;
		pending) real_uci set adsbexchange-stats.main.feeder=manual || return 1 ;;
	esac
	stats_pending=$(real_uci changes adsbexchange-stats)
	rc=0
	readsb_uci_apply_package adsbexchange-stats main.feeder=adsbx main.enabled=1 || rc=$?
	if [ "$scenario" = success ]; then
		[ "$rc" = 0 ] || return 1
		[ "$(real_uci get adsbexchange-stats.main.feeder)" = adsbx ] || return 1
		[ "$(real_uci get adsbexchange-stats.main.enabled)" = 1 ] || return 1
		[ -z "$(real_uci changes adsbexchange-stats)" ] || return 1
	else
		[ "$rc" = 1 ] || return 1
		cmp -s "$tmpdir/config/adsbexchange-stats" "$tmpdir/companion-original" || return 1
		[ "$(real_uci changes adsbexchange-stats)" = "$stats_pending" ] || return 1
	fi
	cmp -s "$tmpdir/config/readsb" "$tmpdir/original" || return 1
	[ "$(real_uci changes readsb)" = "$readsb_pending" ] || return 1
	assert_clean_staging
)
test_primary_section() (
	layout=$1 action=$2
	primary_uuid=00000000-0000-4000-8000-000000000001
	secondary_uuid=00000000-0000-4000-8000-000000000002
	new_uuid=00000000-0000-4000-8000-000000000003
	seed_config
	secondary=main
	case $layout in
		named) first="config readsb 'main'"; secondary=other ;;
		renamed) first="config readsb 'receiver'" ;;
		anonymous) first='config readsb' ;;
	esac
	printf '%s\n' "$first" "  option uuid '$primary_uuid'" \
		"  option write_json '/var/run/primary-readsb'" \
		"config readsb '$secondary'" "  option uuid '$secondary_uuid'" \
		"config feeder 'adsbx'" "  option enabled '1'" \
		"  option preset 'adsbexchange'" > "$tmpdir/config/readsb"
	before=$(real_uci export readsb) || return 1
	_notice() { :; }
	readsb_gen_uuid() { printf '%s\n' "$new_uuid"; }
	readsb_companion_pkgs_all() { :; }
	config_load() { :; }
	config_foreach() { "$1" adsbx; }
	config_get() {
		_test_primary_value=$(real_uci -q get "readsb.$2.$3") || _test_primary_value=${4:-}
		export "$1=$_test_primary_value"
	}
	config_get_bool() {
		config_get "$@"
	}
	case $action in
		uuid-print|uuid-auto|uuid-force)
			flag=${action#uuid-}
			output=$(set -- "--$flag"; . "$tmpdir/readsb-uuid") || return 1
			if [ "$action" = uuid-force ]; then
				[ "$output" = "$new_uuid" ] || return 1
				[ "$(real_uci get 'readsb.@readsb[0].uuid')" = "$new_uuid" ] || return 1
			else
				[ "$output" = "$primary_uuid" ] || return 1
			fi
			;;
		feeder-url)
			output=$(set -- --url adsbx; . "$tmpdir/readsb-feeder") || return 1
			printf '%s\n' "$output" | grep -Fq "https://www.adsbexchange.com/api/feeders/?feed=$primary_uuid" || return 1
			;;
		setup-config)
			output=$(set -- --config; . "$tmpdir/readsb-setup") || return 1
			printf '%s\n' "$output" | grep -Fq "uuid='$primary_uuid'" || return 1
			printf '%s\n' "$output" | grep -Fq 'write_json=' || return 1
			! printf '%s\n' "$output" | grep -Fq "$secondary_uuid" || return 1
			;;
	esac
	[ "$(real_uci get "readsb.$secondary.uuid")" = "$secondary_uuid" ] || return 1
	[ -z "$(real_uci changes readsb)" ] || return 1
	if [ "$action" != uuid-force ]; then
		[ "$(real_uci export readsb)" = "$before" ] || return 1
	fi
)

tests=0
failures=0
run_test() {
	label=$1
	shift
	tests=$((tests+1))
	if "$@" > "$tmpdir/output" 2>&1; then
		printf 'ok %s - %s\n' "$tests" "$label"
	else
		printf 'not ok %s - %s\n' "$tests" "$label"
		cat "$tmpdir/output" >&2
		failures=$((failures+1))
	fi
}
for pending_type in scalar list same-key deletion; do
	run_test "pending $pending_type edits are not committed or replayed" test_pending "$pending_type"
done
run_test 'shared changes arriving during staging stop the commit' test_late_pending
for failure_type in changes readsb.main.device=1090 readsb.main.device_auto=1090 commit; do
	run_test "failure at $failure_type discards the private update" test_failure "$failure_type"
done
if [ "$(id -u)" != 0 ]; then
	run_test 'real commit I/O failure does not leak private changes' test_failure commit-io
fi
run_test 'clean updates persist without duplicating later list additions' test_success
run_test 'companion UCI commit leaves pending readsb edits alone' test_companion_package success
run_test 'companion UCI write failure does not leak partial settings' test_companion_package fail
run_test 'companion UCI update preserves its own pending edits' test_companion_package pending
for layout in named renamed anonymous; do
	for action in uuid-print uuid-auto uuid-force feeder-url setup-config; do
		run_test "$action follows the first $layout readsb section without changing the second" \
			test_primary_section "$layout" "$action"
	done
done
printf '%s tests, %s failures\n' "$tests" "$failures"
[ "$failures" -eq 0 ]

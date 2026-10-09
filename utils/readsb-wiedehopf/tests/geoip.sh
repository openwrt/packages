#!/bin/sh
# SPDX-License-Identifier: GPL-2.0-only

package_dir=$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd) || exit 1
test_dir="./.readsb-geoip-test.$$"
(umask 077 && mkdir "$test_dir") || exit 1
trap 'rm -f "$test_dir/functions.sh" "$test_dir/options.sh" "$test_dir/tooling.sh" "$test_dir/dispatch.sh" "$test_dir/exit.sh" "$test_dir/calls" "$test_dir/output" "$test_dir/lat" "$test_dir/lon" "$test_dir/stage-path" "$test_dir/bin/mktemp" "$test_dir/bin/rm" "$test_dir/bin/rmdir"; rmdir "$test_dir/bin" "$test_dir"' 0
trap 'exit 1' HUP INT TERM
mkdir "$test_dir/bin" || exit 1
for tool in mktemp rm rmdir; do
	ln -s "$(command -v "$tool")" "$test_dir/bin/$tool" || exit 1
done

# Extract only the code under test; never source OpenWrt libraries or fetch URLs.
# shellcheck source=/dev/null
. "$package_dir/files/readsb.functions.sh"
sed -n '/^update_section() {/,/^}/p' "$package_dir/files/readsb-geoip" > "$test_dir/functions.sh" || exit 1
sed -n '/^verbose=0$/p; /^force=0$/,/^_verbose_apply$/p' "$package_dir/files/readsb-geoip" > "$test_dir/options.sh" || exit 1
sed -n '/^last_stage="tool-detect"$/,/^# Strict numeric check;/p' "$package_dir/files/readsb-geoip" > "$test_dir/tooling.sh" || exit 1
sed -n '/^if \[ -n "\$section" \]; then$/,$p' "$package_dir/files/readsb-geoip" > "$test_dir/dispatch.sh" || exit 1
sed -n '/^on_exit() {/,/^}/p; /^trap on_exit /p' "$package_dir/files/readsb-geoip" > "$test_dir/exit.sh" || exit 1
# shellcheck source=/dev/null
. "$test_dir/functions.sh"
set -u

assert_equal() {
	[ "$1" = "$2" ] && return 0
	printf 'expected <%s>, got <%s>\n' "$2" "$1" >&2
	return 1
}

tests=0
failures=0
run_test() {
	label=$1
	shift
	tests=$((tests + 1))
	if "$@"; then
		printf 'ok %s - %s\n' "$tests" "$label"
	else
		printf 'not ok %s - %s\n' "$tests" "$label"
		failures=$((failures + 1))
	fi
}

_debug() { :; }
_log() { printf 'log: %s\n' "$*" >&2; }
_notice() { printf '%s\n' "$*"; }
_warn() { printf 'warn: %s\n' "$*" >&2; }
_err() { printf 'error: %s\n' "$*" >&2; }

lookup() {
	printf 'lookup\n' >> "$test_dir/calls"
	[ "$lookup_mode" != empty ] || return 1
	printf '48.8566 2.3522 192.0.2.1\n'
	[ "$lookup_mode" = success ]
}

uci() {
	local staging='' value
	if [ "$1" = -t ]; then
		staging=$2
		printf '%s\n' "$staging" > "$test_dir/stage-path"
		shift 2
	fi
	[ "$1" != -q ] || shift
	case "$1 $2" in
		'changes readsb') return 0 ;;
		'get readsb.main.lat')
			[ -f "$test_dir/lat" ] || return 1
			IFS= read -r value < "$test_dir/lat"
			printf '%s\n' "$value"
			;;
		'get readsb.main.lon')
			[ -f "$test_dir/lon" ] || return 1
			IFS= read -r value < "$test_dir/lon"
			printf '%s\n' "$value"
			;;
		'set readsb.main.lat='*)
			printf '%s %s\n' "$1" "$2" >> "$test_dir/calls"
			[ "$uci_failure" != lat ] || return 9
			if [ -n "$staging" ]; then
				printf 'lat=%s\n' "${2#*=}" >> "$staging/readsb"
			else
				printf '%s\n' "${2#*=}" > "$test_dir/lat"
			fi
			;;
		'set readsb.main.lon='*)
			printf '%s %s\n' "$1" "$2" >> "$test_dir/calls"
			[ "$uci_failure" != lon ] || return 9
			if [ -n "$staging" ]; then
				printf 'lon=%s\n' "${2#*=}" >> "$staging/readsb"
			else
				printf '%s\n' "${2#*=}" > "$test_dir/lon"
			fi
			;;
		'commit readsb')
			printf '%s %s\n' "$1" "$2" >> "$test_dir/calls"
			[ "$uci_failure" != commit ] || return 9
			if [ -n "$staging" ]; then
				while IFS= read -r value; do
					case $value in
						lat=*) printf '%s\n' "${value#*=}" > "$test_dir/lat" ;;
						lon=*) printf '%s\n' "${value#*=}" > "$test_dir/lon" ;;
						*) return 99 ;;
					esac
				done < "$staging/readsb"
			fi
			;;
		'revert readsb.main.lat'|'revert readsb.main.lon') return 0 ;;
		*)
			printf 'unexpected uci call: %s\n' "$*" >&2
			return 99
			;;
	esac
}

seed_coordinates() {
	rm -f "$test_dir/lat" "$test_dir/lon" "$test_dir/stage-path"
	[ "$stored_lat" = UNSET ] || printf '%s\n' "$stored_lat" > "$test_dir/lat"
	[ "$stored_lon" = UNSET ] || printf '%s\n' "$stored_lon" > "$test_dir/lon"
}

test_update_section() (
	stored_lat=$1 stored_lon=$2
	# Used by the extracted production function.
	# shellcheck disable=SC2034
	force=$3 dry_run=$4
	lookup_mode=$5 uci_failure=$6
	expected_rc=$7 expected_calls=$8 expected_lat=$9 expected_lon=${10}
	expected_preview=${11:-}

	seed_coordinates
	: > "$test_dir/calls"
	saved_path=$PATH
	PATH="$test_dir/bin"
	rc=0
	update_section main > "$test_dir/output" 2>&1 || rc=$?
	PATH=$saved_path
	stored_lat=$(uci -q get readsb.main.lat) || stored_lat=UNSET
	stored_lon=$(uci -q get readsb.main.lon) || stored_lon=UNSET
	assert_equal "$rc" "$expected_rc" || {
		cat "$test_dir/output" >&2
		return 1
	}
	assert_equal "$stored_lat" "$expected_lat" || return 1
	assert_equal "$stored_lon" "$expected_lon" || return 1
	assert_equal "$(cat "$test_dir/calls")" "$expected_calls" || return 1
	if [ -f "$test_dir/stage-path" ]; then
		IFS= read -r path < "$test_dir/stage-path"
		[ ! -e "$path" ] || { printf 'private staging directory leaked: %s\n' "$path" >&2; return 1; }
	fi
	assert_equal "$(awk '/^\[dry-run\] would set / {
		for (i = 4; i <= NF; i++) print "set " $i
	}' "$test_dir/output")" "$expected_preview" || return 1
	if [ "$rc" -eq 0 ] && [ "$dry_run" -eq 0 ] && [ -n "$expected_calls" ]; then
		grep -Fq "lat=$expected_lat lon=$expected_lon" "$test_dir/output" || return 1
	fi
	if [ "$rc" -eq 1 ]; then
		if [ "$lookup_mode" = success ]; then
			grep -q '^error:' "$test_dir/output" || return 1
			grep -q 'rc=9' "$test_dir/output" || return 1
		else
			grep -q '^warn: geoip lookup failed' "$test_dir/output" || return 1
		fi
	fi
)

set_lat='set readsb.main.lat=48.8566'
set_lon='set readsb.main.lon=2.3522'
both="lookup
$set_lat
$set_lon
commit readsb"
lat_only="lookup
$set_lat
commit readsb"
lon_only="lookup
$set_lon
commit readsb"

run_test 'Missing longitude does not replace precise latitude' \
	test_update_section 51.50123456 '' 0 0 success '' 0 "$lon_only" 51.50123456 2.3522
run_test 'Missing latitude does not replace precise longitude' \
	test_update_section '' -0.14123456 0 0 success '' 0 "$lat_only" 48.8566 -0.14123456
run_test 'Both empty coordinates are filled' \
	test_update_section '' '' 0 0 success '' 0 "$both" 48.8566 2.3522
run_test 'Both absent UCI options are filled' \
	test_update_section UNSET UNSET 0 0 success '' 0 "$both" 48.8566 2.3522
run_test 'Absent longitude does not replace precise latitude' \
	test_update_section 51.50123456 UNSET 0 0 success '' 0 "$lon_only" 51.50123456 2.3522
run_test 'Absent latitude does not replace precise longitude' \
	test_update_section UNSET -0.14123456 0 0 success '' 0 "$lat_only" 48.8566 -0.14123456
run_test 'Latitude zero is already populated' \
	test_update_section 0 '' 0 0 success '' 0 "$lon_only" 0 2.3522
run_test 'Longitude zero is already populated' \
	test_update_section '' 0 0 0 success '' 0 "$lat_only" 48.8566 0
run_test 'Both populated coordinates skip lookup and UCI mutations' \
	test_update_section 51.50123456 -0.14123456 0 0 success '' 0 '' 51.50123456 -0.14123456
run_test 'Both zero coordinates skip lookup and UCI mutations' \
	test_update_section 0 0 0 0 success '' 0 '' 0 0

run_test 'Force fills both empty coordinates' \
	test_update_section '' '' 1 0 success '' 0 "$both" 48.8566 2.3522
run_test 'Force replaces populated latitude while filling longitude' \
	test_update_section 51.50123456 '' 1 0 success '' 0 "$both" 48.8566 2.3522
run_test 'Force replaces populated longitude while filling latitude' \
	test_update_section '' -0.14123456 1 0 success '' 0 "$both" 48.8566 2.3522
run_test 'Force replaces both populated coordinates' \
	test_update_section 51.50123456 -0.14123456 1 0 success '' 0 "$both" 48.8566 2.3522

run_test 'Dry-run previews both missing coordinates without changing UCI' \
	test_update_section '' '' 0 1 success '' 0 lookup '' '' "$set_lat
$set_lon"
run_test 'Dry-run previews only missing longitude' \
	test_update_section 51.50123456 '' 0 1 success '' 0 lookup 51.50123456 '' "$set_lon"
run_test 'Dry-run previews only missing latitude' \
	test_update_section '' -0.14123456 0 1 success '' 0 lookup '' -0.14123456 "$set_lat"
run_test 'Dry-run skips both populated coordinates' \
	test_update_section 51.50123456 -0.14123456 0 1 success '' 0 '' 51.50123456 -0.14123456
run_test 'Forced dry-run previews both replacements without changing UCI' \
	test_update_section 51.50123456 -0.14123456 1 1 success '' 0 lookup 51.50123456 -0.14123456 "$set_lat
$set_lon"

run_test 'No provider result leaves both coordinates empty and returns failure' \
	test_update_section '' '' 0 0 empty '' 1 lookup '' ''
run_test 'No provider result preserves populated latitude' \
	test_update_section 51.50123456 '' 0 0 empty '' 1 lookup 51.50123456 ''
run_test 'No provider result preserves populated longitude' \
	test_update_section '' -0.14123456 0 0 empty '' 1 lookup '' -0.14123456
run_test 'A failed lookup with output still makes no UCI changes' \
	test_update_section 51.50123456 '' 0 0 failure '' 1 lookup 51.50123456 ''
run_test 'Forced failed lookup preserves both populated coordinates' \
	test_update_section 51.50123456 -0.14123456 1 0 empty '' 1 lookup 51.50123456 -0.14123456
run_test 'Dry-run still reports lookup failure' \
	test_update_section '' -0.14123456 0 1 empty '' 1 lookup '' -0.14123456
run_test 'Populated coordinates do not need a working provider' \
	test_update_section 51.50123456 -0.14123456 0 0 empty '' 0 '' 51.50123456 -0.14123456
run_test 'Failed latitude write stops before longitude or commit' \
	test_update_section '' '' 0 0 success lat 1 "lookup
$set_lat" '' ''
run_test 'Failed missing latitude write preserves populated longitude' \
	test_update_section '' -0.14123456 0 0 success lat 1 "lookup
$set_lat" '' -0.14123456
run_test 'Failed missing longitude write preserves populated latitude' \
	test_update_section 51.50123456 '' 0 0 success lon 1 "lookup
$set_lon" 51.50123456 ''
run_test 'Failed longitude write leaves neither coordinate staged' \
	test_update_section '' '' 0 0 success lon 1 "lookup
$set_lat
$set_lon" '' ''
run_test 'Commit failure after filling latitude is reported without replacing longitude' \
	test_update_section '' -0.14123456 0 0 success commit 1 "$lat_only" '' -0.14123456
run_test 'Commit failure after filling both coordinates is reported' \
	test_update_section '' '' 0 0 success commit 1 "$both" '' ''
run_test 'Forced update failure preserves the original precise coordinates' \
	test_update_section 51.50123456 -0.14123456 1 0 success lon 1 "lookup
$set_lat
$set_lon" 51.50123456 -0.14123456
run_test 'Forced commit failure preserves the original precise coordinates' \
	test_update_section 51.50123456 -0.14123456 1 0 success commit 1 "$both" 51.50123456 -0.14123456

test_cli() (
	stored_lat=$1 stored_lon=$2
	tooling=$3 lookup_mode=$4 uci_failure=$5 expected_rc=$6 expected_calls=$7
	shift 7

	_verbose_apply() { :; }
	print_help() { echo help; }
	load_uci_safely() { :; }
	config_foreach() { "$1" main; return 0; }
	jsonfilter() { return 99; }
	wget() { return 99; }
	[ "$tooling" != no_jsonfilter ] || unset -f jsonfilter
	[ "$tooling" != no_http ] || unset -f wget

	seed_coordinates
	: > "$test_dir/calls"
	rc=0
	(
		# Only shell builtins and mocks are visible during CLI execution.
		PATH="$test_dir/bin"
		# shellcheck source=/dev/null
		. "$test_dir/options.sh"
		# shellcheck source=/dev/null
		. "$test_dir/tooling.sh"
		# shellcheck source=/dev/null
		. "$test_dir/dispatch.sh"
	) > "$test_dir/output" 2>&1 || rc=$?
	assert_equal "$rc" "$expected_rc" || {
		cat "$test_dir/output" >&2
		return 1
	}
	assert_equal "$(cat "$test_dir/calls")" "$expected_calls" || return 1
	if [ "$expected_rc" = 1 ] && [ -z "$expected_calls" ]; then
		grep -q '^error:' "$test_dir/output" && grep -q '^help$' "$test_dir/output" || return 1
	fi
	case "$tooling" in
		no_jsonfilter) grep -q '^error: jsonfilter not installed' "$test_dir/output" ;;
		no_http) grep -q '^error: no HTTP client found' "$test_dir/output" ;;
	esac
)

run_test 'Default all-section CLI fills only missing latitude' \
	test_cli '' -0.14123456 full success '' 0 "$lat_only"
run_test 'Named-section CLI fills only missing longitude' \
	test_cli 51.50123456 '' full success '' 0 "$lon_only" main
run_test 'Default CLI skips fully populated coordinates' \
	test_cli 51.50123456 -0.14123456 full success '' 0 ''
run_test 'Explicit force from a wizard or one-shot invocation replaces both coordinates' \
	test_cli 51.50123456 -0.14123456 full success '' 0 "$both" --force
run_test 'Named-section CLI honors force after the section name' \
	test_cli 51.50123456 '' full success '' 0 "$both" main --force
run_test 'Named-section dry-run performs no UCI mutations' \
	test_cli '' -0.14123456 full success '' 0 lookup --dry-run main
run_test 'Forced dry-run performs no UCI mutations' \
	test_cli 51.50123456 -0.14123456 full success '' 0 lookup --force --dry-run main
run_test 'Named-section CLI propagates lookup failure' \
	test_cli 51.50123456 '' full empty '' 1 lookup main
run_test 'Named-section CLI propagates write failure' \
	test_cli 51.50123456 '' full success lon 1 "lookup
$set_lon" main
run_test 'Named-section CLI propagates commit failure' \
	test_cli '' -0.14123456 full success commit 1 "$lat_only" main
run_test 'Default all-section CLI propagates lookup failure' \
	test_cli 51.50123456 '' full empty '' 1 lookup
run_test 'Default all-section CLI propagates write failure' \
	test_cli 51.50123456 '' full success lon 1 "lookup
$set_lon"
run_test 'Default all-section CLI propagates commit failure' \
	test_cli '' -0.14123456 full success commit 1 "$lat_only"
run_test 'Missing jsonfilter returns status 2 before lookup or UCI changes' \
	test_cli '' '' no_jsonfilter success '' 2 '' main
run_test 'Missing HTTP client returns status 2 before lookup or UCI changes' \
	test_cli '' '' no_http success '' 2 '' --force
run_test 'Unknown CLI option remains a fatal error before lookup' \
	test_cli '' '' full success '' 1 '' --unknown
run_test 'Two positional sections are rejected before lookup or mutation' \
	test_cli '' '' full success '' 1 '' main extra
run_test 'Duplicate positional sections are also rejected' \
	test_cli '' '' full success '' 1 '' main main
run_test 'Flags between positional sections do not hide extra arguments' \
	test_cli '' '' full success '' 1 '' main --force extra
run_test 'Dry-run still rejects extra sections' \
	test_cli '' '' full success '' 1 '' --dry-run main extra
run_test 'An empty positional section is rejected' \
	test_cli '' '' full success '' 1 '' ''

test_exit_trap() (
	rc=0
	(
		# shellcheck disable=SC2034
		last_stage=test/done
		# shellcheck source=/dev/null
		. "$test_dir/exit.sh"
		exit "$1"
	) > "$test_dir/output" 2>&1 || rc=$?
	assert_equal "$rc" "$1" || return 1
	grep -q "exit rc=$1 stage='test/done'" "$test_dir/output"
)
run_test 'GeoIP uses the portable numeric exit trap' \
	grep -qx 'trap on_exit 0' "$package_dir/files/readsb-geoip"
run_test 'GeoIP exit logging preserves success' test_exit_trap 0
run_test 'GeoIP exit logging preserves failure' test_exit_trap 7

printf '%s tests, %s failures\n' "$tests" "$failures"
[ "$failures" -eq 0 ]

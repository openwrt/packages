#!/bin/sh
# SPDX-License-Identifier: GPL-2.0-only

package_dir=$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd) || exit 1
tmpdir=$(mktemp -d) || exit 1
trap 'rm -f "$tmpdir/calls" "$tmpdir/output" "$tmpdir/cli.sh"; rmdir "$tmpdir"' 0
trap 'exit 1' HUP INT TERM
# shellcheck source=/dev/null
. "$package_dir/files/readsb.functions.sh"
sed -n '/^cmd_setup_companions() {/,/^}/p' "$package_dir/files/readsb-feeder" > "$tmpdir/cli.sh"
# shellcheck source=/dev/null
. "$tmpdir/cli.sh"

tests=0 failures=0
run_test() {
	label=$1; shift
	tests=$((tests+1))
	if "$@"; then printf 'ok %s - %s\n' "$tests" "$label"; else
		printf 'not ok %s - %s\n' "$tests" "$label"; failures=$((failures+1))
	fi
}
assert_equal() {
	[ "$1" = "$2" ] && return 0
	printf 'expected <%s>, got <%s>\n' "$2" "$1" >&2
	return 1
}
test_discovery() (
	installed=$1 available=$2 expected=$3
	readsb_pkg_installed() { [ "$installed" = 1 ]; }
	opkg() {
		[ "$1" = list ] && [ "$2" = adsbexchange-stats ] || return 99
		[ "$available" = 0 ] || echo 'adsbexchange-stats - 2023-02-22-1 - uploader'
	}
	assert_equal "$(readsb_feeder_optional_pkgs adsbexchange)" "$expected" || return 1
	if [ "$installed" = 1 ]; then
		assert_equal "$(readsb_companion_pkgs_all)" adsbexchange-stats
	else
		assert_equal "$(readsb_companion_pkgs_all)" ''
	fi
)
run_test 'unavailable uninstalled companion is not recommended' test_discovery 0 0 ''
run_test 'companion in configured feeds is discoverable without installation' test_discovery 0 1 adsbexchange-stats
run_test 'installed companion remains discoverable without feed metadata' test_discovery 1 0 adsbexchange-stats

test_opt_in() (
	installed=$1 available=$2 consent=$3 install_rc=$4 activate_rc=$5 expected_rc=$6 expected_actions=$7
	current_feeder=${8:-}
	enabled=${9:-0}
	: > "$tmpdir/calls"
	readsb_pkg_installed() { [ "$installed" = 1 ]; }
	readsb_pkg_status() {
		if [ "$installed" = 0 ]; then echo missing; return 1; fi
		if [ "$enabled" = 1 ]; then echo 'running adsbexchange-stats'; else echo 'disabled adsbexchange-stats'; fi
	}
	uci() {
		case $* in
			'-q get adsbexchange-stats.main.feeder') echo "$current_feeder" ;;
			'-q get adsbexchange-stats.main.enabled') echo "$enabled" ;;
			'-q get readsb.adsbx') echo feeder ;;
			'-q get readsb.adsbx.preset') echo adsbexchange ;;
			'-q get readsb.adsbx.enabled') echo 1 ;;
			*) return 1 ;;
		esac
	}
	opkg() {
		case $1 in
			list)
				[ "$available" = 0 ] || echo 'adsbexchange-stats - 2023-02-22-1 - uploader'
				;;
			install)
				printf 'install %s\n' "$2" >> "$tmpdir/calls"
				[ "$install_rc" = 0 ] || return "$install_rc"
				installed=1
				;;
			*) echo "unexpected package operation: $*" >&2; return 99 ;;
		esac
	}
	readsb_companion_service() {
		printf 'service %s\n' "$*" >> "$tmpdir/calls"
		return "$activate_rc"
	}
	wiz_say() { printf '%s\n' "$*"; }
	wiz_yesno() {
		assert_equal "$3" N || return 99
		printf 'consent\n' >> "$tmpdir/calls"
		[ "$consent" != abort ] || return 1
		export "$1=$consent"
	}
	_log() { :; }
	_notice() { :; }
	_warn() { printf 'warning: %s\n' "$*" >&2; }
	rc=0
	wiz_offer_install_companions adsbexchange adsbx > "$tmpdir/output" 2>&1 || rc=$?
	assert_equal "$rc" "$expected_rc" || { cat "$tmpdir/output" >&2; return 1; }
	assert_equal "$(cat "$tmpdir/calls")" "$expected_actions" || return 1
	if [ -n "$current_feeder" ] && [ "$current_feeder" != adsbx ]; then
		grep -q "$current_feeder" "$tmpdir/output"
	fi
)
run_test 'no package available means no prompts or network operations' \
	test_opt_in 0 0 1 0 0 0 ''
run_test 'declining optional uploads performs no install or activation' \
	test_opt_in 0 1 0 0 0 0 consent
run_test 'aborting optional consent does not mutate anything' \
	test_opt_in 0 1 abort 0 0 1 consent
run_test 'consent precedes install and feeder-specific activation' \
	test_opt_in 0 1 1 0 0 0 "$(printf 'consent\ninstall adsbexchange-stats\nservice adsbexchange-stats activate adsbx')"
run_test 'installed package is activated without reinstalling' \
	test_opt_in 1 0 1 0 0 0 "$(printf 'consent\nservice adsbexchange-stats activate adsbx')"
run_test 'installed but declined uploader remains disabled' \
	test_opt_in 1 0 0 0 0 0 consent
run_test 'installation failure does not attempt activation' \
	test_opt_in 0 1 1 9 0 2 "$(printf 'consent\ninstall adsbexchange-stats')"
run_test 'activation failure is surfaced' \
	test_opt_in 1 0 1 0 9 2 "$(printf 'consent\nservice adsbexchange-stats activate adsbx')"
run_test 'another feeder binding is not replaced on No' \
	test_opt_in 1 0 0 0 0 0 consent another 1
run_test 'switching to a different feeder requires explicit consent' \
	test_opt_in 1 0 1 0 0 0 "$(printf 'consent\nservice adsbexchange-stats activate adsbx')" another 1
run_test 'already enabled matching uploader needs no new consent or activation' \
	test_opt_in 1 0 0 0 0 0 '' adsbx 1

test_optional_warnings() (
	installed=$1 state=$2 selected=${3:-adsbx}
	: > "$tmpdir/calls"
	readsb_pkg_installed() { [ "$installed" = 1 ]; }
	readsb_feeder_optional_pkgs() { echo adsbexchange-stats; }
	readsb_pkg_status() { printf '%s adsbexchange-stats\n' "$state"; }
	uci() { echo "$selected"; }
	_warn() { echo warning >> "$tmpdir/calls"; }
	readsb_warn_companions adsbexchange adsbx
	[ ! -s "$tmpdir/calls" ]
)
run_test 'missing optional uploader is not a warning' test_optional_warnings 0 missing
run_test 'intentionally disabled optional uploader is not a warning' test_optional_warnings 1 disabled
run_test 'a different feeder binding does not warn about this feeder' test_optional_warnings 1 stopped another

test_setup_command() (
	want=$1 terminal=$2 active=$3 available=$4 offer_rc=$5 expected_rc=$6 expected_calls=$7
	: > "$tmpdir/calls"
	readsb_feeder_section_exists() { [ "$1" = adsbx ]; }
	wiz_available() { [ "$terminal" = 1 ]; }
	config_load() { :; }
	uci() { echo 00000000-0000-4000-8000-000000000001; }
	# shellcheck disable=SC2034
	readsb_feeder_resolve() {
		readsb_feeder_enabled=$active
		readsb_feeder_preset=adsbexchange
	}
	readsb_feeder_optional_pkgs() {
		[ "$available" = 0 ] || echo adsbexchange-stats
	}
	wiz_offer_install_companions() {
		printf 'offer %s\n' "$*" >> "$tmpdir/calls"
		return "$offer_rc"
	}
	rc=0
	cmd_setup_companions "$want" > "$tmpdir/output" 2>&1 || rc=$?
	assert_equal "$rc" "$expected_rc" && assert_equal "$(cat "$tmpdir/calls")" "$expected_calls"
)
run_test 'setup CLI passes the actual feeder name to optional activation' \
	test_setup_command adsbx 1 1 1 0 0 'offer adsbexchange adsbx'
run_test 'setup CLI rejects a missing feeder' test_setup_command missing 1 1 1 0 3 ''
run_test 'setup CLI rejects a disabled feeder' test_setup_command adsbx 1 0 1 0 2 ''
run_test 'setup CLI rejects non-interactive invocation' test_setup_command adsbx 0 1 1 0 1 ''
run_test 'setup CLI tolerates unavailable optional packages' test_setup_command adsbx 1 1 0 0 0 ''
run_test 'setup CLI treats consent cancellation as clean' \
	test_setup_command adsbx 1 1 1 1 0 'offer adsbexchange adsbx'
run_test 'setup CLI propagates approved activation failure' \
	test_setup_command adsbx 1 1 1 2 2 'offer adsbexchange adsbx'

printf '%s tests, %s failures\n' "$tests" "$failures"
[ "$failures" -eq 0 ]

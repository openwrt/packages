#!/bin/sh
# SPDX-License-Identifier: GPL-2.0-only

package_dir=$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd) || exit 1
tmpdir=$(mktemp -d) || exit 1
trap 'rm -f "$tmpdir/init.sh" "$tmpdir/hotplug.sh" "$tmpdir/location.sh" "$tmpdir/config" "$tmpdir/commands" "$tmpdir/messages" "$tmpdir/writes" "$tmpdir/log" "$tmpdir/bin/readsb-geoip"; rmdir "$tmpdir/bin" "$tmpdir"' 0
trap 'exit 1' HUP INT TERM
mkdir "$tmpdir/bin" || exit 1
# shellcheck disable=SC2016
printf '%s\n' '#!/bin/sh' 'printf "geoip %s\n" "$*" >> "$READSB_TEST_COMMANDS"' > "$tmpdir/bin/readsb-geoip" || exit 1
chmod 700 "$tmpdir/bin/readsb-geoip" || exit 1

# Source definitions without touching host OpenWrt paths or dispatching hotplug.
# shellcheck source=/dev/null
. "$package_dir/files/readsb.functions.sh"
sed '\|^\. /usr/lib/readsb/functions\.sh$|d' "$package_dir/files/readsb.init" > "$tmpdir/init.sh" || exit 1
sed -n '/^_banner_print_companions() {/,/^}/p' "$package_dir/files/readsb-setup" >> "$tmpdir/init.sh" || exit 1
# shellcheck source=/dev/null
. "$tmpdir/init.sh"
sed -n '
	/^pin_device() {/,/^}/p
	/^check_freq() {/,/^}/p
	/^case "$ACTION" in/,$p
' "$package_dir/files/readsb.hotplug" > "$tmpdir/hotplug.sh" || exit 1
sed -n '/^# --- step 1: location /,/^# --- step 2: UUID /p' \
	"$package_dir/files/readsb-setup" > "$tmpdir/location.sh" || exit 1

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
assert_equal() {
	[ "$1" = "$2" ] && return 0
	printf 'expected <%s>, got <%s>\n' "$2" "$1" >&2
	return 1
}
reset_config() {
	printf '%s\n' 'readsb.main.enabled=1' 'readsb.main.hotplug=1' \
		'readsb.main.device_type=rtlsdr' 'readsb.main.net_only=0' "$@" > "$tmpdir/config"
	: > "$tmpdir/commands"
	: > "$tmpdir/messages"
	: > "$tmpdir/writes"
}
config_get() {
	_test_value=$(awk -v key="readsb.$2.$3=" '
		index($0, key) == 1 { value = substr($0, length(key) + 1); found = 1 }
		END { if (!found) exit 1; print value }
	' "$tmpdir/config") || _test_value=${4:-}
	export "$1=$_test_value"
}
config_get_bool() { config_get "$@"; }
uci() {
	[ "$1" != -q ] || shift
	case $1 in
		get)
			case $2 in
				system.@system\[0\].log_level) printf '%s\n' "${test_log_level:-info}" ;;
				readsb.main.*)
					_test_get=''
					config_get _test_get main "${2##*.}"
					printf '%s\n' "$_test_get"
					;;
				*) return 1 ;;
			esac
			;;
		set)
			[ "${2%%=*}" != "${fail_set:-}" ] || return 1
			printf '%s\n' "$2" >> "$tmpdir/config"
			printf 'set %s\n' "$2" >> "$tmpdir/writes"
			;;
		commit) echo commit >> "$tmpdir/writes" ;;
		*) return 1 ;;
	esac
}
_log() { printf 'info: %s\n' "$*" >> "$tmpdir/messages"; }
_notice() { printf 'notice: %s\n' "$*" >> "$tmpdir/messages"; }
_warn() { printf 'warn: %s\n' "$*" >> "$tmpdir/messages"; }
_err() { printf 'error: %s\n' "$*" >> "$tmpdir/messages"; }
_debug() { :; }
assert_config() {
	_actual=''
	config_get _actual main "$1"
	assert_equal "$_actual" "$2"
}

test_frequency() (
	rc=0
	hz=$(readsb_freq_to_hz "$1") || rc=$?
	if [ "$2" = invalid ]; then
		assert_equal "$rc" 1 && assert_equal "$hz" ''
	else
		assert_equal "$rc" 0 && assert_equal "$hz" "$2" || return 1
		expected_mhz=$(awk -v hz="$2" 'BEGIN { printf "%d", hz / 1000000 }')
		assert_equal "$(readsb_freq_to_mhz "$1")" "$expected_mhz"
	fi
)
while IFS='|' read -r input expected; do
	run_test "frequency [$input]" test_frequency "$input" "$expected"
done <<'EOF'
|1090000000
978|978000000
1090|1090000000
1090MHz|1090000000
1090m|1090000000
1090mhz|1090000000
 1090 MHz |1090000000
001090|1090000000
978000000|978000000
1090000000|1090000000
2147483647|2147483647
0|invalid
-1090|invalid
1090.5MHz|invalid
1090garbage|invalid
2147483648|invalid
999999MHz|invalid
EOF

test_ppm() (
	rc=0
	wiz_v_ppm "$1" || rc=$?
	assert_equal "$rc" "$2"
)
for input in -100 -1 0 +1 99 100 0001; do
	run_test "integer PPM $input accepted" test_ppm "$input" 0
done
for input in '' .9 0.9 -0.9 1.0 101 -101 1e1 invalid; do
	run_test "invalid PPM [$input] rejected" test_ppm "$input" 1
done

test_sdr_args() (
	reset_config "readsb.main.freq=$1" "readsb.main.gain=$2" "readsb.main.ppm=$3" \
		"readsb.main.net_only=${7:-0}" "readsb.main.enable_biastee=${8:-0}"
	test_log_level=${6:-info}
	mkdir() { :; }
	procd_open_instance() { echo open >> "$tmpdir/commands"; }
	procd_set_param() {
		[ "$1" = command ] || return 0
		shift
		printf '%s\n' "$@" >> "$tmpdir/commands"
	}
	procd_append_param() { shift; printf '%s\n' "$@" >> "$tmpdir/commands"; }
	procd_close_instance() { :; }
	config_load() { :; }
	config_foreach() { [ "$1" != start_instance ] || start_instance main; }
	seed_hotplug_state() { :; }
	readsb_is_sdr_present() { return 1; }
	rc=0
	if [ "${9:-0}" = 1 ]; then
		start_service || rc=$?
	else
		start_instance main || rc=$?
	fi
	if [ "$4" = invalid ]; then
		assert_equal "$rc" 1 || return 1
		[ ! -s "$tmpdir/commands" ] && grep -q '^error:' "$tmpdir/messages"
	else
		assert_equal "$rc" 0 || return 1
		assert_equal "$(grep '^--freq=' "$tmpdir/commands")" "${4:+--freq=$4}" || return 1
		assert_equal "$(grep '^--gain=' "$tmpdir/commands")" "${5:+--gain=$5}" || return 1
		if [ "${7:-0}" = 1 ]; then
			! grep -Eq '^--(device-type|ppm|enable-biastee)' "$tmpdir/commands"
		else
			assert_equal "$(grep '^--ppm=' "$tmpdir/commands")" "${3:+--ppm=$3}" || return 1
			assert_equal "$(grep -E '^--(device-type|freq|gain|ppm)' "$tmpdir/commands" | head -n 1)" \
				'--device-type=rtlsdr' || return 1
			assert_equal "$(grep -c '^--enable-biastee$' "$tmpdir/commands")" "${8:-0}"
		fi
	fi
)
run_test 'init normalizes MHz and omits gain=max' test_sdr_args 978 max 0 978000000 ''
run_test 'init normalizes suffixed MHz and keeps numeric gain' test_sdr_args 1090MHz 49.6 +1 1090000000 49.6
run_test 'init preserves Hz and auto gain' test_sdr_args 1090000000 auto -1 1090000000 auto
run_test 'debug logging enables verbose auto gain' test_sdr_args 1090 auto 0 1090000000 auto-verbose debug
run_test 'empty freq/gain/ppm use upstream defaults' test_sdr_args '' '' '' '' ''
run_test 'gain=max alone uses the upstream maximum' test_sdr_args '' max 0 '' ''
run_test 'invalid frequency refuses to start' test_sdr_args 1090oops auto 0 invalid ''
run_test 'fractional UCI PPM refuses to start' test_sdr_args 1090 auto 0.9 invalid ''
run_test 'service startup propagates invalid tuning failure' test_sdr_args bad auto 0 invalid '' info 0 0 1
run_test 'net-only ignores SDR tuning' test_sdr_args invalid max 0.9 '' '' info 1
run_test 'bias-T is passed only when enabled' test_sdr_args 1090 auto 0 1090000000 auto info 0 1
run_test 'package enables upstream bias-T support' grep -q 'HAVE_BIASTEE=yes' "$package_dir/Makefile"

test_companions() (
	reset_config
	readsb_pkg_installed() { [ "$1" = adsbexchange-stats ] && [ "$installed" = 1 ]; }
	installed=0
	assert_equal "$(readsb_feeder_optional_pkgs adsbexchange)" '' || return 1
	assert_equal "$(readsb_companion_pkgs_all)" '' || return 1
	assert_equal "$(_banner_print_companions)" '' || return 1
	readsb_warn_companions adsbexchange test
	[ ! -s "$tmpdir/messages" ] || return 1
	wiz_yesno() { echo 'unexpected prompt' >&2; return 1; }
	wiz_offer_install_companions adsbexchange || return 1
	installed=1
	assert_equal "$(readsb_feeder_optional_pkgs adsbexchange)" adsbexchange-stats || return 1
	assert_equal "$(readsb_companion_pkgs_all)" adsbexchange-stats
)
test_telemetry_consent() (
	reset_config
	readsb_pkg_installed() { return 0; }
	readsb_pkg_status() { echo 'stopped readsb-test-no-service'; return 2; }
	wiz_say() { :; }
	wiz_yesno() {
		assert_equal "$3" N || return 1
		[ "$1" = ans ] || return 1
		# shellcheck disable=SC2034
		ans=0
	}
	wiz_offer_install_companions adsbexchange || return 1
	[ ! -s "$tmpdir/messages" ]
)
run_test 'unavailable companions are not recommended; installed ones remain discoverable' test_companions
run_test 'starting a telemetry companion requires an explicit Yes' test_telemetry_consent

test_location_wizard() (
	reset_config "readsb.main.lat=$1" "readsb.main.lon=$2"
	change=$3 consent=$4 expected=$5
	# shellcheck disable=SC2034
	changes_made=0
	wiz_say() { printf '%s\n' "$*" >> "$tmpdir/messages"; }
	# shellcheck disable=SC2034
	wiz_choose() { loc_src='auto-detect'; }
	# shellcheck disable=SC2034
	wiz_yesno() {
		case $1 in
			upd) upd=$change ;;
			geoip_once)
				assert_equal "$3" N || return 1
				geoip_once=$consent
				;;
			geoip_auto) geoip_auto=0 ;;
			*) return 1 ;;
		esac
	}
	READSB_TEST_COMMANDS="$tmpdir/commands"
	PATH="$tmpdir/bin:$PATH"
	export READSB_TEST_COMMANDS PATH
	# shellcheck source=/dev/null
	. "$tmpdir/location.sh"
	assert_equal "$(cat "$tmpdir/commands")" "$expected" || return 1
	if [ "$expected" = 'geoip --force' ]; then
		grep -q 'replace both' "$tmpdir/messages"
	fi
)
run_test 'location wizard preserves existing latitude when filling longitude' \
	test_location_wizard 51.5 '' 1 1 'geoip '
run_test 'location wizard preserves existing longitude when filling latitude' \
	test_location_wizard '' -0.1 1 1 'geoip '
run_test 'location wizard fills an empty location without force' \
	test_location_wizard '' '' 1 1 'geoip '
run_test 'explicit change of a complete location explains and forces replacement' \
	test_location_wizard 51.5 -0.1 1 1 'geoip --force'
run_test 'declining location change makes no lookup' \
	test_location_wizard 51.5 -0.1 0 1 ''
run_test 'declining one-time GeoIP consent makes no lookup' \
	test_location_wizard 51.5 '' 1 0 ''

test_log_filter() (
	reset_config
	printf '%s\n' \
		'Fri Oct 2 05:00:00 2026 daemon.warn readsb[10]: connection lost to feed.example port 30004' \
		'Fri Oct 2 05:00:01 2026 daemon.err readsb[10]: Statistics: start - end' \
		'Fri Oct 2 05:00:02 2026 daemon.warn readsb-setup: unrelated warning' \
		'Fri Oct 2 05:00:03 2026 daemon.warn readsb-feeder[20]: connection lost to feed.example port 30004' \
		'Fri Oct 2 05:00:04 2026 daemon.warn readsb-geoip: lookup failed' \
		'Fri Oct 2 05:00:05 2026 daemon.warn readsb-uuid: regenerating' \
		'Fri Oct 2 05:00:06 2026 daemon.warn another-service: mentions readsb: Bad connection' \
		'Fri Oct 2 05:00:07 2026 daemon.info readsb: ready' > "$tmpdir/log"
	logread() { cat "$tmpdir/log"; }
	assert_equal "$(readsb_log_recent 2)" "$(sed -n '2p;8p' "$tmpdir/log")" || return 1
	assert_equal "$(readsb_log_count_errors)" 1 || return 1
	assert_equal "$(readsb_log_count_errors_for feed.example 30004)" 1 || return 1
	assert_equal "$(readsb_log_last_error_for feed.example 30004)" "$(sed -n '1p' "$tmpdir/log")" || return 1
	assert_equal "$(readsb_pkg_log_recent readsb-feeder 1)" "$(sed -n '4p' "$tmpdir/log")"
)
test_stats_log_filter() (
	printf '%s\n' \
		'Fri Oct 2 05:00:00 2026 daemon.err readsb[10]: Statistics: start - end' \
		'Fri Oct 2 05:00:01 2026 daemon.warn readsb-setup: unrelated warning' \
		'Fri Oct 2 05:00:02 2026 daemon.err readsb[10]: 0 samples dropped' \
		'Fri Oct 2 05:00:03 2026 daemon.err readsb[10]: 2 ms for network input and background tasks' > "$tmpdir/log"
	logread() { cat "$tmpdir/log"; }
	assert_equal "$(readsb_log_last_stats_block)" "$(sed -n '1p;3p;4p' "$tmpdir/log")" || return 1
	assert_equal "$(readsb_log_count_errors)" 0
)
run_test 'log filtering matches exact tags before taking the tail' test_log_filter
run_test 'helper warnings do not interrupt daemon stats or degrade health' test_stats_log_filter

run_hotplug() (
	# shellcheck disable=SC2034
	target=main ACTION=$1 event_serial=$2 event_visible=0 vid=0bda pid=2838 READSB_HOTPLUG_SEED=1
	attached=$3
	readsb_list_sdrs() { [ -z "$attached" ] || printf '%s\n' "$attached"; }
	readsb_count_sdrs() { readsb_list_sdrs | awk 'END { print NR+0 }'; }
	check_driver_collision() { :; }
	# shellcheck source=/dev/null
	. "$tmpdir/hotplug.sh"
)
test_auto_pin() (
	reset_config
	first_serial=${1:-NOSERIAL}
	run_hotplug add "$1" "$first_serial" || return 1
	assert_config device "${1:-0}" && assert_config device_auto "${1:-0}" || return 1
	run_hotplug add "$2" "$(printf '%s\n' "$first_serial" "$2")" || return 1
	assert_config device 1090 && assert_config device_auto 1090 || return 1
	writes_before=$(wc -l < "$tmpdir/writes")
	run_hotplug add "$2" "$(printf '%s\n' "$first_serial" "$2")" || return 1
	assert_equal "$(wc -l < "$tmpdir/writes")" "$writes_before"
)
test_manual_pin() (
	reset_config "readsb.main.device=$1" "readsb.main.device_auto=$2"
	case $1 in
		0) serials=$(printf '%s\n' 978 1090) ;;
		*) serials=$(printf '%s\n' "$1" 1090) ;;
	esac
	run_hotplug add 1090 "$serials" || return 1
	assert_config device "$1" && assert_config device_auto ''
)
test_changed_frequency_pin() (
	reset_config 'readsb.main.device=1090' 'readsb.main.device_auto=1090' 'readsb.main.freq=978MHz'
	run_hotplug add 978 "$(printf '%s\n' 978 1090)" || return 1
	assert_config device 978 && assert_config device_auto 978
)
test_unmatched_auto_pin() (
	reset_config 'readsb.main.device=978' 'readsb.main.device_auto=978'
	run_hotplug add spare "$(printf '%s\n' 978 spare)" || return 1
	assert_config device '' && assert_config device_auto '' || return 1
	grep -q 'no serial matches' "$tmpdir/messages"
)
test_remove_pin() (
	reset_config 'readsb.main.device=1090' 'readsb.main.device_auto=1090'
	run_hotplug remove "$1" "$2" || return 1
	assert_config device "$3" && assert_config device_auto "$3"
)
test_reconcile_pin() (
	reset_config 'readsb.main.device=1090' 'readsb.main.device_auto=1090'
	reconcile_no_usb_section main
	assert_config device '' && assert_config device_auto ''
)
test_pin_write_error() (
	reset_config
	fail_set=readsb.main.device_auto
	rc=0
	run_hotplug add 1090 1090 || rc=$?
	assert_equal "$rc" 1 || return 1
	grep -q '^error:' "$tmpdir/messages" && ! grep -q '^commit$' "$tmpdir/writes"
)
run_test '978 then 1090 reselects the matching auto pin, including seed replays' test_auto_pin 978 1090
run_test '1090 then 978 keeps the matching auto pin' test_auto_pin 1090 978
run_test 'serial-less automatic index is reselected when 1090 arrives' test_auto_pin '' 1090
run_test 'changing frequency re-evaluates an automatic pin' test_changed_frequency_pin
run_test 'manual serial pin is preserved' test_manual_pin 978 ''
run_test 'manual numeric pin is preserved' test_manual_pin 0 ''
run_test 'editing an auto pin makes it manual' test_manual_pin 'manual spare' 978
run_test 'unmatched auto pin is cleared with a warning' test_unmatched_auto_pin
run_test 'removing selected SDR clears its marker' test_remove_pin 1090 978 ''
run_test 'removing unrelated SDR preserves the pin' test_remove_pin 978 1090 1090
run_test 'removing the last SDR clears its marker' test_remove_pin 1090 '' ''
run_test 'boot reconciliation clears stale auto-pin metadata' test_reconcile_pin
run_test 'failed auto-pin metadata write reports an error and does not commit' test_pin_write_error

printf '%s tests, %s failures\n' "$tests" "$failures"
[ "$failures" -eq 0 ]

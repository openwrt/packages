#!/bin/sh
# SPDX-License-Identifier: GPL-2.0-only
# Test overrides intentionally remain in each test's subshell.
# shellcheck disable=SC2030,SC2031

package_dir=$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd) || exit 1
readsb_dir=${1:-"$package_dir/../readsb-wiedehopf"}
[ -r "$readsb_dir/files/readsb.functions.sh" ] || {
	echo "usage: sh tests/stats.sh /path/to/utils/readsb-wiedehopf" >&2
	exit 1
}
tmpdir=$(mktemp -d) || exit 1
cleanup() {
	status=$?
	trap - 0
	rm -f "$tmpdir/functions.sh" "$tmpdir/init.sh" "$tmpdir/upload.sh" \
		"$tmpdir/postinst.sh" "$tmpdir/prerm.sh" "$tmpdir/config" \
		"$tmpdir/calls" "$tmpdir/log" "$tmpdir/uuid" "$tmpdir/env" "$tmpdir/env-check.sh" \
		"$tmpdir/uci-calls" "$tmpdir/cleanup-output" "$tmpdir/stderr" "$tmpdir/stdout" || \
		printf 'cleanup: could not remove test files in %s\n' "$tmpdir" >&2
	rmdir "$tmpdir" 2>/dev/null || \
		printf 'cleanup: temporary directory retained at %s (leftover files or removal failure)\n' "$tmpdir" >&2
	exit "$status"
}
trap cleanup 0
trap 'exit 1' HUP INT TERM
# shellcheck source=/dev/null
. "$readsb_dir/files/readsb.functions.sh"
sed '\|^\. /usr/lib/readsb/functions.sh$|d' "$package_dir/files/adsbexchange-stats.functions.sh" > "$tmpdir/functions.sh"
sed '\|^\. /usr/lib/adsbexchange-stats/functions.sh$|d' "$package_dir/files/adsbexchange-stats.init" > "$tmpdir/init.sh"
sed '\|^\. /usr/lib/adsbexchange-stats/functions.sh$|d' "$package_dir/files/adsbexchange-stats.json-status-helpers.sh" > "$tmpdir/upload.sh"
for hook in postinst prerm; do
	sed -n "/^define Package\\/adsbexchange-stats\\/$hook$/,/^endef$/p" "$package_dir/Makefile" \
		| sed '1d;$d;s/\$\$/\$/g;s|/etc/init.d/adsbexchange-stats|service_mock|g' > "$tmpdir/$hook.sh"
done
# shellcheck source=/dev/null
. "$tmpdir/functions.sh"
# shellcheck source=/dev/null
. "$tmpdir/init.sh"
# shellcheck source=/dev/null
. "$tmpdir/upload.sh"
# shellcheck disable=SC2034
ADSBX_RUNTIME_DIR=$tmpdir ADSBX_UUID_FILE="$tmpdir/uuid" ADSBX_ENV_FILE="$tmpdir/env"

main_uuid=00000000-0000-4000-8000-000000000001
override_uuid=00000000-0000-4000-8000-000000000002
seed() {
	printf '%s\n' "readsb.main.uuid=$main_uuid" 'readsb.main.write_json=/var/run/readsb' \
		'readsb.first=feeder' 'readsb.first.preset=adsbexchange' 'readsb.first.enabled=1' \
		'readsb.second=feeder' 'readsb.second.preset=adsbexchange' 'readsb.second.enabled=1' \
		"readsb.second.uuid=$override_uuid" \
		'adsbexchange-stats.main=adsbexchange-stats' 'adsbexchange-stats.main.enabled=0' \
		'adsbexchange-stats.main.feeder=first' "$@" > "$tmpdir/config"
	: > "$tmpdir/calls"
	: > "$tmpdir/uci-calls"
	: > "$tmpdir/log"
	rm -f "$tmpdir/env" "$tmpdir/uuid"
}
uci() {
	local staging=''
	if [ "$1" = -t ]; then staging=$2; shift 2; fi
	[ "$1" != -q ] || shift
	printf '%s\n' "$1" >> "$tmpdir/uci-calls"
	case $1 in
		batch)
			[ "${fail_batch:-0}" != 1 ] || return 9
			while read -r operation key; do
				[ "$operation" = show ] || return 99
				awk -v key="$key" '
					{
						separator = index($0, "=")
						name = substr($0, 1, separator - 1)
						if (name == key || index(name, key ".") == 1)
							values[name] = substr($0, separator + 1)
					}
					END { for (name in values) print name "='\''" values[name] "'\''" }
				' "$tmpdir/config"
			done
			;;
		get)
			awk -v key="$2=" 'index($0,key)==1 { value=substr($0,length(key)+1); found=1 }
				END { if (!found) exit 1; print value }' "$tmpdir/config"
			;;
		changes)
			case $2 in
				readsb) printf '%s' "${test_pending_readsb:-}" ;;
				adsbexchange-stats) printf '%s' "${test_pending:-}" ;;
				*) return 99 ;;
			esac
			;;
		set)
			[ "${fail_set:-}" != "${2%%=*}" ] || return 9
			if [ -n "$staging" ]; then
				printf '%s\n' "$2" >> "$staging/adsbexchange-stats"
			else
				printf '%s\n' "$2" >> "$tmpdir/config"
			fi
			;;
		commit)
			[ "${fail_commit:-0}" != 1 ] || return 9
			[ -z "$staging" ] || cat "$staging/adsbexchange-stats" >> "$tmpdir/config"
			echo commit >> "$tmpdir/calls"
			;;
		*) echo "unexpected UCI operation: $*" >&2; return 99 ;;
	esac
}
config_get() {
	test_value=$(uci -q get "adsbexchange-stats.$2.$3") || test_value=${4:-}
	export "$1=$test_value"
}
config_get_bool() {
	test_bool=$(uci -q get "adsbexchange-stats.$2.$3") || test_bool=${4:-0}
	case $test_bool in
		1|on|true|yes|enabled) test_bool=1 ;;
		0|off|false|no|disabled) test_bool=0 ;;
		*) test_bool=${4:-0} ;;
	esac
	export "$1=$test_bool"
}
config_load() { :; }
config_foreach() { "$1" main; }
adsbx_info() { printf 'info: %s\n' "$*" >> "$tmpdir/log"; }
adsbx_notice() { printf 'notice: %s\n' "$*" >> "$tmpdir/log"; }
adsbx_warn() { printf 'warn: %s\n' "$*" >> "$tmpdir/log"; }
adsbx_err() { printf 'error: %s\n' "$*" >> "$tmpdir/log"; }
_err() { adsbx_err "$@"; }
enable() { echo enable >> "$tmpdir/calls"; }
restart() { echo restart >> "$tmpdir/calls"; return "${restart_rc:-0}"; }
procd_open_instance() { echo open >> "$tmpdir/calls"; }
procd_set_param() { printf 'procd %s\n' "$*" >> "$tmpdir/calls"; }
procd_close_instance() { :; }
service_mock() {
	printf 'service %s\n' "$*" >> "$tmpdir/calls"
	case $1 in enabled) return "${boot_enabled_rc:-1}" ;; esac
}

assert_equal() {
	[ "$1" = "$2" ] && return 0
	printf 'expected <%s>, got <%s>\n' "$2" "$1" >&2
	return 1
}
tests=0 failures=0
run_test() {
	label=$1; shift
	tests=$((tests+1))
	if "$@"; then printf 'ok %s - %s\n' "$tests" "$label"; else
		printf 'not ok %s - %s\n' "$tests" "$label"; failures=$((failures+1))
	fi
}
test_identity() (
	selector=$1 expected_rc=$2 expected_uuid=$3; shift 3
	seed "$@"
	rc=0
	value=$(adsbx_require_uuid "$selector") || rc=$?
	assert_equal "$rc" "$expected_rc" && assert_equal "$value" "$expected_uuid"
)
test_error_output() (
	# shellcheck source=/dev/null
	. "$tmpdir/functions.sh"
	ADSBX_LOG_TAG=review-stats
	: > "$tmpdir/calls"
	logger() { printf '%s\n' "$*" >> "$tmpdir/calls"; }
	adsbx_err 'failed to start' > "$tmpdir/stdout" 2> "$tmpdir/stderr" || return 1
	[ ! -s "$tmpdir/stdout" ] || return 1
	assert_equal "$(cat "$tmpdir/stderr")" 'review-stats: failed to start' || return 1
	assert_equal "$(cat "$tmpdir/calls")" '-t review-stats -p daemon.err -- failed to start'
)
run_test 'production error logger writes both stderr and syslog without stdout' test_error_output
run_test 'new uploader package starts at release 1' grep -qx 'PKG_RELEASE:=1' "$package_dir/Makefile"
run_test 'daemon control help does not misclassify showurl' \
	grep -Fq 'service adsbexchange-stats {start|stop|restart|reload|status|enable|disable}' "$package_dir/Makefile"
run_test 'package help retains the extra showurl action' \
	grep -qx '    service adsbexchange-stats showurl' "$package_dir/Makefile"
run_test 'default-selected feeder inherits main UUID' test_identity '' 0 "$main_uuid"
run_test 'selected feeder override wins over main UUID' test_identity second 0 "$override_uuid"
run_test 'configured selection resolves its own override' test_identity '' 0 "$override_uuid" \
	'adsbexchange-stats.main.feeder=second'
run_test 'disabled feeder cannot upload' test_identity first 1 '' 'readsb.first.enabled=0'
run_test 'wrong provider cannot upload' test_identity first 1 '' 'readsb.first.preset=adsblol'
run_test 'missing feeder cannot upload' test_identity missing 1 ''
run_test 'empty selection is not guessed from multiple feeders' test_identity '' 1 '' \
	'adsbexchange-stats.main.feeder='
run_test 'malformed feeder override is rejected, not replaced by main UUID' test_identity second 2 '' \
	'readsb.second.uuid=invalid'

test_disabled_start() (
	seed
	start_instance main || return 1
	[ ! -s "$tmpdir/calls" ] && [ ! -e "$tmpdir/env" ]
)
test_enabled_start() (
	seed 'adsbexchange-stats.main.enabled=1' 'adsbexchange-stats.main.feeder=second'
	start_instance main || return 1
	assert_equal "$(cat "$tmpdir/uuid")" "$override_uuid" || return 1
	grep -qx "ADSBX_FEEDER='second'" "$tmpdir/env" && grep -q '^open$' "$tmpdir/calls"
)
test_environment_failure() (
	seed 'adsbexchange-stats.main.enabled=1'
	export ADSBX_UUID_FILE="$tmpdir/missing/uuid"
	rc=0
	start_instance main 2>/dev/null || rc=$?
	assert_equal "$rc" 1 && ! grep -q '^open$' "$tmpdir/calls" &&
		grep -q 'cannot prepare the uploader environment' "$tmpdir/log"
)
test_uuid_permissions() (
	seed 'adsbexchange-stats.main.enabled=1'
	printf '%s\n' old-identity > "$tmpdir/uuid"
	chmod 644 "$tmpdir/uuid" || return 1
	if [ "$1" = failure ]; then
		chmod() { return 9; }
		rc=0
		start_instance main || rc=$?
		assert_equal "$rc" 1 || return 1
		assert_equal "$(cat "$tmpdir/uuid")" old-identity || return 1
		! grep -q '^open$' "$tmpdir/calls"
	else
		start_instance main || return 1
		assert_equal "$(stat -c %a "$tmpdir/uuid")" 600 || return 1
		assert_equal "$(cat "$tmpdir/uuid")" "$main_uuid"
	fi
)
run_test 'pre-existing world-readable UUID file is restricted before writing' test_uuid_permissions success
run_test 'failed UUID permission change prevents writing or starting the uploader' test_uuid_permissions failure
test_start_logging() (
	level=$1 interval=$2 expected_level=$3 expected_interval=$4
	seed 'adsbexchange-stats.main.enabled=1' \
		"adsbexchange-stats.main.log_level=$level" \
		"adsbexchange-stats.main.log_summary_interval=$interval"
	start_instance main || return 1
	grep -qx "ADSBX_LOG_LEVEL='$expected_level'" "$tmpdir/env" || return 1
	grep -qx "ADSBX_SUMMARY_INTERVAL='$expected_interval'" "$tmpdir/env" || return 1
	grep -q "log_level=$expected_level summary=${expected_interval}s" "$tmpdir/log"
)
run_test 'startup notice uses effective defaults for invalid logging settings' \
	test_start_logging invalid invalid 1 300
run_test 'startup notice preserves valid logging settings' test_start_logging 3 60 3 60
run_test 'startup notice normalizes a leading-zero interval' test_start_logging 2 00060 2 60
test_activation() (
	failure=${1:-}
	seed
	original=$(cat "$tmpdir/config")
	case $failure in
		write) fail_set=adsbexchange-stats.main.enabled ;;
		commit) fail_commit=1 ;;
		pending) test_pending="adsbexchange-stats.main.log_level='3'" ;;
		readsb-pending) test_pending_readsb="readsb.second.uuid='$main_uuid'" ;;
	esac
	rc=0
	activate second || rc=$?
	if [ -n "$failure" ]; then
		[ "$rc" -ne 0 ] && assert_equal "$(cat "$tmpdir/config")" "$original" \
			&& [ ! -s "$tmpdir/calls" ]
	else
		assert_equal "$(uci -q get adsbexchange-stats.main.feeder)" second &&
			assert_equal "$(uci -q get adsbexchange-stats.main.enabled)" 1 &&
			assert_equal "$(cat "$tmpdir/calls")" "$(printf 'commit\nenable\nrestart')"
	fi
)
run_test 'disabled uploader does not create an environment or start procd' test_disabled_start
run_test 'enabled uploader uses selected feeder identity in its environment' test_enabled_start
run_test 'failed UUID-file write prevents uploader startup' test_environment_failure
run_test 'explicit activation configures and starts the selected feeder' test_activation
run_test 'activation write failure leaves settings untouched' test_activation write
run_test 'activation commit failure does not enable or start the service' test_activation commit
run_test 'activation refuses pre-existing pending stats edits' test_activation pending
run_test 'activation refuses an uncommitted feeder identity change' test_activation readsb-pending

test_clamp() {
	assert_equal "$(_clamp "$1" "$2" "$3")" "$4"
}
for level in 0 1 2 3; do run_test "log level $level is retained" test_clamp "$level" '0|1|2|3' 1 "$level"; done
run_test 'DNS cache can be explicitly enabled' test_clamp 1 '0|1' 0 1
run_test 'invalid verbosity uses the documented default' test_clamp invalid '0|1|2|3' 1 1

test_hook() (
	hook=$1 upgrade=$2 offline=$3 boot_enabled_rc=$4 expected=$5
	seed
	export PKG_UPGRADE=$upgrade IPKG_INSTROOT=$offline
	rc=0
	(
		# shellcheck source=/dev/null
		. "$tmpdir/$hook.sh"
	) >/dev/null 2>&1 || rc=$?
	assert_equal "$rc" 0 && assert_equal "$(cat "$tmpdir/calls")" "$expected"
)
run_test 'fresh install neither enables nor starts the uploader' test_hook postinst '' '' 1 ''
run_test 'offline image install does not run services' test_hook postinst '' /image 1 ''
run_test 'upgrade preserves a disabled service' test_hook postinst 1 '' 1 'service enabled'
run_test 'upgrade restarts only an already-enabled service' test_hook postinst 1 '' 0 \
	"$(printf 'service enabled\nservice restart')"
run_test 'upgrade removal does not disable the service' test_hook prerm 1 '' 0 ''
run_test 'default UCI configuration has uploads disabled' \
	grep -q "option enabled '0'" "$package_dir/files/adsbexchange-stats.config"
run_test 'package help avoids the reserved procd info action' \
	grep -q '^about()' "$package_dir/files/adsbexchange-stats.init"

test_upload_guard() (
	scenario=$1 expected_rc=$2
	seed 'adsbexchange-stats.main.enabled=1' 'adsbexchange-stats.main.feeder=second'
	# shellcheck disable=SC2034
	ADSBX_FEEDER=second UUID=$override_uuid ADSBX_HTTP_LAST=200 ADSBX_ELAPSED_LAST=12
	case $scenario in
		disabled) echo 'adsbexchange-stats.main.enabled=0' >> "$tmpdir/config" ;;
		feeder-disabled) echo 'readsb.second.enabled=0' >> "$tmpdir/config" ;;
		switched) echo 'adsbexchange-stats.main.feeder=first' >> "$tmpdir/config" ;;
		uuid-changed) echo "readsb.second.uuid=$main_uuid" >> "$tmpdir/config" ;;
		unselected) export ADSBX_FEEDER='' ;;
	esac
	curl() { echo curl >> "$tmpdir/calls"; printf 200; }
	rc=0
	adsbx_curl_upload "$tmpdir/config" || rc=$?
	assert_equal "$rc" "$expected_rc" || return 1
	if [ "$expected_rc" = 0 ]; then
		assert_equal "$(cat "$tmpdir/calls")" curl && assert_equal "$ADSBX_HTTP_LAST" 200
	else
		[ ! -s "$tmpdir/calls" ] && assert_equal "$ADSBX_HTTP_LAST" 000 &&
			assert_equal "$ADSBX_ELAPSED_LAST" 0
	fi
)
run_test 'approved matching feeder can upload' test_upload_guard matching 0
test_upload_log_level() (
	seed 'adsbexchange-stats.main.enabled=1' 'adsbexchange-stats.main.feeder=second'
	ADSBX_FEEDER=second UUID=$override_uuid ADSBX_LOG_LEVEL=$1
	curl() { printf '%s\n' "$@" > "$tmpdir/calls"; printf 200; }
	adsbx_curl_upload "$tmpdir/config" > "$tmpdir/stdout" 2> "$tmpdir/stderr" || return 1
	assert_equal "$ADSBX_LOG_LEVEL" "$2" || return 1
	[ ! -s "$tmpdir/stderr" ] || return 1
	if [ "$2" = 3 ]; then
		grep -qx -- '-v' "$tmpdir/calls" || return 1
	else
		! grep -qx -- '-v' "$tmpdir/calls" || return 1
	fi
	ADSBX_LOG_LEVEL=$1
	adsbx_record_upload 1 10 > "$tmpdir/stdout" 2> "$tmpdir/stderr" || return 1
	assert_equal "$ADSBX_LOG_LEVEL" "$2" && [ ! -s "$tmpdir/stderr" ]
)
for level in 0 1 2 3; do
	run_test "upload helpers preserve valid log level $level" test_upload_log_level "$level" "$level"
done
for level in '' invalid -1 99 0003 '3 extra'; do
	run_test "upload helpers safely normalize invalid log level [$level]" test_upload_log_level "$level" 0
done
for reason in disabled feeder-disabled switched uuid-changed unselected; do
	run_test "upload is blocked when $reason" test_upload_guard "$reason" 1
done

test_integrated_setup() (
	answer=$1
	seed
	test_installed=0
	readsb_pkg_installed() { [ "$test_installed" = 1 ]; }
	readsb_pkg_status() { echo missing; return 1; }
	opkg() {
		case $1 in
			list) echo 'adsbexchange-stats - test - uploader' ;;
			install)
				echo install >> "$tmpdir/calls"
				test_installed=1
				;;
			*) return 99 ;;
		esac
	}
	wiz_say() { :; }
	wiz_yesno() { [ "$3" = N ] || return 99; export "$1=$answer"; }
	readsb_companion_service() {
		[ "$1" = adsbexchange-stats ] && [ "$2" = activate ] || return 99
		activate "$3"
	}
	restart() { echo restart >> "$tmpdir/calls"; start_service; }
	wiz_offer_install_companions adsbexchange second || return 1
	if [ "$answer" = 0 ]; then
		[ ! -s "$tmpdir/calls" ] && [ ! -e "$tmpdir/uuid" ] &&
			assert_equal "$(uci -q get adsbexchange-stats.main.enabled)" 0
	else
		assert_equal "$(head -n 4 "$tmpdir/calls")" "$(printf 'install\ncommit\nenable\nrestart')" &&
			assert_equal "$(cat "$tmpdir/uuid")" "$override_uuid" &&
			grep -qx "ADSBX_FEEDER='second'" "$tmpdir/env"
	fi
)
run_test 'integrated decoder consent activates the real stats action with feeder UUID' test_integrated_setup 1
run_test 'integrated decoder refusal leaves the companion absent and stopped' test_integrated_setup 0
test_reload() (
	seed
	stop() { echo stop >> "$tmpdir/calls"; }
	start() { echo start >> "$tmpdir/calls"; }
	reload_service || return 1
	assert_equal "$(cat "$tmpdir/calls")" "$(printf 'stop\nstart')"
)
run_test 'reload restarts the uploader to consume changed UUID and config' test_reload
test_framework_start() (
	upgrade=$1 boot_rc=$2 permitted=$3 expected_started=$4
	seed "adsbexchange-stats.main.enabled=$permitted"
	# shellcheck disable=SC2034
	PKG_UPGRADE=$upgrade
	enabled() { return "$boot_rc"; }
	start_service || return 1
	if [ "$expected_started" = 1 ]; then
		grep -q '^open$' "$tmpdir/calls"
	else
		! grep -q '^open$' "$tmpdir/calls" && [ ! -e "$tmpdir/env" ]
	fi
)
run_test 'framework fresh-install start cannot bypass UCI upload consent' \
	test_framework_start '' 0 0 0
run_test 'framework upgrade start preserves a disabled boot service' \
	test_framework_start 1 1 1 0
run_test 'framework upgrade can start an already-enabled opted-in uploader' \
	test_framework_start 1 0 1 1

test_boolean_consistency() (
	scope=$1 value=$2 expected_rc=$3
	seed 'adsbexchange-stats.main.enabled=1' 'adsbexchange-stats.main.feeder=second'
	case $scope in
		uploader) echo "adsbexchange-stats.main.enabled=$value" >> "$tmpdir/config" ;;
		feeder) echo "readsb.second.enabled=$value" >> "$tmpdir/config" ;;
	esac
	# shellcheck disable=SC2034
	ADSBX_FEEDER=second UUID=$override_uuid
	curl() { echo curl >> "$tmpdir/calls"; printf 200; }
	rc=0
	adsbx_curl_upload "$tmpdir/config" || rc=$?
	assert_equal "$rc" "$expected_rc" || return 1
	if [ "$expected_rc" = 0 ]; then
		grep -q '^curl$' "$tmpdir/calls" || return 1
		start_service || return 1
		grep -q '^open$' "$tmpdir/calls"
	else
		! grep -q '^curl$' "$tmpdir/calls"
	fi
)
for scope in uploader feeder; do
	for value in 1 on true yes enabled; do
		run_test "$scope boolean '$value' permits an approved upload and startup" \
			test_boolean_consistency "$scope" "$value" 0
	done
	for value in 0 off false no disabled invalid ''; do
		run_test "$scope boolean '$value' blocks upload" \
			test_boolean_consistency "$scope" "$value" 1
	done
done

test_main_section_only() (
	main_permission=$1
	seed "adsbexchange-stats.main.enabled=$main_permission" \
		'adsbexchange-stats.extra=adsbexchange-stats' \
		'adsbexchange-stats.extra.enabled=1' 'adsbexchange-stats.extra.feeder=second'
	config_foreach() { "$1" main; "$1" extra; }
	rc=0
	start_service || rc=$?
	assert_equal "$rc" 0 || return 1
	if [ "$main_permission" = 1 ]; then
		assert_equal "$(grep -c '^open$' "$tmpdir/calls")" 1 &&
			assert_equal "$(cat "$tmpdir/uuid")" "$main_uuid" &&
			grep -qx "ADSBX_FEEDER='first'" "$tmpdir/env"
	else
		! grep -q '^open$' "$tmpdir/calls" && [ ! -e "$tmpdir/env" ]
	fi
)
test_invalid_main_section() (
	seed "adsbexchange-stats.main=$1"
	rc=0
	start_service || rc=$?
	assert_equal "$rc" 1 || return 1
	[ ! -s "$tmpdir/calls" ] && grep -q "main.*section" "$tmpdir/log"
)
run_test 'enabled extra sections cannot replace the main uploader' test_main_section_only 1
run_test 'enabled extra sections cannot bypass disabled main consent' test_main_section_only 0
run_test 'missing main section is an explicit configuration error' test_invalid_main_section ''
run_test 'wrong main section type is an explicit configuration error' test_invalid_main_section wrong-type

test_env_quoting() (
	seed
	export ADSBX_LOG_TAG="$1"
	export ADSBX_RUNTIME_DIR="$tmpdir/runtime path's"
	write_env main "$main_uuid" first || return 1
	sed '\|^\. /usr/lib/adsbexchange-stats/json-status-helpers.sh$|d' "$tmpdir/env" > "$tmpdir/env-check.sh"
	bash -n "$tmpdir/env-check.sh" || return 1
	bash -c '
		. "$1" || exit 1
		[ "$ADSBX_LOG_TAG" = "$2" ] &&
		[ "$TEMP_DIR" = "$3" ] &&
		[ "$UUID_FILE" = "$4" ] &&
		[ "$ADSBX_FEEDER" = first ] &&
		[ "${JSON_PATHS[0]}" = /var/run/readsb ]
	' test "$tmpdir/env-check.sh" "$ADSBX_LOG_TAG" "$ADSBX_RUNTIME_DIR" "$ADSBX_UUID_FILE"
)
run_test 'generated environment preserves plain scalar values' test_env_quoting adsbexchange-stats
run_test 'generated environment preserves spaces as data' test_env_quoting 'receiver stats'
run_test 'generated environment preserves literal quotes and backslashes' test_env_quoting "receiver's \"stats\"\\path"
run_test 'generated environment preserves a single quote alone' test_env_quoting "'"
run_test 'generated environment preserves a trailing quote' test_env_quoting "receiver'"
# shellcheck disable=SC2016
run_test 'generated environment does not reinterpret shell metacharacters' test_env_quoting 'receiver; # $HOME'
run_test 'generated environment preserves embedded newlines' test_env_quoting "$(printf 'receiver\nstats')"

test_runtime_cleanup() (
	seed
	scenario=$1
	runtime="$tmpdir/runtime-state"
	mkdir "$runtime" || return 1
	trap 'command rm -f "$runtime/env" "$runtime/uuid" "$runtime/tmp.json" "$runtime/new.json" "$runtime/upload.gz" "$runtime/curl.stderr" "$runtime/unexpected"; [ ! -d "$runtime" ] || command rmdir "$runtime"' 0
	export ADSBX_RUNTIME_DIR="$runtime" ADSBX_ENV_FILE="$runtime/env" ADSBX_UUID_FILE="$runtime/uuid"
	for filename in env uuid tmp.json new.json upload.gz curl.stderr; do
		printf 'owned test data\n' > "$runtime/$filename"
	done
	[ "$scenario" != unexpected ] || printf 'keep\n' > "$runtime/unexpected"
	stop_service || return 1
	[ -f "$runtime/upload.gz" ] || return 1
	if [ "$scenario" = failure ]; then
		rm() { return 1; }
		rc=0
		service_stopped || rc=$?
		[ "$rc" -ne 0 ] && grep -q '^error:' "$tmpdir/log"
	else
		service_stopped || return 1
		for filename in env uuid tmp.json new.json upload.gz curl.stderr; do
			[ ! -e "$runtime/$filename" ] || return 1
		done
		if [ "$scenario" = unexpected ]; then
			[ -f "$runtime/unexpected" ] && grep -q '^warn:' "$tmpdir/log"
		else
			[ ! -d "$runtime" ] && service_stopped
		fi
	fi
)
run_test 'service-stopped clears all known runtime files after stopping' test_runtime_cleanup normal
run_test 'runtime cleanup preserves unknown files and warns' test_runtime_cleanup unexpected
run_test 'runtime cleanup reports removal failure' test_runtime_cleanup failure

test_metrics() (
	seed
	aircraft_input=$1 bytes_input=$2 expected_aircraft=$3 expected_bytes=$4 expect_warning=$5
	# shellcheck disable=SC2034
	ADSBX_LOG_LEVEL=2 ADSBX_SUMMARY_INTERVAL=300 ADSBX_HTTP_LAST=200 ADSBX_ELAPSED_LAST=0
	ADSBX_CYCLE=0 ADSBX_OK=0 ADSBX_FAIL=0
	ADSBX_AC_TOTAL=0 ADSBX_BYTES_TOTAL=0 ADSBX_LAST_SUMMARY=100
	date() { echo 100; }
	adsbx_record_upload "$aircraft_input" "$bytes_input" || return 1
	assert_equal "$ADSBX_CYCLE" 1 && assert_equal "$ADSBX_OK" 1 &&
		assert_equal "$ADSBX_FAIL" 0 && assert_equal "$ADSBX_LAST_SUMMARY" 100 || return 1
	assert_equal "$ADSBX_AC_TOTAL" "$expected_aircraft" &&
		assert_equal "$ADSBX_BYTES_TOTAL" "$expected_bytes" || return 1
	if [ "$expect_warning" = 1 ]; then
		grep -q '^warn:' "$tmpdir/log"
	else
		! grep -q '^warn:' "$tmpdir/log"
	fi
)
run_test 'normal upload metrics remain unchanged' test_metrics 42 1024 42 1024 0
run_test 'leading-zero metrics are decimal, not octal' test_metrics 0008 0009 8 9 0
run_test 'zero metrics remain valid' test_metrics 0 0000 0 0 0
run_test 'maximum supported metric is accepted' test_metrics 2147483647 2147483647 2147483647 2147483647 0
run_test 'values beyond the supported bound use zero and warn' test_metrics 2147483648 2147483648 0 0 1
run_test 'empty upload metrics become zero with a warning' test_metrics '' '' 0 0 1
run_test 'null/failed JSON or stat output becomes zero with a warning' test_metrics null '' 0 0 1
run_test 'nonnumeric aircraft count does not break metrics accounting' test_metrics invalid 100 0 100 1
run_test 'invalid byte count does not break metrics accounting' test_metrics 12 '.' 12 0 1
run_test 'negative metrics are rejected rather than subtracted' test_metrics -1 -2 0 0 1
run_test 'fractional metrics are rejected rather than evaluated' test_metrics 1.5 4.2 0 0 1
run_test 'oversized metrics cannot overflow shell arithmetic on input' \
	test_metrics 999999999999999999999 999999999999999999999 0 0 1

test_patch_attribution() {
	grep -q '^From: Dr Bill Mcilhargey <contributor@mcilhargey.com>$' "$package_dir/patches/010-openwrt-paths.patch" &&
		grep -q '^Signed-off-by: Dr Bill Mcilhargey <contributor@mcilhargey.com>$' "$package_dir/patches/010-openwrt-paths.patch" &&
		! grep -q '^Co-authored-by: Copilot' "$package_dir/patches/010-openwrt-paths.patch"
}
run_test 'embedded patch metadata records the human maintainer and sign-off' test_patch_attribution

test_upload_snapshot() (
	seed 'adsbexchange-stats.main.enabled=1' 'adsbexchange-stats.main.feeder=second'
	# shellcheck disable=SC2034
	ADSBX_FEEDER=second UUID=$override_uuid
	fail_batch=$1 expected_rc=$2
	# shellcheck disable=SC2329
	curl() { echo curl >> "$tmpdir/calls"; printf 200; }
	rc=0
	adsbx_curl_upload "$tmpdir/config" || rc=$?
	assert_equal "$rc" "$expected_rc" || return 1
	assert_equal "$(cat "$tmpdir/uci-calls")" batch || return 1
	if [ "$expected_rc" = 0 ]; then
		assert_equal "$(cat "$tmpdir/calls")" curl
	else
		[ ! -s "$tmpdir/calls" ] && grep -q '^error:' "$tmpdir/log"
	fi
)
run_test 'each upload reads one UCI snapshot rather than multiple queries' test_upload_snapshot 0 0
run_test 'failed UCI snapshot blocks uploads with an explicit error' test_upload_snapshot 1 1

test_cleanup_status() (
	wanted=$1 failed_command=$2
	rc=0
	(
		# shellcheck disable=SC2329
		rm() { [ "$failed_command" != rm ]; }
		# shellcheck disable=SC2329
		rmdir() { [ "$failed_command" != rmdir ]; }
		trap cleanup 0
		exit "$wanted"
	) > "$tmpdir/cleanup-output" 2>&1 || rc=$?
	assert_equal "$rc" "$wanted" || return 1
	grep -q '^cleanup:' "$tmpdir/cleanup-output"
)
for wanted in 0 7; do
	for failed_command in rm rmdir; do
		run_test "test cleanup preserves exit $wanted when $failed_command fails" \
			test_cleanup_status "$wanted" "$failed_command"
	done
done

printf '%s tests, %s failures\n' "$tests" "$failures"
[ "$failures" -eq 0 ]

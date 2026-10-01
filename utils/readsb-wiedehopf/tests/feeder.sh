#!/bin/sh
# SPDX-License-Identifier: GPL-2.0-only

package_dir=$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd) || exit 1
tmpdir=$(mktemp -d) || exit 1
trap 'rm -f "$tmpdir/functions.sh" "$tmpdir/calls" "$tmpdir/bin/grep"; rmdir "$tmpdir/bin" "$tmpdir"' 0
trap 'exit 1' HUP INT TERM
mkdir "$tmpdir/bin" || exit 1
ln -s "$(command -v grep)" "$tmpdir/bin/grep" || exit 1

# Load the production functions without sourcing OpenWrt libraries or dispatching.
sed -n '
	/^_no_match() {/,/^}/p
	/^_probe_tcp() {/,/^}/p
	/^cmd_probe() {/,/^}/p
	/^cmd_health() {/,/^}/p
' "$package_dir/files/readsb-feeder" > "$tmpdir/functions.sh" || exit 1
# shellcheck source=/dev/null
. "$tmpdir/functions.sh"

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

test_tcp_probe() (
	BASH=$1
	timeout_available=$2
	connect_rc=$3
	nc_mode=$4
	nc_rc=$5
	expected_rc=$6
	expected_calls=$7

	# Only mocked tools and grep are visible; no network connection is made.
	PATH="$tmpdir/bin"
	export PATH
	timeout() {
		printf 'timeout\n' >> "$tmpdir/calls"
		# shellcheck disable=SC2016
		[ "$1" = 3 ] && [ "$2" = "$BASH" ] && [ "$3" = -c ] &&
			[ "$4" = 'exec 9<>"/dev/tcp/$1/$2"' ] && [ "$5" = _ ] &&
			[ "$6" = 127.0.0.1 ] && [ "$7" = 30004 ] || return 125
		return "$connect_rc"
	}
	nc() {
		if [ "$1" = --help ]; then
			case $nc_mode in
				bounded) echo 'nc -w SEC HOST PORT' ;;
				stock) echo 'nc [-l] [-p PORT] [IPADDR PORT]' ;;
			esac
			return 0
		fi
		printf 'nc\n' >> "$tmpdir/calls"
		[ "$1" = -w ] && [ "$2" = 3 ] &&
			[ "$3" = 127.0.0.1 ] && [ "$4" = 30004 ] || return 125
		return "$nc_rc"
	}
	[ "$timeout_available" = 1 ] || unset -f timeout
	[ "$nc_mode" != absent ] || unset -f nc

	: > "$tmpdir/calls"
	rc=0
	_probe_tcp 127.0.0.1 30004 || rc=$?
	assert_equal "$rc" "$expected_rc" || return 1
	assert_equal "$(grep . "$tmpdir/calls")" "$expected_calls"
)

run_test 'Bash uses its own interpreter with timeout' \
	test_tcp_probe /test/bash 1 0 absent 0 0 timeout
run_test 'Bash refused connection is a failed probe, not an unavailable tool' \
	test_tcp_probe /test/bash 1 1 absent 0 1 timeout
run_test 'Bash timed-out connection is a failed probe' \
	test_tcp_probe /test/bash 1 124 absent 0 1 timeout
run_test 'Bash without timeout does not attempt an unbounded connection' \
	test_tcp_probe /test/bash 0 0 absent 0 2 ''
run_test 'Bash without timeout falls back to bounded nc' \
	test_tcp_probe /test/bash 0 0 bounded 0 0 nc
run_test 'Non-Bash shell uses bounded nc, not /dev/tcp' \
	test_tcp_probe '' 1 0 bounded 0 0 nc
run_test 'Bounded nc reports a failed connection' \
	test_tcp_probe '' 1 0 bounded 1 1 nc
run_test 'Stock nc without -w is indeterminate' \
	test_tcp_probe '' 1 0 stock 0 2 ''
run_test 'Missing probe tools are indeterminate' \
	test_tcp_probe '' 0 0 absent 0 2 ''

test_feeder_command() (
	caller=$1
	socket_rc=$2
	probe_rc=$3
	expected_rc=$4
	expected_state=$5
	expected_probes=$6
	error_count=${7:-0}
	loaded=${8:-1}
	pid=${9:-123}
	mixed=${10:-0}
	want=${11:-}
	enabled=${12:-1}

	uci() { echo '00000000-0000-4000-8000-000000000000'; }
	config_load() { :; }
	config_foreach() {
		"$1" test
		[ "$mixed" = 1 ] && "$1" second
		return 0
	}
	# shellcheck disable=SC2034
	readsb_feeder_resolve() {
		readsb_feeder_host="$1.example"
		readsb_feeder_port=30004
		readsb_feeder_enabled=$enabled
	}
	readsb_pid() { [ "$pid" = down ] || echo "$pid"; }
	readsb_connector_live() { [ "$loaded" = 1 ]; }
	readsb_connector_active() {
		[ "$1" = second.example ] && return 1
		return "$socket_rc"
	}
	readsb_log_count_errors_for() { echo "$error_count"; }
	readsb_log_last_error_for() { echo 'connection lost'; }
	_warn() { :; }
	_log() { :; }
	_probe_tcp() {
		echo probe >> "$tmpdir/calls"
		return "$probe_rc"
	}

	: > "$tmpdir/calls"
	rc=0
	output=$("$caller" "$want" 2>&1) || rc=$?
	assert_equal "$rc" "$expected_rc" || {
		printf '%s\n' "$output" >&2
		return 1
	}
	if [ "$expected_state" != NONE ]; then
		printf '%s\n' "$output" | grep -Eq "^test +$expected_state( |$)" || {
			printf 'expected state %s:\n%s\n' "$expected_state" "$output" >&2
			return 1
		}
	fi
	assert_equal "$(grep -c probe "$tmpdir/calls")" "$expected_probes" || return 1
	if [ "$socket_rc" = 2 ] && [ "$probe_rc" = 1 ] && [ "$loaded" = 1 ]; then
		printf '%s\n' "$output" | grep -q 'attribution indeterminate' || return 1
	fi
	if [ "$mixed" = 1 ]; then
		case $caller in
			cmd_probe) second_state=FAIL ;;
			cmd_health) second_state=UNREACHABLE ;;
		esac
		printf '%s\n' "$output" | grep -Eq "^second +$second_state( |$)" || return 1
	fi
)

# Socket rc 2 covers missing resolveip, IPv6 sockets, and DNS-rotated addresses.
while read -r socket_rc probe_rc probe_exit probe_state health_exit health_state probes; do
	run_test "--probe socket=$socket_rc probe=$probe_rc" \
		test_feeder_command cmd_probe "$socket_rc" "$probe_rc" "$probe_exit" "$probe_state" "$probes"
	run_test "--health socket=$socket_rc probe=$probe_rc" \
		test_feeder_command cmd_health "$socket_rc" "$probe_rc" "$health_exit" "$health_state" "$probes"
done <<'EOF'
0 0 0 LIVE 0 LIVE 0
0 1 0 LIVE 0 LIVE 0
0 2 0 LIVE 0 LIVE 0
1 0 0 OK 0 LIVE 1
1 1 2 FAIL 2 UNREACHABLE 1
1 2 0 SKIP 2 DEGRADED 1
2 0 0 OK 0 LIVE 1
2 1 0 SKIP 2 DEGRADED 1
2 2 0 SKIP 2 DEGRADED 1
EOF

run_test 'Active socket with recent errors remains DEGRADED' \
	test_feeder_command cmd_health 0 1 2 DEGRADED 0 1
run_test 'Successful probe with recent errors remains DEGRADED' \
	test_feeder_command cmd_health 2 0 2 DEGRADED 1 1
run_test 'Unloaded connector remains NOT-LOADED' \
	test_feeder_command cmd_health 2 0 2 NOT-LOADED 1 0 0
run_test '--probe still fails if an indeterminate feeder is followed by a confirmed failure' \
	test_feeder_command cmd_probe 2 1 2 SKIP 2 0 1 123 1
run_test '--health keeps socket ambiguity local to each feeder' \
	test_feeder_command cmd_health 2 1 2 DEGRADED 2 0 1 123 1
run_test '--probe works without a running daemon' \
	test_feeder_command cmd_probe 2 0 0 OK 1 0 1 down
run_test '--health reports a stopped daemon' \
	test_feeder_command cmd_health 1 0 2 NONE 0 0 1 down

for caller in cmd_probe cmd_health; do
	run_test "$caller reports an unknown feeder" \
		test_feeder_command "$caller" 1 0 3 NONE 0 0 1 123 0 unknown
	run_test "$caller skips disabled feeders by default" \
		test_feeder_command "$caller" 1 0 3 NONE 0 0 1 123 0 '' 0
	run_test "$caller reports explicitly selected disabled feeders" \
		test_feeder_command "$caller" 1 0 0 DISABLED 0 0 1 123 0 test 0
done

printf '%s tests, %s failures\n' "$tests" "$failures"
[ "$failures" -eq 0 ]

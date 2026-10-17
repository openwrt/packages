#!/bin/sh
# SPDX-License-Identifier: GPL-2.0-only

package_dir=$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd) || exit 1
tmpdir=$(mktemp -d) || exit 1
trap 'rm -f "$tmpdir/functions.sh" "$tmpdir/calls" "$tmpdir/state" "$tmpdir/state.new" "$tmpdir/committed" "$tmpdir/bin/grep"; rmdir "$tmpdir/bin" "$tmpdir"' 0
trap 'exit 1' HUP INT TERM
mkdir "$tmpdir/bin" || exit 1
ln -s "$(command -v grep)" "$tmpdir/bin/grep" || exit 1

# Load the production functions without sourcing OpenWrt libraries or dispatching.
# shellcheck source=/dev/null
. "$package_dir/files/readsb.functions.sh"
sed -n '
	/^_no_match() {/,/^}/p
	/^_emit_mutation() {/,/^}/p
	/^_commit() {/,/^}/p
	/^_probe_tcp() {/,/^}/p
	/^cmd_probe() {/,/^}/p
	/^cmd_health() {/,/^}/p
	/^_feeder_opt_ok() {/,/^}/p
	/^_parse_kv() {/,/^}/p
	/^_discard_new_feeder() {/,/^}/p
	/^cmd_add() {/,/^}/p
	/^cmd_set() {/,/^}/p
	/^cmd_enable_disable() {/,/^}/p
	/^cmd_wizard() {/,/^}/p
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
for status in 125 126 127; do
	run_test "timeout execution error $status is indeterminate rather than unreachable" \
		test_tcp_probe /test/bash 1 "$status" absent 0 2 timeout
done
run_test 'Bash without timeout does not attempt an unbounded connection' \
	test_tcp_probe /test/bash 0 0 absent 0 2 ''
run_test 'Bash without timeout falls back to bounded nc' \
	test_tcp_probe /test/bash 0 0 bounded 0 0 nc
run_test 'Non-Bash shell uses bounded nc, not /dev/tcp' \
	test_tcp_probe '' 1 0 bounded 0 0 nc
run_test 'Bounded nc reports a failed connection' \
	test_tcp_probe '' 1 0 bounded 1 1 nc
for status in 125 126 127; do
	run_test "netcat execution error $status is indeterminate rather than unreachable" \
		test_tcp_probe '' 1 0 bounded "$status" 2 nc
done
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
	readsb_feeder_section_exists() {
		case $1 in
			test) return 0 ;;
			second) [ "$mixed" = 1 ] ;;
			*) return 1 ;;
		esac
	}
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
run_test '--health reports an unknown named feeder before daemon-down' \
	test_feeder_command cmd_health 1 0 3 NONE 0 0 1 down 0 unknown
run_test '--health rejects a non-feeder section even while the daemon is down' \
	test_feeder_command cmd_health 1 0 3 NONE 0 0 1 down 0 main
run_test '--health still reports daemon-down for an existing named feeder' \
	test_feeder_command cmd_health 1 0 2 NONE 0 0 1 down 0 test

for caller in cmd_probe cmd_health; do
	run_test "$caller reports an unknown feeder" \
		test_feeder_command "$caller" 1 0 3 NONE 0 0 1 123 0 unknown
	run_test "$caller skips disabled feeders by default" \
		test_feeder_command "$caller" 1 0 3 NONE 0 0 1 123 0 '' 0
	run_test "$caller reports explicitly selected disabled feeders" \
		test_feeder_command "$caller" 1 0 0 DISABLED 0 0 1 123 0 test 0
done

mutation_uci() {
	[ "$1" != -q ] || shift
	printf '%s %s\n' "$1" "$2" >> "$tmpdir/calls"
	case $1 in
		get)
			awk -v key="$2=" '
				index($0, key) == 1 { value = substr($0, length(key) + 1); found = 1 }
				END { if (!found) exit 1; print value }
			' "$tmpdir/state"
			;;
		add)
			[ "$fail" != create ] || return 9
			echo 'readsb.cfgnew=feeder' >> "$tmpdir/state"
			echo cfgnew
			;;
		rename)
			sed 's/^readsb.cfgnew=/readsb.test=/' "$tmpdir/state" > "$tmpdir/state.new"
			mv "$tmpdir/state.new" "$tmpdir/state"
			;;
		set)
			case $2 in
				readsb.test=*) [ "$fail" != create ] || return 9 ;;
			esac
			[ "$2" != "$fail" ] || return 9
			[ "$fail" != cleanup ] || [ "$2" != readsb.test.enabled=0 ] || return 9
			printf '%s\n' "$2" >> "$tmpdir/state"
			;;
		delete)
			[ "$fail" != "delete:$2" ] && [ "$fail" != cleanup ] || return 9
			if [ "$2" = readsb.test ]; then
				awk '$0 !~ /^readsb[.]test[.=]/' "$tmpdir/state" > "$tmpdir/state.new"
			else
				grep -Fq "$2=" "$tmpdir/state" || return 1
				awk -v key="$2=" 'index($0, key) != 1' "$tmpdir/state" > "$tmpdir/state.new"
			fi
			mv "$tmpdir/state.new" "$tmpdir/state"
			;;
		commit)
			[ "$fail" != commit ] || return 9
			cp "$tmpdir/state" "$tmpdir/committed"
			;;
		*) return 99 ;;
	esac
}

test_add_feeder() (
	fail=$1 expected_rc=$2
	shift 2
	printf '%s\n' 'readsb.main=readsb' 'readsb.main.lat=51.5' 'readsb.other=feeder' \
		'readsb.other.enabled=0' 'readsb.main.pending=keep' > "$tmpdir/state"
	cp "$tmpdir/state" "$tmpdir/committed"
	: > "$tmpdir/calls"

	uci() { mutation_uci "$@"; }
	_notice() { :; }
	readsb_warn_companions() { echo companions >> "$tmpdir/calls"; }

	rc=0
	output=$(cmd_add test "$@" 2>&1) || rc=$?
	assert_equal "$rc" "$expected_rc" || { printf '%s\n' "$output" >&2; return 1; }
	grep -q '^readsb.main.pending=keep$' "$tmpdir/state" || return 1
	grep -q '^readsb.other.enabled=0$' "$tmpdir/state" || return 1
	if [ "$rc" -eq 0 ]; then
		assert_equal "$(uci -q get readsb.test)" feeder || return 1
		assert_equal "$(uci -q get readsb.test.preset)" "$1" || return 1
		cmp -s "$tmpdir/state" "$tmpdir/committed" || return 1
		printf '%s\n' "$output" | grep -q "feeder 'test' added" || return 1
		if [ "$1" = custom ]; then
			assert_equal "$(uci -q get readsb.test.host)" feed.example.com || return 1
			assert_equal "$(uci -q get readsb.test.enabled)" 1
		else
			assert_equal "$(uci -q get readsb.test.enabled)" 0
		fi
	else
		! printf '%s\n' "$output" | grep -q 'added' || return 1
		! grep -q '^companions$' "$tmpdir/calls" || return 1
		! grep -Eq '^readsb[.](test|cfgnew)[.=]' "$tmpdir/committed" || return 1
		if [ "$fail" = cleanup ]; then
			printf '%s\n' "$output" | grep -q 'could not discard' || return 1
		else
			! grep -Eq '^readsb[.](test|cfgnew)[.=]' "$tmpdir/state" || return 1
			cmp -s "$tmpdir/state" "$tmpdir/committed" || return 1
		fi
		if [ "$fail" != commit ]; then
			! grep -q '^commit ' "$tmpdir/calls" || return 1
		fi
		printf '%s\n' "$output" | grep -q 'readsb-feeder:'
	fi
)
run_test '--add preset commits disabled defaults' test_add_feeder '' 0 adsblol
run_test '--add custom commits every validated option' test_add_feeder '' 0 custom \
	host=feed.example.com port=30004 protocol=beast_reduce_plus_out enabled=1 silent_fail=1 \
	uuid=00000000-0000-4000-8000-000000000000
for fail in create readsb.test.preset=custom readsb.test.enabled=0 \
	readsb.test.host=feed.example.com readsb.test.port=30004 \
	readsb.test.protocol=beast_reduce_plus_out readsb.test.enabled=1 \
	readsb.test.silent_fail=1 readsb.test.uuid=00000000-0000-4000-8000-000000000000 commit cleanup; do
	run_test "--add fails safely at $fail" test_add_feeder "$fail" 2 custom \
		host=feed.example.com port=30004 protocol=beast_reduce_plus_out enabled=1 silent_fail=1 \
		uuid=00000000-0000-4000-8000-000000000000
done
run_test '--add validates all options before any mutation' test_add_feeder '' 1 custom \
	host=feed.example.com port=invalid

test_set_feeder() (
	scenario=$1 fail=$2 expected_rc=$3 expected_calls=$4
	shift 4
	printf '%s\n' 'readsb.main=readsb' 'readsb.main.pending=keep' \
		'readsb.other=feeder' 'readsb.other.enabled=0' > "$tmpdir/state"
	if [ "$scenario" != missing ]; then
		printf '%s\n' 'readsb.test=feeder' 'readsb.test.preset=adsblol' \
			'readsb.test.host=old.example' 'readsb.test.enabled=0' \
			'readsb.test.uuid=00000000-0000-4000-8000-000000000000' >> "$tmpdir/state"
		[ "$scenario" = missing-port ] || echo 'readsb.test.port=30004' >> "$tmpdir/state"
	fi
	original_state=$(cat "$tmpdir/state")
	cp "$tmpdir/state" "$tmpdir/committed"
	: > "$tmpdir/calls"
	uci() { mutation_uci "$@"; }
	_notice() { :; }

	rc=0
	output=$(cmd_set test "$@" 2>&1) || rc=$?
	assert_equal "$rc" "$expected_rc" || { printf '%s\n' "$output" >&2; return 1; }
	assert_equal "$(grep -E '^(set|delete|commit) ' "$tmpdir/calls")" "$expected_calls" || return 1
	grep -q '^readsb.main.pending=keep$' "$tmpdir/state" || return 1
	grep -q '^readsb.other.enabled=0$' "$tmpdir/state" || return 1
	if [ "$rc" -eq 0 ]; then
		cmp -s "$tmpdir/state" "$tmpdir/committed" || return 1
		printf '%s\n' "$output" | grep -q "feeder 'test' updated"
	else
		assert_equal "$(cat "$tmpdir/committed")" "$original_state" || return 1
		! printf '%s\n' "$output" | grep -q 'updated:' || return 1
		[ "$rc" != 2 ] || printf '%s\n' "$output" | grep -q 'uci .* failed' || return 1
		if [ "$rc" = 1 ]; then
			assert_equal "$(cat "$tmpdir/state")" "$original_state" || return 1
		fi
		if [ "$scenario" != missing ]; then
			assert_equal "$(uci -q get readsb.test)" feeder || return 1
		fi
		printf '%s\n' "$output" | grep -q 'readsb-feeder:'
	fi
)
run_test '--set commits a successful option update' test_set_feeder existing '' 0 \
	"$(printf 'set readsb.test.enabled=1\ncommit readsb')" enabled=1
run_test '--set commits removal of a populated UUID override' test_set_feeder existing '' 0 \
	"$(printf 'delete readsb.test.uuid\ncommit readsb')" uuid=
run_test '--set commits mixed set/delete options in order' test_set_feeder existing '' 0 \
	"$(printf 'set readsb.test.host=feed.example\ndelete readsb.test.uuid\nset readsb.test.enabled=1\ncommit readsb')" \
	host=feed.example uuid= enabled=1
run_test '--set preserves valid custom-preset conversion' test_set_feeder existing '' 0 \
	"$(printf 'set readsb.test.preset=custom\nset readsb.test.port=30005\ncommit readsb')" preset=custom port=30005
run_test '--set stops on the first failed write' test_set_feeder existing readsb.test.enabled=1 2 \
	'set readsb.test.enabled=1' enabled=1 host=feed.example
run_test '--set does not commit or continue after a later write fails' test_set_feeder existing readsb.test.host=feed.example 2 \
	"$(printf 'set readsb.test.enabled=1\nset readsb.test.host=feed.example')" enabled=1 host=feed.example port=30005
run_test '--set stops on a failed UUID deletion' test_set_feeder existing delete:readsb.test.uuid 2 \
	'delete readsb.test.uuid' uuid= enabled=1
run_test '--set does not commit earlier writes after a deletion fails' test_set_feeder existing delete:readsb.test.uuid 2 \
	"$(printf 'set readsb.test.enabled=1\ndelete readsb.test.uuid')" enabled=1 uuid= port=30005
run_test '--set reports commit failure without success output' test_set_feeder existing commit 2 \
	"$(printf 'set readsb.test.enabled=1\ncommit readsb')" enabled=1
run_test '--set rejects a missing feeder before mutation' test_set_feeder missing '' 3 '' enabled=1
run_test '--set validates all arguments before mutation' test_set_feeder existing '' 1 '' enabled=1 port=bad
run_test '--set rejects an unknown option before mutation' test_set_feeder existing '' 1 '' enabled=1 unknown=value
run_test '--set rejects an incomplete custom endpoint before mutation' test_set_feeder missing-port '' 1 '' preset=custom
run_test '--set retains later overriding values' test_set_feeder existing '' 0 \
	"$(printf 'set readsb.test.enabled=1\nset readsb.test.enabled=0\ncommit readsb')" enabled=1 enabled=0

test_enable_disable() (
	want=$1 fail=$2 expected_rc=$3 expected_calls=$4 name=${5-test}
	printf '%s\n' 'readsb.main=readsb' 'readsb.main.pending=keep' \
		'readsb.test=feeder' 'readsb.test.preset=adsblol' "readsb.test.enabled=$((1-want))" > "$tmpdir/state"
	cp "$tmpdir/state" "$tmpdir/committed"
	original_state=$(cat "$tmpdir/state")
	: > "$tmpdir/calls"
	uci() { mutation_uci "$@"; }
	_notice() { :; }
	readsb_warn_companions() { echo companions >> "$tmpdir/calls"; }
	rc=0
	output=$(cmd_enable_disable "$name" "$want" 2>&1) || rc=$?
	assert_equal "$rc" "$expected_rc" || { printf '%s\n' "$output" >&2; return 1; }
	assert_equal "$(grep -E '^(set|commit|companions)' "$tmpdir/calls")" "$expected_calls" || return 1
	if [ "$rc" = 0 ]; then
		assert_equal "$(uci -q get readsb.test.enabled)" "$want" || return 1
		cmp -s "$tmpdir/state" "$tmpdir/committed" || return 1
		printf '%s\n' "$output" | grep -q "feeder 'test' enabled=$want"
	else
		assert_equal "$(cat "$tmpdir/committed")" "$original_state" || return 1
		! printf '%s\n' "$output" | grep -q "feeder 'test' enabled=" || return 1
		[ "$fail" = commit ] || assert_equal "$(cat "$tmpdir/state")" "$original_state"
	fi
)
run_test '--enable commits only after a successful write' test_enable_disable 1 '' 0 \
	"$(printf 'set readsb.test.enabled=1\ncommit readsb\ncompanions')"
run_test '--disable commits only after a successful write' test_enable_disable 0 '' 0 \
	"$(printf 'set readsb.test.enabled=0\ncommit readsb')"
for want in 0 1; do
	run_test "enabled=$want write failure does not commit unrelated changes" \
		test_enable_disable "$want" "readsb.test.enabled=$want" 2 "set readsb.test.enabled=$want"
	run_test "enabled=$want commit failure does not report success" \
		test_enable_disable "$want" commit 2 "$(printf 'set readsb.test.enabled=%s\ncommit readsb' "$want")"
done
run_test '--enable rejects a missing section before mutation' test_enable_disable 1 '' 3 '' missing
run_test '--disable rejects an empty name before mutation' test_enable_disable 0 '' 1 '' ''

test_wizard_exit() (
	abort_at=$1 expected_rc=$2 add_rc=${3:-0}
	wizard_preset=${4:-custom} feeder_enabled=${5:-1}
	companion_rc=${6:-0}
	: > "$tmpdir/calls"
	wiz_available() { [ "$abort_at" != no-tty ]; }
	wiz_say() { printf '%s\n' "$*"; }
	readsb_feeder_optional_pkgs() {
		[ "$wizard_preset" != adsbexchange ] || echo adsbexchange-stats
	}
	readsb_section_exists() { return 1; }
	wiz_choose() {
		[ "$abort_at" != "$1" ] || return 1
		export "$1=$wizard_preset"
	}
	wiz_ask_validated() {
		[ "$abort_at" != "$1" ] || return 1
		case $1 in
			name) export "$1=test" ;;
			host) export "$1=feed.example.com" ;;
			port) export "$1=30004" ;;
			proto) export "$1=beast_reduce_plus_out" ;;
			uuid) export "$1=00000000-0000-4000-8000-000000000000" ;;
			*) return 99 ;;
		esac
	}
	wiz_ask() {
		[ "$abort_at" != "$1" ] || return 1
		export "$1=$3"
	}
	wiz_yesno() {
		[ "$abort_at" != "$1" ] || return 1
		if [ "$1" = __wcf_ans ] && [ "$abort_at" = confirm-no ]; then
			export "$1=0"
		elif [ "$1" = enabled ]; then
			export "$1=$feeder_enabled"
		else
			export "$1=1"
		fi
	}
	cmd_add() {
		if [ "$wizard_preset" = custom ]; then
			assert_equal "$#" 8 || return 99
			assert_equal "$8" 'protocol=beast_reduce_plus_out' || return 99
		fi
		printf 'add %s\n' "$*" >> "$tmpdir/calls"
		return "$add_rc"
	}
	cmd_setup_companions() { printf 'setup %s\n' "$1" >> "$tmpdir/calls"; return "$companion_rc"; }
	rc=0
	output=$(cmd_wizard 2>&1) || rc=$?
	assert_equal "$rc" "$expected_rc" || { printf '%s\n' "$output" >&2; return 1; }
	if [ "$abort_at" = none ]; then
		grep -q "^add test $wizard_preset " "$tmpdir/calls" || return 1
		if [ "$wizard_preset" = adsbexchange ] && [ "$feeder_enabled" = 1 ] && [ "$add_rc" = 0 ]; then
			assert_equal "$(tail -n 1 "$tmpdir/calls")" 'setup test'
		else
			! grep -q '^setup ' "$tmpdir/calls"
		fi
	else
		[ ! -s "$tmpdir/calls" ]
	fi
)
for abort_at in preset name host port proto enabled silent want_uuid uuid __wcf_ans confirm-no; do
	run_test "wizard cancellation at $abort_at is a clean exit without adding a feeder" \
		test_wizard_exit "$abort_at" 0
done
run_test 'wizard successful confirmation still adds a feeder' test_wizard_exit none 0
run_test 'protocol validator accepts supported token syntax' wiz_v_protocol beast_reduce_plus_out
test_invalid_protocols() (
	for protocol in '' 'beast out' 'beast*' 'beast?' 'beast,out'; do
		! wiz_v_protocol "$protocol" || return 1
	done
)
run_test 'protocol validator rejects whitespace, glob characters and delimiters' test_invalid_protocols
run_test 'wizard mutation failure remains a failure' test_wizard_exit none 2 2
run_test 'wizard still rejects invocation without a terminal' test_wizard_exit no-tty 1
run_test 'ADSBx wizard offers optional stats only after a successful enabled feeder add' \
	test_wizard_exit none 0 0 adsbexchange 1
run_test 'optional companion failure does not turn a saved feeder into a failed add' \
	test_wizard_exit none 0 0 adsbexchange 1 2
run_test 'disabled ADSBx feeder does not offer uploader activation' \
	test_wizard_exit none 0 0 adsbexchange 0
run_test 'failed ADSBx feeder creation does not offer optional setup' \
	test_wizard_exit none 2 2 adsbexchange 1
run_test 'cancelled ADSBx feeder confirmation does not install or activate companions' \
	test_wizard_exit confirm-no 0 0 adsbexchange 1

printf '%s tests, %s failures\n' "$tests" "$failures"
[ "$failures" -eq 0 ]

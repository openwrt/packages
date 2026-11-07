#!/bin/sh
# SPDX-License-Identifier: GPL-2.0-only
# shellcheck shell=ash

SCRIPT_DIR="$(CDPATH='' cd -- "$(dirname "$0")" && pwd)"
INIT_SCRIPT="$SCRIPT_DIR/../files/orbi-bt-setup.init"
TEST_ROOT="${TMPDIR:-/tmp}/orbi-bt-setup-test.$$"
STATE="$TEST_ROOT/state"

tests=0
failures=0

pass() {
	printf 'PASS: %s\n' "$1"
}

fail() {
	printf 'FAIL: %s\n' "$1" >&2
	failures=$((failures + 1))
}

assert_rc() {
	local description="$1"
	local expected="$2"
	local actual="$3"

	tests=$((tests + 1))
	if [ "$expected" -eq "$actual" ]; then
		pass "$description"
	else
		fail "$description (expected $expected, got $actual)"
	fi
}

assert_file() {
	local description="$1"
	local path="$2"

	tests=$((tests + 1))
	if [ -e "$path" ]; then
		pass "$description"
	else
		fail "$description (missing $path)"
	fi
}

assert_no_file() {
	local description="$1"
	local path="$2"

	tests=$((tests + 1))
	if [ ! -e "$path" ]; then
		pass "$description"
	else
		fail "$description (unexpected $path)"
	fi
}

assert_contains() {
	local description="$1"
	local path="$2"
	local text="$3"

	tests=$((tests + 1))
	if grep -F -q "$text" "$path"; then
		pass "$description"
	else
		fail "$description (missing '$text')"
	fi
}

assert_not_contains() {
	local description="$1"
	local path="$2"
	local text="$3"

	tests=$((tests + 1))
	if ! grep -F -q "$text" "$path"; then
		pass "$description"
	else
		fail "$description (unexpected '$text')"
	fi
}

assert_count() {
	local description="$1"
	local expected="$2"
	local path="$3"
	local text="$4"
	local actual

	actual="$(grep -F -c "$text" "$path" 2>/dev/null || true)"
	assert_rc "$description" "$expected" "$actual"
}

assert_logged_pids_gone() {
	local description="$1"
	local action pid _
	local alive=0

	while IFS=: read -r action pid _; do
		[ "$action" = "start" ] || continue
		[ ! -e "/proc/$pid" ] || alive=1
	done < "$STATE/hciattach.log"

	tests=$((tests + 1))
	if [ "$alive" -eq 0 ]; then
		pass "$description"
	else
		fail "$description (a temporary PID is still present)"
	fi
}

assert_lock_available() {
	local description="$1"

	tests=$((tests + 1))
	if "$FLOCK" -n "$SEQUENCE_LOCK" true; then
		pass "$description"
	else
		fail "$description (sequence lock is still held)"
	fi
}

cleanup() {
	if [ -f "$STATE/hciattach.log" ]; then
		while IFS=: read -r action pid _; do
			[ "$action" = "start" ] || continue
			kill -TERM "$pid" 2>/dev/null || true
		done < "$STATE/hciattach.log"
	fi
	rm -rf "$TEST_ROOT"
}
trap cleanup EXIT HUP INT TERM

mkdir -p "$STATE"

cat > "$TEST_ROOT/helper" <<'EOF'
#!/bin/sh
echo "$1" >> "$ORBI_TEST_STATE/helper.log"
case "$1" in
tty)
	[ ! -e "$ORBI_TEST_PENDING" ] || exit 1
	echo /dev/ttyMSM9
	;;
hci)
	[ -e "$ORBI_TEST_STATE/hci" ] || exit 1
	echo hci7
	;;
prepare)
	: > "$ORBI_TEST_PENDING"
	[ "$(cat "$ORBI_TEST_STATE/mode")" != "prepare-fail" ] || exit 1
	;;
verify)
	[ "$(cat "$ORBI_TEST_STATE/mode")" != "verify-fail" ] || exit 1
	rm -f "$ORBI_TEST_PENDING"
	[ "$(cat "$ORBI_TEST_STATE/mode")" != "post-verify-sticky" ] ||
		: > "$ORBI_TEST_STATE/keep-hci"
	;;
*)
	exit 1
	;;
esac
EOF

cat > "$TEST_ROOT/hciattach" <<'EOF'
#!/bin/sh
echo "start:$$:$*" >> "$ORBI_TEST_STATE/hciattach.log"
mode="$(cat "$ORBI_TEST_STATE/mode")"
[ "$mode" = "exit-early" ] && exit 2
[ "$mode" = "no-hci" ] || : > "$ORBI_TEST_STATE/hci"
stopping() {
	echo "stop:$$" >> "$ORBI_TEST_STATE/hciattach.log"
	[ -z "$sleep_pid" ] || kill -TERM "$sleep_pid" 2>/dev/null
	[ -z "$sleep_pid" ] || wait "$sleep_pid" 2>/dev/null
	if [ "$mode" != "sticky-hci" ] &&
			[ ! -e "$ORBI_TEST_STATE/keep-hci" ]; then
		rm -f "$ORBI_TEST_STATE/hci"
	fi
	exit 0
}
trap stopping HUP INT TERM
while :; do
	sleep 1 &
	sleep_pid=$!
	wait "$sleep_pid"
done
EOF

cat > "$TEST_ROOT/bluetoothd" <<'EOF'
#!/bin/sh
[ "$1" = "running" ] && [ -e "$ORBI_TEST_STATE/bluetoothd" ]
EOF

chmod +x "$TEST_ROOT/helper" "$TEST_ROOT/hciattach" "$TEST_ROOT/bluetoothd"

export ORBI_TEST_STATE="$STATE"
export ORBI_TEST_PENDING="$STATE/ana-freq.pending"

PROG="$TEST_ROOT/helper"
HCIATTACH="$TEST_ROOT/hciattach"
BLUETOOTHD_INIT="$TEST_ROOT/bluetoothd"
FLOCK="$(command -v flock)"
HCI_EXTENSION="$STATE/hciextn"
PENDING_MARKER="$ORBI_TEST_PENDING"
REBOOT_MARKER="$STATE/reboot-required"
SEQUENCE_LOCK="$STATE/sequence.lock"
INSTALL_SKIP="$STATE/install.skip"
INITTAB="$STATE/inittab"
ATTACH_POLLS=20
DETACH_POLLS=5
KILL_POLLS=5
POLL_DELAY=0.05

TEST_SERVICE_RUNNING=0
TEST_PIDOF_RUNNING=0
mkdir -p "$TEST_ROOT/init.d"
ln -s init.d/orbi-bt-setup "$TEST_ROOT/S61orbi-bt-setup"
initscript="$TEST_ROOT/S61orbi-bt-setup"

procd_running() {
	echo "$*" >> "$STATE/procd-running.log"
	[ "$TEST_SERVICE_RUNNING" -eq 1 ]
}

pidof() {
	[ "$TEST_PIDOF_RUNNING" -eq 1 ]
}

procd_open_instance() {
	echo open >> "$STATE/procd.log"
}

procd_open_service() {
	echo "open:$*" >> "$STATE/rc-procd.log"
}

procd_close_service() {
	if "$FLOCK" -n "$SEQUENCE_LOCK" true; then
		echo lock-missing >> "$STATE/rc-procd.log"
	else
		echo lock-held >> "$STATE/rc-procd.log"
	fi
	echo "close:$*" >> "$STATE/rc-procd.log"
	[ "$(cat "$STATE/mode")" != "service-close-fail" ]
}

procd_lock() {
	:
}

procd_kill() {
	echo "kill:$*" >> "$STATE/procd-kill.log"
}

procd_set_param() {
	echo "$*" >> "$STATE/procd.log"
}

procd_close_instance() {
	if "$FLOCK" -n "$SEQUENCE_LOCK" true; then
		echo lock-missing >> "$STATE/procd.log"
	else
		echo lock-held >> "$STATE/procd.log"
	fi
	echo close >> "$STATE/procd.log"
	[ "$(cat "$STATE/mode")" != "procd-fail" ]
}

# shellcheck source=../files/orbi-bt-setup.init
. "$INIT_SCRIPT"

reset_case() {
	rm -f "$STATE/ana-freq.pending" "$STATE/bluetoothd" "$STATE/hci" \
		"$STATE/hciattach.log" "$STATE/helper.log" "$STATE/install.skip" \
		"$STATE/inittab" "$STATE/keep-hci" "$STATE/procd.log" \
		"$STATE/procd-kill.log" "$STATE/procd-running.log" \
		"$STATE/rc-procd.log" \
		"$STATE/reboot-required" "$STATE/sequence.lock" "$STATE/stderr" \
		"$STATE/stdout"
	echo normal > "$STATE/mode"
	echo Y > "$STATE/hciextn"
	TEST_SERVICE_RUNNING=0
	TEST_PIDOF_RUNNING=0
	temporary_pid=
	temporary_start=
	prepared=0
	sequence_lock_held=0
}

run_start() {
	start >"$STATE/stdout" 2>"$STATE/stderr"
}

reset_case
if run_start; then rc=0; else rc=$?; fi
assert_rc "normal lifecycle succeeds" 0 "$rc"
assert_count "two temporary attachments are started" 2 \
	"$STATE/hciattach.log" "start:"
assert_count "two temporary attachments are reaped" 2 \
	"$STATE/hciattach.log" "stop:"
assert_logged_pids_gone "normal lifecycle waits for both temporary PIDs"
assert_no_file "successful verify clears the pending marker" \
	"$STATE/ana-freq.pending"
assert_contains "final procd command uses foreground BCSP hciattach" \
	"$STATE/procd.log" \
	"command $TEST_ROOT/hciattach -n -t 10 -s 115200 /dev/ttyMSM9 bcsp 115200 noflow"
assert_contains "final procd instance has a bounded term timeout" \
	"$STATE/procd.log" "term_timeout 10"
assert_not_contains "final procd instance does not respawn" \
	"$STATE/procd.log" "respawn"
assert_contains "outer lock is held through final procd registration" \
	"$STATE/procd.log" "lock-held"
assert_contains "normal lifecycle enters rc_procd" \
	"$STATE/rc-procd.log" "open:"
assert_contains "boot symlink registers the canonical service name" \
	"$STATE/rc-procd.log" "open:orbi-bt-setup"
assert_not_contains "boot symlink does not leak into the service name" \
	"$STATE/rc-procd.log" "open:S61orbi-bt-setup"
assert_contains "boot symlink checks the canonical service name" \
	"$STATE/procd-running.log" "orbi-bt-setup *"
assert_not_contains "boot symlink does not check a prefixed service name" \
	"$STATE/procd-running.log" "S61orbi-bt-setup"
assert_contains "outer lock is held through procd service registration" \
	"$STATE/rc-procd.log" "lock-held"
assert_lock_available "normal lifecycle releases the outer lock"

reset_case
echo no-hci > "$STATE/mode"
if run_start; then rc=0; else rc=$?; fi
assert_rc "HCI appearance timeout fails startup" 1 "$rc"
assert_count "appearance timeout starts only one temporary attachment" 1 \
	"$STATE/hciattach.log" "start:"
assert_count "appearance timeout reaps its temporary attachment" 1 \
	"$STATE/hciattach.log" "stop:"
assert_logged_pids_gone "appearance timeout waits for its temporary PID"
assert_not_contains "appearance timeout never reaches prepare" \
	"$STATE/helper.log" "prepare"
assert_no_file "appearance timeout does not register a procd instance" \
	"$STATE/procd.log"
assert_lock_available "appearance timeout releases the outer lock"

reset_case
echo sticky-hci > "$STATE/mode"
if run_start; then rc=0; else rc=$?; fi
assert_rc "HCI disappearance timeout fails startup" 1 "$rc"
assert_file "post-prepare disappearance failure retains the marker" \
	"$STATE/ana-freq.pending"
assert_count "post-prepare disappearance failure does not retry" 1 \
	"$STATE/hciattach.log" "start:"
assert_contains "post-prepare disappearance failure requires reboot" \
	"$STATE/stderr" "reboot before retrying"
assert_lock_available "disappearance timeout releases the outer lock"

reset_case
echo prepare-fail > "$STATE/mode"
if run_start; then rc=0; else rc=$?; fi
assert_rc "prepare failure fails startup" 1 "$rc"
assert_file "prepare failure retains the marker" "$STATE/ana-freq.pending"
assert_count "prepare failure does not retry" 1 \
	"$STATE/hciattach.log" "start:"
assert_count "prepare failure reaps its temporary attachment" 1 \
	"$STATE/hciattach.log" "stop:"
assert_logged_pids_gone "prepare failure waits for its temporary PID"
assert_contains "prepare failure requires reboot" \
	"$STATE/stderr" "reboot before retrying"
assert_lock_available "prepare failure releases the outer lock"

reset_case
echo post-verify-sticky > "$STATE/mode"
if run_start; then rc=0; else rc=$?; fi
assert_rc "post-verify disappearance timeout fails startup" 1 "$rc"
assert_no_file "successful verify cleared the helper pending marker" \
	"$STATE/ana-freq.pending"
assert_file "post-verify failure records a package reboot marker" \
	"$STATE/reboot-required"
helper_calls="$(wc -l < "$STATE/helper.log")"
rm -f "$STATE/hci" "$STATE/keep-hci"
if run_start; then rc=0; else rc=$?; fi
assert_rc "reboot marker blocks a later retry" 1 "$rc"
assert_rc "reboot marker blocks before another helper command" \
	"$helper_calls" "$(wc -l < "$STATE/helper.log")"
assert_contains "reboot marker refusal explains recovery" \
	"$STATE/stderr" "reboot before retrying"
assert_lock_available "post-verify failure releases the outer lock"

reset_case
echo procd-fail > "$STATE/mode"
if run_start; then rc=0; else rc=$?; fi
assert_rc "final procd registration failure fails startup" 1 "$rc"
assert_no_file "procd failure occurs after helper verify cleared its marker" \
	"$STATE/ana-freq.pending"
assert_file "procd failure records a package reboot marker" \
	"$STATE/reboot-required"
helper_calls="$(wc -l < "$STATE/helper.log")"
if run_start; then rc=0; else rc=$?; fi
assert_rc "procd failure reboot marker blocks a later retry" 1 "$rc"
assert_rc "procd failure retry does not call the helper" \
	"$helper_calls" "$(wc -l < "$STATE/helper.log")"
assert_lock_available "procd failure releases the outer lock"

reset_case
echo service-close-fail > "$STATE/mode"
if run_start; then rc=0; else rc=$?; fi
assert_rc "procd service registration failure fails startup" 1 "$rc"
assert_no_file "service registration failure follows successful verify" \
	"$STATE/ana-freq.pending"
assert_file "service registration failure records a reboot marker" \
	"$STATE/reboot-required"
assert_contains "service registration failure reports the error" \
	"$STATE/stderr" "failed to register the final procd service"
assert_lock_available "service registration failure releases the outer lock"
helper_calls="$(wc -l < "$STATE/helper.log")"
if run_start; then rc=0; else rc=$?; fi
assert_rc "service registration reboot marker blocks a later retry" 1 "$rc"
assert_rc "service registration retry does not call the helper" \
	"$helper_calls" "$(wc -l < "$STATE/helper.log")"

reset_case
: > "$STATE/bluetoothd"
if run_start; then rc=0; else rc=$?; fi
assert_rc "running bluetoothd blocks startup" 1 "$rc"
assert_no_file "bluetoothd refusal does not launch hciattach" \
	"$STATE/hciattach.log"
assert_contains "bluetoothd refusal explains the required action" \
	"$STATE/stderr" "stop bluetoothd"
assert_no_file "bluetoothd refusal does not enter rc_procd" \
	"$STATE/rc-procd.log"
assert_lock_available "bluetoothd refusal releases the outer lock"

reset_case
TEST_SERVICE_RUNNING=1
: > "$STATE/bluetoothd"
if run_start; then rc=0; else rc=$?; fi
assert_rc "already running service remains untouched" 0 "$rc"
assert_no_file "already running start does not enter rc_procd" \
	"$STATE/rc-procd.log"
assert_no_file "already running start does not run the helper" \
	"$STATE/helper.log"
assert_no_file "already running start does not launch hciattach" \
	"$STATE/hciattach.log"

reset_case
: > "$STATE/bluetoothd"
if stop test-instance >"$STATE/stdout" 2>"$STATE/stderr"; then
	rc=0
else
	rc=$?
fi
assert_rc "running bluetoothd blocks service stop" 1 "$rc"
assert_contains "stop refusal explains the required action" \
	"$STATE/stderr" "stop bluetoothd"
assert_no_file "stop refusal does not kill the procd instance" \
	"$STATE/procd-kill.log"

reset_case
if stop test-instance >"$STATE/stdout" 2>"$STATE/stderr"; then
	rc=0
else
	rc=$?
fi
assert_rc "safe service stop succeeds" 0 "$rc"
assert_contains "safe service stop kills the requested procd instance" \
	"$STATE/procd-kill.log" "kill:orbi-bt-setup test-instance"

reset_case
: > "$STATE/bluetoothd"
if restart test-instance >"$STATE/stdout" 2>"$STATE/stderr"; then
	rc=0
else
	rc=$?
fi
assert_rc "running bluetoothd blocks service restart" 1 "$rc"
assert_no_file "restart refusal does not run the helper" "$STATE/helper.log"
assert_no_file "restart refusal does not kill the procd instance" \
	"$STATE/procd-kill.log"
assert_contains "restart refusal explains the required action" \
	"$STATE/stderr" "stop bluetoothd"

reset_case
printf 'ttyMSM9::askfirst:/usr/libexec/login.sh\n' > "$STATE/inittab"
if run_start; then rc=0; else rc=$?; fi
assert_rc "configured respawning getty blocks startup" 1 "$rc"
assert_no_file "getty refusal does not launch hciattach" \
	"$STATE/hciattach.log"
assert_contains "getty refusal requires disabling the owner" \
	"$STATE/stderr" "disable the respawning owner"
assert_lock_available "getty refusal releases the outer lock"

reset_case
exec 8>"$SEQUENCE_LOCK"
"$FLOCK" -n 8
if run_start; then rc=0; else rc=$?; fi
assert_rc "busy outer lock blocks a concurrent sequence" 1 "$rc"
assert_no_file "busy outer lock does not run the helper" "$STATE/helper.log"
assert_contains "busy outer lock reports the conflict" \
	"$STATE/stderr" "another Orbi Bluetooth setup sequence"
"$FLOCK" -u 8
exec 8>&-

reset_case
: > "$STATE/install.skip"
: > "$STATE/bluetoothd"
if run_start; then rc=0; else rc=$?; fi
assert_rc "package install defers hardware setup" 0 "$rc"
assert_no_file "package install consumes its deferral marker" \
	"$STATE/install.skip"
assert_no_file "deferred package install does not launch hciattach" \
	"$STATE/hciattach.log"
assert_no_file "deferred package install does not enter rc_procd" \
	"$STATE/rc-procd.log"
assert_lock_available "package install deferral does not retain the outer lock"

reset_case
echo N > "$STATE/hciextn"
if run_start; then rc=0; else rc=$?; fi
assert_rc "disabled HCI extensions block startup" 1 "$rc"
assert_no_file "HCI extension refusal does not launch hciattach" \
	"$STATE/hciattach.log"
assert_lock_available "HCI extension refusal releases the outer lock"

printf '%d tests, %d failures\n' "$tests" "$failures"
[ "$failures" -eq 0 ]

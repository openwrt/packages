#!/bin/bash
# SPDX-License-Identifier: GPL-2.0-only

package_dir=$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd) || exit 1
source_file=${1:-}
if [[ ! -r "$source_file" ]]; then
	printf 'usage: bash tests/uploader.sh /path/to/pinned/upstream/json-status\n' >&2
	exit 1
fi
for tool in git patch gzip stat python3 timeout; do
	command -v "$tool" >/dev/null || { printf 'required test tool is missing: %s\n' "$tool" >&2; exit 1; }
done
if [[ $(git hash-object "$source_file") != c4b260cbf5bec4965eac29b1ea207943f94dd6b4 ]]; then
	printf 'uploader test requires json-status from pinned commit 11647f27\n' >&2
	exit 1
fi
tmpdir=$(mktemp -d) || exit 1
runtime_dirs=("$tmpdir/runtime" "$tmpdir/runtime space" "$tmpdir/runtime's path" "$tmpdir/runtime denied" "$tmpdir/-runtime")
data_dirs=("$tmpdir/data" "$tmpdir/data space" "$tmpdir/data's path" "$tmpdir/data denied" "$tmpdir/-data")
cleanup() {
	status=$?
	trap - EXIT
	for directory in "${runtime_dirs[@]}"; do
		rm -f "$directory/uuid" "$directory/tmp.json" "$directory/new.json" "$directory/upload.gz"
		[[ ! -d "$directory" ]] || rmdir "$directory"
	done
	for directory in "${data_dirs[@]}"; do
		rm -f "$directory/aircraft.json"
		[[ ! -d "$directory" ]] || rmdir "$directory"
	done
	rm -f "$tmpdir/json-status" "$tmpdir/json-status.orig" "$tmpdir/patch.log" \
		"$tmpdir/reject" "$tmpdir/env" "$tmpdir/stdout" "$tmpdir/stderr" \
		"$tmpdir/result" "$tmpdir/payload.json" "$tmpdir/uploader" "$tmpdir/-env"
	rmdir "$tmpdir" || printf 'uploader test retained temporary files in %s\n' "$tmpdir" >&2
	exit "$status"
}
trap cleanup EXIT
trap 'exit 1' HUP INT TERM
cp "$source_file" "$tmpdir/json-status" || exit 1
if ! patch --batch --forward --fuzz=0 --no-backup-if-mismatch \
	--reject-file "$tmpdir/reject" -d "$tmpdir" -p1 \
	< "$package_dir/patches/010-openwrt-paths.patch" > "$tmpdir/patch.log" 2>&1; then
	cat "$tmpdir/patch.log" >&2
	exit 1
fi
bash -n "$tmpdir/json-status" || exit 1
# Never source a real host's optional legacy configuration during this test.
sed 's|/etc/default/adsbexchange-stats|"$ADSBX_TEST_LEGACY"|g' \
	"$tmpdir/json-status" > "$tmpdir/uploader" || exit 1
bash -n "$tmpdir/uploader" || exit 1
# shellcheck source=/dev/null
. <(sed -n '/^_env_assignment() {/,/^}/p' "$package_dir/files/adsbexchange-stats.init")

test_uploader() (
	runtime=$1 data=$2 expect_failure=${3:-0}
	cd "$tmpdir" || return 1
	env_file="$tmpdir/env"
	[[ $runtime != -runtime ]] || env_file=-env
	umask 022
	mkdir -m 755 -- "$runtime" "$data" || return 1
	printf '%s\n' 00000000-0000-4000-8000-000000000001 > "$runtime/uuid"
	chmod 600 -- "$runtime/uuid" || return 1
	printf '{"now":1,"aircraft":[]}\n' > "$data/aircraft.json"
	rm -f "$tmpdir/result" "$tmpdir/payload.json"
	{
		_env_assignment TEMP_DIR "$runtime"
		_env_assignment UUID_FILE "$runtime/uuid"
		_env_assignment FIXTURE_JSON_DIR "$data"
		_env_assignment FIXTURE_RESULT "$tmpdir/result"
		_env_assignment FIXTURE_PAYLOAD "$tmpdir/payload.json"
		printf '%s\n' 'JSON_PATHS=("$FIXTURE_JSON_DIR")' 'DNS_CACHE=0' 'ADSBX_LOG_LEVEL=0'
		cat <<'ENV'
sleep() { :; }
vcgencmd() { return 1; }
curl() {
	case $1 in
		-V|--version) printf 'curl 8.0.0\n' ;;
		*) printf 'unexpected network request in uploader test\n' >&2; return 99 ;;
	esac
}
jq() {
	python3 -c '
import json, sys
value = json.load(sys.stdin)
if sys.argv[1] == "-r":
    print(len(value["aircraft"]))
else:
    index = sys.argv.index("UUID")
    value.update(uuid=sys.argv[index + 1], v="", rssi=0)
    value["rssi-min"] = value["rssi-max"] = 0
    print(json.dumps(value))
' "$@"
}
adsbx_curl_upload() {
	[[ $# = 1 && $1 = "$TEMP_DIR/upload.gz" && -s $1 ]] || return 41
	gzip -dc -- "$1" > "$FIXTURE_PAYLOAD" || return 42
	ADSBX_HTTP_LAST=200
}
adsbx_record_upload() {
	[[ $1 = 0 && $2 -gt 0 ]] || exit 43
	python3 -c '
import json, sys
with open(sys.argv[1]) as source:
    value = json.load(source)
assert value["uuid"] == "00000000-0000-4000-8000-000000000001"
assert value["aircraft"] == []
' "$FIXTURE_PAYLOAD" || exit 44
	printf 'uploaded\n' > "$FIXTURE_RESULT"
	exit 0
}
ENV
		if [[ $expect_failure = 1 ]]; then
			cat <<'ENV'
chmod() {
	[[ ${3:-${2:-}} != "$TEMP_DIR" ]] || return 9
	command chmod "$@"
}
ENV
		fi
	} > "$env_file"
	rc=0
	ADSBX_TEST_LEGACY="$tmpdir/missing-defaults" ADSBX_ENV_FILE="$env_file" \
		timeout 10 bash "$tmpdir/uploader" \
		> "$tmpdir/stdout" 2> "$tmpdir/stderr" || rc=$?
	if [[ $expect_failure = 1 ]]; then
		[[ $rc = 99 && ! -e "$runtime/tmp.json" && ! -e "$runtime/new.json" &&
		   ! -e "$runtime/upload.gz" && ! -e "$tmpdir/result" ]] &&
			grep -q 'Unable to prepare private runtime directory' "$tmpdir/stderr"
		return $?
	fi
	if [[ $rc != 0 ]]; then
		printf 'actual uploader exited %s before completing its cycle\n' "$rc" >&2
		cat "$tmpdir/stderr" >&2
		return 1
	fi
	[[ $(cat "$tmpdir/result") = uploaded ]] || return 1
	! grep -Fq '00000000-0000-4000-8000-000000000001' "$tmpdir/stdout" || {
		printf 'upstream startup exposed the station UUID\n' >&2
		return 1
	}
	[[ $(stat -c %a -- "$runtime") = 700 ]] || {
		printf 'upstream runtime directory was not restricted to 0700\n' >&2
		return 1
	}
)
failures=0
for index in 0 1 2; do
	if test_uploader "${runtime_dirs[$index]}" "${data_dirs[$index]}"; then
		printf 'ok %s - actual uploader cycle with runtime/data path case %s\n' "$((index + 1))" "$index"
	else
		printf 'not ok %s - actual uploader cycle with runtime/data path case %s\n' "$((index + 1))" "$index"
		failures=$((failures + 1))
	fi
done
if test_uploader "${runtime_dirs[3]}" "${data_dirs[3]}" 1; then
	printf 'ok 4 - runtime chmod failure stops the actual uploader before scratch writes\n'
else
	printf 'not ok 4 - runtime chmod failure stops the actual uploader before scratch writes\n'
	failures=$((failures + 1))
fi
if test_uploader -runtime -data; then
	printf 'ok 5 - actual uploader treats leading-dash paths as file operands\n'
else
	printf 'not ok 5 - actual uploader treats leading-dash paths as file operands\n'
	failures=$((failures + 1))
fi
printf '5 tests, %s failures\n' "$failures"
[[ $failures = 0 ]]

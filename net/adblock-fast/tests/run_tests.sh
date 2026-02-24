#!/usr/bin/env bash
# SPDX-License-Identifier: AGPL-3.0-or-later
# Functional test runner for adblock-fast.
#
# Adapts the mwan4 mock-and-expect pattern for adblock-fast:
#   - Patches ES module imports to require() calls
#   - Redirects hardcoded paths to a temp directory
#   - Exports internal functions for test access
#   - Uses real shell commands (sed/sort/grep/awk) with mock UCI/UBus
#
# Usage: cd source.openwrt.melmac.ca/adblock-fast && bash tests/run_tests.sh [test_file...]

set -o pipefail

line='........................................'

# ── Temp directories ─────────────────────────────────────────────────

TESTDIR="/tmp/adb_test.$$"
patch_dir="/tmp/adb_test_modules.$$"
stub_dir="$TESTDIR/stubs"

mkdir -p "$TESTDIR"/{var_run/adblock-fast,var,shm,var_lib_unbound,etc,cache,tmp}
mkdir -p "$patch_dir"
mkdir -p "$stub_dir"

trap "rm -rf '$TESTDIR' '$patch_dir'" EXIT

# ── Copy test data ───────────────────────────────────────────────────

cp -r ./tests/data "$TESTDIR/data"

# ── Prepare resolved mock fixtures (replace TESTDIR placeholder) ─────

mkdir -p "$TESTDIR/mocks_resolved/uci" "$TESTDIR/mocks_resolved/ubus"
for f in ./tests/mocks/uci/*.json; do
	sed "s|TESTDIR|$TESTDIR|g" "$f" > "$TESTDIR/mocks_resolved/uci/$(basename "$f")"
done
for f in ./tests/mocks/ubus/*.json; do
	cp "$f" "$TESTDIR/mocks_resolved/ubus/$(basename "$f")"
done

# ── Create resolver stubs ───────────────────────────────────────────

cat > "$stub_dir/dnsmasq" << 'STUB'
#!/bin/sh
case "$1" in
    --version)
        echo "Dnsmasq version 2.89"
        echo "Compile time options: IPv6 GNU-getopt no-DBus no-UBus no-i18n no-IDN DHCP DHCPv6 no-Lua TFTP no-conntrack ipset nftset auth no-cryptohash no-DNSSEC loop-detect inotify dumpfile"
        ;;
    --test)
        echo "dnsmasq: syntax check OK."
        exit 0
        ;;
esac
STUB
chmod +x "$stub_dir/dnsmasq"

for cmd in smartdns unbound; do
	printf '#!/bin/sh\nexit 0\n' > "$stub_dir/$cmd"
	chmod +x "$stub_dir/$cmd"
done

# Create ipset/nft stubs
for cmd in ipset nft; do
	printf '#!/bin/sh\nexit 0\n' > "$stub_dir/$cmd"
	chmod +x "$stub_dir/$cmd"
done

# Create resolveip stub
cat > "$stub_dir/resolveip" << 'STUB'
#!/bin/sh
echo "127.0.0.1"
exit 0
STUB
chmod +x "$stub_dir/resolveip"

# ── Patch adblock-fast.uc ───────────────────────────────────────────

# The sed pipeline:
#   1. Convert ES module imports to require() calls
#   2. Redirect hardcoded paths to TESTDIR
#   3. Extend is_present() search paths with stub_dir
#   4. Export internal test helpers

sed \
	-e "s|import { readfile, writefile, popen, stat, unlink, rename, open, glob, mkdir, mkstemp, symlink, chmod, chown, realpath, lsdir, access, dirname } from 'fs';|let _fs = require('fs'), readfile = _fs.readfile, writefile = _fs.writefile, popen = _fs.popen, stat = _fs.stat, unlink = _fs.unlink, rename = _fs.rename, open = _fs.open, glob = _fs.glob, mkdir = _fs.mkdir, mkstemp = _fs.mkstemp, symlink = _fs.symlink, chmod = _fs.chmod, chown = _fs.chown, realpath = _fs.realpath, lsdir = _fs.lsdir, access = _fs.access, dirname = _fs.dirname;|" \
	-e "s|import { cursor } from 'uci';|let _uci = require('uci'), cursor = _uci.cursor;|" \
	-e "s|import { connect } from 'ubus';|let _ubus = require('ubus'), connect = _ubus.connect;|" \
	-e "s|dnsmasq_file: '/var/run/adblock-fast/adblock-fast.dnsmasq'|dnsmasq_file: '${TESTDIR}/var_run/adblock-fast/adblock-fast.dnsmasq'|" \
	-e "s|config_file: '/etc/config/adblock-fast'|config_file: '${TESTDIR}/etc/adblock-fast'|" \
	-e "s|run_file: '/dev/shm/adblock-fast'|run_file: '${TESTDIR}/shm/adblock-fast'|" \
	-e "s|status_file: '/dev/shm/adblock-fast.status.json'|status_file: '${TESTDIR}/shm/adblock-fast.status.json'|" \
	-e "s|'/var/run/' + pkg.name|'${TESTDIR}/var_run/' + pkg.name|g" \
	-e "s|'/var/lib/unbound/adb_list.' + pkg.name|'${TESTDIR}/var_run/' + pkg.name + '/adb_list.' + pkg.name|g" \
	-e "s|'/var/' + pkg.name|'${TESTDIR}/var/' + pkg.name|g" \
	-e "s|for (let dir in \['/usr/sbin', '/usr/bin', '/sbin', '/bin'\])|for (let dir in ['${stub_dir}', '/usr/sbin', '/usr/bin', '/sbin', '/bin'])|" \
	-e "s|stat('/etc/config/dhcp')|stat('${TESTDIR}/etc/dhcp')|g" \
	-e "s|stat('/etc/config/smartdns')|stat('${TESTDIR}/etc/smartdns')|g" \
	./files/lib/adblock-fast/adblock-fast.uc > "$patch_dir/adblock-fast.uc"

# Append test-helper exports to the patched module.
# We add a _test_internals object that gives tests access to module-private state.
# NOTE: cfg is accessed via get_cfg()/set_cfg() because env.load_config()
# reassigns cfg, which would make a direct reference stale.
sed -i '/^export default {/,/^};/{
	/process_file_url,/a\
\t// Test helpers (injected by test runner)\
\t_test_internals: {\
\t\tdownload_lists: download_lists,\
\t\tdetect_file_type: detect_file_type,\
\t\tdns_modes: dns_modes,\
\t\tget_cfg: function() { return cfg; },\
\t\tset_cfg: function(k, v) { cfg[k] = v; },\
\t\tstate: state,\
\t\tenv: env,\
\t\tdns_output: dns_output,\
\t\tstatus_data: status_data,\
\t\tlist_formats: list_formats,\
\t\ttmp: tmp,\
\t\tappend_urls: append_urls,\
\t\tcount_lines: count_lines,\
\t\tcount_blocked_domains: count_blocked_domains,\
\t},
}' "$patch_dir/adblock-fast.uc"

# Patch cli.uc too (for tests that exercise the CLI path)
sed \
	-e "s|import adb from 'adblock-fast';|let adb = require('adblock-fast');|" \
	./files/lib/adblock-fast/cli.uc > "$patch_dir/cli.uc"

# ── Set up environment ───────────────────────────────────────────────

export TMPDIR="$TESTDIR/tmp"
export PATH="$stub_dir:$PATH"

# ucode invocation: patched module first, then mocklib, then original source
ucode="ucode -S -L$patch_dir -L./tests/lib -L./files/lib/adblock-fast"

# ── Test framework (adapted from mwan4) ──────────────────────────────

extract_sections() {
	local file=$1
	local dir=$2
	local count=0
	local tag line outfile

	while IFS= read -r line; do
		case "$line" in
			"-- Testcase --")
				tag="test"
				count=$((count + 1))
				outfile=$(printf "%s/%03d.in" "$dir" $count)
				printf "" > "$outfile"
			;;
			"-- Environment --")
				tag="env"
				count=$((count + 1))
				outfile=$(printf "%s/%03d.env" "$dir" $count)
				printf "" > "$outfile"
			;;
			"-- Expect stdout --"|"-- Expect stderr --"|"-- Expect exitcode --")
				tag="${line#-- Expect }"
				tag="${tag% --}"
				count=$((count + 1))
				outfile=$(printf "%s/%03d.%s" "$dir" $count "$tag")
				printf "" > "$outfile"
			;;
			"-- File "*" --")
				tag="file"
				outfile="${line#-- File }"
				outfile="$(echo "${outfile% --}" | xargs)"
				outfile="$dir/files$(readlink -m "/${outfile:-file}")"
				mkdir -p "$(dirname "$outfile")"
				printf "" > "$outfile"
			;;
			"-- End --")
				tag=""
				outfile=""
			;;
			*)
				if [ -n "$tag" ]; then
					printf "%s\\n" "$line" >> "$outfile"
				fi
			;;
		esac
	done < "$file"

	# Post-process: replace TESTDIR placeholder in extracted files
	# - files/ directory (mock data)
	# - expect sections (.stdout, .stderr) so tests can reference TESTDIR paths
	# NOTE: Do NOT substitute in .in files — those use TESTDIR as a ucode global variable
	find "$dir/files" -type f 2>/dev/null | while read -r f; do
		sed -i "s|TESTDIR|$TESTDIR|g" "$f"
	done
	for f in "$dir"/*.stdout "$dir"/*.stderr; do
		[ -f "$f" ] && sed -i "s|TESTDIR|$TESTDIR|g" "$f"
	done

	return $(ls -l "$dir/"*.in 2>/dev/null | wc -l)
}

run_testcase() {
	local num=$1
	local dir=$2
	local in=$3
	local env=$4
	local out=$5
	local err=$6
	local code=$7
	local fail=0

	# Clean test state between runs
	rm -rf "$TESTDIR"/var_run/adblock-fast/*
	rm -f "$TESTDIR"/var/adblock-fast.*
	rm -f "$TESTDIR"/shm/adblock-fast*
	rm -f "$TESTDIR"/var_lib_unbound/*
	rm -f "$TESTDIR"/tmp/adblock-fast*
	mkdir -p "$TESTDIR"/var_run/adblock-fast

	$ucode \
		-D MOCK_SEARCH_PATH='["'"$dir"'/files", "'"$TESTDIR"'/mocks_resolved", "./tests/mocks"]' \
		-D TESTDIR='"'"$TESTDIR"'"' \
		${env:+-F "$env"} \
		-l mocklib \
		- <"$in" >"$dir/res.out" 2>"$dir/res.err"

	printf "%d\n" $? > "$dir/res.code"

	touch "$dir/empty"

	if ! cmp -s "$dir/res.err" "${err:-$dir/empty}"; then
		[ $fail = 0 ] && printf "!\n"
		printf "Testcase #%d: Expected stderr did not match:\n" $num
		diff -u --color=always --label="Expected stderr" --label="Resulting stderr" "${err:-$dir/empty}" "$dir/res.err"
		printf -- "---\n"
		fail=1
	fi

	if ! cmp -s "$dir/res.out" "${out:-$dir/empty}"; then
		[ $fail = 0 ] && printf "!\n"
		printf "Testcase #%d: Expected stdout did not match:\n" $num
		diff -u --color=always --label="Expected stdout" --label="Resulting stdout" "${out:-$dir/empty}" "$dir/res.out"
		printf -- "---\n"
		fail=1
	fi

	if [ -n "$code" ] && ! cmp -s "$dir/res.code" "$code"; then
		[ $fail = 0 ] && printf "!\n"
		printf "Testcase #%d: Expected exit code did not match:\n" $num
		diff -u --color=always --label="Expected code" --label="Resulting code" "$code" "$dir/res.code"
		printf -- "---\n"
		fail=1
	fi

	return $fail
}

run_test() {
	local file=$1
	local name=${file##*/}
	local res ecode eout eerr ein eenv tests
	local testcase_first=0 failed=0 count=0

	printf "%s %s " "$name" "${line:${#name}}"

	mkdir "/tmp/test.$$"

	extract_sections "$file" "/tmp/test.$$"
	tests=$?

	[ -f "/tmp/test.$$/001.in" ] && testcase_first=1

	for res in "/tmp/test.$$/"[0-9]*; do
		case "$res" in
			*.in)
				count=$((count + 1))

				if [ $testcase_first = 1 ]; then
					# Flush previous test
					if [ -n "$ein" ]; then
						run_testcase $count "/tmp/test.$$" "$ein" "$eenv" "$eout" "$eerr" "$ecode" || failed=$((failed + 1))

						eout=""
						eerr=""
						ecode=""
						eenv=""
					fi

					ein=$res
				else
					run_testcase $count "/tmp/test.$$" "$res" "$eenv" "$eout" "$eerr" "$ecode" || failed=$((failed + 1))

					eout=""
					eerr=""
					ecode=""
					eenv=""
				fi

			;;
			*.env) eenv=$res ;;
			*.stdout) eout=$res ;;
			*.stderr) eerr=$res ;;
			*.exitcode) ecode=$res ;;
		esac
	done

	# Flush last test
	if [ $testcase_first = 1 ] && [ -n "$ein" ]; then
		run_testcase $count "/tmp/test.$$" "$ein" "$eenv" "$eout" "$eerr" "$ecode" || failed=$((failed + 1))
	fi

	rm -r "/tmp/test.$$"

	if [ $failed = 0 ]; then
		printf "OK\n"
	else
		printf "%s %s FAILED (%d/%d)\n" "$name" "${line:${#name}}" $failed $tests
	fi

	return $failed
}


n_tests=0
n_fails=0

select_tests="$@"

use_test() {
	local input="$(readlink -f "$1")"
	local test

	[ -f "$input" ] || return 1
	[ -n "$select_tests" ] || return 0

	for test in $select_tests; do
		test="$(readlink -f "$test")"

		[ "$test" != "$input" ] || return 0
	done

	return 1
}

for catdir in tests/[0-9][0-9]_*; do
	[ -d "$catdir" ] || continue

	printf "\n##\n## Running %s tests\n##\n\n" "${catdir##*/[0-9][0-9]_}"

	for testfile in "$catdir/"[0-9][0-9]_*; do
		use_test "$testfile" || continue

		n_tests=$((n_tests + 1))
		run_test "$testfile" || n_fails=$((n_fails + 1))
	done
done

# ── Shell script syntax checks ──────────────────────────────────────

printf "\n##\n## Checking shell script syntax\n##\n\n"
for shellscript in \
	files/etc/init.d/* \
	files/etc/uci-defaults/*; do
	[ -f "$shellscript" ] || continue
	head -1 "$shellscript" | grep -q '^#!/bin/sh' || continue
	name="${shellscript#files/}"
	n_tests=$((n_tests + 1))
	printf "%s %s " "$name" "${line:${#name}}"
	if sh -n "$shellscript" 2>/dev/null; then
		printf "OK\n"
	else
		printf "FAIL\n"
		sh -n "$shellscript"
		n_fails=$((n_fails + 1))
	fi
done

printf "\nRan %d tests, %d okay, %d failures\n" $n_tests $((n_tests - n_fails)) $n_fails
exit $n_fails

#!/usr/bin/env bash

line='........................................'

# Create a patched copy of pbr.uc that converts ES module imports to require()
# calls, so the mock framework can intercept them through the module cache.
# The original uses:
#   import { readfile, writefile, popen, stat, unlink, open, glob, mkdir, mkstemp, access, dirname, lsdir } from 'fs';
#   import { cursor } from 'uci';
#   import { connect } from 'ubus';
# We convert to require() calls so mocklib can intercept them.
patch_dir="/tmp/pbr_test_modules.$$"
mkdir -p "$patch_dir"

# Symlink sub-modules so that import statements in the patched pbr.uc
# resolve correctly (import resolves relative to the importing file).
for mod in pkg.uc validators.uc sys.uc output.uc config.uc \
           platform.uc network.uc nft.uc; do
	ln -sf "$(pwd)/files/lib/pbr/$mod" "$patch_dir/$mod"
done

# Copy pbr.uc to the patch directory. The sed converts any remaining
# ES import statements for fs/uci/ubus to require() calls so the mock
# framework can intercept them through the module cache.
sed \
	-e "s|import { readfile, writefile, popen, stat, unlink, open, glob, mkdir, mkstemp, access, dirname, lsdir } from 'fs';|let _fs = require('fs'), readfile = _fs.readfile, writefile = _fs.writefile, popen = _fs.popen, stat = _fs.stat, unlink = _fs.unlink, open = _fs.open, glob = _fs.glob, mkdir = _fs.mkdir, mkstemp = _fs.mkstemp, access = _fs.access, dirname = _fs.dirname, lsdir = _fs.lsdir;|" \
	-e "s|import { cursor } from 'uci';|let _uci = require('uci'), cursor = _uci.cursor;|" \
	-e "s|import { connect } from 'ubus';|let _ubus = require('ubus'), connect = _ubus.connect;|" \
	./files/lib/pbr/pbr.uc > "$patch_dir/pbr.uc.tmp"

# ucode does NOT hoist function declarations — a function body that references
# another function defined later in the file gets a null binding.  Fix this by
# pre-declaring every top-level function with `let` and converting the
# `function name(` declarations to `name = function(` assignments so that all
# closures share the same (pre-declared) binding.
#
# The conversion also adds `;` after the closing `}` of each converted
# function, since `name = function() { ... }` is an expression statement
# that requires a terminating semicolon.
awk '
  # First pass (via ARGV manipulation): collect top-level function names
  NR == FNR {
    if (match($0, /^function ([a-zA-Z_][a-zA-Z0-9_]*)[\t ]*\(/, m))
      names[m[1]] = 1
    next
  }
  # Second pass: emit patched file
  # After the use-strict line, inject forward declarations
  /^'\''use strict'\''/ {
    print
    n = asorti(names, sorted)
    if (n > 0) {
      printf "let "
      for (i = 1; i <= n; i++) {
        if (i > 1) printf ", "
        printf "%s", sorted[i]
      }
      printf ";\n"
    }
    next
  }
  # Convert top-level function declarations to assignments and track braces
  /^function [a-zA-Z_][a-zA-Z0-9_]*[\t ]*\(/ {
    sub(/^function /, "")
    match($0, /^[a-zA-Z_][a-zA-Z0-9_]*/)
    name = substr($0, RSTART, RLENGTH)
    $0 = name " = function" substr($0, RSTART + RLENGTH)
    in_func_assign = 1
    depth = 0
    # Count braces on this line
    for (ci = 1; ci <= length($0); ci++) {
      ch = substr($0, ci, 1)
      if (ch == "{") depth++
      else if (ch == "}") depth--
    }
    if (depth == 0) { $0 = $0 ";"; in_func_assign = 0 }
    print
    next
  }
  in_func_assign {
    for (ci = 1; ci <= length($0); ci++) {
      ch = substr($0, ci, 1)
      if (ch == "{") depth++
      else if (ch == "}") depth--
    }
    if (depth == 0) { $0 = $0 ";"; in_func_assign = 0 }
    print
    next
  }
  { print }
' "$patch_dir/pbr.uc.tmp" "$patch_dir/pbr.uc.tmp" > "$patch_dir/pbr.uc"
rm -f "$patch_dir/pbr.uc.tmp"

trap "rm -rf '$patch_dir'" EXIT

# Search paths: patched pbr.uc first, then tests/lib (for mocklib), then original source
ucode="ucode -S -L$patch_dir -L./tests/lib -L./files/lib/pbr"

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

	$ucode \
		-D MOCK_SEARCH_PATH='["'"$dir"'/files", "./tests/mocks"]' \
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
	if [ $testcase_first = 1 ] && [ -n "$eout$eerr$ecode" ]; then
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

select_tests=("$@")

use_test() {
	local input="$(readlink -f "$1")"
	local test

	[ -f "$input" ] || return 1
	[ ${#select_tests[@]} -gt 0 ] || return 0

	for test in "${select_tests[@]}"; do
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
		
		if [ "${testfile##*.}" = "sh" ]; then
			name=${testfile##*/}
			printf "%s %s " "$name" "${line:${#name}}"
			if bash "$testfile" >/dev/null 2>&1; then
				printf "OK\n"
			else
				printf "FAILED\n"
				bash "$testfile" # run again to show output
				n_fails=$((n_fails + 1))
			fi
			continue
		fi

		run_test "$testfile" || n_fails=$((n_fails + 1))
	done
done

# ── Shell script syntax checks ──────────────────────────────────────

printf "\n##\n## Checking shell script syntax\n##\n\n"
for shellscript in \
	files/etc/init.d/* \
	files/etc/uci-defaults/* \
	files/usr/share/pbr/pbr.user.*; do
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

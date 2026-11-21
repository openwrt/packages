#!/usr/bin/env bash

line='........................................'

# Search paths: tests/lib (for mocklib), then the production modules. pbr.uc reaches
# fs, uci and ubus through require(), which mocklib intercepts in the module cache.
ucode="ucode -S -L./tests/lib -L./files/lib/pbr"

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

# ── ucode syntax compatibility ────────────────────────────
#
# check-ucode-syntax.sh only means something on the oldest ucode pbr supports, and
# refuses a newer one, while this suite runs on any ucode. So it takes its own
# interpreter, and is skipped when none is given.

printf "\n##\n## Checking syntax against the oldest supported ucode\n##\n\n"
name="check-ucode-syntax.sh"
printf "%s %s " "$name" "${line:${#name}}"
if [ -z "$PBR_UCODE_OLDEST" ]; then
	printf "SKIP (PBR_UCODE_OLDEST not set)\n"
else
	n_tests=$((n_tests + 1))
	if tests/check-ucode-syntax.sh "$PBR_UCODE_OLDEST" >/dev/null 2>&1; then
		printf "OK\n"
	else
		printf "FAILED\n"
		tests/check-ucode-syntax.sh "$PBR_UCODE_OLDEST" # run again to show output
		n_fails=$((n_fails + 1))
	fi
fi

printf "\nRan %d tests, %d okay, %d failures\n" $n_tests $((n_tests - n_fails)) $n_fails
exit $n_fails

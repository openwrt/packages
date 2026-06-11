#!/bin/bash
# Test runner for pbr shell tests (shunit2-based)
# Usage: bash tests/run_tests.sh [test_pattern]
set -uo pipefail

cd "$(dirname "$0")/.." || exit 1
TESTS_DIR="$(pwd)/tests"
PASS=0
FAIL=0
TOTAL=0
FAILED_TESTS=""

# Check shunit2 availability
if ! command -v shunit2 >/dev/null 2>&1 && [ ! -f /usr/bin/shunit2 ]; then
	echo "ERROR: shunit2 not found. Install with: apt-get install shunit2" >&2
	exit 1
fi

pattern="${1:-}"

for test_dir in "$TESTS_DIR"/[0-9]*/; do
	[ -d "$test_dir" ] || continue
	for test_script in "$test_dir"[0-9]*; do
		[ -f "$test_script" ] || continue
		test_name="${test_dir##*tests/}${test_script##*/}"
		# Filter by pattern if provided
		if [ -n "$pattern" ] && ! echo "$test_name" | grep -q "$pattern"; then
			continue
		fi
		TOTAL=$((TOTAL + 1))
		output_file="$(mktemp)"
		if bash "$test_script" >"$output_file" 2>&1; then
			printf '\033[0;32mPASS\033[0m: %s\n' "$test_name"
			PASS=$((PASS + 1))
		else
			printf '\033[0;31mFAIL\033[0m: %s\n' "$test_name"
			cat "$output_file" | sed 's/^/  /'
			FAIL=$((FAIL + 1))
			FAILED_TESTS="${FAILED_TESTS:+$FAILED_TESTS\n}  $test_name"
		fi
		rm -f "$output_file"
	done
done

echo ""
echo "Results: $PASS/$TOTAL passed, $FAIL failed"
if [ -n "$FAILED_TESTS" ]; then
	echo ""
	echo "Failed tests:"
	printf "%b\n" "$FAILED_TESTS"
fi
[ "$FAIL" -eq 0 ]

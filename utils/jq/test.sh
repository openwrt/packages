#!/bin/sh
# Exercise jq's core JSON filtering (CI's generic probe covers --version).

[ -x /usr/bin/jq ] || { echo "FAIL: /usr/bin/jq not installed"; exit 1; }

check() { # label expected actual
	[ "$2" = "$3" ] || { echo "FAIL: $1 (want '$2' got '$3')"; exit 1; }
}

check "object field"   "1"         "$(echo '{"a":1,"b":2}' | jq '.a')"
check "arithmetic"     "5"         "$(jq -n '2+3')"
check "array map"      "[2,4,6]"   "$(echo '[1,2,3]' | jq -c 'map(.*2)')"
check "reduce add"     "6"         "$(echo '[1,2,3]' | jq 'add')"
check "sorted keys"    '["a","b"]' "$(echo '{"b":2,"a":1}' | jq -c 'keys')"
check "string builtin" "HELLO"     "$(echo '"hello"' | jq -r 'ascii_upcase')"
check "select + pipe"  '[{"n":5}]' "$(echo '[{"n":1},{"n":5}]' | jq -c '[.[]|select(.n>2)]')"

echo "jq: all filters OK"

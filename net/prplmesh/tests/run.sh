#!/bin/sh
# SPDX-License-Identifier: BSD-2-Clause-Patent
set -eu

test_dir="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
source_dir="${1:?Usage: tests/run.sh /path/to/prepared/prplMesh-6.2.0}"
test_binary="$(mktemp /tmp/prplmesh-sta-test.XXXXXX)"
trap 'rm -f "$test_binary"' EXIT HUP INT TERM
"${CXX:-c++}" -std=c++14 -Wall -Wextra -Werror -fsanitize=address,undefined \
	-I"$source_dir/common/beerocks/bwl/nl80211" \
	"$test_dir/sta_wpa_utils_test.cpp" -o "$test_binary"
"$test_binary"

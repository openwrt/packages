#!/bin/sh
# SPDX-License-Identifier: BSD-2-Clause-Patent
set -eu

test_dir="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
source_dir="${1:?Usage: tests/control-socket.sh /path/to/prepared/prplMesh-6.2.0}"
test_work="$(mktemp -d /tmp/prplmesh-ctrl-build.XXXXXX)"
trap 'rm -rf "$test_work"' EXIT HUP INT TERM
hal="$source_dir/common/beerocks/bwl/nl80211"
logging="$source_dir/framework/external/easylogging"
"${CC:-cc}" -g -fsanitize=address,undefined -I"$hal/wpa_ctrl_compat" \
	-c "$hal/wpa_ctrl_compat/wpa_ctrl_compat.c" -o "$test_work/wpa_ctrl.o"
"${CXX:-c++}" -std=c++14 -g -Wall -Wextra -pthread -fsanitize=address,undefined \
	-include cstdint -DELPP_NO_DEFAULT_LOG_FILE \
	-I"$hal" -I"$hal/wpa_ctrl_compat" -I"$logging" \
	"$test_dir/wpa_ctrl_recovery_test.cpp" "$hal/wpa_ctrl_client.cpp" \
	"$logging/easylogging++.cc" "$test_work/wpa_ctrl.o" -o "$test_work/check"
"$test_work/check"

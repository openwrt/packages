#!/bin/sh
# The package ships scripts and an rpcd plugin, no binary of its own, so the
# generic --version probe cannot apply; check the installed pieces instead.

fail() { echo "FAIL: $1"; exit 1; }

[ -x /usr/libexec/librespeed-run ] || fail "librespeed-run not installed"
[ -x /usr/libexec/librespeed-aggregate ] || fail "librespeed-aggregate not installed"
[ -f /usr/share/rpcd/ucode/librespeed.uc ] || fail "rpcd plugin not installed"
[ -f /etc/config/librespeed ] || fail "UCI config not installed"
[ -x /etc/init.d/librespeed ] || fail "init script not installed"

sh -n /usr/libexec/librespeed-run || fail "librespeed-run does not parse"
/usr/libexec/librespeed-run --version | grep librespeed-common \
	|| fail "librespeed-run --version"
/usr/libexec/librespeed-aggregate --version | grep librespeed-common \
	|| fail "librespeed-aggregate --version"
sh -n /etc/init.d/librespeed || fail "init script does not parse"

# The plugin file has no side effects at load time: it defines its methods
# and returns them. Run as a file, the way rpcd loads it -- include() cannot
# be used here, it rejects the module import statements the plugin needs.
ucode /usr/share/rpcd/ucode/librespeed.uc >/dev/null \
	|| fail "rpcd plugin does not load"

# Retention must recognise epoch as jshn actually writes it -- with a space
# after the colon. The fixture comes from json_dump itself, so the check
# breaks if either side changes shape.
line=$(. /usr/share/libubox/jshn.sh; json_init; json_add_int epoch 1; json_dump) \
	|| fail "jshn not usable"
echo "$line" | awk 'match($0, /"epoch":[[:space:]]*[0-9]+/) { ok = 1 }
	{ print }
	END { exit !ok }' || fail "retention regex does not match jshn output"

echo "librespeed-common: installed files OK"

#!/bin/sh
# shellcheck disable=SC2034,SC1090,SC2154

# geoip-shell-owrt-uninstall.sh

# trimmed down uninstaller specifically for the OpenWrt geoip-shell package

# Copyright: antonk (antonk.d3v@gmail.com)
# github.com/friendly-bits

p_name="geoip-shell"
manmode=1
nolog=1

lib_dir="/usr/lib/$p_name"
_lib="$lib_dir/$p_name-lib"

geoinit="${p_name}-geoinit.sh"
geoinit_path="/usr/bin/$geoinit"

[ -f "$geoinit_path" ] && . "$geoinit_path"

for lib_f in owrt-common uninstall "$_fw_backend"; do
	[ -f "$_lib-$lib_f.sh" ] && . "$_lib-$lib_f.sh"
done

: "${conf_dir:=/etc/$p_name}"
[ -d "$conf_dir" ] && : "${conf_file:="$conf_dir/$p_name.conf"}"
[ -f "$conf_file" ] && getconfig datadir
: "${datadir:=/tmp/$p_name-data}"

rm -f "$conf_dir/setupdone" 2>/dev/null
rm_iplists_rules
rm_cron_jobs
rm_data
rm_owrt_fw_include
rm_symlink

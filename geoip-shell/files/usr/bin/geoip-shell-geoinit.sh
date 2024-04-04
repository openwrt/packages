#!/bin/sh

# Copyright: antonk (antonk.d3v@gmail.com)
# github.com/friendly-bits

export conf_dir="/etc/geoip-shell" install_dir="/usr/bin" lib_dir="/usr/lib/geoip-shell" iplist_dir="/tmp" lock_file="/tmp/geoip-shell.lock"
export conf_file="/etc/geoip-shell/geoip-shell.conf" _lib="$lib_dir/geoip-shell-lib" i_script="$install_dir/geoip-shell" _nl='
'
export LC_ALL=C POSIXLY_CORRECT=yes default_IFS="	 $_nl"


[ "$root_ok" ] || { [ "$(id -u)" = 0 ] && export root_ok="1"; }
. "${_lib}-common.sh" || exit 1
[ "$fwbe_ok" ] || [ ! "$root_ok" ] && return 0
. "$conf_dir/${p_name}.const" || exit 1
[ ! -s "$conf_file" ] && return 0
getconfig _fw_backend

export fwbe_ok=1 _fw_backend
:

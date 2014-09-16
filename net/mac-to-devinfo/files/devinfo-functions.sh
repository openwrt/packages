#!/bin/sh
# Shell script compatibility wrappers for /sbin/uci
#
# Copyright (C) 2008  Felix Fietkau <nbd@openwrt.org>
# Copyright (C) 2009  Daniel Dickinson
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA

# $UCI and $UCISTATE must be set

CONFIG_APPEND=
_C=0
LOAD_STATE=1
LIST_SEP=" "

config_load() {
    local PACKAGE="$1"
    local DATA
    local RET

    _C=0

    if [ -z "$CONFIG_APPEND" ]; then
	CONFIG_SECTIONS=
	CONFIG_NUM_SECTIONS=0
	CONFIG_SECTION=
    fi
    export NO_EXPORT=
    DATA="$($UCI -P $UCISTATE -S -n export "$PACKAGE" 2>/dev/null)"
	RET="$?"
	[ "$RET" != 0 -o -z "$DATA" ] || eval "$DATA"
	unset DATA

	${CONFIG_SECTION:+config_cb}
	return "$RET"
}

reset_cb() {
	config_cb() { return 0; }
	option_cb() { return 0; }
	list_cb() { return 0; }
}
reset_cb
config () {
	local cfgtype="$1"
	local name="$2"
	
	CONFIG_NUM_SECTIONS=$(($CONFIG_NUM_SECTIONS + 1))
	name="${name:-cfg$CONFIG_NUM_SECTIONS}"
	append CONFIG_SECTIONS "$name"
	[ -n "$NO_CALLBACK" ] || config_cb "$cfgtype" "$name"
	CONFIG_SECTION="$name"
	eval "CONFIG_${CONFIG_SECTION}_TYPE=\"$cfgtype\""
}

option () {
	local varname="$1"; shift
	local value="$*"

	eval "CONFIG_${CONFIG_SECTION}_${varname}=\"$value\""
	[ -n "$NO_CALLBACK" ] || option_cb "$varname" "$*"
}

list() {
	local varname="$1"; shift
	local value="$*"
	local len

	config_get len "$CONFIG_SECTION" "${varname}_LENGTH" 
	len="$((${len:-0} + 1))"
	config_set "$CONFIG_SECTION" "${varname}_ITEM$len" "$value"
	config_set "$CONFIG_SECTION" "${varname}_LENGTH" "$len"
	append "CONFIG_${CONFIG_SECTION}_${varname}" "$value" "$LIST_SEP"
	list_cb "$varname" "$*"
}

config_get() {
	case "$3" in
		"") eval "echo \"\${CONFIG_${1}_${2}}\"";;
		*)  eval "$1=\${CONFIG_${2}_${3}}";;
	esac
}

config_foreach() {
	local function="$1"
	[ "$#" -ge 1 ] && shift
	local type="$1"
	[ "$#" -ge 1 ] && shift
	local section cfgtype
	
	[ -z "$CONFIG_SECTIONS" ] && return 0
	for section in ${CONFIG_SECTIONS}; do
		config_get cfgtype "$section" TYPE
		[ -n "$type" -a "x$cfgtype" != "x$type" ] && continue
		$function "$section" "$@"
	done
}

package() {
	return 0
}

append() {
	local var="$1"
	local value="$2"
	local sep="${3:- }"
	
	eval "$var=\${$var:+\${$var}\${value:+\$sep}}\$value"
}


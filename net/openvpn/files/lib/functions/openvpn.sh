#!/bin/sh

get_openvpn_option() {
	local value config="$1" variable="$2" option="$3"

	value="$(sed -rne 's/^[ \t]*'"$option"'[ \t]+'"'([^']+)'"'[ \t]*$/\1/p' "$config" 2>/dev/null | tail -n1 2>/dev/null)"
	[ -n "$value" ] || value="$(sed -rne 's/^[ \t]*'"$option"'[ \t]+"(([^"\\]|\\.)+)"[ \t]*$/\1/p' "$config" 2>/dev/null | tail -n1 2>/dev/null | sed -re 's/\\(.)/\1/g' 2>/dev/null)"
	[ -n "$value" ] || value="$(sed -rne 's/^[ \t]*'"$option"'[ \t]+(([^ \t\\]|\\.)+)[ \t]*$/\1/p' "$config" 2>/dev/null | tail -n1 2>/dev/null | sed -re 's/\\(.)/\1/g' 2>/dev/null)"
	[ -n "$value" ] || return 1

	export -n "$variable=$value"
	return 0
}


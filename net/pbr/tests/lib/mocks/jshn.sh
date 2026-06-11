#!/bin/bash
# Minimal mock /usr/share/libubox/jshn.sh for pbr tests
# Implements enough of the jshn API to support the json() function and procd_open_data

# Internal state
_JSON_PREFIX=""
_JSON_DEPTH=0
declare -gA _JSON_DATA
_JSON_CUR_PATH=""
_JSON_KEYS=""
_JSON_NS=""

json_set_namespace() {
	_JSON_NS="${1:-}"
}

json_init() {
	_JSON_DATA=()
	_JSON_DEPTH=0
	_JSON_CUR_PATH=""
	_JSON_KEYS=""
}

json_add_string() {
	local key="$1" value="$2"
	_JSON_DATA["${_JSON_CUR_PATH}${key}"]="$value"
}

json_add_boolean() {
	local key="$1" value="$2"
	[ "$value" = "1" ] && value="true" || value="false"
	_JSON_DATA["${_JSON_CUR_PATH}${key}"]="$value"
}

json_add_int() {
	local key="$1" value="$2"
	_JSON_DATA["${_JSON_CUR_PATH}${key}"]="$value"
}

json_add_object() {
	local key="${1:-}"
	if [ -n "$key" ]; then
		_JSON_CUR_PATH="${_JSON_CUR_PATH}${key}."
	fi
	_JSON_DEPTH=$((_JSON_DEPTH + 1))
}

json_close_object() {
	_JSON_DEPTH=$((_JSON_DEPTH - 1))
	# Pop last path component
	if [ -n "$_JSON_CUR_PATH" ]; then
		_JSON_CUR_PATH="${_JSON_CUR_PATH%*.}"
		_JSON_CUR_PATH="${_JSON_CUR_PATH%.*}"
		[ -n "$_JSON_CUR_PATH" ] && _JSON_CUR_PATH="${_JSON_CUR_PATH}."
	fi
}

json_add_array() {
	local key="${1:-}"
	if [ -n "$key" ]; then
		_JSON_CUR_PATH="${_JSON_CUR_PATH}${key}."
		_JSON_DATA["${_JSON_CUR_PATH}_type"]="array"
	fi
	_JSON_DEPTH=$((_JSON_DEPTH + 1))
}

json_close_array() {
	json_close_object
}

json_select() {
	local key="$1"
	if [ "$key" = ".." ]; then
		# Go up one level
		if [ -n "$_JSON_CUR_PATH" ]; then
			_JSON_CUR_PATH="${_JSON_CUR_PATH%*.}"
			_JSON_CUR_PATH="${_JSON_CUR_PATH%.*}"
			[ -n "$_JSON_CUR_PATH" ] && _JSON_CUR_PATH="${_JSON_CUR_PATH}."
		fi
		return 0
	fi
	# Check if key exists
	local prefix="${_JSON_CUR_PATH}${key}."
	local found=0
	for k in "${!_JSON_DATA[@]}"; do
		if [[ "$k" == "${prefix}"* ]] || [ -n "${_JSON_DATA["${_JSON_CUR_PATH}${key}"]:-}" ]; then
			found=1
			break
		fi
	done
	if [ "$found" = "1" ]; then
		_JSON_CUR_PATH="$prefix"
		return 0
	fi
	return 1
}

json_get_var() {
	local var="$1" key="$2"
	local val="${_JSON_DATA["${_JSON_CUR_PATH}${key}"]:-}"
	eval "$var=\"\$val\""
}

json_get_keys() {
	local var="$1"
	local prefix="$_JSON_CUR_PATH"
	local keys="" k
	for k in "${!_JSON_DATA[@]}"; do
		if [[ "$k" == "${prefix}"* ]]; then
			local rest="${k#"$prefix"}"
			local first="${rest%%.*}"
			if [ -n "$first" ] && ! echo " $keys " | grep -q " $first "; then
				keys="${keys:+$keys }$first"
			fi
		fi
	done
	eval "$var=\"\$keys\""
}

json_dump() {
	# Simple JSON output - enough for testing
	echo "{}"
}

json_load() {
	json_init
}

json_load_file() {
	local file="$1"
	[ -f "$file" ] || return 1
	json_init
	return 0
}

json_cleanup() {
	json_init
}

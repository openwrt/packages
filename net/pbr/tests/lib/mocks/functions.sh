#!/bin/bash
# Mock /lib/functions.sh for pbr tests
# Implements OpenWrt UCI config shell API backed by UCI-format config files

# Config state
_CONFIG_LOADED_PKG=""
declare -gA _CONFIG_TYPES    # section -> type
declare -gA _CONFIG_OPTS     # section.option -> value
declare -gA _CONFIG_LISTS    # section.option -> "val1 val2 ..."
_CONFIG_SECTIONS=""

config_load() {
	local package="$1"
	local file="${UCI_CONFIG_DIR:-${IPKG_INSTROOT}/etc/config}/${package}"

	# Reset state
	_CONFIG_LOADED_PKG="$package"
	_CONFIG_TYPES=()
	_CONFIG_OPTS=()
	_CONFIG_LISTS=()
	_CONFIG_SECTIONS=""

	[ -f "$file" ] || return 1

	local section="" anon_counter=0
	while IFS= read -r line || [ -n "$line" ]; do
		# Strip leading whitespace
		line="${line#"${line%%[![:space:]]*}"}"
		# Skip comments and empty lines
		[[ "$line" == \#* || -z "$line" ]] && continue

		if [[ "$line" =~ ^config[[:space:]]+([^[:space:]\'\"]+)[[:space:]]*([\'\"]([^\'\"]*)[\'\"])?(.*)$ ]]; then
			local type="${BASH_REMATCH[1]}"
			section="${BASH_REMATCH[3]}"
			[ -z "$section" ] && section="cfg${anon_counter}" && anon_counter=$((anon_counter + 1))
			_CONFIG_TYPES["$section"]="$type"
			_CONFIG_SECTIONS="${_CONFIG_SECTIONS:+$_CONFIG_SECTIONS }$section"
		elif [[ "$line" =~ ^option[[:space:]]+([^[:space:]]+)[[:space:]]+[\'\"]([^\'\"]*)[\'\"] ]]; then
			local key="${BASH_REMATCH[1]}"
			local val="${BASH_REMATCH[2]}"
			_CONFIG_OPTS["${section}.${key}"]="$val"
		elif [[ "$line" =~ ^option[[:space:]]+([^[:space:]]+)[[:space:]]+([^[:space:]]+) ]]; then
			local key="${BASH_REMATCH[1]}"
			local val="${BASH_REMATCH[2]}"
			val="${val//\'/}"
			val="${val//\"/}"
			_CONFIG_OPTS["${section}.${key}"]="$val"
		elif [[ "$line" =~ ^list[[:space:]]+([^[:space:]]+)[[:space:]]+[\'\"]([^\'\"]*)[\'\"] ]]; then
			local key="${BASH_REMATCH[1]}"
			local val="${BASH_REMATCH[2]}"
			if [ -n "${_CONFIG_LISTS["${section}.${key}"]:-}" ]; then
				_CONFIG_LISTS["${section}.${key}"]="${_CONFIG_LISTS["${section}.${key}"]} $val"
			else
				_CONFIG_LISTS["${section}.${key}"]="$val"
			fi
		elif [[ "$line" =~ ^list[[:space:]]+([^[:space:]]+)[[:space:]]+([^[:space:]]+) ]]; then
			local key="${BASH_REMATCH[1]}"
			local val="${BASH_REMATCH[2]}"
			val="${val//\'/}"
			val="${val//\"/}"
			if [ -n "${_CONFIG_LISTS["${section}.${key}"]:-}" ]; then
				_CONFIG_LISTS["${section}.${key}"]="${_CONFIG_LISTS["${section}.${key}"]} $val"
			else
				_CONFIG_LISTS["${section}.${key}"]="$val"
			fi
		fi
	done < "$file"
}

config_get() {
	local var="$1" section="$2" option="$3" default="$4"
	local key="${section}.${option}"
	local val="${_CONFIG_OPTS[$key]:-${_CONFIG_LISTS[$key]:-}}"
	[ -z "$val" ] && val="$default"
	eval "$var=\"\$val\""
}

config_get_bool() {
	local var="$1" section="$2" option="$3" default="${4:-0}"
	local key="${section}.${option}"
	local val="${_CONFIG_OPTS[$key]:-$default}"
	case "$val" in
		1|yes|on|true|enabled) val=1;;
		*) val=0;;
	esac
	eval "$var=$val"
}

config_get_list() {
	config_get "$@"
}

config_foreach() {
	local callback="$1" type="$2"
	local section
	for section in $_CONFIG_SECTIONS; do
		[ "${_CONFIG_TYPES[$section]:-}" = "$type" ] && "$callback" "$section"
	done
}

config_list_foreach() {
	local section="$1" option="$2" callback="$3"
	local key="${section}.${option}"
	local val="${_CONFIG_LISTS[$key]:-}"
	local item
	for item in $val; do
		"$callback" "$item"
	done
}

uci_get() {
	local package="${1:-}" section="${2:-}" option="${3:-}" default="${4:-}"
	[ -z "$package" ] || [ -z "$section" ] && return 1
	# Auto-load if different package
	if [ "$_CONFIG_LOADED_PKG" != "$package" ]; then
		config_load "$package"
	fi
	if [ -n "$option" ]; then
		local key="${section}.${option}"
		echo "${_CONFIG_OPTS[$key]:-${_CONFIG_LISTS[$key]:-$default}}"
	else
		# Check if section exists
		[ -n "${_CONFIG_TYPES[$section]:-}" ] && echo "$section"
	fi
}

uci_add_list() {
	local package="$1" section="$2" option="$3" value="$4"
	local key="${section}.${option}"
	if [ -n "${_CONFIG_LISTS[$key]:-}" ]; then
		_CONFIG_LISTS[$key]="${_CONFIG_LISTS[$key]} $value"
	else
		_CONFIG_LISTS[$key]="$value"
	fi
}

uci_remove() {
	local package="$1" section="$2" option="${3:-}"
	if [ -n "$option" ]; then
		unset "_CONFIG_OPTS[${section}.${option}]"
		unset "_CONFIG_LISTS[${section}.${option}]"
	fi
}

uci_remove_list() {
	local package="$1" section="$2" option="$3" value="$4"
	local key="${section}.${option}"
	local old="${_CONFIG_LISTS[$key]:-}"
	local new="" item
	for item in $old; do
		[ "$item" != "$value" ] && new="${new:+$new }$item"
	done
	_CONFIG_LISTS[$key]="$new"
}

uci_commit() { :; }

uci_set() {
	local package="$1" section="$2" option="$3" value="$4"
	_CONFIG_OPTS["${section}.${option}"]="$value"
}

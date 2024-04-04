#!/bin/sh

curr_ver=0.4.7

# Copyright: antonk (antonk.d3v@gmail.com)
# github.com/friendly-bits

get_a_arr_keys() {
	___me="get_a_arr_keys"
	case $# in 2) ;; *) wrongargs "$@"; return 1; esac
	_arr_name="$1"; _out_var="$2"
	_check_vars "$_arr_name" "$_out_var" || return 1

	eval "$_out_var=\"\$(printf '%s ' \$_a_${_arr_name}___keys)\""
	:
}

set_a_arr_el() {
	___me="set_a_arr_el"
	_arr_name="$1"; ___pair="$2"
	case "$#" in 2) ;; *) wrongargs "$@"; return 1; esac
	check_pair || return 1
	___key="${___pair%%=*}"
	___new_val="${___pair#*=}"
	_check_vars "$_arr_name" "$___key" || return 1

	eval "___keys=\"\${_a_${_arr_name}___keys}\" _a_${_arr_name}_${___key}"='${___new_val}'

	case "$___keys" in
		*"$_nl$___key"|*"$_nl$___key$_nl"* ) ;;
		*) eval "_a_${_arr_name}___keys=\"$___keys$_nl$___key\""
	esac
	:
}

get_a_arr_val() {
	___me="get_a_arr_val"
	case "$#" in 3) ;; *) wrongargs "$@"; return 1; esac
	_arr_name="$1"; ___key="$2"; _out_var="$3"
	_check_vars "$_arr_name" "$___key" "$_out_var" || return 1

	eval "$_out_var=\"\$_a_${_arr_name}_${___key}\""
}

_check_vars() {
	is_alphanum "$1$2$3" -n && return 0
	for ___seq in _arr_name _out_var ___key; do
		eval "_var_val=\"\$$___seq\""
		is_alphanum "$_var_val"
	done
	return 1
}

check_pair() {
	case "$___pair" in *=* ) ;; *) echolog -err "$___me: '$___pair' is not a 'key=value' pair."; return 1; esac
}

wrongargs() {
	echolog -err "$___me: '$*': wrong number of arguments '$#'."
}

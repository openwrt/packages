#!/bin/sh

# shellcheck disable=SC2039

# shellcheck source=/dev/null
. /lib/functions/keepalived/common.sh

set_var() {
	export "$1=$2"
}

get_var() {
	eval echo "\"\${${1}}\""
}

get_var_flag() {
	local value

	value=$(get_var "$1")
	value=${value:-0}
	[ "$value" = "0" ] && return 1

	return 0
}

_service() {
	[ -z "$SERVICE_NAME" ] && return

	local rc="/etc/init.d/$SERVICE_NAME"

	[ ! -x "$rc" ] && return

	case $1 in
		start) $rc running || $rc start ;;
		stop) $rc running && $rc stop ;;
		reload)
			if $rc running; then
				$rc reload
			else
				$rc start
			fi
			;;
		restart)
			if $rc running; then
				$rc restart
			else
				$rc start
			fi
			;;
	esac
}

_start_service() {
	_service start
}

_stop_service() {
	_service stop
}

_restart_service() {
	_service restart
}

_reload_service() {
	_service reload
}

set_service_name() {
	set_var SERVICE_NAME "$1"
}

add_sync_file() {
	append SYNC_FILES_LIST "$1"
}

is_sync_file() {
	list_contains SYNC_FILES_LIST "$1"
}

set_update_target() {
	set_var UPDATE_TARGET "${1:-1}"
}

get_update_target() {
	get_var UPDATE_TARGET
}

unset_update_target() {
	set_var UPDATE_TARGET
}

is_update_target() {
	get_var_flag UPDATE_TARGET
}

set_master_cb() {
	set_var MASTER_CB "$1"
}

get_master_cb() {
	get_var MASTER_CB
}

set_backup_cb() {
	set_var BACKUP_CB "$1"
}

get_backup_cb() {
	get_var BACKUP_CB
}

set_fault_cb() {
	set_var FAULT_CB "$1"
}

get_fault_cb() {
	get_var FAULT_CB
}

set_sync_cb() {
	set_var SYNC_CB "$1"
}

get_sync_cb() {
	get_var SYNC_CB
}

set_reload_if_master() {
	set_var NOTIFY_MASTER_RELOAD 1
}

master_and_reload() {
	get_var_flag NOTIFY_MASTER_RELOAD
}

set_restart_if_master() {
	set_var NOTIFY_MASTER_RESTART 1
}

master_and_restart() {
	get_var_flag NOTIFY_MASTER_RESTART
}

set_reload_if_backup() {
	set_var NOTIFY_BACKUP_RELOAD 1
}

backup_and_reload() {
	get_var_flag NOTIFY_BACKUP_RELOAD
}

set_stop_if_backup() {
	set_var NOTIFY_BACKUP_STOP 1
}

backup_and_stop() {
	get_var_flag NOTIFY_BACKUP_STOP 1
}

set_reload_if_sync() {
	set_var NOTIFY_SYNC_RELOAD "${1:-1}"
}

get_reload_if_sync() {
	get_var NOTIFY_SYNC_RELOAD
}

sync_and_reload() {
	get_var_flag NOTIFY_SYNC_RELOAD
}

set_restart_if_sync() {
	set_var NOTIFY_SYNC_RESTART 1
}

sync_and_restart() {
	get_var_flag NOTIFY_SYNC_RESTART
}

_notify_master() {
	if master_and_reload; then
		log_debug "reload service $SERVICE_NAME"
		_reload_service
	elif master_and_restart; then
		log_debug "restart service $SERVICE_NAME"
		_restart_service
	fi
}

_notify_backup() {
	if backup_and_stop; then
		log_debug "stop service $SERVICE_NAME"
		_stop_service
	elif backup_and_reload; then
		log_debug "restart service $SERVICE_NAME"
		_restart_service
	fi
}

_notify_fault() {
	return 0
}

_notify_sync() {
	[ -z "$RSYNC_SOURCE" ] && return
	[ -z "$RSYNC_TARGET" ] && return

	if ! is_update_target; then
		log_notice "skip $RSYNC_TARGET. Update target not set. To set use \"set_update_target 1\""
		return
	fi

	is_sync_file "$RSYNC_TARGET" || return

	if ! cp -a "$RSYNC_SOURCE" "$RSYNC_TARGET"; then
		log_err "can not copy $RSYNC_SOURCE => $RSYNC_TARGET"
		return
	fi

	log_debug "updated $RSYNC_SOURCE to $RSYNC_TARGET"

	if sync_and_reload; then
		log_debug "reload service $SERVICE_NAME"
		_reload_service
	elif sync_and_restart; then
		log_debug "restart service $SERVICE_NAME"
		_restart_service
	fi
}

call_cb() {
	[ $# -eq 0 ] && return
	if __function__ "$1"; then
		log_debug "calling function \"$1\""
		"$1"
	else
		log_err "function \"$1\" not defined"
	fi
}

keepalived_hotplug() {
	[ -z "$(get_master_cb)" ] && set_master_cb _notify_master
	[ -z "$(get_backup_cb)" ] && set_backup_cb _notify_backup
	[ -z "$(get_fault_cb)" ] && set_fault_cb _notify_fault
	[ -z "$(get_sync_cb)" ] && set_sync_cb _notify_sync

	[ -z "$(get_update_target)" ] && set_update_target "$@"
	[ -z "$(get_reload_if_sync)" ] && set_reload_if_sync "$@"

	case $ACTION in
		NOTIFY_MASTER) call_cb "$(get_master_cb)" ;;
		NOTIFY_BACKUP) call_cb "$(get_backup_cb)" ;;
		NOTIFY_FAULT) call_cb "$(get_fault_cb)" ;;
		NOTIFY_SYNC) call_cb "$(get_sync_cb)" ;;
	esac
}

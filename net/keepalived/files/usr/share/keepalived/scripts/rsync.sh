#!/bin/sh

# shellcheck disable=SC2039

# shellcheck source=/dev/null
. /lib/functions.sh
# shellcheck source=/dev/null
. /lib/functions/keepalived/common.sh

RSYNC_USER=$(get_rsync_user)
RSYNC_HOME=$(get_rsync_user_home)

utc_timestamp() {
	date -u +%s
}

update_last_sync_time() {
	uci_revert_state keepalived "$1" last_sync_time
	uci_set_state keepalived "$1" last_sync_time "$(utc_timestamp)"
}

update_last_sync_status() {
	local cfg="$1"
	shift
	local status="$*"

	uci_revert_state keepalived "$cfg" last_sync_status
	uci_set_state keepalived "$cfg" last_sync_status "$status"
}

ha_sync_send() {
	local cfg=$1
	local address ssh_key ssh_port sync_list sync_dir sync_file count
	local ssh_options ssh_remote dirs_list files_list
	local changelog="/tmp/changelog"

	config_get address "$cfg" address
	[ -z "$address" ] && return 0

	config_get ssh_port "$cfg" ssh_port 22
	config_get sync_dir "$cfg" sync_dir "$RSYNC_HOME"
	[ -z "$sync_dir" ] && return 0
	config_get ssh_key "$cfg" ssh_key "$sync_dir"/.ssh/id_rsa
	config_get sync_list "$cfg" sync_list

	for sync_file in $sync_list $(sysupgrade -l); do
		[ -f "$sync_file" ] && {
			dir="${sync_file%/*}"
			list_contains files_list "${sync_file}" || append files_list "${sync_file}"
		}
		[ -d "$sync_file" ] && dir="${sync_file}"
		list_contains dirs_list "${sync_dir}${dir}" || append dirs_list "${sync_dir}${dir}"
	done

	ssh_options="-y -y -i $ssh_key -p $ssh_port"
	ssh_remote="$RSYNC_USER@$address"

	# shellcheck disable=SC2086
	timeout 10 ssh $ssh_options $ssh_remote mkdir -m 755 -p "$dirs_list /tmp" || {
		log_err "can not connect to $address. check key or connection"
		update_last_sync_time "$cfg"
		update_last_sync_status "$cfg" "SSH Connection Failed"
		return 0
	}

	# shellcheck disable=SC2086
	if rsync --out-format='%n' --dry-run -a --relative ${files_list} -e "ssh $ssh_options" --rsync-path="sudo rsync" "$ssh_remote":"$sync_dir" > "$changelog"; then
		count=$(wc -l "$changelog")
		if [ "${count%% *}" = "0" ]; then
			log_debug "all files are up to date"
			update_last_sync_time "$cfg"
			update_last_sync_status "$cfg" "Up to Date"
			return 0
		fi
	else
		log_err "rsync dry run failed for $address"
		update_last_sync_time "$cfg"
		update_last_sync_status "$cfg" "Rsync Detection Failed"
		return 0
	fi

	# shellcheck disable=SC2086
	rsync -a --relative ${files_list} ${changelog} -e "ssh $ssh_options" --rsync-path="sudo rsync" "$ssh_remote":"$sync_dir" || {
		log_err "rsync transfer failed for $address"
		update_last_sync_time "$cfg"
		update_last_sync_status "$cfg" "Rsync Transfer Failed"
	}

	log_info "keepalived sync is compeleted for $address"
	update_last_sync_time "$cfg"
	update_last_sync_status "$cfg" "Successful"
}

ha_sync_receive() {
	local cfg=$1
	local ssh_pubkey
	local name auth_file home_dir

	config_get name "$cfg" name
	config_get sync_dir "$cfg" sync_dir "$RSYNC_HOME"
	[ -z "$sync_dir" ] && return 0
	config_get ssh_pubkey "$cfg" ssh_pubkey
	[ -z "$ssh_pubkey" ] && return 0

	home_dir=$sync_dir
	auth_file="$home_dir/.ssh/authorized_keys"

	if ! grep -q "^$ssh_pubkey$" "$auth_file" 2> /dev/null; then
		log_notice "public key not found. Updating"
		echo "$ssh_pubkey" > "$auth_file"
		chown "$RSYNC_USER":"$RSYNC_USER" "$auth_file"
	fi

	/etc/init.d/keepalived-inotify enabled || /etc/init.d/keepalived-inotify enable
	/etc/init.d/keepalived-inotify running "$name" || /etc/init.d/keepalived-inotify start "$name"
}

ha_sync_each_peer() {
	local cfg="$1"
	local c_name="$2"
	local name sync sync_mode

	config_get name "$cfg" name
	[ "$name" != "$c_name" ] && return 0

	config_get sync "$cfg" sync 0
	[ "$sync" = "0" ] && return 0

	config_get sync_mode "$cfg" sync_mode
	[ -z "$sync_mode" ] && return 0

	case "$sync_mode" in
		send) ha_sync_send "$cfg" ;;
		receive) ha_sync_receive "$cfg" ;;
	esac
}

ha_sync_peers() {
	config_foreach ha_sync_each_peer peer "$1"
}

ha_sync() {
	config_list_foreach "$1" unicast_peer ha_sync_peers
}

main() {
	local lockfile="/var/lock/keepalived-rsync.lock"

	if ! lock -n "$lockfile" > /dev/null 2>&1; then
		log_info "another process is already running"
		return 1
	fi

	config_load keepalived
	config_foreach ha_sync vrrp_instance

	lock -u "$lockfile"

	return 0
}

main "$@"

#!/bin/sh

curr_ver=0.4.7

# Copyright: antonk (antonk.d3v@gmail.com)
# github.com/friendly-bits

p_name="geoip-shell"
. "/usr/bin/${p_name}-geoinit.sh" || exit 1

san_args "$@"
newifs "$delim"
set -- $_args; oldifs

usage() {
cat <<EOF

Usage: $me [action] [-l <"list_ids">] [-o <true|false>] [-d] [-V] [-h]

Serves as a proxy to call the -fetch, -apply and -backup scripts with arguments required for each action.

Actions:
  add|remove  : Add or remove ip lists to/from geoip firewall rules.
  update      : Fetch ip lists and reactivate them via the *apply script.
  restore     : Restore previously downloaded lists (skip fetching).

Options:
  -l $list_ids_usage
  -o <true|false>  : No backup: don't create backup of ip lists and firewall rules after the action.

  -a               : daemon mode (will retry actions \$max_attempts times with growing time intervals)
  -d               : Debug
  -V               : Version
  -h               : This help

EOF
}

daemon_mode=

tolower action_run "$1"
case "$action_run" in
	add|remove|update|restore) shift ;;
	*) action="$action_run"; unknownact
esac

while getopts ":l:aodVh" opt; do
	case $opt in
		l) lists_arg=$OPTARG ;;
		a) export daemon_mode=1 ;;
		o) nobackup_arg=$OPTARG ;;
		d) ;;
		V) echo "$curr_ver"; exit 0 ;;
		h) usage; exit 0 ;;
		*) unknownopt
	esac
done
shift $((OPTIND-1))

extra_args "$@"

is_root_ok
. "$_lib-$_fw_backend.sh" || die




daemon_prep_next() {
	echolog "Retrying in $secs seconds"
	sleep $secs
	add2list ok_lists "$fetched_lists"
	san_str lists_fetch "$failed_lists $missing_lists"
}

for entry in iplists nobackup geosource geomode max_attempts reboot_sleep; do
	getconfig "$entry"
done
export iplists geomode

nobackup="${nobackup_arg:-$nobackup}"

apply_lists="$lists_arg"
[ ! "$apply_lists" ] && case "$action_run" in update|restore) apply_lists="$iplists"; esac

trimsp apply_lists
fast_el_cnt "$apply_lists" " " lists_cnt

failed_lists_cnt=0

[ "$_fw_backend" = ipt ] && raw_mode="-r"

check_deps "$i_script-fetch.sh" "$i_script-apply.sh" "$i_script-backup.sh" || die

[ ! -f "$conf_file" ] && die "config file '$conf_file' doesn't exist! Re-install $p_name."

[ ! "$iplist_dir" ] && die "iplist file path can not be empty!"

[ ! "$geomode" ] && die "\$geomode variable should not be empty! Something is wrong!"

mk_lock
trap 'set +f; rm -f \"$iplist_dir/\"*.iplist 2>/dev/null; eval "$trap_args_unlock"' INT TERM HUP QUIT

[ ! "$manmode" ] && echolog "Starting action '$action_run'."

[ "$daemon_mode" ] && {
	uptime="$(cat /proc/uptime)"; uptime="${uptime%%.*}"
	sl_time=$((reboot_sleep-uptime))
	[ $sl_time -gt 0 ] && {
		echolog "Sleeping for ${sl_time}s..."
		sleep $sl_time
	}
}

case "$action_run" in
	add) action_apply=add; [ ! "$apply_lists" ] && die "no list id's were specified!" ;;
	update) action_apply=add; check_lists_coherence || force="-f" ;;
	remove) action_apply=remove; rm_lists="$apply_lists" ;;
	restore)
		check_lists_coherence -n 2>/dev/null && { echolog "Geoip firewall rules and sets are Ok. Exiting."; die 0; }
		if [ "$nobackup" = true ]; then
			echolog "$p_name was configured with 'nobackup' option, changing action to 'update'."
			action_run=update action_apply=add force="-f"
		else
			call_script -l "$i_script-backup.sh" restore; rv_cs=$?
			getconfig apply_lists iplists
			if [ "$rv_cs" = 0 ]; then
				nobackup=true
			else
				echolog -err "Restore from backup failed. Changing action to 'update'."
				action_run=update action_apply=add force="-f"
			fi
		fi
esac

unset echolists ok_lists missing_lists lists_fetch fetched_lists

[ ! "$daemon_mode" ] && max_attempts=1
case "$action_run" in add|update) lists_fetch="$apply_lists" ;; *) max_attempts=1; esac

attempt=0 secs=5
while true; do
	attempt=$((attempt+1))
	secs=$((secs+5))
	[ "$daemon_mode" ] && [ $attempt -gt $max_attempts ] && die "Giving up."

	if [ "$action_apply" = add ] && [ "$lists_fetch" ]; then
		setstatus "$status_file" "failed_lists=$lists_fetch" "fetched_lists=" || die

		call_script "$i_script-fetch.sh" -l "$lists_fetch" -p "$iplist_dir" -s "$status_file" -u "$geosource" "$force" "$raw_mode"

		getstatus "$status_file" || die "$FAIL read the status file '$status_file'"

		[ "$failed_lists" ] && {
			echolog -err "$FAIL fetch and validate lists '$failed_lists'."
			[ "$action_run" = add ] && {
				set +f; rm "$iplist_dir/"*.iplist 2>/dev/null; set -f
				die 254 "Aborting the action 'add'."
			}
			[ "$daemon_mode" ] && { daemon_prep_next; continue; }
		}

		fast_el_cnt "$failed_lists" " " failed_lists_cnt
		[ "$failed_lists_cnt" -ge "$lists_cnt" ] && {
			[ "$daemon_mode" ] && { daemon_prep_next; continue; } ||
				die 254 "All fetch attempts failed."
		}
	fi

	lists_fetch=
	san_str ok_lists "$fetched_lists $ok_lists"
	san_str apply_lists "$ok_lists $rm_lists"
	apply_rv=0
	case "$action_run" in update|add|remove)
		[ ! "$apply_lists" ] && { echolog "Firewall reconfiguration isn't required."; die 0; }

		call_script "$i_script-apply.sh" "$action_apply" -l "$apply_lists"; apply_rv=$?
		set +f; rm "$iplist_dir/"*.iplist 2>/dev/null; set -f

		case "$apply_rv" in
			0) ;;
			254) [ "$in_install" ] && die
				echolog -err "$p_name-apply.sh exited with code '254'. $FAIL execute action '$action_apply'." ;;
			*) 
		esac
		echolists=" for ip lists '$ok_lists$rm_lists'"
	esac

	if check_lists_coherence; then
		[ "$failed_lists" ] && [ "$daemon_mode" ] && { daemon_prep_next; continue; }
		[ "$action_run" = update ] && [ ! "$failed_lists" ] &&
			{ setstatus "$status_file" "last_update=$(date +%h-%d-%Y' '%H:%M:%S)" || die; }
		echolog "Successfully executed action '$action_run'$echolists."; echo; break
	else
		[ "$daemon_mode" ] && { daemon_prep_next; continue; }
		echolog -warn "actual $geomode firewall config differs from the config file!"
		for opt in unexpected missing; do
			eval "[ \"\$${opt}_lists\" ] && printf '%s\n' \"$opt $geomode ip lists in the firewall: '\$${opt}_lists'\"" >&2
		done
		die
	fi
done

if [ "$apply_rv" = 0 ] && [ "$nobackup" = false ]; then
	call_script -l "$i_script-backup.sh" create-backup
else
	
	:
fi

case "$failed_lists_cnt" in
	0) rv=0 ;;
	*) rv=254
esac

die "$rv"

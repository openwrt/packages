#!/bin/sh
# shellcheck disable=SC3043

# Copyright (c) 2016, prpl Foundation
# Copyright  ANNO DOMINI  2024  Jan Chren (rindeal)  <dev.rindeal(a)gmail.com>
#
# Permission to use, copy, modify, and/or distribute this software for any purpose with or without
# fee is hereby granted, provided that the above copyright notice and this permission notice appear
# in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE
# INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE
# FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM
# LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION,
# ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
#
# Author: Nils Koenig <openwrt@newk.it>

# shellcheck disable=SC3040
set -o pipefail

SCRIPT="$0"
LOCKFILE="/tmp/wifi_schedule.lock"
LOGFILE="/tmp/log/wifi_schedule.log"
LOGGING=0 #default is off
PACKAGE="wifi_schedule"
GLOBAL="${PACKAGE}.@global[0]"


# Converts the result of arithmetic expansion to a normal command return code
# Usage: if _arith_bool $(( 3*4 > 12 && foo <= bar )) ...
_arith_bool() { [ "$1" -ne 0 ] ;}

# Usage: if _uci_bool $(_uci_get_value "foo.bar") ...
_uci_bool() { [ "$1" -eq 1 ] ;}

# Usage: _join_by_char , foo bar baz
# Prints: `foo.bar,baz`
_join_by_char()
{
    local IFS
    IFS="$1"
    shift
    printf "%s" "$*"
}

_log()
{
    _uci_bool "${LOGGING}" || return
    echo "$(date)" "$@" >> "${LOGFILE}"
}

_exit()
{
    lock -u "${LOCKFILE}"
    exit "$1"
}

_uci_get_value_raw() { uci get "$1" 2> /dev/null ;}

_uci_get_value()
{
    _uci_get_value_raw "$1"
    local rc=$?
    if [ ${rc} -ne 0 ]; then
        _log "Could not determine UCI value '$1'"
    fi
    return ${rc}
}

_cfg_global_is_enabled() { _uci_bool "$(_uci_get_value "${GLOBAL}.enabled")" ;}

_cfg_global_is_unload_modules_enabled()
{
    local unload_modules
    unload_modules="$(_uci_get_value_raw "${GLOBAL}.unload_modules")" || return 1
    _uci_bool "${unload_modules}"
}

# Prints: `entry1_name$'\n'entry2_name$'\n'...`
_cfg_list_entries()
{
    uci show "${PACKAGE}" | awk -F= '$2 == "entry" { n = split($1, a, "."); print a[n] }'
}

_cfg_entry_is_enabled() { _uci_bool "$(_uci_get_value "${PACKAGE}.${entry}.enabled")" ;}

_cfg_entry_is_now_within_timewindow()
{
    local entry="$1"
    local starttime stoptime daysofweek
    local nowts startts stopts
    starttime=$( _uci_get_value "${PACKAGE}.${entry}.starttime" ) || return 1
    stoptime=$(  _uci_get_value "${PACKAGE}.${entry}.stoptime"  ) || return 1
    daysofweek=$(_uci_get_value "${PACKAGE}.${entry}.daysofweek") || return 1

    # check if day of week matches today
    echo "$daysofweek" | grep -q "$(date +%A)" || return 1

    nowts=$(  date -u +%s -d "$(date "+%H:%M")")
    startts=$(date -u +%s -d "$starttime")
    stopts=$( date -u +%s -d "$stoptime")
    # add a day if stopts goes past midnight
    stopts=$(( stopts < startts ? stopts + 86400 : stopts ))

    _arith_bool $(( nowts >= startts && nowts < stopts ))
}

_cfg_can_wifi_run_now()
{
    local entry
    for entry in $(_cfg_list_entries)
    do
        test -n "${entry}" || continue
        _cfg_entry_is_enabled "${entry}" || continue
        _cfg_entry_is_now_within_timewindow "$entry" && return 0
    done
    return 1
}

_cron_restart() { service cron restart > /dev/null ;}

_crontab_append_line() { (crontab -l ; printf "%s\n" "$(_join_by_char ' ' "$@")") | crontab - ;}

# Usage: _crontab_rm_script_entries_by_arg          # this removes all script entries
# Usage: _crontab_rm_script_entries_by_arg recheck  # this removes just entries with recheck argument
_crontab_rm_script_entries_by_arg()
{
    # this loop will create regexp that looks like this:
    #
    #     ^\b${SCRIPT}\b\s+\b${@}\b
    #
    local regex="(:?^|[[:space:]])${SCRIPT}"
    local arg
    for arg in "$@"
    do
        regex="${regex}[[:space:]]{1,}${arg}"
    done
    regex="${regex}(:?$|[[:space:]])"

    crontab -l | awk -v cmd_field_n=6 -v regex="${regex}" '
        {
            is_blank_or_comment = $0 ~ /^[[:space:]]*(:?#.*)?$/
            is_env_var = $0 ~ /^[[:space:]]*[a-zA-Z_]{1,}[a-zA-Z0-9_]{0,}[[:space:]]*=.*$/
            # find index of cmdline start
            match($0, "[[:space:]]*([^[:space:]]+[[:space:]]+){" cmd_field_n - 1 "}")
            cmdline = substr($0, RLENGTH + 1)
            if ( is_blank_or_comment || is_env_var || cmdline !~ regex )
            {
                print
                next
            }
        }' | crontab -
}

_crontab_add_from_cfg_entry()
{
    local entry="$1"
    local starttime stoptime daysofweek forcewifidown
    starttime=$(    _uci_get_value "${PACKAGE}.${entry}.starttime" ) || return 1
    stoptime=$(     _uci_get_value "${PACKAGE}.${entry}.stoptime"  ) || return 1
    daysofweek=$(   _uci_get_value "${PACKAGE}.${entry}.daysofweek") || return 1
    forcewifidown=$(_uci_get_value "${PACKAGE}.${entry}.forcewifidown")

    # parse `HH:MM` to `Xhh` and `Xmm` variables
    local starthh stophh startmm stopmm
    starthh=$(echo "$starttime" | cut -c 1-2) startmm=$(echo "$starttime" | cut -c 4-5)
    stophh=$( echo "$stoptime"  | cut -c 1-2) stopmm=$( echo "$stoptime"  | cut -c 4-5)

    local fdow
    # shellcheck disable=SC2046,SC2086
    fdow=$(_join_by_char "," $(printf "%.3s\n" $daysofweek))

    if [ "$starttime" != "$stoptime" ]
    then
        _crontab_append_line "$startmm $starthh * * ${fdow} ${SCRIPT} start ${entry}"
    fi

    local stopmode="stop"
    if _uci_bool "$forcewifidown" ; then
        stopmode="forcestop"
    fi

    _crontab_append_line "$stopmm $stophh * * ${fdow} ${SCRIPT} ${stopmode} ${entry}"

    return 0
}

_crontab_reset_from_cfg()
{
    _crontab_rm_script_entries_by_arg

    _cfg_global_is_enabled || return

    local entry
    for entry in $(_cfg_list_entries)
    do
        test -n "${entry}" || continue
        _cfg_entry_is_enabled "${entry}" || continue
        _crontab_add_from_cfg_entry "${entry}"
    done
}

# region: kernel module unload feature

get_module_list()
{
    local mod_list
    local _if
    for _if in $(_wifi_get_interfaces)
    do
        local mod mod_dep
        mod=$(basename "$(readlink -f "/sys/class/net/${_if}/device/driver")")
        mod_dep=$(modinfo "${mod}" | awk '$1 ~ /^depends:/ { print $2 }')
        mod_list=$(printf "%s\n%s,%s" "${mod_list}" "${mod}" "${mod_dep}" | sort -u)
    done
    echo "$mod_list" | tr ',' ' '
}

save_module_list_uci()
{
    local list
    list=$(get_module_list)
    uci set "${GLOBAL}.modules=${list}"
    uci commit "${PACKAGE}"
}

_unload_modules()
{
    local list retries
    list=$(_uci_get_value "${GLOBAL}.modules")
    retries=$(_uci_get_value "${GLOBAL}.modules_retries") || return 1
    _log "unload_modules ${list} (retries: ${retries})"
    local i=0
    while _arith_bool $(( i < retries )) && test -n "$list"
    do
        : $(( i += 1 ))
        local mod
        local first=0
        for mod in ${list}
        do
            if [ $first -eq 0 ]; then
                list=""
                first=1
            fi

            if ! rmmod "${mod}" >/dev/null 2>&1 ; then
                list="$list $mod"
            fi
        done
    done
}

_load_modules()
{
    local list retries
    list=$(   _uci_get_value "${GLOBAL}.modules") || return 1
    retries=$(_uci_get_value "${GLOBAL}.modules_retries") || return 1
    _log "load_modules ${list} (retries: ${retries})"
    local i=0
    while _arith_bool $(( i < retries )) && test -n "$list"
    do
        : $(( i += 1 ))
        local mod
        local first=0
        for mod in ${list}
        do
            if [ $first -eq 0 ]; then
                list=""
                first=1
            fi
            modprobe "${mod}" > /dev/null 2>&1
            rc=$?
            if [ $rc -ne 255 ]; then
                list="$list $mod"
            fi
        done
    done
}

# endregion: kernel module unload feature

# Prints: `phy0-ap0$'\n'phy0-ap1$'\n'`
_wifi_get_interfaces() { iwinfo | awk '/[^[:alnum:]]ESSID[^[:alnum:]]/ { print $1 }' ;}

# Prints: `radio0$'\n'radio1$'\n'`
_wifi_get_devices() { uci show "wireless" | awk -F= '$2 == "wifi-device" { n = split($1, a, "."); print a[n] }' ;}

_wifi_rfkill_set_all_to()
{
    local status="$1"
    _arith_bool $(( status == 0 || status == 1 )) || return 1
    for radio in $(_wifi_get_devices)
    do
        uci set "wireless.${radio}.disabled=${status}"
    done
    uci commit
    /sbin/wifi
}

_wifi_rfkill_unblock_all() { _wifi_rfkill_set_all_to 0 ;}
_wifi_rfkill_block_all()   { _wifi_rfkill_set_all_to 1 ;}

wifi_disable()
{
    _crontab_rm_script_entries_by_arg "recheck"
    _cron_restart
    _wifi_rfkill_block_all
    if _cfg_global_is_unload_modules_enabled
    then
        _unload_modules
    fi
}

wifi_soft_disable()
{
    if ! command -v iwinfo 2>/dev/null ; then
        _log "iwinfo not available, skipping"
        return 1
    fi

    local has_assoc=false
    local mac_filter='([[:xdigit:]]{1,2}:){5}[[:xdigit:]]{1,2}'

    local ignore_stations ignore_stations_filter
    ignore_stations=$(_uci_get_value_raw "${GLOBAL}.ignore_stations")
    # shellcheck disable=SC2086
    ignore_stations_filter=$( _join_by_char "|" ${ignore_stations} )

    # check if no stations are associated
    local _if
    for _if in $(_wifi_get_interfaces)
    do
        local stations ignored_stations
        stations=$(iwinfo "${_if}" assoclist | grep -o -E "${mac_filter}")
        if [ -n "${ignore_stations}" ]; then
            local all_stations="$stations"
            # shellcheck disable=SC2086
            stations=$(printf "%s\n" ${stations} | grep -vwi -E "${ignore_stations_filter}")
            # shellcheck disable=SC2086
            ignored_stations="$( printf "%s\n" $all_stations $stations | sort | uniq -u )"
        fi

        test -n "${stations}" || continue

        has_assoc=true

        # shellcheck disable=SC2086
        _log "Clients connected on '${_if}': $(_join_by_char ' ' ${stations})"
        if test -n "${ignored_stations}"
        then
        # shellcheck disable=SC2086
        _log "Clients ignored on   '${_if}': $(_join_by_char ' ' ${ignored_stations})"
        fi
    done

    _crontab_rm_script_entries_by_arg "recheck"

    if [ "$has_assoc" = "false" ]
    then
        if _cfg_can_wifi_run_now
        then
            _log "Do not disable wifi since there is an allow timewindow, skip rechecking."
        else
            _log "No stations associated, disable wifi."
            wifi_disable
        fi
    else
        _log "Could not disable wifi due to associated stations, retrying..."
        local recheck_interval
        recheck_interval=$(_uci_get_value "${GLOBAL}.recheck_interval")
        if test -n "${recheck_interval}" && _arith_bool $(( recheck_interval > 0 )) ; then
            _crontab_append_line "*/${recheck_interval} * * * * /bin/nice -n 19 ${SCRIPT} recheck"
        fi
    fi

    _cron_restart
}

wifi_enable()
{
    _crontab_rm_script_entries_by_arg "recheck"
    _cron_restart
    if _cfg_global_is_unload_modules_enabled
    then
        _load_modules
    fi
    _wifi_rfkill_unblock_all
}

wifi_startup()
{
    _cfg_global_is_enabled || return

    if _cfg_can_wifi_run_now
    then
        _log "enable wifi"
        wifi_enable
    else
        _log "disable wifi"
        wifi_disable
    fi
}

usage()
{
    echo "$0 cron|start|startup|stop|forcestop|recheck|getmodules|savemodules|help"
    echo ""
    echo "    UCI Config File: /etc/config/${PACKAGE}"
    echo ""
    echo "    cron: Create cronjob entries."
    echo "    start: Start wifi."
    echo "    startup: Checks current timewindow and enables/disables WIFI accordingly."
    echo "    stop: Stop wifi gracefully, i.e. check if there are stations associated and if so keep retrying."
    echo "    forcestop: Stop wifi immediately."
    echo "    recheck: Recheck if wifi can be disabled now."
    echo "    getmodules: Returns a list of modules used by the wireless driver(s)"
    echo "    savemodules: Saves a list of automatic determined modules to UCI"
    echo "    help: This description."
    echo ""
}

# shellcheck disable=SC2317
_cleanup()
{
    lock -u "${LOCKFILE}"
    rm "${LOCKFILE}"
}

###############################################################################
# MAIN
###############################################################################
trap _cleanup EXIT

LOGGING=$(_uci_get_value "${GLOBAL}.logging") || _exit 1
_log "${SCRIPT}" "$@"
lock "${LOCKFILE}"

case "$1" in
    cron)
        _crontab_reset_from_cfg
        _cron_restart
        wifi_startup
    ;;
    start) wifi_enable ;;
    startup) wifi_startup ;;
    forcestop) wifi_disable ;;
    stop) wifi_soft_disable ;;
    recheck) wifi_soft_disable ;;
    getmodules) get_module_list ;;
    savemodules) save_module_list_uci ;;
    help|--help|-h|*) usage ;;
esac

_exit 0

#!/bin/sh
# travelmate, a wlan connection manager for travel router
# written by Dirk Brenken (dev@brenken.org)

# This is free software, licensed under the GNU General Public License v3.
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.

# set initial defaults
#
LC_ALL=C
PATH="/usr/sbin:/usr/bin:/sbin:/bin"
<<<<<<< HEAD
trm_ver="0.7.4"
=======
trm_ver="0.9.0"
>>>>>>> fb00f8f39d2fd26dba01970cd859777609a5b91d
trm_sysver="$(ubus -S call system board | jsonfilter -e '@.release.description')"
trm_enabled=0
trm_debug=0
trm_automatic=1
trm_maxretry=3
trm_maxwait=30
trm_timeout=60
<<<<<<< HEAD
trm_iw="$(command -v iw)"
trm_radio=""
trm_rtfile="/tmp/trm_runtime.json"

# source required system libraries
#
if [ -r "/lib/functions.sh" ] && [ -r "/usr/share/libubox/jshn.sh" ]
then
    . "/lib/functions.sh"
    . "/usr/share/libubox/jshn.sh"
else
    f_log "error" "system libraries not found"
fi
=======
trm_iwinfo="$(command -v iwinfo)"
trm_radio=""
trm_rtfile="/tmp/trm_runtime.json"
>>>>>>> fb00f8f39d2fd26dba01970cd859777609a5b91d

# f_envload: load travelmate environment
#
f_envload()
{
    # initialize lists
    #
    trm_devlist=""
    trm_stalist=""
    trm_radiolist=""

    # load uci config and check 'enabled' option
    #
    option_cb()
    {
        local option="${1}"
        local value="${2}"
        eval "${option}=\"${value}\""
    }
    config_load travelmate

    if [ ${trm_enabled} -ne 1 ]
    then
        f_log "info " "travelmate is currently disabled, please set 'trm_enabled' to '1' to use this service"
        exit 0
    fi
<<<<<<< HEAD

    # check for wireless tool
    #
    if [ -z "${trm_iw}" ]
    then
        f_log "error" "no wireless tool found, please install package 'iw'"
    fi
=======
>>>>>>> fb00f8f39d2fd26dba01970cd859777609a5b91d
}

# f_prepare: gather radio information & bring down all STA interfaces
#
f_prepare()
{
    local config="${1}"
    local mode="$(uci -q get wireless."${config}".mode)"
    local radio="$(uci -q get wireless."${config}".device)"
    local disabled="$(uci -q get wireless."${config}".disabled)"

    if ([ -z "${trm_radio}" ] || [ "${trm_radio}" = "${radio}" ]) && \
        [ -z "$(printf "%s" "${trm_radiolist}" | grep -Fo " ${radio}")" ]
    then
        trm_radiolist="${trm_radiolist} ${radio}"
    fi
    if [ "${mode}" = "sta" ]
    then
        trm_stalist="${trm_stalist} ${config}_${radio}"
        if [ -z "${disabled}" ] || [ "${disabled}" = "0" ]
        then
            uci -q set wireless."${config}".disabled=1
        fi
    fi
    f_log "debug" "prepare: ${mode}, radio: ${radio}, config: ${config}, disabled: ${disabled}"
}

# f_check: check interface status
#
f_check()
{
    local ifname radio status cnt=1 mode="${1}"

<<<<<<< HEAD
    ubus call network reload
    trm_ifstatus="false"
=======
    trm_ifstatus="false"
    ubus call network reload
>>>>>>> fb00f8f39d2fd26dba01970cd859777609a5b91d
    while [ ${cnt} -le ${trm_maxwait} ]
    do
        status="$(ubus -S call network.wireless status 2>/dev/null)"
        if [ -n "${status}" ]
        then
<<<<<<< HEAD
            if [ "${mode}" = "ap" ]
            then
                for radio in ${trm_radiolist}
                do
                    trm_ifstatus="$(printf "%s" "${status}" | jsonfilter -e "@.${radio}.up")"
                    if [ "${trm_ifstatus}" = "true" ]
                    then
                        trm_aplist="${trm_aplist} $(printf "%s" "${status}" | jsonfilter -e "@.${radio}.interfaces[@.config.mode=\"ap\"].ifname")_${radio}"
                        ifname="${trm_aplist}"
                    else
                        trm_aplist=""
                        trm_ifstatus="false"
                        break
                    fi
                done
            else
                ifname="$(printf "%s" "${status}" | jsonfilter -e '@.*.interfaces[@.config.mode="sta"].ifname')"
                if [ -n "${ifname}" ]
                then
                    trm_ifstatus="$(ubus -S call network.interface dump 2>/dev/null | jsonfilter -e "@.interface[@.device=\"${ifname}\"].up")"
                fi
=======
            if [ "${mode}" = "dev" ]
            then
                for radio in ${trm_radiolist}
                do
                    trm_ifstatus="$(printf "%s" "${status}" | jsonfilter -l1 -e "@.${radio}.up")"
                    if [ "${trm_ifstatus}" = "true" ]
                    then
                        trm_devlist="${trm_devlist} ${radio}"
                    else
                        trm_devlist=""
                        break
                    fi
                done
                ifname="${trm_devlist}"
            else
                ifname="$(printf "%s" "${status}" | jsonfilter -l1 -e '@.*.interfaces[@.config.mode="sta"].ifname')"
                if [ -n "${ifname}" ]
                then
                    trm_ifstatus="$(ubus -S call network.interface dump 2>/dev/null | jsonfilter -l1 -e "@.interface[@.device=\"${ifname}\"].up")"
                fi
            fi
            if [ "${mode}" = "initial" ] || [ "${trm_ifstatus}" = "true" ]
            then
                break
>>>>>>> fb00f8f39d2fd26dba01970cd859777609a5b91d
            fi
        fi
        cnt=$((cnt+1))
        sleep 1
    done
    f_log "debug" "check: ${mode}, name: ${ifname}, status: ${trm_ifstatus}, count: ${cnt}, max-wait: ${trm_maxwait}, automatic: ${trm_automatic}"
}

# f_jsnupdate: update runtime information
#
f_jsnupdate()
{
    local iface="${1}" radio="${2}" ssid="${3}"

    json_init
    json_add_object "data"
    json_add_string "travelmate_version" "${trm_ver}"
    json_add_string "station_connection" "${trm_ifstatus}"
    json_add_string "station_ssid" "${ssid}"
    json_add_string "station_interface" "${iface}"
    json_add_string "station_radio" "${radio}"
    json_add_string "last_rundate" "$(/bin/date "+%d.%m.%Y %H:%M:%S")"
    json_add_string "system" "${trm_sysver}"
    json_close_object
    json_dump > "${trm_rtfile}"
}
<<<<<<< HEAD

# f_status: output runtime information
#
f_status()
{
    local key keylist value

=======

# f_status: output runtime information
#
f_status()
{
    local key keylist value

>>>>>>> fb00f8f39d2fd26dba01970cd859777609a5b91d
    if [ -s "${trm_rtfile}" ]
    then
        printf "%s\n" "::: travelmate runtime information"
        json_load "$(cat "${trm_rtfile}" 2>/dev/null)"
        json_select data
        json_get_keys keylist
        for key in ${keylist}
        do
            json_get_var value "${key}"
            printf " %-18s : %s\n" "${key}" "${value}"
        done
    fi
}

# f_log: write to syslog, exit on error
#
f_log()
{
    local class="${1}"
    local log_msg="${2}"

    if [ -n "${log_msg}" ] && ([ "${class}" != "debug" ] || [ ${trm_debug} -eq 1 ])
    then
        logger -t "travelmate-[${trm_ver}] ${class}" "${log_msg}"
        if [ "${class}" = "error" ]
        then
            logger -t "travelmate-[${trm_ver}] ${class}" "Please check 'https://github.com/openwrt/packages/blob/master/net/travelmate/files/README.md' (${trm_sysver})"
            exit 255
        fi
    fi
}

# f_main: main function for connection handling
#
f_main()
{
    local dev config ssid_list sta_ssid sta_radio sta_iface cnt=1

    f_check "initial"
    if [ "${trm_ifstatus}" != "true" ]
    then
        > "${trm_rtfile}"
        config_load wireless
        config_foreach f_prepare wifi-iface
        if [ -n "$(uci -q changes wireless)" ]
        then
            uci -q commit wireless
        fi
<<<<<<< HEAD
        f_check "ap"
        f_log "debug" "ap-list: ${trm_aplist}, sta-list: ${trm_stalist}"
        for ap in ${trm_aplist}
        do
            cnt=1
            ap_radio="${ap##*_}"
            ap="${ap%%_*}"
            if [ -z "$(printf "%s" "${trm_stalist}" | grep -Fo "_${ap_radio}")" ]
=======
        f_check "dev"
        f_log "debug" "main: ${trm_devlist}, sta-list: ${trm_stalist}"
        for dev in ${trm_devlist}
        do
            cnt=1
            if [ -z "$(printf "%s" "${trm_stalist}" | grep -Fo "_${dev}")" ]
>>>>>>> fb00f8f39d2fd26dba01970cd859777609a5b91d
            then
                continue
            fi
            while [ ${cnt} -le ${trm_maxretry} ]
            do
<<<<<<< HEAD
                ssid_list="$(${trm_iw} dev "${ap}" scan 2>/dev/null | \
                    awk '/SSID: /{if(!seen[$0]++){printf "\"";for(i=2; i<=NF; i++)if(i==2)printf $i;else printf " "$i;printf "\" "}}')"
                f_log "debug" "iw: ${trm_iw}, ap: ${ap}, ssids: ${ssid_list}"
=======
                ssid_list="$(${trm_iwinfo} "${dev}" scan | awk '/ESSID: "/{ORS=" ";if (!seen[$0]++) for(i=2; i<=NF; i++) print $i}')"
                f_log "debug" "main: ${trm_iwinfo}, dev: ${dev}, ssids: ${ssid_list}"
>>>>>>> fb00f8f39d2fd26dba01970cd859777609a5b91d
                if [ -n "${ssid_list}" ]
                then
                    for sta in ${trm_stalist}
                    do
                        config="${sta%%_*}"
                        sta_radio="${sta##*_}"
                        sta_ssid="$(uci -q get wireless."${config}".ssid)"
                        sta_iface="$(uci -q get wireless."${config}".network)"
<<<<<<< HEAD
                        if [ -n "$(printf "%s" "${ssid_list}" | grep -Fo "\"${sta_ssid}\"")" ] && [ "${ap_radio}" = "${sta_radio}" ]
=======
                        if [ -n "$(printf "%s" "${ssid_list}" | grep -Fo "\"${sta_ssid}\"")" ] && [ "${dev}" = "${sta_radio}" ]
>>>>>>> fb00f8f39d2fd26dba01970cd859777609a5b91d
                        then
                            uci -q set wireless."${config}".disabled=0
                            f_check "sta"
                            if [ "${trm_ifstatus}" = "true" ]
                            then
                                uci -q commit wireless
                                f_log "info " "interface '${sta_iface}' on '${sta_radio}' connected to uplink '${sta_ssid}' (${trm_sysver})"
                                f_jsnupdate "${sta_iface}" "${sta_radio}" "${sta_ssid}"
                                return 0
                            elif [ ${cnt} -eq ${trm_maxretry} ]
                            then
                                uci -q set wireless."${config}".disabled=1
                                uci -q set wireless."${config}".ssid="${sta_ssid}_err"
                                uci -q commit wireless
                                f_check "dev"
                                f_log "info " "interface 'can't connect to uplink '${sta_ssid}' (${cnt}/${trm_maxretry}), uplink disabled (${trm_sysver})"
                            else
                                uci -q revert wireless
<<<<<<< HEAD
                                f_log "info " "interface '${sta_iface}' on '${sta_radio}' can't connect to uplink '${sta_ssid}' (${trm_sysver})"
                                f_jsnupdate "${sta_iface}" "${sta_radio}" "${sta_ssid}"
=======
                                f_check "dev"
                                f_log "info " "can't connect to uplink '${sta_ssid}' (${cnt}/${trm_maxretry}) (${trm_sysver})"
>>>>>>> fb00f8f39d2fd26dba01970cd859777609a5b91d
                            fi
                            f_jsnupdate "${sta_iface}" "${sta_radio}" "${sta_ssid}"
                        fi
                    done
                fi
                cnt=$((cnt+1))
                sleep 5
            done
        done
        if [ ! -s "${trm_rtfile}" ]
        then
<<<<<<< HEAD
=======
            trm_ifstatus="false"
>>>>>>> fb00f8f39d2fd26dba01970cd859777609a5b91d
            f_jsnupdate "n/a" "n/a" "n/a"
        fi
    else
        if [ ! -s "${trm_rtfile}" ]
        then
            config="$(ubus -S call network.wireless status | jsonfilter -l1 -e '@.*.interfaces[@.config.mode="sta"].section')"
            sta_radio="$(uci -q get wireless."${config}".device)"
            sta_ssid="$(uci -q get wireless."${config}".ssid)"
            sta_iface="$(uci -q get wireless."${config}".network)"
            f_jsnupdate "${sta_iface}" "${sta_radio}" "${sta_ssid}"
        fi
    fi
}

<<<<<<< HEAD
=======
# source required system libraries
#
if [ -r "/lib/functions.sh" ] && [ -r "/usr/share/libubox/jshn.sh" ]
then
    . "/lib/functions.sh"
    . "/usr/share/libubox/jshn.sh"
else
    f_log "error" "system libraries not found"
fi

>>>>>>> fb00f8f39d2fd26dba01970cd859777609a5b91d
# handle different travelmate actions
#
f_envload
case "${1}" in
    status)
        f_status
        ;;
    *)
        f_main
        while [ ${trm_automatic} -eq 1 ]
        do
            sleep ${trm_timeout}
            f_envload
            f_main
        done
        ;;
esac
exit 0

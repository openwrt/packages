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
trm_ver="1.0.1"
trm_sysver="unknown"
trm_enabled=0
trm_debug=0
trm_automatic=1
trm_maxretry=3
trm_maxwait=30
trm_timeout=60
trm_iwinfo="$(command -v iwinfo)"
trm_radio=""
trm_rtfile="/tmp/trm_runtime.json"
trm_wpa="$(command -v wpa_supplicant)"

# f_envload: load travelmate environment
#
f_envload()
{
    local sys_call sys_desc sys_model sys_ver

    # get system information
    #
    sys_call="$(ubus -S call system board 2>/dev/null)"
    if [ -n "${sys_call}" ]
    then
        sys_desc="$(printf '%s' "${sys_call}" | jsonfilter -e '@.release.description')"
        sys_model="$(printf '%s' "${sys_call}" | jsonfilter -e '@.model')"
        sys_ver="$(cat /etc/turris-version 2>/dev/null)"
        if [ -n "${sys_ver}" ]
        then
            sys_desc="${sys_desc}/${sys_ver}"
        fi
        trm_sysver="${sys_model}, ${sys_desc}"
    fi

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

    # check eap capabilities
    #
    trm_eap="$("${trm_wpa}" -veap >/dev/null 2>&1; printf "%u" ${?})"
}

# f_prepare: gather radio information & bring down all STA interfaces
#
f_prepare()
{
    local config="${1}"
    local mode="$(uci -q get wireless."${config}".mode)"
    local network="$(uci -q get wireless."${config}".network)"
    local radio="$(uci -q get wireless."${config}".device)"
    local disabled="$(uci -q get wireless."${config}".disabled)"
    local eaptype="$(uci -q get wireless."${config}".eap_type)"

    if ([ -z "${trm_radio}" ] || [ "${trm_radio}" = "${radio}" ]) && \
        [ -z "$(printf "%s" "${trm_radiolist}" | grep -Fo " ${radio}")" ]
    then
        trm_radiolist="${trm_radiolist} ${radio}"
    fi
    if [ "${mode}" = "sta" ] && [ "${network}" = "${trm_iface}" ]
    then
        if [ -z "${disabled}" ] || [ "${disabled}" = "0" ]
        then
            uci -q set wireless."${config}".disabled=1
        fi
        if [ -z "${eaptype}" ] || [ ${trm_eap} -eq 0 ]
        then
            trm_stalist="${trm_stalist} ${config}_${radio}"
        fi
    fi
    f_log "debug" "prepare: ${config}, mode: ${mode}, network: ${network}, radio: ${radio}, eap: ${trm_eap}, disabled: ${disabled}"
}

# f_check: check interface status
#
f_check()
{
    local ifname radio status cnt=1 mode="${1}"

    trm_ifstatus="false"
    ubus call network reload
    while [ ${cnt} -le ${trm_maxwait} ]
    do
        status="$(ubus -S call network.wireless status 2>/dev/null)"
        if [ -n "${status}" ]
        then
            if [ "${mode}" = "dev" ]
            then
                for radio in ${trm_radiolist}
                do
                    trm_ifstatus="$(printf "%s" "${status}" | jsonfilter -l1 -e "@.${radio}.up")"
                    if [ "${trm_ifstatus}" = "true" ] && [ -z "$(printf "%s" "${trm_devlist}" | grep -Fo " ${radio}")" ]
                    then
                        trm_devlist="${trm_devlist} ${radio}"
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
    local iface="${1}" radio="${2}" essid="${3:-"-"}" bssid="${4:-"-"}"

    json_init
    json_add_object "data"
    json_add_string "travelmate_version" "${trm_ver}"
    json_add_string "station_connection" "${trm_ifstatus}"
    json_add_string "station_id" "${essid}/${bssid}"
    json_add_string "station_interface" "${iface}"
    json_add_string "station_radio" "${radio}"
    json_add_string "last_rundate" "$(/bin/date "+%d.%m.%Y %H:%M:%S")"
    json_add_string "system" "${trm_sysver}"
    json_close_object
    json_dump > "${trm_rtfile}"
}

# f_status: output runtime information
#
f_status()
{
    local key keylist value

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
    local dev config raw_scan essid_list bssid_list sta_essid sta_bssid sta_radio sta_iface cnt=1

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
        f_check "dev"
        f_log "debug" "main: ${trm_devlist}, sta-list: ${trm_stalist}"
        for dev in ${trm_devlist}
        do
            cnt=1
            if [ -z "$(printf "%s" "${trm_stalist}" | grep -Fo "_${dev}")" ]
            then
                continue
            fi
            while [ ${trm_maxretry} -eq 0 ] || [ ${cnt} -le ${trm_maxretry} ]
            do
                raw_scan="$(${trm_iwinfo} "${dev}" scan)"
                essid_list="$(printf "%s" "${raw_scan}" | awk '/ESSID: "/{ORS=" ";if (!seen[$0]++) for(i=2; i<=NF; i++) print $i}')"
                bssid_list="$(printf "%s" "${raw_scan}" | awk '/Address: /{ORS=" ";if (!seen[$5]++) print $5}')"
                f_log "debug" "main: ${trm_iwinfo}, dev: ${dev}"
                f_log "debug" "main: ${essid_list}"
                f_log "debug" "main: ${bssid_list}"
                if [ -n "${essid_list}" ] || [ -n "${bssid_list}" ]
                then
                    for sta in ${trm_stalist}
                    do
                        config="${sta%%_*}"
                        sta_radio="${sta##*_}"
                        sta_essid="$(uci -q get wireless."${config}".ssid)"
                        sta_bssid="$(uci -q get wireless."${config}".bssid)"
                        sta_iface="$(uci -q get wireless."${config}".network)"
                        if (([ -n "$(printf "%s" "${essid_list}" | grep -Fo "\"${sta_essid}\"")" ] && [ -z "${sta_bssid}" ]) || \
                            ([ -n "$(printf "%s" "${bssid_list}" | grep -Fo "${sta_bssid}")" ] && [ -z "$(printf "%s" "${essid_list}" | grep -Fo "\"${sta_essid}\"")" ]) || \
                            ([ -n "$(printf "%s" "${essid_list}" | grep -Fo "\"${sta_essid}\"")" ] && [ -n "$(printf "%s" "${bssid_list}" | grep -Fo "${sta_bssid}")" ])) && \
                             [ "${dev}" = "${sta_radio}" ]
                        then
                            uci -q set wireless."${config}".disabled=0
                            f_check "sta"
                            if [ "${trm_ifstatus}" = "true" ]
                            then
                                uci -q commit wireless
                                f_log "info " "interface '${sta_iface}' on '${sta_radio}' connected to uplink '${sta_essid:-"-"}/${sta_bssid:-"-"}' (${trm_sysver})"
                                f_jsnupdate "${sta_iface}" "${sta_radio}" "${sta_essid}" "${sta_bssid}"
                                return 0
                            elif [ ${trm_maxretry} -ne 0 ] && [ ${cnt} -eq ${trm_maxretry} ]
                            then
                                uci -q set wireless."${config}".disabled=1
                                if [ -n "${sta_essid}" ]
                                then
                                    uci -q set wireless."${config}".ssid="${sta_essid}_err"
                                fi
                                if [ -n "${sta_bssid}" ]
                                then
                                    uci -q set wireless."${config}".bssid="${sta_bssid}_err"
                                fi
                                uci -q commit wireless
                                f_check "dev"
                                f_log "info " "can't connect to uplink '${sta_essid:-"-"}/${sta_bssid:-"-"}' (${cnt}/${trm_maxretry}), uplink disabled (${trm_sysver})"
                            else
                                if [ ${trm_maxretry} -eq 0 ]
                                then
                                    cnt=0
                                fi
                                uci -q revert wireless
                                f_check "dev"
                                f_log "info " "can't connect to uplink '${sta_essid:-"-"}/${sta_bssid:-"-"}' (${cnt}/${trm_maxretry}) (${trm_sysver})"
                            fi
                            f_jsnupdate "${sta_iface}" "${sta_radio}" "${sta_essid}" "${sta_bssid}"
                        fi
                    done
                fi
                cnt=$((cnt+1))
                sleep 5
            done
        done
        if [ ! -s "${trm_rtfile}" ]
        then
            trm_ifstatus="false"
            f_jsnupdate "n/a" "n/a"
        fi
    else
        if [ ! -s "${trm_rtfile}" ]
        then
            config="$(ubus -S call network.wireless status | jsonfilter -l1 -e '@.*.interfaces[@.config.mode="sta"].section')"
            sta_radio="$(uci -q get wireless."${config}".device)"
            sta_essid="$(uci -q get wireless."${config}".ssid)"
            sta_bssid="$(uci -q get wireless."${config}".bssid)"
            sta_iface="$(uci -q get wireless."${config}".network)"
            f_jsnupdate "${sta_iface}" "${sta_radio}" "${sta_essid}" "${sta_bssid}"
        fi
    fi
}

# source required system libraries
#
if [ -r "/lib/functions.sh" ] && [ -r "/usr/share/libubox/jshn.sh" ]
then
    . "/lib/functions.sh"
    . "/usr/share/libubox/jshn.sh"
else
    f_log "error" "system libraries not found"
fi

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

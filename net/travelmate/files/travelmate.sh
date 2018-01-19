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
trm_ver="1.0.2"
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

# load travelmate environment
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
        f_log "info" "travelmate is currently disabled, please set 'trm_enabled' to '1' to use this service"
        exit 0
    fi

    # check eap capabilities
    #
    trm_eap="$("${trm_wpa}" -veap >/dev/null 2>&1; printf "%u" ${?})"
}

# gather radio information & bring down all STA interfaces
#
f_prep()
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
    f_log "debug" "f_prep ::: config: ${config}, mode: ${mode}, network: ${network}, radio: ${radio}, disabled: ${disabled}"
}

# check interface status
#
f_check()
{
    local ifname radio dev_status cnt=1 mode="${1}" status="${2:-"false"}"

    trm_ifstatus="false"
    ubus call network reload
    while [ ${cnt} -le ${trm_maxwait} ]
    do
        dev_status="$(ubus -S call network.wireless status 2>/dev/null)"
        if [ -n "${dev_status}" ]
        then
            if [ "${mode}" = "dev" ]
            then
                if [ "${trm_ifstatus}" != "${status}" ]
                then
                    trm_ifstatus="${status}"
                    f_jsnup
                fi
                for radio in ${trm_radiolist}
                do
                    trm_ifstatus="$(printf "%s" "${dev_status}" | jsonfilter -l1 -e "@.${radio}.up")"
                    if [ "${trm_ifstatus}" = "true" ] && [ -z "$(printf "%s" "${trm_devlist}" | grep -Fo " ${radio}")" ]
                    then
                        trm_devlist="${trm_devlist} ${radio}"
                    fi
                done
                if [ "${trm_radiolist}" = "${trm_devlist}" ] || [ ${cnt} -eq ${trm_maxwait} ] || [ "${status}" = "false" ]
                then
                    ifname="${trm_devlist}"
                    break
                fi
            else
                ifname="$(printf "%s" "${dev_status}" | jsonfilter -l1 -e '@.*.interfaces[@.config.mode="sta"].ifname')"
                if [ -n "${ifname}" ]
                then
                    trm_ifstatus="$(ubus -S call network.interface dump 2>/dev/null | jsonfilter -l1 -e "@.interface[@.device=\"${ifname}\"].up")"
                fi
            fi
            if [ "${mode}" = "initial" ] || [ "${trm_ifstatus}" = "true" ]
            then
                if [ "${mode}" != "initial" ] && [ "${trm_ifstatus}" != "${status}" ]
                then
                    f_jsnup
                fi
                break
            fi
        fi
        cnt=$((cnt+1))
        sleep 1
    done
    f_log "debug" "f_check::: mode: ${mode}, name: ${ifname}, status: ${trm_ifstatus}, cnt: ${cnt}, max-wait: ${trm_maxwait}, automatic: ${trm_automatic}"
}

# update runtime information
#
f_jsnup()
{
    local status iface="${1}" radio="${2}" essid="${3}" bssid="${4}"

    if [ "${trm_ifstatus}" = "true" ]
    then
        status="connected"
    elif [ "${trm_ifstatus}" = "false" ]
    then
        status="not connected"
    elif [ "${trm_ifstatus}" = "running" ]
    then
        status="running"
    elif [ "${trm_ifstatus}" = "error" ]
    then
        status="error"
    fi

    json_init
    json_add_object "data"
    json_add_string "travelmate_status" "${status}"
    json_add_string "travelmate_version" "${trm_ver}"
    json_add_string "station_id" "${essid:-"-"}/${bssid:-"-"}"
    json_add_string "station_interface" "${iface:-"n/a"}"
    json_add_string "station_radio" "${radio:-"n/a"}"
    json_add_string "last_rundate" "$(/bin/date "+%d.%m.%Y %H:%M:%S")"
    json_add_string "system" "${trm_sysver}"
    json_close_object
    json_dump > "${trm_rtfile}"
}

# write to syslog
#
f_log()
{
    local class="${1}"
    local log_msg="${2}"

    if [ -n "${log_msg}" ] && ([ "${class}" != "debug" ] || [ ${trm_debug} -eq 1 ])
    then
        logger -p "${class}" -t "travelmate-[${trm_ver}]" "${log_msg}"
        if [ "${class}" = "err" ]
        then
            trm_ifstatus="error"
            f_jsnup
            logger -p "${class}" -t "travelmate-[${trm_ver}]" "Please check 'https://github.com/openwrt/packages/blob/master/net/travelmate/files/README.md' (${trm_sysver})"
            exit 1
        fi
    fi
}

# main function for connection handling
#
f_main()
{
    local dev config raw_scan essid_list bssid_list sta_essid sta_bssid sta_radio sta_iface cnt=1

    f_check "initial"
    if [ "${trm_ifstatus}" != "true" ]
    then
        config_load wireless
        config_foreach f_prep wifi-iface
        if [ -n "$(uci -q changes wireless)" ]
        then
            uci -q commit wireless
        fi
        f_check "dev" "running"
        f_log "debug" "f_main ::: iwinfo: ${trm_iwinfo}, eap_rc: ${trm_eap}, dev_list: ${trm_devlist}, sta_list: ${trm_stalist}"
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
                f_log "debug" "f_main ::: dev: ${dev}, ssid_list: ${essid_list}, bssid_list: ${bssid_list}"
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
                                f_log "info" "interface '${sta_iface}' on '${sta_radio}' connected to uplink '${sta_essid:-"-"}/${sta_bssid:-"-"}' (${trm_sysver})"
                                f_jsnup "${sta_iface}" "${sta_radio}" "${sta_essid}" "${sta_bssid}"
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
                                f_log "info" "can't connect to uplink '${sta_essid:-"-"}/${sta_bssid:-"-"}' (${cnt}/${trm_maxretry}), uplink disabled (${trm_sysver})"
                            else
                                if [ ${trm_maxretry} -eq 0 ]
                                then
                                    cnt=0
                                fi
                                uci -q revert wireless
                                f_check "dev"
                                f_log "info" "can't connect to uplink '${sta_essid:-"-"}/${sta_bssid:-"-"}' (${cnt}/${trm_maxretry}) (${trm_sysver})"
                            fi
                            f_jsnup "${sta_iface}" "${sta_radio}" "${sta_essid}" "${sta_bssid}"
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
            f_jsnup
        fi
    else
        if [ ! -s "${trm_rtfile}" ]
        then
            config="$(ubus -S call network.wireless status | jsonfilter -l1 -e '@.*.interfaces[@.config.mode="sta"].section')"
            sta_radio="$(uci -q get wireless."${config}".device)"
            sta_essid="$(uci -q get wireless."${config}".ssid)"
            sta_bssid="$(uci -q get wireless."${config}".bssid)"
            sta_iface="$(uci -q get wireless."${config}".network)"
            f_jsnup "${sta_iface}" "${sta_radio}" "${sta_essid}" "${sta_bssid}"
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
    f_log "err" "system libraries not found"
fi

# control travelmate actions
#
f_envload
f_main
while [ ${trm_automatic} -eq 1 ]
do
    sleep ${trm_timeout}
    f_envload
    f_main
done
exit 0

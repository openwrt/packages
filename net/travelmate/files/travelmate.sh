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
trm_ver="1.2.2"
trm_sysver="unknown"
trm_enabled=0
trm_debug=0
trm_captive=1
trm_captiveurl="http://captive.apple.com"
trm_minquality=35
trm_maxretry=3
trm_maxwait=30
trm_timeout=60
trm_radio=""
trm_connection=""
trm_rtfile="/tmp/trm_runtime.json"
trm_fetch="$(command -v uclient-fetch)"
trm_iwinfo="$(command -v iwinfo)"
trm_wpa="$(command -v wpa_supplicant)"
trm_action="${1:-"start"}"
trm_pidfile="/var/run/travelmate.pid"

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

    # (re-)initialize global list variables
    #
    unset trm_devlist trm_stalist trm_radiolist

    # load config and check 'enabled' option
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

    # validate input ranges
    #
    if [ ${trm_minquality} -lt 20 ] || [ ${trm_minquality} -gt 80 ]
    then
        trm_minquality=35
    fi
    if [ ${trm_maxretry} -lt 1 ] || [ ${trm_maxretry} -gt 10 ]
    then
        trm_maxretry=3
    fi
    if [ ${trm_maxwait} -lt 20 ] || [ ${trm_maxwait} -gt 40 ] || [ ${trm_maxwait} -ge ${trm_timeout} ]
    then
        trm_maxwait=30
    fi
    if [ ${trm_timeout} -lt 30 ] || [ ${trm_timeout} -gt 300 ] || [ ${trm_timeout} -le ${trm_maxwait} ]
    then
        trm_timeout=60
    fi
}

# gather radio information & bring down all STA interfaces
#
f_prep()
{
    local eap_rc=0 config="${1}"
    local mode="$(uci_get wireless "${config}" mode)"
    local network="$(uci_get wireless "${config}" network)"
    local radio="$(uci_get wireless "${config}" device)"
    local disabled="$(uci_get wireless "${config}" disabled)"
    local eaptype="$(uci_get wireless "${config}" eap_type)"

    if ([ -z "${trm_radio}" ] || [ "${trm_radio}" = "${radio}" ]) && \
        [ -z "$(printf "%s" "${trm_radiolist}" | grep -Fo " ${radio}")" ]
    then
        trm_radiolist="${trm_radiolist} ${radio}"
    fi
    if [ "${mode}" = "sta" ] && [ "${network}" = "${trm_iface}" ]
    then
        if [ -z "${disabled}" ] || [ "${disabled}" = "0" ]
        then
            uci_set wireless "${config}" disabled 1
        fi
        if [ -n "${eaptype}" ]
        then
            eap_rc="$("${trm_wpa}" -veap >/dev/null 2>&1; printf "%u" ${?})"
        fi
        if [ -z "${eaptype}" ] || [ ${eap_rc} -eq 0 ]
        then
            trm_stalist="${trm_stalist} ${config}_${radio}"
        fi
    fi
    f_log "debug" "f_prep ::: config: ${config}, mode: ${mode}, network: ${network}, eap_rc: ${eap_rc}, radio: ${radio}, trm_radio: ${trm_radio:-"-"}, disabled: ${disabled}"
}

# check interface status
#
f_check()
{
    local IFS ifname radio dev_status config sta_essid sta_bssid result wait=1 mode="${1}" status="${2:-"false"}"

    trm_ifquality=0
    trm_ifstatus="false"
    if [ "${mode}" != "initial" ]
    then
        ubus call network reload
    fi
    while [ ${wait} -le ${trm_maxwait} ]
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
                    result="$(printf "%s" "${dev_status}" | jsonfilter -l1 -e "@.${radio}.up")"
                    if [ "${result}" = "true" ] && [ -z "$(printf "%s" "${trm_devlist}" | grep -Fo " ${radio}")" ]
                    then
                        trm_devlist="${trm_devlist} ${radio}"
                    fi
                done
                if [ "${trm_devlist}" = "${trm_radiolist}" ] || [ ${wait} -eq ${trm_maxwait} ]
                then
                    ifname="${trm_devlist}"
                    break
                else
                    unset trm_devlist
                fi
            elif [ "${mode}" = "rev" ]
            then
                wait=$(( ${trm_maxwait} / 3 ))
                sleep ${wait}
                break
            else
                ifname="$(printf "%s" "${dev_status}" | jsonfilter -l1 -e '@.*.interfaces[@.config.mode="sta"].ifname')"
                if [ -n "${ifname}" ]
                then
                    trm_ifquality="$(${trm_iwinfo} ${ifname} info 2>/dev/null | awk -F "[\/| ]" '/Link Quality:/{printf "%i\n", (100 / $NF * $(NF-1)) }')"
                    if [ ${trm_ifquality} -ge ${trm_minquality} ]
                    then
                        trm_ifstatus="$(ubus -S call network.interface dump 2>/dev/null | jsonfilter -l1 -e "@.interface[@.device=\"${ifname}\"].up")"
                    elif [ "${mode}" = "initial" ] && [ ${trm_ifquality} -lt ${trm_minquality} ]
                    then
                        trm_ifstatus="${status}"
                        sta_essid="$(printf "%s" "${dev_status}" | jsonfilter -l1 -e '@.*.interfaces[@.config.mode="sta"].*.ssid')"
                        sta_bssid="$(printf "%s" "${dev_status}" | jsonfilter -l1 -e '@.*.interfaces[@.config.mode="sta"].*.bssid')"
                        f_log "info" "uplink '${sta_essid:-"-"}/${sta_bssid:-"-"}' is out of range (${trm_ifquality}/${trm_minquality}), uplink disconnected (${trm_sysver})"
                    fi
                fi
            fi
            if [ "${mode}" = "initial" ] || [ "${trm_ifstatus}" = "true" ]
            then
                if ([ "${trm_ifstatus}" != "true" ] && [ "${trm_ifstatus}" != "${status}" ]) || [ ${trm_ifquality} -lt ${trm_minquality} ]
                then
                    f_jsnup
                fi
                if [ "${mode}" = "initial" ] && [ "${trm_captive}" -eq 1 ] && [ "${trm_ifstatus}" = "true" ]
                then
                    result="$(${trm_fetch} --timeout=$(( ${trm_maxwait} / 3 )) --spider "${trm_captiveurl}" 2>&1 | awk '/^Redirected/{printf "%s" "net cp \047"$NF"\047";exit}/^Download completed/{printf "%s" "net ok";exit}/^Failed|^Connection error/{printf "%s" "net nok";exit}')"
                    if [ -n "${result}" ] && ([ -z "${trm_connection}" ] || [ "${result}" != "${trm_connection%/*}" ])
                    then
                        trm_connection="${result}/${trm_ifquality}"
                        f_jsnup
                    fi
                fi
                break
            fi
        fi
        wait=$(( wait + 1 ))
        sleep 1
    done
    f_log "debug" "f_check::: mode: ${mode}, name: ${ifname:-"-"}, status: ${trm_ifstatus}, quality: ${trm_ifquality}, connection: ${trm_connection:-"-"}, wait: ${wait}, max_wait: ${trm_maxwait}, min_quality: ${trm_minquality}, captive: ${trm_captive}"
}

# update runtime information
#
f_jsnup()
{
    local config sta_iface sta_radio sta_essid sta_bssid dev_status status="${trm_ifstatus}" faulty_list faulty_station="${1}"

    if [ "${status}" = "true" ]
    then
        status="connected (${trm_connection:-"-"})"
    else
        unset trm_connection
        if [ "${status}" = "false" ]
        then
            status="not connected"
        fi
    fi

    dev_status="$(ubus -S call network.wireless status 2>/dev/null)"
    if [ -n "${dev_status}" ]
    then
        config="$(printf "%s" "${dev_status}" | jsonfilter -l1 -e '@.*.interfaces[@.config.mode="sta"].section')"
        if [ -n "${config}" ]
        then
            sta_iface="$(uci_get wireless "${config}" network)"
            sta_radio="$(uci_get wireless "${config}" device)"
            sta_essid="$(uci_get wireless "${config}" ssid)"
            sta_bssid="$(uci_get wireless "${config}" bssid)"
        fi
    fi

    json_get_var faulty_list "faulty_stations"
    if [ -n "${faulty_station}" ]
    then
        if [ -z "$(printf "%s" "${faulty_list}" | grep -Fo "${faulty_station}")" ]
        then
            faulty_list="${faulty_list} ${faulty_station}"
        fi
    fi
    json_add_string "travelmate_status" "${status}"
    json_add_string "travelmate_version" "${trm_ver}"
    json_add_string "station_id" "${sta_radio:-"-"}/${sta_essid:-"-"}/${sta_bssid:-"-"}"
    json_add_string "station_interface" "${sta_iface:-"-"}"
    json_add_string "faulty_stations" "${faulty_list}"
    json_add_string "last_rundate" "$(/bin/date "+%d.%m.%Y %H:%M:%S")"
    json_add_string "system" "${trm_sysver}"
    json_dump > "${trm_rtfile}"
    f_log "debug" "f_jsnup::: config: ${config:-"-"}, status: ${status:-"-"}, sta_iface: ${sta_iface:-"-"}, sta_radio: ${sta_radio:-"-"}, sta_essid: ${sta_essid:-"-"}, sta_bssid: ${sta_bssid:-"-"}, faulty_list: ${faulty_list:-"-"}"
}

# write to syslog
#
f_log()
{
    local class="${1}"
    local log_msg="${2}"

    if [ -n "${log_msg}" ] && ([ "${class}" != "debug" ] || [ ${trm_debug} -eq 1 ])
    then
        logger -p "${class}" -t "travelmate-${trm_ver}[${$}]" "${log_msg}"
        if [ "${class}" = "err" ]
        then
            trm_ifstatus="error"
            f_jsnup
            logger -p "${class}" -t "travelmate-${trm_ver}[${$}]" "Please check 'https://github.com/openwrt/packages/blob/master/net/travelmate/files/README.md' (${trm_sysver})"
            exit 1
        fi
    fi
}

# main function for connection handling
#
f_main()
{
    local IFS cnt dev config scan scan_list scan_essid scan_bssid scan_quality sta sta_essid sta_bssid sta_radio sta_iface faulty_list

    f_check "initial"
    if [ "${trm_ifstatus}" != "true" ]
    then
        config_load wireless
        config_foreach f_prep wifi-iface
        uci_commit wireless
        f_check "dev" "running"
        json_get_var faulty_list "faulty_stations"
        f_log "debug" "f_main ::: iwinfo: ${trm_iwinfo}, dev_list: ${trm_devlist}, sta_list: ${trm_stalist:0:800}, faulty_list: ${faulty_list:-"-"}"
        for dev in ${trm_devlist}
        do
            if [ -z "$(printf "%s" "${trm_stalist}" | grep -Fo "_${dev}")" ]
            then
                continue
            fi
            cnt=1
            while [ ${cnt} -le ${trm_maxretry} ]
            do
                scan_list="$(${trm_iwinfo} "${dev}" scan 2>/dev/null | awk 'BEGIN{FS="[/ ]"}/Address:/{var1=$NF}/ESSID:/{var2="";for(i=12;i<=NF;i++)if(var2==""){var2=$i}else{var2=var2" "$i}}/Quality:/{printf "%i,%s,%s\n",(100/$NF*$(NF-1)),var1,var2}' | sort -rn | awk '{ORS=",";print $0}')"
                f_log "debug" "f_main ::: dev: ${dev}, scan_list: ${scan_list:0:800}, cnt: ${cnt}, max_cnt: ${trm_maxretry}"
                if [ -n "${scan_list}" ]
                then
                    for sta in ${trm_stalist}
                    do
                        config="${sta%%_*}"
                        sta_radio="${sta##*_}"
                        sta_essid="$(uci_get wireless "${config}" ssid)"
                        sta_bssid="$(uci_get wireless "${config}" bssid)"
                        sta_iface="$(uci_get wireless "${config}" network)"
                        json_get_var faulty_list "faulty_stations"
                        if [ -n "$(printf "%s" "${faulty_list}" | grep -Fo "${sta_radio}/${sta_essid}/${sta_bssid}")" ]
                        then
                            continue
                        fi
                        IFS=","
                        for scan in ${scan_list}
                        do
                            if [ -z "${scan_quality}" ]
                            then
                                scan_quality="${scan}"
                            elif [ -z "${scan_bssid}" ]
                            then
                                scan_bssid="${scan}"
                            elif [ -z "${scan_essid}" ]
                            then
                                scan_essid="${scan}"
                            fi
                            if [ -n "${scan_quality}" ] && [ -n "${scan_bssid}" ] && [ -n "${scan_essid}" ]
                            then
                                if [ ${scan_quality} -ge ${trm_minquality} ]
                                then
                                    if (([ "${scan_essid}" = "\"${sta_essid}\"" ] && ([ -z "${sta_bssid}" ] || [ "${scan_bssid}" = "${sta_bssid}" ])) || \
                                        ([ "${scan_bssid}" = "${sta_bssid}" ] && [ "${scan_essid}" = "unknown" ])) && [ "${dev}" = "${sta_radio}" ]
                                    then
                                        f_log "debug" "f_main ::: scan_quality: ${scan_quality}, scan_bssid: ${scan_bssid}, scan_essid: ${scan_essid}"
                                        uci_set wireless "${config}" disabled 0
                                        f_check "sta"
                                        if [ "${trm_ifstatus}" = "true" ]
                                        then
                                            uci_commit wireless
                                            f_check "initial"
                                            f_log "info" "connected to uplink '${sta_radio}/${sta_essid}/${sta_bssid:-"-"}' (${trm_sysver})"
                                            return 0
                                        elif [ ${cnt} -eq ${trm_maxretry} ]
                                        then
                                            uci_set wireless "${config}" disabled 1
                                            uci_commit wireless
                                            faulty_station="${sta_radio}/${sta_essid}/${sta_bssid:-"-"}"
                                            f_jsnup "${faulty_station}"
                                            f_log "info" "can't connect to uplink '${sta_radio}/${sta_essid}/${sta_bssid:-"-"}', uplink disabled (${trm_sysver})"
                                            f_check "rev"
                                            break
                                        else
                                            uci -q revert wireless
                                            f_jsnup
                                            f_log "info" "can't connect to uplink '${sta_radio}/${sta_essid}/${sta_bssid:-"-"}' (${trm_sysver})"
                                            f_check "rev"
                                            break
                                        fi
                                    fi
                                fi
                                unset scan_quality scan_bssid scan_essid
                            fi
                        done
                        unset IFS scan_quality scan_bssid scan_essid
                    done
                fi
                cnt=$(( cnt + 1 ))
                sleep $(( ${trm_maxwait} / 6 ))
            done
        done
        if [ ! -s "${trm_rtfile}" ]
        then
            trm_ifstatus="false"
            f_jsnup
        fi
    elif [ ! -s "${trm_rtfile}" ]
    then
        f_jsnup
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

# initialize json runtime file
#
if [ ! -s "${trm_rtfile}" ]
then
    json_init
    json_add_object "data"
else
    json_load_file "${trm_rtfile}"
    json_select data
fi

# control travelmate actions
#
while true
do
    if [ -z "${trm_action}" ]
    then
        sleep ${trm_timeout}
    elif [ "${trm_action}" = "stop" ]
    then
        > "${trm_rtfile}"
        f_log "info" "travelmate instance stopped ::: action: ${trm_action}, pid: $(cat ${trm_pidfile} 2>/dev/null)"
        exit 0
    else
        f_log "info" "travelmate instance started ::: action: ${trm_action}, pid: ${$}"
        unset trm_action
    fi
    f_envload
    f_main
done

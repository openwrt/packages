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
trm_ver="1.1.1"
trm_sysver="unknown"
trm_enabled=0
trm_debug=0
trm_automatic=1
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
    trm_devlist=""
    trm_stalist=""
    trm_radiolist=""

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

    # check eap capabilities
    #
    trm_eap="$("${trm_wpa}" -veap >/dev/null 2>&1; printf "%u" ${?})"
}

# gather radio information & bring down all STA interfaces
#
f_prep()
{
    local config="${1}"
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
    local ifname radio dev_status config sta_iface sta_radio sta_essid sta_bssid result cnt=1 mode="${1}" status="${2:-"false"}" IFS=" "

    trm_ifquality=0
    trm_ifstatus="false"
    if [ "${mode}" != "initial" ]
    then
        ubus call network reload
    fi
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
                    status="$(printf "%s" "${dev_status}" | jsonfilter -l1 -e "@.${radio}.up")"
                    if [ "${status}" = "true" ] && [ -z "$(printf "%s" "${trm_devlist}" | grep -Fo " ${radio}")" ]
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
                config="$(printf "%s" "${dev_status}" | jsonfilter -l1 -e '@.*.interfaces[@.config.mode="sta"].section')"
                if [ -n "${ifname}" ] && [ -n "${config}" ]
                then
                    sta_iface="$(uci_get wireless "${config}" network)"
                    sta_radio="$(uci_get wireless "${config}" device)"
                    sta_essid="$(uci_get wireless "${config}" ssid)"
                    sta_bssid="$(uci_get wireless "${config}" bssid)"
                    trm_ifquality="$(${trm_iwinfo} ${ifname} info 2>/dev/null | awk -F "[\/| ]" '/Link Quality:/{printf "%i\n", (100 / $NF * $(NF-1)) }')"
                    if [ ${trm_ifquality} -ge ${trm_minquality} ]
                    then
                        trm_ifstatus="$(ubus -S call network.interface dump 2>/dev/null | jsonfilter -l1 -e "@.interface[@.device=\"${ifname}\"].up")"
                    elif [ "${mode}" = "initial" ] && [ ${trm_ifquality} -lt ${trm_minquality} ]
                    then
                        trm_connection=""
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
                    result="$(${trm_fetch} --timeout=1 --spider "${trm_captiveurl}" 2>&1 | awk '/^Redirected/{printf "%s" "cp \047"$NF"\047";exit}/^Download completed/{printf "%s" "net ok";exit}/^Failed/{printf "%s" "net nok";exit}')"
                    if ([ -n "${result}" ] && [ -z "${trm_connection}" ]) || [ "${trm_connection%/*}" != "${result}" ]
                    then
                        trm_connection="${result}/${trm_ifquality}"
                        f_jsnup "${sta_iface}" "${sta_radio}" "${sta_essid}" "${sta_bssid}"
                    fi
                fi
                break
            fi
        fi
        cnt=$((cnt+1))
        sleep 1
    done
    f_log "debug" "f_check::: mode: ${mode}, name: ${ifname:-"-"}, status: ${trm_ifstatus}, quality: ${trm_ifquality}, connection: ${trm_connection:-"-"}, cnt: ${cnt}, max_wait: ${trm_maxwait}, min_quality: ${trm_minquality}, captive: ${trm_captive}, automatic: ${trm_automatic}"
}

# update runtime information
#
f_jsnup()
{
    local status="${trm_ifstatus}" iface="${1}" radio="${2}" essid="${3}" bssid="${4}"

    if [ "${status}" = "true" ]
    then
        status="connected (${trm_connection:-"-"})"
    elif [ "${status}" = "false" ]
    then
        status="not connected"
    fi

    json_init
    json_add_object "data"
    json_add_string "travelmate_status" "${status}"
    json_add_string "travelmate_version" "${trm_ver}"
    json_add_string "station_id" "${essid:-"-"}/${bssid:-"-"}"
    json_add_string "station_interface" "${iface:-"-"}"
    json_add_string "station_radio" "${radio:-"-"}"
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
    local cnt dev config scan scan_list scan_essid scan_bssid scan_quality sta sta_essid sta_bssid sta_radio sta_iface IFS=" "

    f_check "initial"
    if [ "${trm_ifstatus}" != "true" ]
    then
        config_load wireless
        config_foreach f_prep wifi-iface
        uci_commit wireless
        f_check "dev" "running"
        f_log "debug" "f_main ::: iwinfo: ${trm_iwinfo}, eap_rc: ${trm_eap}, dev_list: ${trm_devlist}, sta_list: ${trm_stalist:0:800}"
        for dev in ${trm_devlist}
        do
            if [ -z "$(printf "%s" "${trm_stalist}" | grep -Fo "_${dev}")" ]
            then
                continue
            fi
            cnt=1
            while [ ${trm_maxretry} -eq 0 ] || [ ${cnt} -le ${trm_maxretry} ]
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
                                        uci_set wireless "${config}" disabled 0
                                        f_check "sta"
                                        if [ "${trm_ifstatus}" = "true" ]
                                        then
                                            uci_commit wireless
                                            f_log "info" "interface '${sta_iface}' on '${sta_radio}' connected to uplink '${sta_essid:-"-"}/${sta_bssid:-"-"}' (${trm_sysver})"
                                            f_check "initial"
                                            return 0
                                        elif [ ${trm_maxretry} -ne 0 ] && [ ${cnt} -eq ${trm_maxretry} ]
                                        then
                                            uci_set wireless "${config}" disabled 1
                                            if [ -n "${sta_essid}" ]
                                            then
                                                uci_set wireless "${config}" ssid "${sta_essid}_err"
                                            fi
                                            if [ -n "${sta_bssid}" ]
                                            then
                                                uci_set wireless "${config}" bssid "${sta_bssid}_err"
                                            fi
                                            uci_commit wireless
                                            f_log "info" "can't connect to uplink '${sta_essid:-"-"}/${sta_bssid:-"-"}', uplink disabled (${trm_sysver})"
                                            f_check "dev"
                                        else
                                            if [ ${trm_maxretry} -eq 0 ]
                                            then
                                                cnt=0
                                            fi
                                            uci -q revert wireless
                                            f_log "info" "can't connect to uplink '${sta_essid:-"-"}/${sta_bssid:-"-"}' (${trm_sysver})"
                                            f_check "dev"
                                        fi
                                    fi
                                fi
                                scan_quality=""
                                scan_bssid=""
                                scan_essid=""
                            fi
                        done
                        IFS=" "
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
            sta_radio="$(uci_get wireless "${config}" device)"
            sta_essid="$(uci_get wireless "${config}" ssid)"
            sta_bssid="$(uci_get wireless "${config}" bssid)"
            sta_iface="$(uci_get wireless "${config}" network)"
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

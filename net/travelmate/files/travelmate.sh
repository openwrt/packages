#!/bin/sh
# travelmate, a wlan connection manager for travel router
# written by Dirk Brenken (dev@brenken.org)

# This is free software, licensed under the GNU General Public License v3.
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.

# prepare environment
#
LC_ALL=C
PATH="/usr/sbin:/usr/bin:/sbin:/bin"
trm_pid="${$}"
trm_ver="0.2.6"
trm_debug=0
trm_loop=30
trm_maxretry=3
trm_iw=1
trm_device=""

# function to prepare all relevant AP and STA interfaces
#
trm_prepare()
{
    local config="${1}"
    local mode="$(uci -q get wireless."${config}".mode)"
    local device="$(uci -q get wireless."${config}".device)"
    local network="$(uci -q get wireless."${config}".network)"
    local ifname="$(uci -q get wireless."${config}".ifname)"
    local disabled="$(uci -q get wireless."${config}".disabled)"

    if [ "${mode}" = "ap" ] && [ -n "${network}" ] && [ -n "${ifname}" ] &&
        ([ -z "${trm_device}" ] || [ "${trm_device}" = "${device}" ])
    then
        trm_aplist="${trm_aplist} ${ifname}"
        if [ -z "${disabled}" ] || [ "${disabled}" = "1" ]
        then
            trm_set "none" "${config}" "${network}" "up"
        fi
    elif [ "${mode}" = "sta" ] && [ -n "${network}" ]
    then
        trm_stalist="${trm_stalist} ${config}_${network}"
        if [ -z "${disabled}" ] || [ "${disabled}" = "0" ]
        then
            trm_set "none" "${config}" "${network}" "down"
        fi
    fi
}

# function to set different wlan interface status
#
trm_set()
{
    local change="${1}"
    local config="${2}"
    local interface="${3}"
    local command="${4}"

    if [ "${command}" = "up" ]
    then
        uci -q set wireless."${config}".disabled=0
        ubus call network.interface."${interface}" "${command}"
        trm_checklist="${trm_checklist} ${interface}"
    elif [ "${command}" = "down" ]
    then
        uci -q set wireless."${config}".disabled=1
        ubus call network.interface."${interface}" "${command}"
    fi

    trm_log "debug" "set  ::: change: ${change}, config: ${config}, interface: ${interface}, command: ${command}, checklist: ${trm_checklist}, uci-changes: $(uci -q changes wireless)"
    if [ -n "$(uci -q changes wireless)" ]
    then
        if [ "${change}" = "commit" ]
        then
            uci -q commit wireless
            ubus call network reload
            trm_check
        elif [ "${change}" = "partial" ]
        then
            ubus call network reload
            trm_check
        elif [ "${change}" = "defer" ]
        then
            uci -q revert wireless
        elif [ "${change}" = "revert" ]
        then
            uci -q revert wireless
            ubus call network reload
            trm_check
        fi
    fi
}

# function to check interface status on "up" event
#
trm_check()
{
    local interface value
    local cnt=0

    for interface in ${trm_checklist}
    do
        while [ $((cnt)) -lt 15 ]
        do
            json_load "$(ubus -S call network.interface."${interface}" status)"
            json_get_var trm_status up
            if [ "${trm_status}" = "1" ] || [ -n "${trm_uplink}" ]
            then
                trm_log "debug" "check::: interface: ${interface}, status: ${trm_status}, uplink-cfg: ${trm_uplink}, uplink-ssid: ${trm_ssid}, loop-cnt: ${cnt}, error-cnt: $((trm_count_${trm_config}))"
                json_cleanup
                break
            fi
            cnt=$((cnt+1))
            sleep 1
        done
    done
    if [ -n "${trm_uplink}" ] && [ "${trm_status}" = "0" ]
    then
        ubus call network reload
        eval "trm_count_${trm_uplink}=\$((trm_count_${trm_uplink}+1))"
        trm_checklist=""
        trm_uplink=""
        trm_log "info" "uplink ${trm_ssid} get lost"
    elif [ -z "${trm_uplink}" ] && [ -n "${trm_checklist}" ]
    then
        trm_checklist=""
    fi
}

# function to write to syslog
#
trm_log()
{
    local class="${1}"
    local log_msg="${2}"

    if [ -n "${log_msg}" ] && ([ "${class}" != "debug" ] || ([ "${class}" = "debug" ] && [ $((trm_debug)) -eq 1 ]))
    then
        logger -t "travelmate-${trm_ver}[${trm_pid}] ${class}" "${log_msg}" 2>&1
    fi
}

# source required system libraries
#
if [ -r "/lib/functions.sh" ] && [ -r "/usr/share/libubox/jshn.sh" ]
then
    . "/lib/functions.sh"
    . "/usr/share/libubox/jshn.sh"
    json_init
else
    trm_log "error" "required system libraries not found"
    exit 255
fi

# load uci config and check 'enabled' option
#
option_cb()
{
    local option="${1}"
    local value="${2}"
    eval "${option}=\"${value}\""
}

config_load travelmate

if [ "${trm_enabled}" != "1" ]
then
    trm_log "info" "travelmate is currently disabled, please set 'trm_enabled' to '1' to use this service"
    exit 0
fi

# check for preferred wireless tool
#
if [ $((trm_iw)) -eq 1 ]
then
    trm_scanner="$(which iw)"
else
    trm_scanner="$(which iwinfo)"
fi

if [ -z "${trm_scanner}" ]
then
    trm_log "error" "no wireless tool for wlan scanning found, please install 'iw' or 'iwinfo'"
    exit 1
fi

# infinitive loop to establish and track STA uplink connections
#
while true
do
    if [ -z "${trm_uplink}" ] || [ "${trm_status}" = "0" ]
    then
        trm_aplist=""
        trm_stalist=""
        config_load wireless
        config_foreach trm_prepare wifi-iface
        trm_set "commit"
        if [ -z "${trm_aplist}" ]
        then
            trm_log "error" "no usable AP configuration found, please add an 'ifname' entry in '/etc/config/wireless'"
            exit 1
        fi
        for ap in ${trm_aplist}
        do
            ubus -t 10 wait_for hostapd."${ap}"
            if [ $((trm_iw)) -eq 1 ]
            then
                trm_ssidlist="$(${trm_scanner} dev "${ap}" scan 2>/dev/null | awk '/SSID: /{if(!seen[$0]++){printf "\"";for(i=2; i<=NF; i++)if(i==2)printf $i;else printf " "$i;printf "\" "}}')"
            else
                trm_ssidlist="$(${trm_scanner} "${ap}" scan | awk '/ESSID: ".*"/{ORS=" ";if (!seen[$0]++) for(i=2; i<=NF; i++) print $i}')"
            fi
            trm_log "debug" "main ::: scan-tool: ${trm_scanner}, aplist: ${trm_aplist}, ssidlist: ${trm_ssidlist}"
            if [ -n "${trm_ssidlist}" ]
            then
                if [ -z "${trm_stalist}" ]
                then
                    trm_log "error" "no usable STA configuration found, please add a 'network' entry in '/etc/config/wireless'"
                    exit 1
                fi
                for sta in ${trm_stalist}
                do
                    trm_config="${sta%%_*}"
                    trm_network="${sta##*_}"
                    trm_ifname="$(uci -q get wireless."${trm_config}".ifname)"
                    trm_ssid="\"$(uci -q get wireless."${trm_config}".ssid)\""
                    if [ -z "${trm_ifname}" ]
                    then
                        trm_ifname="${trm_network}"
                    fi
                    if [ $((trm_count_${trm_config})) -lt $((trm_maxretry)) ] || [ $((trm_maxretry)) -eq 0 ]
                    then
                        if [ -n "$(printf "${trm_ssidlist}" | grep -Fo "${trm_ssid}")" ]
                        then
                            trm_set "partial" "${trm_config}" "${trm_network}" "up"
                            if [ "${trm_status}" = "1" ]
                            then
                                trm_checklist="${trm_network}"
                                trm_uplink="${trm_config}"
                                trm_set "defer"
                                trm_log "info" "wwan interface \"${trm_ifname}\" connected to uplink ${trm_ssid}" 
                                break 2
                            else
                                trm_set "revert"
                                eval "trm_count_${trm_config}=\$((trm_count_${trm_config}+1))"
                            fi
                        fi
                    elif [ $((trm_count_${trm_config})) -eq $((trm_maxretry)) ] && [ $((trm_maxretry)) -ne 0 ]
                    then
                        eval "trm_count_${trm_config}=\$((trm_count_${trm_config}+1))"
                        trm_log "info" "uplink ${trm_ssid} disabled due to permanent connection failures"
                    fi
                done
            fi
            sleep 5
        done
    else
        trm_check
        if [ -n "${trm_uplink}" ]
        then
            sleep ${trm_loop}
        fi
    fi
done

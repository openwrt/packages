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
trm_ver="0.3.2"
trm_enabled=1
trm_debug=0
trm_maxwait=20
trm_maxretry=3
trm_iw=1

f_envload()
{
    # source required system libraries
    #
    if [ -r "/lib/functions.sh" ]
    then
        . "/lib/functions.sh"
    else
        f_log "error" "status  ::: required system library not found"
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

    if [ ${trm_enabled} -ne 1 ]
    then
        f_log "info " "status  ::: travelmate is currently disabled, please set 'trm_enabled' to '1' to use this service"
        exit 0
    fi

    # check for preferred wireless tool
    #
    if [ ${trm_iw} -eq 1 ]
    then
        trm_scanner="$(which iw)"
    else
        trm_scanner="$(which iwinfo)"
    fi
    if [ -z "${trm_scanner}" ]
    then
        f_log "error" "status  ::: no wireless tool for wlan scanning found, please install 'iw' or 'iwinfo'"
    fi
}

# function to bring down all STA interfaces
#
f_prepare()
{
    local config="${1}"
    local mode="$(uci -q get wireless."${config}".mode)"
    local network="$(uci -q get wireless."${config}".network)"
    local disabled="$(uci -q get wireless."${config}".disabled)"

    if [ "${mode}" = "sta" ] && [ -n "${network}" ]
    then
        trm_stalist="${trm_stalist} ${config}_${network}"
        if [ -z "${disabled}" ] || [ "${disabled}" = "0" ]
        then
            uci -q set wireless."${config}".disabled=1
            f_log "debug" "prepare ::: config: ${config}, interface: ${network}"
        fi
    fi
}

f_check()
{
    local ifname cnt=1 mode="${1}"
    trm_ifstatus="false"

    while [ ${cnt} -le ${trm_maxwait} ]
    do
        if [ "${mode}" = "ap" ]
        then
            trm_ifstatus="$(ubus -S call network.wireless status | jsonfilter -l1 -e '@.*.up')"
        else
            ifname="$(ubus -S call network.wireless status | jsonfilter -l1 -e '@.*.interfaces[@.config.mode="sta"].ifname')"
            if [ -n "${ifname}" ]
            then
                trm_ifstatus="$(ubus -S call network.interface dump | jsonfilter -e "@.interface[@.device=\"${ifname}\"].up")"
            fi
        fi
        if [ "${mode}" = "initial" ] || [ "${trm_ifstatus}" = "true" ]
        then
            break
        fi
        cnt=$((cnt+1))
        sleep 1
    done
    f_log "debug" "check   ::: mode: ${mode}, name: ${ifname}, status: ${trm_ifstatus}, count: ${cnt}, max-wait: ${trm_maxwait}"
}

# function to write to syslog
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
            exit 255
        fi
    fi
}

f_main()
{
    local ap_list ssid_list config network ssid cnt=1
    local sysver="$(ubus -S call system board | jsonfilter -e '@.release.description')"

    f_check "initial"
    if [ "${trm_ifstatus}" != "true" ]
    then
        config_load wireless
        config_foreach f_prepare wifi-iface
        if [ -n "$(uci -q changes wireless)" ]
        then
            uci -q commit wireless
            ubus call network reload
        fi
        f_check "ap"
        ap_list="$(ubus -S call network.wireless status | jsonfilter -e '@.*.interfaces[@.config.mode="ap"].ifname')"
        f_log "debug" "main    ::: ap-list: ${ap_list}, sta-list: ${trm_stalist}"
        if [ -z "${ap_list}" ] || [ -z "${trm_stalist}" ]
        then
            f_log "error" "status  ::: no usable AP/STA configuration found"
        fi
        for ap in ${ap_list}
        do
            while [ ${cnt} -le ${trm_maxretry} ]
            do
                if [ ${trm_iw} -eq 1 ]
                then
                    ssid_list="$(${trm_scanner} dev "${ap}" scan 2>/dev/null | \
                        awk '/SSID: /{if(!seen[$0]++){printf "\"";for(i=2; i<=NF; i++)if(i==2)printf $i;else printf " "$i;printf "\" "}}')"
                else
                    ssid_list="$(${trm_scanner} "${ap}" scan | \
                        awk '/ESSID: ".*"/{ORS=" ";if (!seen[$0]++) for(i=2; i<=NF; i++) print $i}')"
                fi
                f_log "debug" "main    ::: scan-tool: ${trm_scanner}, ssidlist: ${ssid_list}"
                if [ -n "${ssid_list}" ]
                then
                    for sta in ${trm_stalist}
                    do
                        config="${sta%%_*}"
                        network="${sta##*_}"
                        ssid="\"$(uci -q get wireless."${config}".ssid)\""
                        if [ -n "$(printf "${ssid_list}" | grep -Fo "${ssid}")" ]
                        then
                            uci -q set wireless."${config}".disabled=0
                            uci -q commit wireless
                            ubus call network reload
                            f_check "sta"
                            if [ "${trm_ifstatus}" = "true" ]
                            then
                                f_log "info " "status  ::: wwan interface connected to uplink ${ssid} (${cnt}/${trm_maxretry}, ${sysver})"
                                sleep 5
                                return 0
                            else
                                uci -q set wireless."${config}".disabled=1
                                uci -q commit wireless
                                ubus call network reload
                                f_log "info " "status  ::: wwan interface can't connect to uplink ${ssid} (${cnt}/${trm_maxretry}, ${sysver})"
                            fi
                        fi
                    done
                else
                    f_log "info " "status  ::: empty uplink list (${cnt}/${trm_maxretry}, ${sysver})"
                fi
                cnt=$((cnt+1))
                sleep 5
            done
        done
        f_log "info " "status  ::: no wwan uplink found (${sysver})"
    else
        f_log "info " "status  ::: wwan uplink still connected (${sysver})"
    fi
}

if [ "${trm_procd}" = "true" ]
then
    f_envload
    f_main
fi
exit 0
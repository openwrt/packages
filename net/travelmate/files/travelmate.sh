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
trm_ver="0.4.1"
trm_sysver="$(ubus -S call system board | jsonfilter -e '@.release.description')"
trm_enabled=1
trm_debug=0
trm_active=0
trm_maxwait=20
trm_maxretry=3
trm_timeout=60
trm_iw=1

# f_envload: load travelmate environment
#
f_envload()
{
    # source required system libraries
    #
    if [ -r "/lib/functions.sh" ]
    then
        . "/lib/functions.sh"
    else
        f_log "error" "required system library not found"
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
        f_log "info " "travelmate is currently disabled, please set 'trm_enabled' to '1' to use this service"
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
        f_log "error" "no wireless tool for wlan scanning found, please install 'iw' or 'iwinfo'"
    fi
}

# f_prepare: gather radio information & bring down all STA interfaces
#
f_prepare()
{
    local config="${1}"
    local mode="$(uci -q get wireless."${config}".mode)"
    local radio="$(uci -q get wireless."${config}".device)"
    local disabled="$(uci -q get wireless."${config}".disabled)"

    if [ "${mode}" = "ap" ] && ([ -z "${disabled}" ] || [ "${disabled}" = "0" ]) && \
        ([ -z "${trm_radio}" ] || [ "${trm_radio}" = "${radio}" ])
    then
        trm_radiolist="${trm_radiolist} ${radio}"
    elif [ "${mode}" = "sta" ]
    then
        trm_stalist="${trm_stalist} ${config}_${radio}"
        if [ -z "${disabled}" ] || [ "${disabled}" = "0" ]
        then
            uci -q set wireless."${config}".disabled=1
        fi
    fi
    f_log "debug" "mode: ${mode}, radio: ${radio}, config: ${config}, disabled: ${disabled}"
}

# f_check: check interface status
#
f_check()
{
    local ifname radio cnt=1 mode="${1}"
    trm_ifstatus="false"

    while [ ${cnt} -le ${trm_maxwait} ]
    do
        if [ "${mode}" = "ap" ]
        then
            for radio in ${trm_radiolist}
            do
                trm_ifstatus="$(ubus -S call network.wireless status | jsonfilter -e "@.${radio}.up")"
                if [ "${trm_ifstatus}" = "true" ]
                then
                    trm_aplist="${trm_aplist} $(ubus -S call network.wireless status | jsonfilter -e "@.${radio}.interfaces[@.config.mode=\"ap\"].ifname")_${radio}"
                    ifname="${trm_aplist}"
                else
                    trm_aplist=""
                    trm_ifstatus="false"
                    break
                fi
            done
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
    f_log "debug" "mode: ${mode}, name: ${ifname}, status: ${trm_ifstatus}, count: ${cnt}, max-wait: ${trm_maxwait}"
}

# f_active: keep travelmate in an active state
#
f_active()
{
    if [ ${trm_active} -eq 1 ]
    then
        (sleep ${trm_timeout}; /etc/init.d/travelmate start >/dev/null 2>&1) &
    fi
}

# f_log: function to write to syslog
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
            logger -t "travelmate-[${trm_ver}] ${class}" "Please check the readme 'https://github.com/openwrt/packages/blob/master/net/travelmate/files/README.md' (${trm_sysver})"
            f_active
            exit 255
        fi
    fi
}

# f_main: main function for connection handling
#
f_main()
{
    local ssid_list config ap_radio sta_radio ssid cnt=1

    f_check "initial"
    if [ "${trm_ifstatus}" != "true" ]
    then
        f_log "info " "start travelmate scanning ..."
        config_load wireless
        config_foreach f_prepare wifi-iface
        if [ -n "$(uci -q changes wireless)" ]
        then
            uci -q commit wireless
            ubus call network reload
        fi
        f_check "ap"
        f_log "debug" "ap-list: ${trm_aplist}, sta-list: ${trm_stalist}"
        if [ -z "${trm_aplist}" ] || [ -z "${trm_stalist}" ]
        then
            f_log "error" "no usable AP/STA configuration found"
        fi
        for ap in ${trm_aplist}
        do
            cnt=1
            ap_radio="${ap##*_}"
            ap="${ap%%_*}"
            if [ -z "$(printf "${trm_stalist}" | grep -Fo "_${ap_radio}")" ]
            then
                continue
            fi
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
                f_log "debug" "scanner: ${trm_scanner}, ap: ${ap}, ssids: ${ssid_list}"
                if [ -n "${ssid_list}" ]
                then
                    for sta in ${trm_stalist}
                    do
                        config="${sta%%_*}"
                        sta_radio="${sta##*_}"
                        ssid="\"$(uci -q get wireless."${config}".ssid)\""
                        if [ -n "$(printf "${ssid_list}" | grep -Fo "${ssid}")" ] && [ "${ap_radio}" = "${sta_radio}" ]
                        then
                            uci -q set wireless."${config}".disabled=0
                            uci -q commit wireless
                            ubus call network reload
                            f_check "sta"
                            if [ "${trm_ifstatus}" = "true" ]
                            then
                                f_log "info " "wwan interface connected to uplink ${ssid} (${cnt}/${trm_maxretry}, ${trm_sysver})"
                                sleep 5
                                return 0
                            else
                                uci -q set wireless."${config}".disabled=1
                                uci -q commit wireless
                                ubus call network reload
                                f_log "info " "wwan interface can't connect to uplink ${ssid} (${cnt}/${trm_maxretry}, ${trm_sysver})"
                            fi
                        fi
                    done
                else
                    f_log "info " "empty uplink list (${cnt}/${trm_maxretry}, ${trm_sysver})"
                fi
                cnt=$((cnt+1))
                sleep 5
            done
        done
        f_log "info " "no wwan uplink found (${trm_sysver})"
    fi
}

f_envload
f_main
f_active
exit 0

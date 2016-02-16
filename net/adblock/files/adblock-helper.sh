#!/bin/sh
#################################################
# function library used by adblock-update.sh    #
# written by Dirk Brenken (openwrt@brenken.org) #
#################################################

#####################################
# f_envload: load adblock environment
#
f_envload()
{
    local cfg_version

    # get version string from default adblock configuration file
    #
    cfg_version="$(/sbin/uci -q get adblock.global.adb_cfgver 2>/dev/null)"
    cfg_enabled="$(/sbin/uci -q get adblock.global.adb_enabled 2>/dev/null)"
    rc=$?
    if [ $((rc)) -ne 0 ] || [ "${cfg_version}" != "${adb_scriptver%.*}" ]
    then
        cp -pf "/etc/adblock/adblock.conf.default" "/etc/config/adblock" >/dev/null 2>&1
        rc=$?
        if [ $((rc)) -eq 0 ]
        then
            f_log "new default adblock configuration applied, please check your settings in '/etc/config/adblock'"
        else
            f_log "original adblock configuration not found, please (re-)install the adblock package via 'opkg install adblock --force-maintainer'" "${rc}"
            f_exit
        fi
    elif [ $((rc)) -eq 0 ] && [ $((cfg_enabled)) -ne 1 ]
    then
        rc=-1
        f_log "adblock is currently disabled, please run 'uci set adblock.global.adb_enabled=1' and 'uci commit adblock' to enable this service"
        f_exit
    fi

    # source in openwrt function library
    #
    if [ -r "/lib/functions.sh" ]
    then
        . "/lib/functions.sh" 2>/dev/null
    else
        rc=110
        f_log "openwrt function library not found" "${rc}"
        f_exit
    fi

    # source in openwrt network library
    #
    if [ -r "/lib/functions/network.sh" ]
    then
        . "/lib/functions/network.sh" 2>/dev/null
    else
        rc=115
        f_log "openwrt network library not found" "${rc}"
        f_exit
    fi

    # check opkg availability and get list with all installed openwrt packages
    #
    if [ -r "/var/lock/opkg.lock" ]
    then
        rc=-1
        f_log "adblock installation finished, 'opkg' currently locked by package installer"
        f_exit
    fi
    pkg_list="$(opkg list-installed 2>/dev/null)"
    if [ -z "${pkg_list}" ]
    then
        rc=120
        f_log "empty openwrt package list" "${rc}"
        f_exit
    fi
}

######################################################
# f_envparse: parse adblock config and set environment
#
f_envparse()
{
    # set initial defaults,
    # may be overwritten by setting appropriate adblock config options in global section of /etc/config/adblock
    #
    adb_wanif="wan"
    adb_lanif="lan"
    adb_port="65535"
    adb_nullipv4="192.0.2.1"
    adb_nullipv6="::ffff:c000:0201"
    adb_maxtime="60"
    adb_maxloop="20"
    adb_blacklist="/etc/adblock/adblock.blacklist"
    adb_whitelist="/etc/adblock/adblock.whitelist"

    # function to read/set global options by callback,
    # prepare list items and build option list for all others
    #
    config_cb()
    {
        local type="${1}"
        local name="${2}"
        if [ "${type}" = "adblock" ]
        then
            option_cb()
            {
                local option="${1}"
                local value="${2}"
                eval "${option}=\"${value}\""
            }
        else
            option_cb()
            {
                local option="${1}"
                local value="${2}"
                local opt_out="$(printf "${option}" | sed -n '/.*_ITEM[0-9]$/p; /.*_LENGTH$/p; /enabled/p' 2>/dev/null)"
                if [ -z "${opt_out}" ]
                then
                    all_options="${all_options} ${option}"
                fi
            }
            list_cb()
            {
                local list="${1}"
                local value="${2}"
                if [ "${list}" = "adb_catlist" ]
                then
                    adb_cat_shalla="${adb_cat_shalla} ${value}"
                fi
            }
        fi
    }

    # function to iterate through option list, read/set all options in "enabled" sections
    #
    parse_config()
    {
        local config="${1}"
        config_get switch "${config}" "enabled"
        if [ "${switch}" = "1" ]
        then
            for option in ${all_options}
            do
                config_get value "${config}" "${option}"
                if [ -n "${value}" ]
                then
                    local opt_src="$(printf "${option}" | sed -n '/^adb_src_[a-z0-9]*$/p' 2>/dev/null)"
                    if [ -n "${opt_src}" ]
                    then
                        adb_sources="${adb_sources} ${value}"
                    else
                        eval "${option}=\"${value}\""
                    fi
                fi
            done
        fi
    }

    # load adblock config and start parsing functions
    #
    config_load adblock
    config_foreach parse_config service
    config_foreach parse_config source

    # set more script defaults (can't be overwritten by adblock config options)
    #
    adb_cnt=0
    adb_minspace=20000
    adb_unique=1
    adb_tmpfile="$(mktemp -tu 2>/dev/null)"
    adb_tmpdir="$(mktemp -p /tmp -d 2>/dev/null)"
    adb_dnsdir="/tmp/dnsmasq.d"
    adb_dnsprefix="adb_list"
    adb_prechain_ipv4="prerouting_rule"
    adb_fwdchain_ipv4="forwarding_rule"
    adb_outchain_ipv4="output_rule"
    adb_prechain_ipv6="PREROUTING"
    adb_fwdchain_ipv6="forwarding_rule"
    adb_outchain_ipv6="output_rule"
    adb_fetch="/usr/bin/wget"
    unset adb_srclist
    unset adb_revsrclist
    unset adb_errsrclist

    # set adblock source ruleset definitions
    #
    rset_start="sed -r 's/[[:space:]]|[\[!#/:;_].*|[0-9\.]*localhost.*//g; s/[\^#/:;_\.\t ]*$//g'"
    rset_end="tr -cd '[0-9a-z\.\-]\n' | sed -r 's/^[ \.\-].*$|^[a-z0-9]*[ \.\-]*$//g; /^[#/:;_\s]*$/d'"
    rset_adaway="${rset_start} | sed 's/\([0-9]\{1,3\}\.\)\{3\}[0-1]\{1,1\}//g' | ${rset_end}"
    rset_blacklist="${rset_start} | ${rset_end}"
    rset_disconnect="${rset_start} | ${rset_end}"
    rset_dshield="${rset_start} | ${rset_end}"
    rset_feodo="${rset_start} | ${rset_end}"
    rset_malware="${rset_start} | ${rset_end}"
    rset_malwarelist="${rset_start} | sed 's/\([0-9]\{1,3\}\.\)\{3\}[0-1]\{1,1\}//g' | ${rset_end}"
    rset_openphish="sed -e 's|^[^/]*//||' -e 's|/.*$||'"
    rset_palevo="${rset_start} | ${rset_end}"
    rset_ruadlist="sed -e '/^\|\|/! s/.*//; /\^$/! s/.*//; s/\^$//g; /[\.]/! s/.*//; s/^[\|]\{1,2\}//g' | ${rset_end}"
    rset_shalla="${rset_start} | sed 's/\([0-9]\{1,3\}\.\)\{3\}[0-9]\{1,3\}$//g' | ${rset_end}"
    rset_spam404="${rset_start} | sed 's/^\|\|//g' | ${rset_end}"
    rset_whocares="${rset_start} | sed 's/\([0-9]\{1,3\}\.\)\{3\}[0-1]\{1,1\}//g' | ${rset_end}"
    rset_winhelp="${rset_start} | sed 's/\([0-9]\{1,3\}\.\)\{3\}[0-1]\{1,1\}//g' | ${rset_end}"
    rset_yoyo="${rset_start} | sed 's/,/\n/g' | ${rset_end}"
    rset_zeus="${rset_start} | ${rset_end}"

    # get logical wan update interfaces (with default route) and their device names
    #
    while [ $((adb_cnt)) -le $((adb_maxloop)) ]
    do
        network_find_wan adb_wanif4 2>/dev/null
        network_find_wan6 adb_wanif6 2>/dev/null
        if [ -z "${adb_wanif4}" ] && [ -z "${adb_wanif6}" ]
        then
            network_flush_cache
        elif [ "${adb_wanif4}" = "${adb_lanif}" ] || [ "${adb_wanif6}" = "${adb_lanif}" ]
        then
            rc=125
            f_log "LAN only (${adb_lanif}) network, no valid IPv4/IPv6 wan update interface found" "${rc}"
            f_exit
        else
            network_get_device adb_wandev4 "${adb_wanif4}" 2>/dev/null
            network_get_device adb_wandev6 "${adb_wanif6}" 2>/dev/null
            break
        fi
        if [ $((adb_cnt)) -ge $((adb_maxloop)) ]
        then
            rc=125
            f_log "no valid IPv4/IPv6 wan update interface found" "${rc}"
            f_exit
        fi
        adb_cnt=$((adb_cnt + 1))
        sleep 1
    done

    # get lan ip addresses
    #
    network_get_ipaddr adb_ipv4 "${adb_lanif}" 2>/dev/null
    network_get_ipaddr6 adb_ipv6 "${adb_lanif}" 2>/dev/null
    if [ -z "${adb_ipv4}" ] && [ -z "${adb_ipv6}" ]
    then
        rc=130
        f_log "no valid IPv4/IPv6 configuration for given logical LAN interface found (${adb_lanif}), please set 'adb_lanif' manually" "${rc}"
        f_exit
    fi

    # read system ntp server names
    #
    adb_ntpsrv="$(uci get system.ntp.server 2>/dev/null)"
}

#################################################
# f_envcheck: check/set environment prerequisites
#
f_envcheck()
{
    local check

    # check general package dependencies
    #
    f_depend "uhttpd"
    f_depend "wget"
    f_depend "iptables"
    f_depend "kmod-ipt-nat"

    # check ipv6 related package dependencies
    #
    if [ -n "${adb_wanif6}" ]
    then
        check="$(printf "${pkg_list}" | grep "^ip6tables -" 2>/dev/null)"
        if [ -z "${check}" ]
        then
            f_log "package 'ip6tables' not found, IPv6 support wíll be disabled"
            unset adb_wanif6
        else
            check="$(printf "${pkg_list}" | grep "^kmod-ipt-nat6 -" 2>/dev/null)"
            if [ -z "${check}" ]
            then
                f_log "package 'kmod-ipt-nat6' not found, IPv6 support wíll be disabled"
                unset adb_wanif6
            fi
        fi
    fi

    # check ca-certificates package and set wget parms accordingly
    #
    check="$(printf "${pkg_list}" | grep "^ca-certificates -" 2>/dev/null)"
    if [ -z "${check}" ]
    then
        wget_parm="--no-config --no-check-certificate --quiet --tries=1 --no-cache --no-cookies --max-redirect=0 --dns-timeout=5"
    else
        wget_parm="--no-config --quiet --tries=1 --no-cache --no-cookies --max-redirect=0 --dns-timeout=5"
    fi

    # check adblock blacklist/whitelist configuration
    #
    if [ ! -r "${adb_blacklist}" ]
    then
        rc=135
        f_log "adblock blacklist not found (${adb_blacklist})" "${rc}"
        f_exit
    elif [ ! -r "${adb_whitelist}" ]
    then
        rc=135
        f_log "adblock whitelist not found (${adb_whitelist})" "${rc}"
        f_exit
    fi

    # check adblock temp directory
    #
    if [ -n "${adb_tmpdir}" ] && [ -d "${adb_tmpdir}" ]
    then
        f_space "${adb_tmpdir}"
        if [ "${space_ok}" = "false" ]
        then
            rc=140
            f_log "not enough space in '${adb_tmpdir}', please supersize your temp directory" "${rc}"
            f_exit
        fi
    else
        rc=140
        f_log "temp directory not found" "${rc}"
        f_exit
    fi

    # check total and swap memory
    #
    mem_total="$(grep -F "MemTotal" "/proc/meminfo" 2>/dev/null | grep -o "[0-9]*" 2>/dev/null)"
    mem_free="$(grep -F "MemFree" "/proc/meminfo" 2>/dev/null | grep -o "[0-9]*" 2>/dev/null)"
    swap_total="$(grep -F "SwapTotal" "/proc/meminfo" 2>/dev/null | grep -o "[0-9]*" 2>/dev/null)"
    if [ $((mem_total)) -le 64000 ] && [ $((swap_total)) -eq 0 ]
    then
        adb_unique=0
        f_log "not enough memory, overall sort/unique processing will be disabled"
        f_log "please consider adding an external swap device to supersize your temp directory (total: ${mem_total}, free: ${mem_free}, swap: ${mem_swap})"
    fi

    # check backup configuration
    #
    if [ -n "${adb_backupdir}" ] && [ -d "${adb_backupdir}" ]
    then
        f_space "${adb_backupdir}"
        if [ "${space_ok}" = "false" ]
        then
            f_log "not enough space in '${adb_backupdir}', backup/restore will be disabled"
            backup_ok="false"
        else
            f_log "backup/restore will be enabled"
            backup_ok="true"
        fi
    else
        backup_ok="false"
        f_log "backup/restore will be disabled"
    fi

    # check log configuration
    #
    adb_logdir="${adb_logfile%/*}"
    if [ -n "${adb_logdir}" ] && [ -d "${adb_logdir}" ]
    then
        f_space "${adb_logdir}"
        if [ "${space_ok}" = "false" ]
        then
            f_log "not enough space in '${adb_logdir}', logging will be disabled"
            log_ok="false"
        else
            f_log "logging will be enabled"
            log_ok="true"
        fi
    else
        log_ok="false"
        f_log "logging will be disabled"
    fi

    # check ipv4/iptables configuration
    #
    if [ -n "${adb_wanif4}" ] && [ -n "${adb_wandev4}" ]
    then
        f_firewall "IPv4" "nat" "A" "${adb_prechain_ipv4}" "adb-prerouting" "! -i ${adb_wandev4} -p tcp -d ${adb_nullipv4} -m multiport --dports 80,443 -j REDIRECT --to-ports ${adb_port}"
        f_firewall "IPv4" "nat" "A" "${adb_prechain_ipv4}" "adb-dns" "! -i ${adb_wandev4} -p udp --dport 53 -j REDIRECT"
        f_firewall "IPv4" "nat" "A" "${adb_prechain_ipv4}" "adb-dns" "! -i ${adb_wandev4} -p tcp --dport 53 -j REDIRECT"
        f_firewall "IPv4" "filter" "A" "${adb_fwdchain_ipv4}" "adb-forward" "! -i ${adb_wandev4} -p udp -d ${adb_nullipv4} -j REJECT --reject-with icmp-port-unreachable"
        f_firewall "IPv4" "filter" "A" "${adb_fwdchain_ipv4}" "adb-forward" "! -i ${adb_wandev4} -p tcp -d ${adb_nullipv4} -j REJECT --reject-with tcp-reset"
        f_firewall "IPv4" "filter" "A" "${adb_fwdchain_ipv4}" "adb-forward" "! -i ${adb_wandev4} -d ${adb_nullipv4} -j REJECT --reject-with icmp-proto-unreachable"
        f_firewall "IPv4" "filter" "A" "${adb_outchain_ipv4}" "adb-output" "! -i ${adb_wandev4} -p udp -d ${adb_nullipv4} -j REJECT --reject-with icmp-port-unreachable"
        f_firewall "IPv4" "filter" "A" "${adb_outchain_ipv4}" "adb-output" "! -i ${adb_wandev4} -p tcp -d ${adb_nullipv4} -j REJECT --reject-with tcp-reset"
        f_firewall "IPv4" "filter" "A" "${adb_outchain_ipv4}" "adb-output" "! -i ${adb_wandev4} -d ${adb_nullipv4} -j REJECT --reject-with icmp-proto-unreachable"
        if [ "${fw_done}" = "true" ]
        then
            f_log "created volatile IPv4 firewall ruleset"
            fw_done="false"
        fi
    fi

    # check ipv6/ip6tables configuration
    #
    if [ -n "${adb_wanif6}" ] && [ -n "${adb_wandev6}" ]
    then
        f_firewall "IPv6" "nat" "A" "${adb_prechain_ipv6}" "adb-prerouting" "! -i ${adb_wandev6} -p tcp -d ${adb_nullipv6} -m multiport --dports 80,443 -j REDIRECT --to-ports ${adb_port}"
        f_firewall "IPv6" "nat" "A" "${adb_prechain_ipv6}" "adb-dns" "! -i ${adb_wandev6} -p udp --dport 53 -j REDIRECT"
        f_firewall "IPv6" "nat" "A" "${adb_prechain_ipv6}" "adb-dns" "! -i ${adb_wandev6} -p tcp --dport 53 -j REDIRECT"
        f_firewall "IPv6" "filter" "A" "${adb_fwdchain_ipv6}" "adb-forward" "! -i ${adb_wandev6} -p udp -d ${adb_nullipv6} -j REJECT --reject-with icmp-port-unreachable"
        f_firewall "IPv6" "filter" "A" "${adb_fwdchain_ipv6}" "adb-forward" "! -i ${adb_wandev6} -p tcp -d ${adb_nullipv6} -j REJECT --reject-with tcp-reset"
        f_firewall "IPv6" "filter" "A" "${adb_fwdchain_ipv6}" "adb-forward" "! -i ${adb_wandev6} -d ${adb_nullipv6} -j REJECT --reject-with icmp-proto-unreachable"
        f_firewall "IPv6" "filter" "A" "${adb_outchain_ipv6}" "adb-output" "! -i ${adb_wandev6} -p udp -d ${adb_nullipv6} -j REJECT --reject-with icmp-port-unreachable"
        f_firewall "IPv6" "filter" "A" "${adb_outchain_ipv6}" "adb-output" "! -i ${adb_wandev6} -p tcp -d ${adb_nullipv6} -j REJECT --reject-with tcp-reset"
        f_firewall "IPv6" "filter" "A" "${adb_outchain_ipv6}" "adb-output" "! -i ${adb_wandev6} -d ${adb_nullipv6} -j REJECT --reject-with icmp-proto-unreachable"
        if [ "${fw_done}" = "true" ]
        then
            f_log "created volatile IPv6 firewall ruleset"
            fw_done="false"
        fi
    fi

    # check volatile adblock uhttpd instance configuration
    #
    rc="$(ps | grep "[u]httpd.*\-h /www/adblock" >/dev/null 2>&1; printf ${?})"
    if [ $((rc)) -ne 0 ]
    then
        if [ -n "${adb_wanif4}" ] && [ -n "${adb_wanif6}" ]
        then
            uhttpd -h "/www/adblock" -k 5 -N 200 -t 0 -T 1 -D -S -E "/adblock.html" -p "${adb_ipv4}:${adb_port}" -p "[${adb_ipv6}]:${adb_port}">/dev/null 2>&1
            rc=${?}
            if [ $((rc)) -eq 0 ]
            then
                f_log "created volatile uhttpd instance (${adb_ipv4}:${adb_port}, [${adb_ipv6}]:${adb_port})"
            else
                f_log "failed to initialize volatile uhttpd instance (${adb_ipv4}:${adb_port}, [${adb_ipv6}]:${adb_port})" "${rc}"
                f_restore
            fi
        elif [ -n "${adb_wanif4}" ]
        then
            uhttpd -h "/www/adblock" -k 5 -N 200 -t 0 -T 1 -D -S -E "/adblock.html" -p "${adb_ipv4}:${adb_port}" >/dev/null 2>&1
            rc=${?}
            if [ $((rc)) -eq 0 ]
            then
                f_log "created volatile uhttpd instance (${adb_ipv4}:${adb_port})"
            else
                f_log "failed to initialize volatile uhttpd instance (${adb_ipv4}:${adb_port})" "${rc}"
                f_restore
            fi
        elif [ -n "${adb_wanif6}" ]
        then
            uhttpd -h "/www/adblock" -k 5 -N 200 -t 0 -T 1 -D -S -E "/adblock.html" -p "[${adb_ipv6}]:${adb_port}" >/dev/null 2>&1
            rc=${?}
            if [ $((rc)) -eq 0 ]
            then
                f_log "created volatile uhttpd instance ([${adb_ipv6}]:${adb_port})"
            else
                f_log "failed to initialize volatile uhttpd instance ([${adb_ipv6}]:${adb_port})" "${rc}"
                f_restore
            fi
        fi
    fi

    # wait for active wan update interface
    #
    while [ $((adb_cnt)) -le $((adb_maxloop)) ]
    do
        for interface in ${adb_wanif}
        do
            network_get_device adb_wandev "${interface}" 2>/dev/null
            if [ -z "${adb_wandev}" ] || [ ! -d "/sys/class/net/${adb_wandev}" ]
            then
                if [ -n "${adb_wandev4}" ]
                then
                    adb_wandev="${adb_wandev4}"
                else
                    adb_wandev="${adb_wandev6}"
                fi
                if [ -z "${adb_wandev}" ] || [ ! -d "/sys/class/net/${adb_wandev}" ]
                then
                    rc=145
                    f_log "no valid network device for given logical WAN interface found, please set 'adb_wanif' manually" "${rc}"
                    f_restore
                fi
            fi
            check="$(cat /sys/class/net/${adb_wandev}/operstate 2>/dev/null)"
            if [ "${check}" = "up" ]
            then
                f_log "get active wan update interface/device (${adb_wanif}/${adb_wandev})"
                break 2
            elif [ $((adb_cnt)) -eq $((adb_maxloop)) ]
            then
                rc=145
                f_log "wan update interface/device not running (${adb_wanif}/${adb_wandev})" "${rc}"
                f_restore
            fi
            adb_cnt=$((adb_cnt + 1))
            sleep 1
        done
    done

    # ntp time sync
    #
    if [ -n "${adb_ntpsrv}" ]
    then
        unset ntp_pool
        for srv in ${adb_ntpsrv}
        do
            ntp_pool="${ntp_pool} -p ${srv}"
        done
        /usr/sbin/ntpd -nq ${ntp_pool} >/dev/null 2>&1
        rc=${?}
        if [ $((rc)) -eq 0 ]
        then
            f_log "get ntp time sync"
        else
            rc=0
            f_log "ntp time sync failed"
        fi
    fi

    # set dnsmasq defaults
    #
    if [ -n "${adb_wanif4}" ] && [ -n "${adb_wanif6}" ]
    then
        adb_dnsformat="awk -v ipv4="${adb_nullipv4}" -v ipv6="${adb_nullipv6}" '{print \"address=/\"\$0\"/\"ipv4\"\n\"\"address=/\"\$0\"/\"ipv6}'"
    elif [ -n "${adb_wanif4}" ]
    then
        adb_dnsformat="awk -v ipv4="${adb_nullipv4}" '{print \"address=/\"\$0\"/\"ipv4}'"
    elif [ -n "${adb_wanif6}" ]
    then
        adb_dnsformat="awk -v ipv6="${adb_nullipv6}" '{print \"address=/\"\$0\"/\"ipv6}'"
    fi

    # remove no longer used opkg package list
    #
    unset pkg_list
}

######################################
# f_depend: check package dependencies
#
f_depend()
{
    local package="${1}"

    check="$(printf "${pkg_list}" | grep "^${package} -" 2>/dev/null)"
    if [ -z "${check}" ]
    then
        rc=150
        f_log "package '${package}' not found" "${rc}"
        f_exit
    fi
}

##############################################
# f_firewall: set iptables rules for ipv4/ipv6
#
f_firewall()
{
    local ipt
    local iptv4="/usr/sbin/iptables"
    local iptv6="/usr/sbin/ip6tables"
    local proto="${1}"
    local table="${2}"
    local ctype="${3}"
    local chain="${4}"
    local notes="${5}"
    local rules="${6}"

    # select appropriate iptables executable
    #
    if [ "${proto}" = "IPv4" ]
    then
        ipt="${iptv4}"
    else
        ipt="${iptv6}"
    fi

    # check whether iptables rule already applied and proceed accordingly
    #
    rc="$("${ipt}" -w -t "${table}" -C "${chain}" -m comment --comment "${notes}" ${rules}  >/dev/null 2>&1; printf ${?})"
    if [ $((rc)) -ne 0 ]
    then
        "${ipt}" -w -t "${table}" -"${ctype}" "${chain}" -m comment --comment "${notes}" ${rules} >/dev/null 2>&1
        rc=${?}
        if [ $((rc)) -eq 0 ]
        then
            fw_done="true"
        else
            f_log "failed to initialize volatile ${proto} firewall rule '${notes}'" "${rc}"
            f_restore
        fi
    fi
}

###################################################
# f_log: log messages to stdout, syslog and logfile
#
f_log()
{
    local log_parm
    local log_msg="${1}"
    local log_rc="${2}"
    local class="info "

    # check for terminal session
    #
    if [ -t 1 ]
    then
        log_parm="-s"
    fi

    # log to different output devices, set log class accordingly
    #
    if [ -n "${log_msg}" ]
    then
        if [ $((log_rc)) -gt 0 ]
        then
            class="error"
            log_rc=", rc: ${log_rc}"
            log_msg="${log_msg}${log_rc}"
        fi
        /usr/bin/logger ${log_parm} -t "adblock[${adb_pid}] ${class}" "${log_msg}"
        if [ "${log_ok}" = "true" ]
        then
            printf "%s\n" "$(/bin/date "+%d.%m.%Y %H:%M:%S") adblock[${adb_pid}] ${class}: ${log_msg}" >> "${adb_logfile}"
        fi
    fi
}

################################################
# f_space: check mount points/space requirements
#
f_space()
{
    local mp="${1}"

    # check relevant mount points in a subshell
    #
    if [ -d "${mp}" ]
    then
        av_space="$(df "${mp}" 2>/dev/null | tail -n1 2>/dev/null | awk '{print $4}')"
        if [ $((av_space)) -lt $((adb_minspace)) ]
        then
            space_ok="false"
        fi
    fi
}

##################################################################
# f_restore: restore last adblock list backups and restart dnsmasq
#
f_restore()
{
    local rm_done
    local restore_done

    # remove bogus adblock lists
    #
    if [ -n "${adb_revsrclist}" ]
    then
        rm_done="$(find "${adb_dnsdir}" -maxdepth 1 -type f \( ${adb_revsrclist} \) -print -exec rm -f "{}" \; 2>/dev/null)"
        rc=${?}
        if [ $((rc)) -eq 0 ] && [ -n "${rm_done}" ]
        then
            f_log "all bogus adblock lists removed"
        elif [ $((rc)) -ne 0 ]
        then
            f_log "error during removal of bogus adblock lists" "${rc}"
            f_exit
        fi
    fi

    # restore backups
    #
    if [ "${backup_ok}" = "true" ] && [ "$(printf "${adb_backupdir}/${adb_dnsprefix}."*)" != "${adb_backupdir}/${adb_dnsprefix}.*" ]
    then
        restore_done="$(find "${adb_backupdir}" -maxdepth 1 -type f -name "${adb_dnsprefix}.*" -print -exec cp -pf "{}" "${adb_dnsdir}" \; 2>/dev/null)"
        rc=${?}
        if [ $((rc)) -eq 0 ] && [ -n "${restore_done}" ]
        then
            f_log "all available backups restored"
        elif [ $((rc)) -ne 0 ]
        then
            f_log "error during restore of adblock lists" "${rc}"
            f_exit
        fi
    else
        f_log "no backups found, nothing to restore"
    fi

    # (re-)try dnsmasq restart without bogus adblock lists / with backups 
    #
    if [ -n "${restore_done}" ] || [ -n "${rm_done}" ]
    then
        /etc/init.d/dnsmasq restart >/dev/null 2>&1
        sleep 2
        dns_status="$(ps 2>/dev/null | grep "[d]nsmasq" 2>/dev/null)"
        if [ -n "${dns_status}" ]
        then
            rc=0
            if [ -n "${adb_wanif4}" ] && [ -n "${adb_wanif6}" ]
            then
                adb_count="$(($(head -qn -4 "${adb_dnsdir}/${adb_dnsprefix}."* 2>/dev/null | wc -l) / 2))"
            else
                adb_count="$(head -qn -4 "${adb_dnsdir}/${adb_dnsprefix}."* 2>/dev/null | wc -l)"
            fi
            f_log "adblock lists with overall ${adb_count} domains loaded"
        else
            rc=160
            f_log "dnsmasq restart failed, please check 'logread' output" "${rc}"
        fi
    fi
    f_exit
}

###################################
# f_exit: delete (temporary) files,
# generate statistics and exit
#
f_exit()
{
    local ipv4_prerouting
    local ipv4_forward
    local ipv4_output
    local ipv6_prerouting
    local ipv6_forward
    local ipv6_output
    local iptv4="/usr/sbin/iptables"
    local iptv6="/usr/sbin/ip6tables"

    # delete temporary files & directories
    #
    if [ -f "${adb_tmpfile}" ]
    then
       rm -f "${adb_tmpfile}" >/dev/null 2>&1
    fi
    if [ -d "${adb_tmpdir}" ]
    then
       rm -rf "${adb_tmpdir}" >/dev/null 2>&1
    fi

    # final log message and iptables statistics
    #
    if [ $((rc)) -eq 0 ]
    then
        if [ -n "${adb_wanif4}" ]
        then
            ipv4_prerouting="$(${iptv4} -t nat -vnL | awk '$11 ~ /^adb-prerouting$/ {sum += $1} END {print sum}')"
            ipv4_forward="$(${iptv4} -vnL | awk '$11 ~ /^adb-forward$/ {sum += $1} END {print sum}')"
            ipv4_output="$(${iptv4} -vnL | awk '$11 ~ /^adb-output$/ {sum += $1} END {print sum}')"
        fi
        if [ -n "${adb_wanif6}" ]
        then
            ipv6_prerouting="$(${iptv6} -t nat -vnL | awk '$11 ~ /^adb-prerouting$/ {sum += $1} END {print sum}')"
            ipv6_forward="$(${iptv6} -vnL | awk '$11 ~ /^adb-forward$/ {sum += $1} END {print sum}')"
            ipv6_output="$(${iptv6} -vnL | awk '$11 ~ /^adb-output$/ {sum += $1} END {print sum}')"
        fi
        if [ -n "${adb_wanif4}" ] && [ -n "${adb_wanif6}" ]
        then
            f_log "adblock firewall statistics (IPv4/IPv6):"
            f_log "${ipv4_prerouting}/${ipv6_prerouting} packets redirected in PREROUTING chain"
            f_log "${ipv4_forward}/${ipv6_forward} packets rejected in FORWARD chain"
            f_log "${ipv4_output}/${ipv6_output} packets rejected in OUTPUT chain"
        elif [ -n "${adb_wanif4}" ]
        then
            f_log "adblock firewall statistics (IPv4):"
            f_log "${ipv4_prerouting} packets redirected in PREROUTING chain"
            f_log "${ipv4_forward} packets rejected in FORWARD chain"
            f_log "${ipv4_output} packets rejected in OUTPUT chain"
        elif [ -n "${adb_wanif6}" ]
        then
            f_log "${ipv6_prerouting} packets redirected in PREROUTING chain"
            f_log "${ipv6_forward} packets rejected in FORWARD chain"
            f_log "${ipv6_output} packets rejected in OUTPUT chain"
        fi
        f_log "domain adblock processing finished successfully (${adb_scriptver}, ${openwrt_version}, $(/bin/date "+%d.%m.%Y %H:%M:%S"))"
    elif [ $((rc)) -gt 0 ]
    then
        f_log "domain adblock processing failed (${adb_scriptver}, ${openwrt_version}, $(/bin/date "+%d.%m.%Y %H:%M:%S"))"
    else
        rc=0
    fi
    rm -f "${adb_pidfile}" >/dev/null 2>&1
    exit ${rc}
}

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

    # get list with all installed openwrt packages
    #
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
    # set the C locale, characters are single bytes, the charset is ASCII
    # speeds up sort, grep etc.
    #
    LC_ALL=C

    # set initial defaults,
    # may be overwritten by setting appropriate adblock config options in global section of /etc/config/adblock
    #
    adb_wanif="wan"
    adb_lanif="lan"
    adb_port="65535"
    adb_nullipv4="254.0.0.1"
    adb_nullipv6="::ffff:fe00:0001"
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
    adb_minspace="20000"
    adb_unique="1"
    adb_tmpfile="$(mktemp -tu 2>/dev/null)"
    adb_tmpdir="$(mktemp -p /tmp -d 2>/dev/null)"
    adb_dnsdir="/tmp/dnsmasq.d"
    adb_dnsprefix="adb_list"
    unset adb_srcfind
    unset adb_revsrcfind

    # set adblock source ruleset definitions
    #
    rset_start="sed -r 's/[[:space:]]|[\[!#/:;_].*|[0-9\.]*localhost.*//g; s/[\^#/:;_\.\t ]*$//g'"
    rset_end="sed '/^[#/:;_\s]*$/d'"
    rset_adaway="${rset_start} | sed 's/\([0-9]\{1,3\}\.\)\{3\}[0-1]\{1,1\}//g' | ${rset_end}"
    rset_blacklist="${rset_start} | ${rset_end}"
    rset_disconnect="${rset_start} | ${rset_end}"
    rset_dshield="${rset_start} | ${rset_end}"
    rset_feodo="${rset_start} | ${rset_end}"
    rset_malware="${rset_start} | ${rset_end}"
    rset_malwarelist="${rset_start} | sed 's/\([0-9]\{1,3\}\.\)\{3\}[0-1]\{1,1\}//g' | ${rset_end}"
    rset_palevo="${rset_start} | ${rset_end}"
    rset_shalla="${rset_start} | sed 's/\([0-9]\{1,3\}\.\)\{3\}[0-9]\{1,3\}$//g' | ${rset_end}"
    rset_spam404="${rset_start} | sed 's/^\|\|//g' | ${rset_end}"
    rset_whocares="${rset_start} | sed 's/\([0-9]\{1,3\}\.\)\{3\}[0-1]\{1,1\}//g' | ${rset_end}"
    rset_winhelp="${rset_start} | sed 's/\([0-9]\{1,3\}\.\)\{3\}[0-1]\{1,1\}//g' | ${rset_end}"
    rset_yoyo="${rset_start} | sed 's/,/\n/g' | ${rset_end}"
    rset_zeus="${rset_start} | ${rset_end}"

    # get logical wan update interfaces
    #
    network_find_wan adb_wanif4 2>/dev/null
    network_find_wan6 adb_wanif6 2>/dev/null
    if [ "${adb_wanif4}" = "${adb_lanif}" ] || [ "${adb_wanif6}" = "${adb_lanif}" ]
    then
        rc=125
        f_log "LAN only (${adb_lanif}) network, no valid IPv4/IPv6 wan update interface found" "${rc}"
        f_exit
    elif [ -z "${adb_wanif4}" ] && [ -z "${adb_wanif6}" ]
    then
        rc=125
        f_log "no valid IPv4/IPv6 wan update interface found" "${rc}"
        f_exit
    fi

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
    # check general package dependencies
    #
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
        wget_parm="--no-config --no-check-certificate --quiet"
    else
        wget_parm="--no-config --quiet"
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
        f_space "${adb_tmpdir}" "please supersize your /tmp directory"
        if [ "${space_ok}" = "false" ]
        then
            rc=140
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
        f_log "overall sort/unique processing will be disabled,"
        f_log "please consider adding an external swap device to supersize your /tmp directory (total: ${mem_total}, free: ${mem_free}, swap: ${mem_swap})"
    fi

    # check backup configuration
    #
    if [ -n "${adb_backupdir}" ] && [ -d "${adb_backupdir}" ]
    then
        f_space "${adb_backupdir}" "backup/restore will be disabled"
        if [ "${space_ok}" = "false" ]
        then
            backup_ok="false"
        else
            backup_ok="true"
        fi
    else
        backup_ok="false"
        f_log "backup/restore will be disabled"
    fi

    # check debug log configuration
    #
    adb_logdir="${adb_logfile%/*}"
    if [ -n "${adb_logdir}" ] && [ -d "${adb_logdir}" ]
    then
        f_space "${adb_logdir}" "debug logging will be disabled"
        if [ "${space_ok}" = "false" ]
        then
            log_ok="false"
        else
            log_ok="true"
        fi
    else
        log_ok="false"
        f_log "debug logging will be disabled"
    fi

    # check ipv4/iptables configuration
    #
    if [ -n "${adb_wanif4}" ]
    then
        f_firewall "IPv4" "nat" "I" "PREROUTING" "adb-nat: tcp, port 80, DNAT" "-p tcp -d ${adb_nullipv4} --dport 80 -j DNAT --to-destination ${adb_ipv4}:${adb_port}"
        f_firewall "IPv4" "nat" "A" "PREROUTING" "adb-dns: udp, port 53, DNAT" "-p udp --dport 53 -j DNAT --to-destination ${adb_ipv4}"
        f_firewall "IPv4" "nat" "A" "PREROUTING" "adb-dns: tcp, port 53, DNAT" "-p tcp --dport 53 -j DNAT --to-destination ${adb_ipv4}"
        f_firewall "IPv4" "filter" "I" "FORWARD" "adb-rej: all protocols, all ports, REJECT" "-d ${adb_nullipv4} -j REJECT"
    fi

    # check ipv6/ip6tables configuration
    #
    if [ -n "${adb_wanif6}" ]
    then
        f_firewall "IPv6" "nat" "I" "PREROUTING" "adb-nat: tcp, port 80, DNAT" "-p tcp -d ${adb_nullipv6} --dport 80 -j DNAT --to-destination [${adb_ipv6}]:${adb_port}"
        f_firewall "IPv6" "nat" "A" "PREROUTING" "adb-dns: udp, port 53, DNAT" "-p udp --dport 53 -j DNAT --to-destination ${adb_ipv6}"
        f_firewall "IPv6" "nat" "A" "PREROUTING" "adb-dns: tcp, port 53, DNAT" "-p tcp --dport 53 -j DNAT --to-destination ${adb_ipv6}"
        f_firewall "IPv6" "filter" "I" "FORWARD" "adb-rej: all protocols, all ports, REJECT" "-d ${adb_nullipv6} -j REJECT"
    fi

    # check volatile adblock uhttpd instance configuration
    #
    rc="$(ps | grep "[u]httpd.*\-h /www/adblock" >/dev/null 2>&1; printf ${?})"
    if [ $((rc)) -ne 0 ]
    then
        if [ -n "${adb_wanif4}" ] && [ -n "${adb_wanif6}" ]
        then
            uhttpd -h "/www/adblock" -k 0 -N 100 -T 5 -D -E "/adblock.html" -p "${adb_ipv4}:${adb_port}" -p "[${adb_ipv6}]:${adb_port}">/dev/null 2>&1
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
            uhttpd -h "/www/adblock" -k 0 -N 100 -T 5 -D -E "/adblock.html" -p "${adb_ipv4}:${adb_port}" >/dev/null 2>&1
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
            uhttpd -h "/www/adblock" -k 0 -N 100 -T 5 -D -E "/adblock.html" -p "[${adb_ipv6}]:${adb_port}" >/dev/null 2>&1
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
    cnt=0
    while [ $((cnt)) -le $((adb_maxloop)) ]
    do
        for interface in ${adb_wanif}
        do
            network_get_device adb_wandev "${interface}" 2>/dev/null
            if [ -z "${adb_wandev}" ] || [ ! -d "/sys/class/net/${adb_wandev}" ]
            then
                if [ -n "${adb_wanif4}" ]
                then
                    network_get_device adb_wandev "${adb_wanif4}" 2>/dev/null
                else
                    network_get_device adb_wandev "${adb_wanif6}" 2>/dev/null
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
                f_log "get active wan update interface/device (${adb_wanif}/${adb_wandev}) after ${cnt} loops"
                break 2
            elif [ $((cnt)) -eq $((adb_maxloop)) ]
            then
                rc=145
                f_log "wan update interface/device not running (${adb_wanif}/${adb_wandev}) after ${cnt} loops" "${rc}"
                f_restore
            fi
            cnt=$((cnt + 1))
            sleep 1
        done
    done

    # wait for ntp sync
    #
    if [ -n "${adb_ntpsrv}" ]
    then
        cnt=0
        unset ntp_pool
        for srv in ${adb_ntpsrv}
        do
            ntp_pool="${ntp_pool} -p ${srv}"
        done
        /usr/sbin/ntpd -nq ${ntp_pool} >/dev/null 2>&1
        rc=${?}
        if [ $((rc)) -eq 0 ]
        then
            ntp_ok="true"
            f_log "get ntp time sync"
        else
            rc=0
            ntp_ok="false"
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
    local rc_func
    local package="${1}"

    check="$(printf "${pkg_list}" | grep "^${package} -" 2>/dev/null)"
    if [ -z "${check}" ]
    then
        rc_func=150
        f_log "package '${package}' not found" "${rc_func}"
        f_exit
    fi
}

##############################################
# f_firewall: set iptables rules for ipv4/ipv6
#
f_firewall()
{
    local rc_func
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
    rc_func="$("${ipt}" -w -t "${table}" -C "${chain}" -m comment --comment "${notes}" ${rules}  >/dev/null 2>&1; printf ${?})"
    if [ $((rc_func)) -ne 0 ]
    then
        "${ipt}" -w -t "${table}" -"${ctype}" "${chain}" -m comment --comment "${notes}" ${rules} >/dev/null 2>&1
        rc_func=${?}
        if [ $((rc_func)) -eq 0 ]
        then
            f_log "created volatile ${proto} firewall rule in '${chain}' chain (${notes})"
        else
            f_log "failed to initialize volatile ${proto} firewall rule in '${chain}' chain (${notes})" "${rc_func}"
            f_restore
        fi
    fi
}

###################################################
# f_log: log messages to stdout, syslog and logfile
#
f_log()
{
    local log_msg="${1}"
    local log_rc="${2}"
    local class="info "

    # log to different output devices, set log class accordingly
    #
    if [ -n "${log_msg}" ]
    then
        if [ $((log_rc)) -ne 0 ]
        then
            class="error"
            log_rc=", rc: ${log_rc}"
            log_msg="${log_msg}${log_rc}"
        fi
        /usr/bin/logger -s -t "adblock[${pid}] ${class}" "${log_msg}"
        if [ "${log_ok}" = "true" ] && [ "${ntp_ok}" = "true" ]
        then
            printf "%s\n" "$(/bin/date "+%d.%m.%Y %H:%M:%S") adblock[${pid}] ${class}: ${log_msg}" >> "${adb_logfile}"
        fi
    fi
}

################################################
# f_space: check mount points/space requirements
#
f_space()
{
    local rc_func
    local mp="${1}"
    local notes="${2}"

    # check relevant mount points in a subshell
    #
    if [ -d "${mp}" ]
    then
        df "${mp}" 2>/dev/null |\
        tail -n1 2>/dev/null |\
        while read filesystem overall used available scrap
        do
            av_space="${available}"
            if [ $((av_space)) -eq 0 ]
            then
                rc_func=155
                f_log "no space left on device/not mounted (${mp}), ${notes}"
                exit ${rc_func}
            elif [ $((av_space)) -lt $((adb_minspace)) ]
            then
                rc_func=155
                f_log "not enough space left on device (${mp}), ${notes}"
                exit ${rc_func}
            fi
        done

        # subshell return code handling, set space trigger accordingly
        #
        rc_func=${?}
        if [ $((rc_func)) -ne 0 ]
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
    local rc_func
    local removal_done
    local restore_done

    # remove bogus adblock lists
    #
    if [ -n "${adb_revsrclist}" ]
    then
        find "${adb_dnsdir}" -maxdepth 1 -type f \( ${adb_revsrcfind} \) -exec rm -f "{}" \; 2>/dev/null
        rc_func=${?}
        if [ $((rc_func)) -ne 0 ]
        then
            f_log "error during removal of bogus adblock lists" "${rc_func}"
            f_exit
        else
            removal_done="true"
            f_log "all bogus adblock lists removed"
        fi
    fi

    # restore backups
    #
    if [ "${backup_ok}" = "true" ] && [ -d "${adb_backupdir}" ] && [ "$(printf "${adb_backupdir}/${adb_dnsprefix}."*)" != "${adb_backupdir}/${adb_dnsprefix}.*" ]
    then
        for file in ${adb_backupdir}/${adb_dnsprefix}.*
        do
            filename="${file##*/}"
            cp -pf "${file}" "${adb_dnsdir}" 2>/dev/null
            rc_func=${?}
            if [ $((rc_func)) -ne 0 ]
            then
                f_log "error during restore of adblock list (${filename})" "${rc_func}"
                f_exit
            fi
            restore_done="true"
        done
        f_log "all available backups restored"
    else
        f_log "no backups found, nothing to restore"
    fi

    # (re-)try dnsmasq restart without bogus adblock lists / with backups 
    #
    if [ "${restore_done}" = "true" ] || [ "${removal_done}" = "true" ]
    then
        /etc/init.d/dnsmasq restart >/dev/null 2>&1
        sleep 2
        dns_status="$(ps 2>/dev/null | grep "[d]nsmasq" 2>/dev/null)"
        if [ -n "${dns_status}" ]
        then
            rc=0
        else
            rc=160
            f_log "dnsmasq restart failed, please check 'logread' output" "${rc}"
            f_restore
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
    local ipv4_nat
    local ipv4_rej
    local ipv6_nat
    local ipv6_rej

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
        if [ -n "${adb_wanif4}" ] && [ -n "${adb_wanif6}" ]
        then
            ipv4_nat="$(iptables -t nat -vnL | grep -F "adb-nat" | grep -Eo "[0-9]+" | head -n1)"
            ipv4_rej="$(iptables -vnL | grep -F "adb-rej" | grep -Eo "[0-9]+" | head -n1)"
            ipv6_nat="$(ip6tables -t nat -vnL | grep -F "adb-nat" | grep -Eo "[0-9]+" | head -n1)"
            ipv6_rej="$(ip6tables -vnL | grep -F "adb-rej" | grep -Eo "[0-9]+" | head -n1)"
            f_log "adblock firewall statistics (IPv4/IPv6): ${ipv4_nat}/${ipv6_nat} packets redirected in PREROUTING chain, ${ipv4_rej}/${ipv6_rej} packets rejected in FORWARD chain"
        elif [ -n "${adb_wanif4}" ]
        then
            ipv4_nat="$(iptables -t nat -vnL | grep -F "adb-nat" | grep -Eo "[0-9]+" | head -n1)"
            ipv4_rej="$(iptables -vnL | grep -F "adb-rej" | grep -Eo "[0-9]+" | head -n1)"
            f_log "adblock firewall statistics (IPv4): ${ipv4_nat} packets redirected in PREROUTING chain, ${ipv4_rej} packets rejected in FORWARD chain"
        elif [ -n "${adb_wanif6}" ]
        then
            ipv6_nat="$(ip6tables -t nat -vnL | grep -F "adb-nat" | grep -Eo "[0-9]+" | head -n1)"
            ipv6_rej="$(ip6tables -vnL | grep -F "adb-rej" | grep -Eo "[0-9]+" | head -n1)"
            f_log "adblock firewall statistics (IPv6): ${ipv6_nat} packets redirected in PREROUTING chain, ${ipv6_rej} packets rejected in FORWARD chain"
        fi
        f_log "domain adblock processing finished successfully (${adb_version}, ${openwrt_version}, $(/bin/date "+%d.%m.%Y %H:%M:%S"))"
    else
        f_log "domain adblock processing failed (${adb_version}, ${openwrt_version}, $(/bin/date "+%d.%m.%Y %H:%M:%S"))"
    fi
    exit ${rc}
}

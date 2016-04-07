#!/bin/sh
# function library used by adblock-update.sh
# written by Dirk Brenken (openwrt@brenken.org)

#####################################
# f_envload: load adblock environment
#
f_envload()
{
    local cfg_version

    # get version string from default adblock configuration file
    #
    cfg_version="$(/sbin/uci -q get adblock.global.adb_cfgver)"
    cfg_enabled="$(/sbin/uci -q get adblock.global.adb_enabled)"
    rc=$?
    if [ $((rc)) -ne 0 ] || [ "${cfg_version}" != "${adb_scriptver%.*}" ]
    then
        cp -pf "/etc/adblock/adblock.conf.default" "/etc/config/adblock"
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
        . "/lib/functions.sh"
    else
        rc=110
        f_log "openwrt function library not found" "${rc}"
        f_exit
    fi

    # source in openwrt network library
    #
    if [ -r "/lib/functions/network.sh" ]
    then
        . "/lib/functions/network.sh"
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
    pkg_list="$(opkg list-installed)"
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
    adb_blacklist="/etc/adblock/adblock.blacklist"
    adb_whitelist="/etc/adblock/adblock.whitelist"
    adb_forcedns=1

    # function to read global options by callback
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
            reset_cb
        fi
    }

    # function to iterate through config list, read only options in "enabled" sections
    #
    adb_cfglist="adb_backupdir adb_src"
    unset adb_sources
    parse_config()
    {
        local config="${1}"
        config_get switch "${config}" "enabled"
        if [ "${switch}" = "1" ]
        then
            for option in ${adb_cfglist}
            do
                config_get value "${config}" "${option}"
                if [ -n "${value}" ]
                then
                    if [ "${option}" = "adb_src" ]
                    then
                        if [ "${config}" = "shalla" ]
                        then
                            categories()
                            {
                                local cat="${1}"
                                adb_cat_shalla="${adb_cat_shalla} ${cat}"
                            }
                            eval "adb_arc_shalla=\"${value}\""
                            config_list_foreach "shalla" "adb_catlist" "categories"
                        else
                            adb_sources="${adb_sources} ${value}"
                        fi
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
    adb_count=0
    adb_minspace=12000
    adb_tmpfile="$(mktemp -tu)"
    adb_tmpdir="$(mktemp -p /tmp -d)"
    adb_dnsdir="/tmp/dnsmasq.d"
    adb_dnsprefix="adb_list"
    adb_prechain_ipv4="prerouting_rule"
    adb_fwdchain_ipv4="forwarding_rule"
    adb_outchain_ipv4="output_rule"
    adb_prechain_ipv6="PREROUTING"
    adb_fwdchain_ipv6="forwarding_rule"
    adb_outchain_ipv6="output_rule"
    adb_fetch="/usr/bin/wget"
    unset adb_srclist adb_revsrclist adb_errsrclist

    # set adblock source ruleset definitions
    #
    rset_core="([A-Za-z0-9_-]+\.){1,}[A-Za-z]+"
    rset_adaway="awk '\$0 ~/^127\.0\.0\.1[ \t]+${rset_core}/{print tolower(\$2)}'"
    rset_blacklist="awk '\$1 ~/^${rset_core}/{print tolower(\$1)}'"
    rset_disconnect="awk '\$1 ~/^${rset_core}/{print tolower(\$1)}'"
    rset_dshield="awk '\$1 ~/^${rset_core}/{print tolower(\$1)}'"
    rset_feodo="awk '\$1 ~/^${rset_core}/{print tolower(\$1)}'"
    rset_malware="awk '\$1 ~/^${rset_core}/{print tolower(\$1)}'"
    rset_malwarelist="awk '\$0 ~/^127\.0\.0\.1[ \t]+${rset_core}/{print tolower(\$2)}'"
    rset_openphish="awk -F '/' '\$3 ~/^${rset_core}/{print tolower(\$3)}'"
    rset_palevo="awk '\$1 ~/^${rset_core}/{print tolower(\$1)}'"
    rset_ruadlist="awk -F '[|^]' '\$0 ~/^\|\|${rset_core}\^$/{print tolower(\$3)}'"
    rset_shalla="awk -F '/' '\$1 ~/^${rset_core}/{print tolower(\$1)}'"
    rset_spam404="awk '\$1 ~/^${rset_core}/{print tolower(\$1)}'"
    rset_sysctl="awk '\$0 ~/^127\.0\.0\.1[ \t]+${rset_core}/{print tolower(\$2)}'"
    rset_whocares="awk '\$0 ~/^127\.0\.0\.1[ \t]+${rset_core}/{print tolower(\$2)}'"
    rset_winhelp="awk '\$0 ~/^0\.0\.0\.0[ \t]+${rset_core}/{print tolower(\$2)}'"
    rset_yoyo="awk '\$1 ~/^${rset_core}/{print tolower(\$1)}'"
    rset_zeus="awk '\$1 ~/^${rset_core}/{print tolower(\$1)}'"

    # get logical wan update interfaces (with default route) and their device names
    #
    network_find_wan adb_wanif4
    network_find_wan6 adb_wanif6
    if [ -z "${adb_wanif4}" ] && [ -z "${adb_wanif6}" ]
    then
        rc=125
        f_log "no valid IPv4/IPv6 wan update interface found" "${rc}"
        f_exit
    elif [ "${adb_wanif4}" = "${adb_lanif}" ] || [ "${adb_wanif6}" = "${adb_lanif}" ]
    then
        rc=125
        f_log "LAN only (${adb_lanif}) network, no valid IPv4/IPv6 wan update interface found" "${rc}"
        f_exit
    else
        network_get_device adb_wandev4 "${adb_wanif4}"
        network_get_device adb_wandev6 "${adb_wanif6}"
    fi

    # get lan ip addresses
    #
    network_get_ipaddr adb_ipv4 "${adb_lanif}"
    network_get_ipaddr6 adb_ipv6 "${adb_lanif}"
    if [ -z "${adb_ipv4}" ] && [ -z "${adb_ipv6}" ]
    then
        rc=130
        f_log "no valid IPv4/IPv6 configuration for given logical LAN interface found (${adb_lanif}), please set 'adb_lanif' manually" "${rc}"
        f_exit
    fi
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
        check="$(printf "${pkg_list}" | grep "^ip6tables -")"
        if [ -z "${check}" ]
        then
            f_log "package 'ip6tables' not found, IPv6 support will be disabled"
            unset adb_wanif6
        else
            check="$(printf "${pkg_list}" | grep "^kmod-ipt-nat6 -")"
            if [ -z "${check}" ]
            then
                f_log "package 'kmod-ipt-nat6' not found, IPv6 support will be disabled"
                unset adb_wanif6
            fi
        fi
    fi

    # check ca-certificates package and set wget parms accordingly
    #
    wget_parm="--no-config --quiet --tries=1 --no-cache --no-cookies --max-redirect=0 --dns-timeout=5 --connect-timeout=5 --read-timeout=5"
    check="$(printf "${pkg_list}" | grep "^ca-certificates -")"
    if [ -z "${check}" ]
    then
        wget_parm="${wget_parm} --no-check-certificate"
    fi

    # check adblock blacklist/whitelist configuration
    #
    if [ ! -r "${adb_blacklist}" ]
    then
        f_log "adblock blacklist not found, source will be disabled"
    fi
    if [ ! -r "${adb_whitelist}" ]
    then
        f_log "adblock whitelist not found, source will be disabled"
    fi

    # check adblock temp directory
    #
    if [ -n "${adb_tmpdir}" ] && [ -d "${adb_tmpdir}" ]
    then
        f_space "${adb_tmpdir}"
        if [ "${space_ok}" = "false" ]
        then
            if [ $((av_space)) -le 2000 ]
            then
                rc=135
                f_log "not enough free space in '${adb_tmpdir}' (avail. ${av_space} kb)" "${rc}"
                f_exit
            else
                f_log "not enough free space to handle all adblock list sources at once in '${adb_tmpdir}' (avail. ${av_space} kb)"
            fi
        fi
    else
        rc=135
        f_log "temp directory not found" "${rc}"
        f_exit
    fi

    # memory check
    #
    mem_total="$(awk '$1 ~ /^MemTotal/ {printf $2}' "/proc/meminfo")"
    mem_free="$(awk '$1 ~ /^MemFree/ {printf $2}' "/proc/meminfo")"
    mem_swap="$(awk '$1 ~ /^SwapTotal/ {printf $2}' "/proc/meminfo")"
    if [ $((mem_total)) -le 64000 ] && [ $((mem_swap)) -eq 0 ]
    then
        mem_ok="false"
        f_log "not enough free memory, overall sort processing will be disabled (total: ${mem_total}, free: ${mem_free}, swap: ${mem_swap})"
    else
        mem_ok="true"
    fi

    # check backup configuration
    #
    if [ -n "${adb_backupdir}" ] && [ -d "${adb_backupdir}" ]
    then
        f_space "${adb_backupdir}"
        if [ "${space_ok}" = "false" ]
        then
            f_log "not enough free space in '${adb_backupdir}'(avail. ${av_space} kb), backup/restore will be disabled"
            backup_ok="false"
        else
            f_log "backup/restore will be enabled"
            backup_ok="true"
        fi
    else
        backup_ok="false"
        f_log "backup/restore will be disabled"
    fi

    # check ipv4/iptables configuration
    #
    if [ -n "${adb_wanif4}" ] && [ -n "${adb_wandev4}" ]
    then
        f_firewall "IPv4" "nat" "A" "${adb_prechain_ipv4}" "adb-prerouting" "! -i ${adb_wandev4} -p tcp -d ${adb_nullipv4} -m multiport --dports 80,443 -j REDIRECT --to-ports ${adb_port}"
        f_firewall "IPv4" "filter" "A" "${adb_fwdchain_ipv4}" "adb-forward" "! -i ${adb_wandev4} -d ${adb_nullipv4} -j REJECT --reject-with icmp-host-unreachable"
        f_firewall "IPv4" "filter" "A" "${adb_outchain_ipv4}" "adb-output" "! -i ${adb_wandev4} -d ${adb_nullipv4} -j REJECT --reject-with icmp-host-unreachable"
        if [ $((adb_forcedns)) -eq 1 ]
        then
            f_firewall "IPv4" "nat" "A" "${adb_prechain_ipv4}" "adb-dns" "! -i ${adb_wandev4} -p udp --dport 53 -j REDIRECT"
            f_firewall "IPv4" "nat" "A" "${adb_prechain_ipv4}" "adb-dns" "! -i ${adb_wandev4} -p tcp --dport 53 -j REDIRECT"
        fi
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
        f_firewall "IPv6" "filter" "A" "${adb_fwdchain_ipv6}" "adb-forward" "! -i ${adb_wandev6} -d ${adb_nullipv6} -j REJECT --reject-with icmp6-addr-unreachable"
        f_firewall "IPv6" "filter" "A" "${adb_outchain_ipv6}" "adb-output" "! -i ${adb_wandev6} -d ${adb_nullipv6} -j REJECT --reject-with icmp6-addr-unreachable"
        if [ $((adb_forcedns)) -eq 1 ]
        then
            f_firewall "IPv6" "nat" "A" "${adb_prechain_ipv6}" "adb-dns" "! -i ${adb_wandev6} -p udp --dport 53 -j REDIRECT"
            f_firewall "IPv6" "nat" "A" "${adb_prechain_ipv6}" "adb-dns" "! -i ${adb_wandev6} -p tcp --dport 53 -j REDIRECT"
        fi
        if [ "${fw_done}" = "true" ]
        then
            f_log "created volatile IPv6 firewall ruleset"
            fw_done="false"
        fi
    fi

    # check volatile adblock uhttpd instance configuration
    #
    rc="$(ps | grep -q "[u]httpd.*\-h /www/adblock"; printf ${?})"
    if [ $((rc)) -ne 0 ]
    then
        if [ -n "${adb_wanif4}" ] && [ -n "${adb_wanif6}" ]
        then
            uhttpd -h "/www/adblock" -k 5 -N 200 -t 0 -T 1 -D -S -E "/index.html" -p "${adb_ipv4}:${adb_port}" -p "[${adb_ipv6}]:${adb_port}"
            rc=${?}
        elif [ -n "${adb_wanif4}" ]
        then
            uhttpd -h "/www/adblock" -k 5 -N 200 -t 0 -T 1 -D -S -E "/index.html" -p "${adb_ipv4}:${adb_port}"
            rc=${?}
        elif [ -n "${adb_wanif6}" ]
        then
            uhttpd -h "/www/adblock" -k 5 -N 200 -t 0 -T 1 -D -S -E "/index.html" -p "[${adb_ipv6}]:${adb_port}"
            rc=${?}
        fi
        if [ $((rc)) -eq 0 ]
        then
            f_log "created volatile uhttpd instance"
        else
            f_log "failed to initialize volatile uhttpd instance" "${rc}"
            f_restore
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
    local check
    local package="${1}"

    check="$(printf "${pkg_list}" | grep "^${package} -")"
    if [ -z "${check}" ]
    then
        rc=140
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
    rc="$("${ipt}" -w -t "${table}" -C "${chain}" -m comment --comment "${notes}" ${rules}; printf ${?})"
    if [ $((rc)) -ne 0 ]
    then
        "${ipt}" -w -t "${table}" -"${ctype}" "${chain}" -m comment --comment "${notes}" ${rules}
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

##########################################
# f_log: log messages to stdout and syslog
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

    # log to different output devices and set log class accordingly
    #
    if [ -n "${log_msg}" ]
    then
        if [ $((log_rc)) -gt 0 ]
        then
            class="error"
            log_rc=", rc: ${log_rc}"
            log_msg="${log_msg}${log_rc}"
        fi
        /usr/bin/logger ${log_parm} -t "adblock[${adb_pid}] ${class}" "${log_msg}" 2>&1
    fi
}

################################################
# f_space: check mount points/space requirements
#
f_space()
{
    local mp="${1}"

    if [ -d "${mp}" ]
    then
        av_space="$(df "${mp}" | tail -n1 | awk '{printf $4}')"
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
        rm_done="$(find "${adb_dnsdir}" -maxdepth 1 -type f \( ${adb_revsrclist} \) -print -exec rm -f "{}" \;)"
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
        restore_done="$(find "${adb_backupdir}" -maxdepth 1 -type f -name "${adb_dnsprefix}.*" -print -exec cp -pf "{}" "${adb_dnsdir}" \;)"
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
        /etc/init.d/dnsmasq restart
        sleep 1
        rc="$(ps | grep -q "[d]nsmasq"; printf ${?})"
        if [ $((rc)) -eq 0 ]
        then
            rc=0
            adb_count="$(head -qn -3 "${adb_dnsdir}/${adb_dnsprefix}."* | wc -l)"
            if [ -n "${adb_wanif4}" ] && [ -n "${adb_wanif6}" ]
            then
                adb_count="$((adb_count / 2))"
            fi
            f_log "adblock lists with overall ${adb_count} domains loaded"
        else
            rc=145
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
    local ipv4_prerouting=0
    local ipv4_forward=0
    local ipv4_output=0
    local ipv6_prerouting=0
    local ipv6_forward=0
    local ipv6_output=0
    local iptv4="/usr/sbin/iptables"
    local iptv6="/usr/sbin/ip6tables"

    # delete temporary files & directories
    #
    if [ -f "${adb_tmpfile}" ]
    then
       rm -f "${adb_tmpfile}"
    fi
    if [ -d "${adb_tmpdir}" ]
    then
       rm -rf "${adb_tmpdir}"
    fi

    # final log message and iptables statistics
    #
    if [ $((rc)) -eq 0 ]
    then
        if [ -n "${adb_wanif4}" ]
        then
            ipv4_prerouting="$(${iptv4} -t nat -vnL | awk '$11 ~ /^adb-prerouting$/ {sum += $1} END {printf sum}')"
            ipv4_forward="$(${iptv4} -vnL | awk '$11 ~ /^adb-forward$/ {sum += $1} END {printf sum}')"
            ipv4_output="$(${iptv4} -vnL | awk '$11 ~ /^adb-output$/ {sum += $1} END {printf sum}')"
        fi
        if [ -n "${adb_wanif6}" ]
        then
            ipv6_prerouting="$(${iptv6} -t nat -vnL | awk '$10 ~ /^adb-prerouting$/ {sum += $1} END {printf sum}')"
            ipv6_forward="$(${iptv6} -vnL | awk '$10 ~ /^adb-forward$/ {sum += $1} END {printf sum}')"
            ipv6_output="$(${iptv6} -vnL | awk '$10 ~ /^adb-output$/ {sum += $1} END {printf sum}')"
        fi
        f_log "adblock firewall statistics (IPv4/IPv6):"
        f_log "${ipv4_prerouting}/${ipv6_prerouting} packets redirected in PREROUTING chain"
        f_log "${ipv4_forward}/${ipv6_forward} packets rejected in FORWARD chain"
        f_log "${ipv4_output}/${ipv6_output} packets rejected in OUTPUT chain"
        f_log "domain adblock processing finished successfully (${adb_scriptver}, ${openwrt_version}, $(/bin/date "+%d.%m.%Y %H:%M:%S"))"
    elif [ $((rc)) -gt 0 ]
    then
        f_log "domain adblock processing failed (${adb_scriptver}, ${openwrt_version}, $(/bin/date "+%d.%m.%Y %H:%M:%S"))"
    else
        rc=0
    fi
    rm -f "${adb_pidfile}"
    exit ${rc}
}

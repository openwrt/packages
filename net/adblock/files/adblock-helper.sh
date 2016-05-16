#!/bin/sh
# function library used by adblock-update.sh
# written by Dirk Brenken (dev@brenken.org)

# f_envload: load adblock environment
#
f_envload()
{
    # source in system function library
    #
    if [ -r "/lib/functions.sh" ]
    then
        . "/lib/functions.sh"
    else
        rc=110
        f_log "system function library not found" "${rc}"
        f_exit
    fi

    # source in system network library
    #
    if [ -r "/lib/functions/network.sh" ]
    then
        . "/lib/functions/network.sh"
    else
        rc=115
        f_log "system network library not found" "${rc}"
        f_exit
    fi

    # set initial defaults,
    # may be overwritten by setting appropriate adblock config options in global section of /etc/config/adblock
    #
    adb_lanif="lan"
    adb_nullport="65535"
    adb_nullipv4="192.0.2.1"
    adb_nullipv6="::ffff:c000:0201"
    adb_whitelist="/etc/adblock/adblock.whitelist"
    adb_whitelist_rset="\$1 ~/^([A-Za-z0-9_-]+\.){1,}[A-Za-z]+/{print tolower(\$1)}"
    adb_forcedns=1

    # function to parse global section by callback
    #
    config_cb()
    {
        local type="${1}"
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

    # function to parse 'service' and 'source' sections
    #
    parse_config()
    {
        local value opt section="${1}" options="adb_dir adb_src adb_src_rset adb_src_cat"
        config_get switch "${section}" "enabled"
        if [ "${switch}" = "1" ]
        then
            if [ "${section}" != "backup" ]
            then
                eval "adb_sources=\"${adb_sources} ${section}\""
            fi
            for opt in ${options}
            do
                config_get value "${section}" "${opt}"
                if [ -n "${value}" ]
                then
                    eval "${opt}_${section}=\"${value}\""
                fi
            done
        fi
    }

    # check opkg availability
    #
    if [ -r "/var/lock/opkg.lock" ]
    then
        rc=-1
        f_log "adblock installation finished successfully, 'opkg' currently locked by package installer"
        f_exit
    fi

    # get list with all installed packages
    #
    pkg_list="$(opkg list-installed)"
    if [ -z "${pkg_list}" ]
    then
        rc=120
        f_log "empty package list" "${rc}"
        f_exit
    fi

    # load adblock config and start parsing functions
    #
    config_load adblock
    config_foreach parse_config service
    config_foreach parse_config source

    # set more script defaults (can't be overwritten by adblock config options)
    #
    adb_minspace=12000
    adb_tmpfile="$(mktemp -tu)"
    adb_tmpdir="$(mktemp -p /tmp -d)"
    adb_dnsdir="/tmp/dnsmasq.d"
    adb_dnsprefix="adb_list"
    adb_uci="$(which uci)"
    adb_iptv4="$(which iptables)"
    adb_iptv6="$(which ip6tables)"
    adb_fetch="$(which wget-ssl)"
    unset adb_srclist adb_revsrclist adb_errsrclist

    # check 'enabled' & 'version' config options
    #
    if [ -z "${adb_enabled}" ] || [ -z "${adb_cfgver}" ] || [ "${adb_cfgver}" != "${adb_mincfgver}" ]
    then
        rc=-1
        f_log "outdated adblock configuration found, please copy latest version from '/etc/adblock/adblock.conf.default' to '/etc/config/adblock'"
        f_exit
    fi
    if [ $((adb_enabled)) -ne 1 ]
    then
        rc=-1
        f_log "adblock is currently disabled, please set adblock.global.adb_enabled=1' to use this service"
        f_exit
    fi

    # check running dnsmasq instance
    #
    rc="$(ps | grep -q "[d]nsmasq"; printf ${?})"
    if [ $((rc)) -ne 0 ]
    then
        rc=-1
        f_log "please enable the local dnsmasq instance to use adblock"
        f_exit
    fi

    # check running firewall
    #
    check="$(${adb_iptv4} -vnL | grep -F "DROP")"
    if [ -z "${check}" ]
    then
        rc=-1
        f_log "please enable the local firewall to use adblock"
        f_exit
    fi

    # get lan ip addresses
    #
    network_get_ipaddr adb_ipv4 "${adb_lanif}"
    network_get_ipaddr6 adb_ipv6 "${adb_lanif}"
    if [ -z "${adb_ipv4}" ] && [ -z "${adb_ipv6}" ]
    then
        rc=-1
        f_log "no valid IPv4/IPv6 configuration found (${adb_lanif}), please set 'adb_lanif' manually"
        f_exit
    fi

    # check logical update interfaces (with default route)
    #
    network_find_wan adb_wanif4
    network_find_wan6 adb_wanif6
    if [ -z "${adb_wanif4}" ] && [ -z "${adb_wanif6}" ]
    then
        adb_wanif4="${adb_lanif}"
    fi

    # check AP mode
    #
    if [ "${adb_wanif4}" = "${adb_lanif}" ] || [ "${adb_wanif6}" = "${adb_lanif}" ]
    then
        adb_nullipv4="${adb_ipv4}"
        adb_nullipv6="${adb_ipv6}"
        if [ "$(uci get uhttpd.main.listen_http | grep -Fo "80")" = "80" ] ||
           [ "$(uci get uhttpd.main.listen_https | grep -Fo "443")" = "443" ]
        then
            rc=-1
            f_log "AP mode detected, set local LuCI instance to ports <> 80/443"
            f_exit
        else
            apmode_ok="true"
        fi
    fi

    # get system release level
    #
    adb_sysver="$(printf "${pkg_list}" | grep "^base-files -")"
    adb_sysver="${adb_sysver##*-}"
}

# f_envcheck: check/set environment prerequisites
#
f_envcheck()
{
    local check

    if [ "${apmode_ok}" = "true" ]
    then
        f_log "AP mode enabled"
    fi

    # check general package dependencies
    #
    f_depend "busybox"
    f_depend "uci"
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

    # check ca-certificates package and set fetch parms accordingly
    #
    fetch_parm="--no-config --quiet --tries=1 --no-cache --no-cookies --max-redirect=0 --dns-timeout=5 --connect-timeout=5 --read-timeout=5"
    check="$(printf "${pkg_list}" | grep "^ca-certificates -")"
    if [ -z "${check}" ]
    then
        fetch_parm="${fetch_parm} --no-check-certificate"
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
                rc=125
                f_log "not enough free space in '${adb_tmpdir}' (avail. ${av_space} kb)" "${rc}"
                f_exit
            else
                f_log "not enough free space to handle all adblock list sources at once in '${adb_tmpdir}' (avail. ${av_space} kb)"
            fi
        fi
    else
        rc=130
        f_log "temp directory not found" "${rc}"
        f_exit
    fi

    # check memory
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
    if [ -n "${adb_dir_backup}" ] && [ -d "${adb_dir_backup}" ]
    then
        f_space "${adb_dir_backup}"
        if [ "${space_ok}" = "false" ]
        then
            f_log "not enough free space in '${adb_dir_backup}'(avail. ${av_space} kb), backup/restore will be disabled"
            backup_ok="false"
        else
            f_log "backup/restore will be enabled"
            backup_ok="true"
        fi
    else
        backup_ok="false"
        f_log "backup/restore will be disabled"
    fi

    # set dnsmasq defaults
    #
    if [ -n "${adb_wanif4}" ] && [ -n "${adb_wanif6}" ]
    then
        adb_dnsformat="awk -v ipv4="${adb_nullipv4}" -v ipv6="${adb_nullipv6}" '{print \"address=/\"\$0\"/\"ipv4\"\n\"\"address=/\"\$0\"/\"ipv6}'"
    elif [ -n "${adb_wanif4}" ]
    then
        adb_dnsformat="awk -v ipv4="${adb_nullipv4}" '{print \"address=/\"\$0\"/\"ipv4}'"
    else
        adb_dnsformat="awk -v ipv6="${adb_nullipv6}" '{print \"address=/\"\$0\"/\"ipv6}'"
    fi

    # check ipv4/iptables configuration
    #
    if [ -n "${adb_wanif4}" ]
    then
        f_firewall "IPv4" "nat" "A" "prerouting_rule" "adb-nat" "-p tcp -d ${adb_nullipv4} -m multiport --dports 80,443 -j DNAT --to-destination ${adb_ipv4}:${adb_nullport}"
        f_firewall "IPv4" "filter" "A" "forwarding_rule" "adb-fwd" "-p tcp -d ${adb_nullipv4} -j REJECT --reject-with tcp-reset"
        f_firewall "IPv4" "filter" "A" "forwarding_rule" "adb-fwd" "-d ${adb_nullipv4} -j REJECT --reject-with icmp-host-unreachable"
        f_firewall "IPv4" "filter" "A" "output_rule" "adb-out" "-p tcp -d ${adb_nullipv4} -j REJECT --reject-with tcp-reset"
        f_firewall "IPv4" "filter" "A" "output_rule" "adb-out" "-d ${adb_nullipv4} -j REJECT --reject-with icmp-host-unreachable"
        if [ $((adb_forcedns)) -eq 1 ]
        then
            f_firewall "IPv4" "nat" "A" "prerouting_rule" "adb-dns" "-p udp --dport 53 -j DNAT --to-destination ${adb_ipv4}:53"
            f_firewall "IPv4" "nat" "A" "prerouting_rule" "adb-dns" "-p tcp --dport 53 -j DNAT --to-destination ${adb_ipv4}:53"
        fi
        if [ "${fw_done}" = "true" ]
        then
            f_log "created volatile IPv4 firewall ruleset"
            fw_done="false"
        fi
    fi

    # check ipv6/ip6tables configuration
    #
    if [ -n "${adb_wanif6}" ]
    then
        f_firewall "IPv6" "nat" "A" "PREROUTING" "adb-nat" "-p tcp -d ${adb_nullipv6} -m multiport --dports 80,443 -j DNAT --to-destination [${adb_ipv6}]:${adb_nullport}"
        f_firewall "IPv6" "filter" "A" "forwarding_rule" "adb-fwd" "-p tcp -d ${adb_nullipv6} -j REJECT --reject-with tcp-reset"
        f_firewall "IPv6" "filter" "A" "forwarding_rule" "adb-fwd" "-d ${adb_nullipv6} -j REJECT --reject-with icmp6-addr-unreachable"
        f_firewall "IPv6" "filter" "A" "output_rule" "adb-out" "-p tcp -d ${adb_nullipv6} -j REJECT --reject-with tcp-reset"
        f_firewall "IPv6" "filter" "A" "output_rule" "adb-out" "-d ${adb_nullipv6} -j REJECT --reject-with icmp6-addr-unreachable"
        if [ $((adb_forcedns)) -eq 1 ]
        then
            f_firewall "IPv6" "nat" "A" "PREROUTING" "adb-dns" "-p udp --dport 53 -j DNAT --to-destination [${adb_ipv6}]:53"
            f_firewall "IPv6" "nat" "A" "PREROUTING" "adb-dns" "-p tcp --dport 53 -j DNAT --to-destination [${adb_ipv6}]:53"
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
            uhttpd -h "/www/adblock" -k 0 -N 100 -t 0 -T 1 -D -S -E "/index.html" -p "${adb_ipv4}:${adb_nullport}" -p "[${adb_ipv6}]:${adb_nullport}"
            rc=${?}
        elif [ -n "${adb_wanif4}" ]
        then
            uhttpd -h "/www/adblock" -k 0 -N 100 -t 0 -T 1 -D -S -E "/index.html" -p "${adb_ipv4}:${adb_nullport}"
            rc=${?}
        else
            uhttpd -h "/www/adblock" -k 0 -N 100 -t 0 -T 1 -D -S -E "/index.html" -p "[${adb_ipv6}]:${adb_nullport}"
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

    # check whitelist entries
    #
    if [ -s "${adb_whitelist}" ]
    then
        awk "${adb_whitelist_rset}" "${adb_whitelist}" > "${adb_tmpdir}/tmp.whitelist"
    fi

    # remove no longer used opkg package list
    #
    unset pkg_list
}

# f_depend: check package dependencies
#
f_depend()
{
    local check
    local package="${1}"

    check="$(printf "${pkg_list}" | grep "^${package} -")"
    if [ -z "${check}" ]
    then
        rc=135
        f_log "package '${package}' not found" "${rc}"
        f_exit
    fi
}

# f_firewall: set iptables rules for ipv4/ipv6
#
f_firewall()
{
    local ipt="${adb_iptv4}"
    local proto="${1}"
    local table="${2}"
    local ctype="${3}"
    local chain="${4}"
    local notes="${5}"
    local rules="${6}"

    # select appropriate iptables executable for IPv6
    #
    if [ "${proto}" = "IPv6" ]
    then
        ipt="${adb_iptv6}"
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
            f_exit
        fi
    fi
}

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
        "${adb_log}" ${log_parm} -t "adblock[${adb_pid}] ${class}" "${log_msg}" 2>&1
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

# f_cntconfig: calculate counters in config
#
f_cntconfig()
{
    local src_name
    local count=0
    local count_sum=0

    for src_name in $(ls -ASr "${adb_dnsdir}/${adb_dnsprefix}"*)
    do
        count="$(wc -l < "${src_name}")"
        src_name="${src_name##*.}"
        if [ -n "${adb_wanif4}" ] && [ -n "${adb_wanif6}" ]
        then
            count=$((count / 2))
        fi
        "${adb_uci}" -q set "adblock.${src_name}.adb_src_count=${count}"
        count_sum=$((count_sum + count))
    done
    "${adb_uci}" -q set "adblock.global.adb_overall_count=${count_sum}"
}

# f_rmconfig: remove counters & timestamps in given config sections
#
f_rmconfig()
{
    local src_name
    local rm_done="${1}"
    local restore_done="${2:-false}"

    for src_name in ${rm_done}
    do
        src_name="${src_name#*.}"
        if [ "${restore_done}" = "true" ]
        then
            src_name="${src_name%.*}"
            "${adb_uci}" -q set "adblock.${src_name}.adb_src_timestamp=list restored"
        else
            "${adb_uci}" -q delete "adblock.${src_name}.adb_src_count"
            "${adb_uci}" -q delete "adblock.${src_name}.adb_src_timestamp"
        fi
    done
}

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
            f_rmconfig "${rm_done}"
            f_log "all bogus adblock lists removed"
        elif [ $((rc)) -ne 0 ]
        then
            f_log "error during removal of bogus adblock lists" "${rc}"
            f_exit
        fi
    fi

    # restore backups
    #
    if [ "${backup_ok}" = "true" ]
    then
        restore_done="$(find "${adb_dir_backup}" -maxdepth 1 -type f -name "${adb_dnsprefix}*.gz" -print -exec cp -pf "{}" "${adb_dnsdir}" \;)"
        rc=${?}
        if [ $((rc)) -eq 0 ] && [ -n "${restore_done}" ]
        then
            find "${adb_dnsdir}" -maxdepth 1 -type f -name "${adb_dnsprefix}*.gz" -exec gunzip -f "{}" \;
            f_log "all available backups restored"
        elif [ $((rc)) -ne 0 ] && [ -n "${restore_done}" ]
        then
            f_log "error during restore of adblock lists" "${rc}"
            f_exit
        fi
    else
        f_log "backup service disabled, nothing to restore"
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
            f_cntconfig
            f_log "adblock lists with overall ${adb_count} domains loaded"
        else
            rc=140
            f_log "dnsmasq restart failed, please check 'logread' output" "${rc}"
        fi
    fi
    f_exit
}

# f_exit: delete (temporary) files, generate statistics and exit
#
f_exit()
{
    local ipv4_adblock=0
    local ipv6_adblock=0

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
            ipv4_adblock="$(${adb_iptv4} -t nat -vnL | awk '$11 ~ /^adb-nat$/ {sum += $1} END {printf sum}')"
            ipv4_adblock="$((${ipv4_adblock} + $(${adb_iptv4} -vnL | awk '$11 ~ /^adb-(fwd|out)$/ {sum += $1} END {printf sum}')))"
        fi
        if [ -n "${adb_wanif6}" ]
        then
            ipv6_adblock="$(${adb_iptv6} -t nat -vnL | awk '$10 ~ /^adb-nat$/ {sum += $1} END {printf sum}')"
            ipv6_adblock="$((${ipv6_adblock} + $(${adb_iptv6} -vnL | awk '$10 ~ /^adb-(fwd|out)$/ {sum += $1} END {printf sum}')))"
        fi
        if [ -n "$(${adb_uci} -q changes adblock)" ]
        then
            "${adb_uci}" -q commit "adblock"
        fi
        f_log "firewall statistics (IPv4/IPv6): ${ipv4_adblock}/${ipv6_adblock} ad related packets blocked"
        f_log "domain adblock processing finished successfully (${adb_scriptver}, ${adb_sysver}, $(/bin/date "+%d.%m.%Y %H:%M:%S"))"
    elif [ $((rc)) -gt 0 ]
    then
        if [ -n "$(${adb_uci} -q changes adblock)" ]
        then
            "${adb_uci}" -q revert "adblock"
        fi
        f_log "domain adblock processing failed (${adb_scriptver}, ${adb_sysver}, $(/bin/date "+%d.%m.%Y %H:%M:%S"))"
    else
        rc=0
    fi
    rm -f "${adb_pidfile}"
    exit ${rc}
}

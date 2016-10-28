#!/bin/sh
# function library used by adblock-update.sh
# written by Dirk Brenken (dev@brenken.org)

# set initial defaults
#
LC_ALL=C
PATH="/usr/sbin:/usr/bin:/sbin:/bin"
adb_scriptver="1.5.4"
adb_mincfgver="2.5"
adb_hotplugif=""
adb_lanif="lan"
adb_nullport="65534"
adb_nullportssl="65535"
adb_nullipv4="198.18.0.1"
adb_nullipv6="::ffff:c612:0001"
adb_whitelist="/etc/adblock/adblock.whitelist"
adb_whitelist_rset="\$1 ~/^([A-Za-z0-9_-]+\.){1,}[A-Za-z]+/{print tolower(\"^\"\$1\"\\\|[.]\"\$1)}"
adb_dnsdir="/tmp/dnsmasq.d"
adb_dnshidedir="${adb_dnsdir}/.adb_hidden"
adb_dnsprefix="adb_list"
adb_count=0
adb_minspace=12000
adb_forcedns=1
adb_fetchttl=5
adb_restricted=0
adb_loglevel=1
adb_uci="$(which uci)"

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
        rc=-10
        f_log "system function library not found, please check your installation"
        f_exit
    fi

    # source in system network library
    #
    if [ -r "/lib/functions/network.sh" ]
    then
        . "/lib/functions/network.sh"
    else
        rc=-10
        f_log "system network library not found, please check your installation"
        f_exit
    fi

    # uci function to parse global section by callback
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

    # uci function to parse 'service' and 'source' sections
    #
    parse_config()
    {
        local value opt section="${1}" options="enabled adb_dir adb_src adb_src_rset adb_src_cat"
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
    }

    # load adblock config and start parsing functions
    #
    config_load adblock
    config_foreach parse_config service
    config_foreach parse_config source

    # get network basics
    #
    network_get_ipaddr adb_ipv4 "${adb_lanif}"
    network_get_ipaddr6 adb_ipv6 "${adb_lanif}"
    network_get_device adb_landev "${adb_lanif}"
    network_find_wan adb_wanif4
    network_find_wan6 adb_wanif6
}

# f_envcheck: check/set environment prerequisites
#
f_envcheck()
{
    local check

    # check 'enabled' & 'version' config options
    #
    if [ -z "${adb_enabled}" ] || [ -z "${adb_cfgver}" ] || [ "${adb_cfgver%%.*}" != "${adb_mincfgver%%.*}" ]
    then
        rc=-1
        f_log "outdated adblock config (${adb_cfgver} vs. ${adb_mincfgver}), please run '/etc/init.d/adblock cfgup' to update your configuration"
        f_exit
    elif [ "${adb_cfgver#*.}" != "${adb_mincfgver#*.}" ]
    then
        outdated_ok="true"
    fi
    if [ "${adb_enabled}" != "1" ]
    then
        rc=-10
        f_log "adblock is currently disabled, please set adb_enabled to '1' to use this service"
        f_exit
    fi

    # check opkg availability
    #
    adb_pkglist="$(opkg list-installed)"
    if [ $(($?)) -eq 255 ]
    then
        rc=-10
        f_log "adblock installation finished successfully, 'opkg' currently locked by package installer"
        f_exit
    elif [ -z "${adb_pkglist}" ]
    then
        rc=-1
        f_log "empty 'opkg' package list, please check your installation"
        f_exit
    fi
    adb_sysver="$(printf "${adb_pkglist}" | grep "^base-files -")"
    adb_sysver="${adb_sysver##*-}"

    # get lan ip addresses
    #
    if [ -z "${adb_ipv4}" ] && [ -z "${adb_ipv6}" ]
    then
        rc=-1
        f_log "no valid IPv4/IPv6 configuration found (${adb_lanif}), please set 'adb_lanif' manually"
        f_exit
    fi

    # check logical update interfaces (with default route)
    #
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
        if [ -n "$(${adb_uci} -q get uhttpd.main.listen_http | grep -o ":80$")" ] ||
           [ -n "$(${adb_uci} -q get uhttpd.main.listen_https | grep -o ":443$")" ]
        then
            rc=-1
            f_log "AP mode detected, please set local LuCI instance to ports <> 80/443"
            f_exit
        else
            apmode_ok="true"
        fi
    else
        apmode_ok="false"
        check="$(${adb_uci} -q get bcp38.@bcp38[0].enabled)"
        if [ "${check}" = "1" ]
        then
            if [ -n "$(${adb_uci} -q get bcp38.@bcp38[0].match | grep -Fo "${adb_nullipv4%.*}")" ]
            then
                rc=-1
                f_log "please whitelist '${adb_nullipv4}' in your bcp38 configuration to use adblock"
                f_exit
            fi
        fi
    fi

    # check general package dependencies
    #
    f_depend "busybox -"
    f_depend "uci -"
    f_depend "uhttpd -"
    f_depend "iptables -"
    f_depend "kmod-ipt-nat -"
    f_depend "firewall -"
    f_depend "dnsmasq*"

    # check ipv6 related package dependencies
    #
    if [ -n "${adb_wanif6}" ]
    then
        f_depend "ip6tables -" "true"
        if [ "${package_ok}" = "false" ]
        then
            f_log "package 'ip6tables' not found, IPv6 support will be disabled"
            unset adb_wanif6
        else
            f_depend "kmod-ipt-nat6 -" "true"
            if [ "${package_ok}" = "false" ]
            then
                f_log "package 'kmod-ipt-nat6' not found, IPv6 support will be disabled"
                unset adb_wanif6
            fi
        fi
    fi

    # check uclient-fetch/wget dependencies
    #
    f_depend "uclient-fetch -" "true"
    if [ "${package_ok}" = "true" ]
    then
        f_depend "libustream-polarssl -" "true"
        if [ "${package_ok}" = "false" ]
        then
            f_depend "libustream-\(mbedtls\|openssl\|cyassl\) -" "true"
            if [ "${package_ok}" = "true" ]
            then
                adb_fetch="$(which uclient-fetch)"
                fetch_parm="-q"
                response_parm=
            fi
        fi
    fi
    if [ -z "${adb_fetch}" ]
    then
        f_depend "wget -" "true"
        if [ "${package_ok}" = "true" ]
        then
            adb_fetch="$(which /usr/bin/wget* | head -1)"
            fetch_parm="--no-config --quiet --tries=1 --no-cache --no-cookies --max-redirect=0 --dns-timeout=${adb_fetchttl} --connect-timeout=${adb_fetchttl} --read-timeout=${adb_fetchttl}"
            response_parm="--spider --server-response"
        fi
        if [ -z "${adb_fetch}" ]
        then
            rc=-1
            f_log "please install 'uclient-fetch' or 'wget' with ssl support to use adblock"
            f_exit
        fi
    fi

    # check ca-certificate package and set fetch parm accordingly
    #
    f_depend "ca-certificates -" "true"
    if [ "${package_ok}" = "false" ]
    then
        fetch_parm="${fetch_parm} --no-check-certificate"
    fi

    # start normal processing/logging
    #
    f_log "domain adblock processing started (${adb_scriptver}, ${adb_sysver}, $(/bin/date "+%d.%m.%Y %H:%M:%S"))"

    # log partially outdated config
    #
    if [ "${outdated_ok}" = "true" ]
    then
        f_log "partially outdated adblock config (${adb_mincfgver} vs. ${adb_cfgver}), please run '/etc/init.d/adblock cfgup' to update your configuration"
    fi

    # log ap mode
    #
    if [ "${apmode_ok}" = "true" ]
    then
        f_log "AP mode enabled"
    fi

    # set/log restricted mode
    #
    if [ "${adb_restricted}" = "1" ]
    then
        adb_uci="$(which true)"
        f_log "Restricted mode enabled"
    fi

    # check dns hideout directory
    #
    if [ -d "${adb_dnshidedir}" ]
    then
        mv_done="$(find "${adb_dnshidedir}" -maxdepth 1 -type f -name "${adb_dnsprefix}*" -print -exec mv -f "{}" "${adb_dnsdir}" \;)"
    else
        mkdir -p -m 660 "${adb_dnshidedir}"
    fi

    # check adblock temp directory
    #
    adb_tmpfile="$(mktemp -tu)"
    adb_tmpdir="$(mktemp -p /tmp -d)"
    if [ -n "${adb_tmpdir}" ] && [ -d "${adb_tmpdir}" ]
    then
        f_space "${adb_tmpdir}"
        if [ "${space_ok}" = "false" ]
        then
            if [ $((av_space)) -le 2000 ]
            then
                rc=105
                f_log "not enough free space in '${adb_tmpdir}' (avail. ${av_space} kb)"
                f_exit
            else
                f_log "not enough free space to handle all block list sources at once in '${adb_tmpdir}' (avail. ${av_space} kb)"
            fi
        fi
    else
        rc=110
        f_log "temp directory not found"
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
    if [ "${enabled_backup}" = "1" ] && [ -d "${adb_dir_backup}" ]
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

    # check volatile iptables configuration
    #
    if [ -n "${adb_wanif4}" ]
    then
        if [ "${apmode_ok}" = "false" ]
        then
            if [ "${adb_forcedns}" = "1" ] && [ -n "${adb_landev}" ]
            then
                f_firewall "IPv4" "nat" "prerouting_rule" "adb-dns" "1" "dns" "-p udp --dport 53 -j DNAT --to-destination ${adb_ipv4}:53"
                f_firewall "IPv4" "nat" "prerouting_rule" "adb-dns" "2" "dns" "-p tcp --dport 53 -j DNAT --to-destination ${adb_ipv4}:53"
            fi
            f_firewall "IPv4" "filter" "forwarding_rule" "adb-fwd" "1" "fwd" "-p tcp -j REJECT --reject-with tcp-reset"
            f_firewall "IPv4" "filter" "forwarding_rule" "adb-fwd" "2" "fwd" "-j REJECT --reject-with icmp-host-unreachable"
            f_firewall "IPv4" "filter" "output_rule" "adb-out" "1" "out" "-p tcp -j REJECT --reject-with tcp-reset"
            f_firewall "IPv4" "filter" "output_rule" "adb-out" "2" "out" "-j REJECT --reject-with icmp-host-unreachable"
        fi
        f_firewall "IPv4" "nat" "prerouting_rule" "adb-nat" "1" "nat" "-p tcp --dport 80 -j DNAT --to-destination ${adb_ipv4}:${adb_nullport}"
        f_firewall "IPv4" "nat" "prerouting_rule" "adb-nat" "2" "nat" "-p tcp --dport 443 -j DNAT --to-destination ${adb_ipv4}:${adb_nullportssl}"
    fi
    if [ -n "${adb_wanif6}" ]
    then
        if [ "${apmode_ok}" = "false" ]
        then
            if [ "${adb_forcedns}" = "1" ] && [ -n "${adb_landev}" ]
            then
                f_firewall "IPv6" "nat" "PREROUTING" "adb-dns" "1" "dns" "-p udp --dport 53 -j DNAT --to-destination [${adb_ipv6}]:53"
                f_firewall "IPv6" "nat" "PREROUTING" "adb-dns" "2" "dns" "-p tcp --dport 53 -j DNAT --to-destination [${adb_ipv6}]:53"
            fi
            f_firewall "IPv6" "filter" "forwarding_rule" "adb-fwd" "1" "fwd" "-p tcp -j REJECT --reject-with tcp-reset"
            f_firewall "IPv6" "filter" "forwarding_rule" "adb-fwd" "2" "fwd" "-j REJECT --reject-with icmp6-addr-unreachable"
            f_firewall "IPv6" "filter" "output_rule" "adb-out" "1" "out" "-p tcp -j REJECT --reject-with tcp-reset"
            f_firewall "IPv6" "filter" "output_rule" "adb-out" "2" "out" "-j REJECT --reject-with icmp6-addr-unreachable"
        fi
        f_firewall "IPv6" "nat" "PREROUTING" "adb-nat" "1" "nat" "-p tcp --dport 80 -j DNAT --to-destination [${adb_ipv6}]:${adb_nullport}"
        f_firewall "IPv6" "nat" "PREROUTING" "adb-nat" "2" "nat" "-p tcp --dport 443 -j DNAT --to-destination [${adb_ipv6}]:${adb_nullportssl}"
    fi
    if [ "${firewall_ok}" = "true" ]
    then
        f_log "created volatile firewall rulesets"
    fi

    # check volatile uhttpd instance configuration
    #
    if [ -n "${adb_wanif4}" ] && [ -n "${adb_wanif6}" ]
    then
        f_uhttpd "adbIPv46_80" "1" "-p ${adb_ipv4}:${adb_nullport} -p [${adb_ipv6}]:${adb_nullport}"
        f_uhttpd "adbIPv46_443" "0" "-p ${adb_ipv4}:${adb_nullportssl} -p [${adb_ipv6}]:${adb_nullportssl}"
    elif [ -n "${adb_wanif4}" ]
    then
        f_uhttpd "adbIPv4_80" "1" "-p ${adb_ipv4}:${adb_nullport}"
        f_uhttpd "adbIPv4_443" "0" "-p ${adb_ipv4}:${adb_nullportssl}"
    else
        f_uhttpd "adbIPv6_80" "1" "-p [${adb_ipv6}]:${adb_nullport}"
        f_uhttpd "adbIPv6_443" "0" "-p [${adb_ipv6}]:${adb_nullportssl}"
    fi
    if [ "${uhttpd_ok}" = "true" ]
    then
        f_log "created volatile uhttpd instances"
    fi

    # check whitelist entries
    #
    if [ -s "${adb_whitelist}" ]
    then
        awk "${adb_whitelist_rset}" "${adb_whitelist}" > "${adb_tmpdir}/tmp.whitelist"
    fi

    # remove temporary package list
    #
    unset adb_pkglist
}

# f_depend: check package dependencies
#
f_depend()
{
    local check
    local package="${1}"
    local check_only="${2}"
    package_ok="true"

    check="$(printf "${adb_pkglist}" | grep "^${package}")"
    if [ "${check_only}" = "true" ] && [ -z "${check}" ]
    then
        package_ok="false"
    elif [ -z "${check}" ]
    then
        rc=-1
        f_log "package '${package}' not found"
        f_exit
    fi
}

# f_firewall: set iptables rules for ipv4/ipv6
#
f_firewall()
{
    local ipt="iptables"
    local nullip="${adb_nullipv4}"
    local proto="${1}"
    local table="${2}"
    local chsrc="${3}"
    local chain="${4}"
    local chpos="${5}"
    local notes="adb-${6}"
    local rules="${7}"

    # select appropriate iptables executable for IPv6
    #
    if [ "${proto}" = "IPv6" ]
    then
        ipt="ip6tables"
        nullip="${adb_nullipv6}"
    fi

    # check whether iptables chain already exist
    #
    rc="$("${ipt}" -w -t "${table}" -nL "${chain}" >/dev/null 2>&1; printf ${?})"
    if [ $((rc)) -ne 0 ]
    then
        "${ipt}" -w -t "${table}" -N "${chain}"
        "${ipt}" -w -t "${table}" -A "${chain}" -m comment --comment "${notes}" -j RETURN
        if [ "${chain}" = "adb-dns" ]
        then
            "${ipt}" -w -t "${table}" -A "${chsrc}" -i "${adb_landev}+" -m comment --comment "${notes}" -j "${chain}"
        else
            "${ipt}" -w -t "${table}" -A "${chsrc}" -d "${nullip}" -m comment --comment "${notes}" -j "${chain}"
        fi
        rc=${?}
        if [ $((rc)) -ne 0 ]
        then
            f_log "failed to initialize volatile ${proto} firewall chain '${chain}'"
            f_exit
        fi
    fi

    # check whether iptables rule already exist
    #
    rc="$("${ipt}" -w -t "${table}" -C "${chain}" -m comment --comment "${notes}" ${rules} >/dev/null 2>&1; printf ${?})"
    if [ $((rc)) -ne 0 ]
    then
        "${ipt}" -w -t "${table}" -I "${chain}" "${chpos}" -m comment --comment "${notes}" ${rules}
        rc=${?}
        if [ $((rc)) -eq 0 ]
        then
            firewall_ok="true"
        else
            f_log "failed to initialize volatile ${proto} firewall rule '${notes}'"
            f_exit
        fi
    fi
}

# f_uhttpd: start uhttpd instances
#
f_uhttpd()
{
    local check
    local realm="${1}"
    local timeout="${2}"
    local ports="${3}"

    check="$(pgrep -f "uhttpd -h /www/adblock -N 25 -T ${timeout} -r ${realm}")"
    if [ -z "${check}" ]
    then
        uhttpd -h "/www/adblock" -N 25 -T "${timeout}" -r "${realm}" -k 0 -t 0 -R -D -S -E "/index.html" ${ports}
        rc=${?}
        if [ $((rc)) -eq 0 ]
        then
            uhttpd_ok="true"
        else
            f_log "failed to initialize volatile uhttpd instance (${realm})"
            f_exit
        fi
    fi
}

# f_space: check mount points/space requirements
#
f_space()
{
    local mp="${1}"
    space_ok="true"

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

    for src_name in $(ls -ASr "${adb_dnsdir}/${adb_dnsprefix}"*)
    do
        count="$(wc -l < "${src_name}")"
        src_name="${src_name##*.}"
        if [ -n "${adb_wanif4}" ] && [ -n "${adb_wanif6}" ]
        then
            count=$((count / 2))
        fi
        "${adb_uci}" -q set "adblock.${src_name}.adb_src_count=${count}"
        adb_count=$((adb_count + count))
    done
    "${adb_uci}" -q set "adblock.global.adb_overall_count=${adb_count}"
}

# f_rmconfig: remove volatile config entries
#
f_rmconfig()
{
    local opt
    local options="adb_src_timestamp adb_src_count"
    local section="${1}"

    "${adb_uci}" -q delete "adblock.global.adb_overall_count"
    "${adb_uci}" -q delete "adblock.global.adb_dnstoggle"
    "${adb_uci}" -q delete "adblock.global.adb_percentage"
    "${adb_uci}" -q delete "adblock.global.adb_lastrun"
    for opt in ${options}
    do
        "${adb_uci}" -q delete "adblock.${section}.${opt}"
    done
}

# f_rmdns: remove dns block lists and backups
#
f_rmdns()
{
    rm_dns="$(find "${adb_dnsdir}" -maxdepth 1 -type f -name "${adb_dnsprefix}*" -print -exec rm -f "{}" \;)"
    if [ -n "${rm_dns}" ]
    then
        rm -rf "${adb_dnshidedir}"
        if [ "${enabled_backup}" = "1" ] && [ -d "${adb_dir_backup}" ]
        then
            rm -f "${adb_dir_backup}/${adb_dnsprefix}"*.gz
        fi
        /etc/init.d/dnsmasq restart
    fi
}

# f_rmuhttpd: remove uhttpd instances
#
f_rmuhttpd()
{
    rm_uhttpd="$(pgrep -f "uhttpd -h /www/adblock")"
    if [ -n "${rm_uhttpd}" ]
    then
        for pid in ${rm_uhttpd}
        do
            kill -9 "${pid}"
        done
    fi
}

# f_rmfirewall: remove firewall rulsets
#
f_rmfirewall()
{
    rm_fw="$(iptables -w -t nat -vnL | grep -Fo "adb-")"
    if [ -n "${rm_fw}" ]
    then
        iptables-save | grep -Fv -- "adb-" | iptables-restore
        if [ -n "$(lsmod | grep -Fo "ip6table_nat")" ]
        then
            ip6tables-save | grep -Fv -- "adb-" | ip6tables-restore
        fi
    fi
}

# f_log: log messages to stdout and syslog
#
f_log()
{
    local log_parm
    local log_msg="${1}"
    local class="info "

    if [ $((rc)) -gt 0 ]
    then
        class="error"
    elif [ $((rc)) -lt 0 ]
    then
        class="warn "
    fi
    if [ -t 1 ]
    then
        log_parm="-s"
    fi
    if [ -n "${log_msg}" ] && ([ $((adb_loglevel)) -gt 0 ] || [ "${class}" != "info " ])
    then
        logger ${log_parm} -t "adblock[${adb_pid}] ${class}" "${log_msg}" 2>&1
    fi
}

# f_statistics: adblock runtime statistics
f_statistics()
{
    local ipv4_blk=0 ipv4_all=0 ipv4_pct=0
    local ipv6_blk=0 ipv6_all=0 ipv6_pct=0

    if [ -n "${adb_wanif4}" ]
    then
        ipv4_blk="$(iptables -t nat -vxnL adb-nat | awk '$3 ~ /^DNAT$/ {sum += $1} END {printf sum}')"
        ipv4_all="$(iptables -t nat -vxnL PREROUTING | awk '$3 ~ /^(delegate_prerouting|prerouting_rule)$/ {sum += $1} END {printf sum}')"
        if [ $((ipv4_all)) -gt 0 ] && [ $((ipv4_blk)) -gt 0 ] && [ $((ipv4_all)) -gt $((ipv4_blk)) ]
        then
            ipv4_pct="$(printf "${ipv4_blk}" | awk -v all="${ipv4_all}" '{printf( "%5.2f\n",$1/all*100)}')"
        elif [ $((ipv4_all)) -lt $((ipv4_blk)) ]
        then
            iptables -t nat -Z adb-nat
        fi
    fi
    if [ -n "${adb_wanif6}" ]
    then
        ipv6_blk="$(ip6tables -t nat -vxnL adb-nat | awk '$3 ~ /^DNAT$/ {sum += $1} END {printf sum}')"
        ipv6_all="$(ip6tables -t nat -vxnL PREROUTING | awk '$3 ~ /^(adb-nat|DNAT)$/ {sum += $1} END {printf sum}')"
        if [ $((ipv6_all)) -gt 0 ] && [ $((ipv6_blk)) -gt 0 ] && [ $((ipv6_all)) -gt $((ipv6_blk)) ]
        then
            ipv6_pct="$(printf "${ipv6_blk}" | awk -v all="${ipv6_all}" '{printf( "%5.2f\n",$1/all*100)}')"
        elif [ $((ipv6_all)) -lt $((ipv6_blk)) ]
        then
            ip6tables -t nat -Z adb-nat
        fi
    fi
    "${adb_uci}" -q set "adblock.global.adb_percentage=${ipv4_pct}%/${ipv6_pct}%"
    f_log "firewall statistics (IPv4/IPv6): ${ipv4_pct}%/${ipv6_pct}% of all packets in prerouting chain are ad related & blocked"
}

# f_exit: delete temporary files, generate statistics and exit
#
f_exit()
{
    local lastrun="$(date "+%d.%m.%Y %H:%M:%S")"

    if [ "${adb_restricted}" = "1" ]
    then
        adb_uci="$(which true)"
    fi

    # delete temp files & directories
    #
    rm -f "${adb_tmpfile}"
    rm -rf "${adb_tmpdir}"

    # tidy up on error
    #
    if [ $((rc)) -lt 0 ] || [ $((rc)) -gt 0 ]
    then
        f_rmdns
        f_rmuhttpd
        f_rmfirewall
        config_foreach f_rmconfig source
        if [ $((rc)) -eq -1 ]
        then
            "${adb_uci}" -q set "adblock.global.adb_lastrun=${lastrun} => runtime error, please check the log!"
        fi
    fi

    # final log message and iptables statistics
    #
    if [ $((rc)) -eq 0 ]
    then
        f_statistics
        "${adb_uci}" -q set "adblock.global.adb_lastrun=${lastrun}"
        f_log "domain adblock processing finished successfully (${adb_scriptver}, ${adb_sysver}, ${lastrun})"
    elif [ $((rc)) -gt 0 ]
    then
        f_log "domain adblock processing failed (${adb_scriptver}, ${adb_sysver}, ${lastrun})"
    else
        rc=0
    fi
    if [ -n "$("${adb_uci}" -q changes adblock)" ]
    then
        "${adb_uci}" -q commit "adblock"
    fi
    rm -f "${adb_pidfile}"
    exit ${rc}
}

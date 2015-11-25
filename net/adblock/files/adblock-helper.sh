#!/bin/sh
##############################################
# function library used by adblock-update.sh #
# written by Dirk Brenken (dirk@brenken.org) #
##############################################

#####################################
# f_envload: load adblock environment
#
f_envload()
{
    # source in openwrt function library
    #
    if [ -r "/lib/functions.sh" ]
    then
        . /lib/functions.sh
    else
        rc=510
        f_log "openwrt function library not found" "${rc}"
        f_deltemp
    fi

    # source in openwrt json helpers library
    #
    if [ -r "/usr/share/libubox/jshn.sh" ]
    then
        . "/usr/share/libubox/jshn.sh"
    else
        rc=515
        f_log "openwrt json helpers library not found" "${rc}"
        f_deltemp
    fi

    # get list with all installed openwrt packages
    #
    pkg_list="$(opkg list-installed 2>/dev/null)"
    if [ -z "${pkg_list}" ]
    then
        rc=520
        f_log "empty openwrt package list" "${rc}"
        f_deltemp
    fi
}

######################################################
# f_envparse: parse adblock config and set environment
#
f_envparse()
{
    # set the C locale, characters are single bytes, the charset is ASCII
    # speeds up sort, grep etc., guarantees unique domains
    #
    LC_ALL=C

    # set initial defaults (may be overwritten by adblock config options)
    #
    adb_if="adblock"
    adb_minspace="20000"
    adb_maxtime="60"
    adb_maxloop="5"

    # adblock device name auto detection
    # derived from first entry in openwrt lan ifname config
    #
    adb_dev="$(uci get network.lan.ifname 2>/dev/null)"
    adb_dev="${adb_dev/ *}"

    # adblock ntp server name auto detection
    # derived from ntp list found in openwrt ntp server config
    #
    adb_ntpsrv="$(uci get system.ntp.server 2>/dev/null)"

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
                local opt_out="$(printf "${option}" | sed -n '/.*_ITEM[0-9]$/p; /.*_LENGTH$/p; /enabled/p')"
                if [ -z "${opt_out}" ]
                then
                    all_options="${all_options} ${option}"
                fi
            }
            list_cb()
            {
                local list="${1}"
                local value="${2}"
                if [ "${list}" = "adb_wanlist" ]
                then
                    adb_wandev="${adb_wandev} ${value}"
                elif [ "${list}" = "adb_ntplist" ]
                then
                    adb_ntpsrv="${adb_ntpsrv} ${value}"
                elif [ "${list}" = "adb_catlist" ]
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
                    local opt_src="$(printf "${option}" | sed -n '/^adb_src_[a-z0-9]*$/p')"
                    if [ -n "${opt_src}" ]
                    then
                        adb_sources="${adb_sources} ${value}"
                    else
                        eval "${option}=\"${value}\""
                    fi
                fi
            done
        elif [ "${config}" = "wancheck" ]
        then
           unset adb_wandev
        elif [ "${config}" = "ntpcheck" ]
        then
           unset adb_ntpsrv
        elif [ "${config}" = "shalla" ]
        then
           unset adb_cat_shalla
        fi
    }

    # load adblock config and start parsing functions
    #
    config_load adblock
    config_foreach parse_config service
    config_foreach parse_config source

    # set temp variables and counter
    #
    adb_tmpfile="$(mktemp -tu 2>/dev/null)"
    adb_tmpdir="$(mktemp -d 2>/dev/null)"

    # set adblock source ruleset definitions
    #
    rset_start="sed -r 's/[[:space:]]|[\[!#/:;_].*|[0-9\.]*localhost//g; s/[\^#/:;_\.\t ]*$//g'"
    rset_end="sed '/^[#/:;_\s]*$/d'"
    rset_default="${rset_start} | ${rset_end}"
    rset_yoyo="${rset_start} | sed 's/,/\n/g' | ${rset_end}"
    rset_shalla="${rset_start} | sed 's/\([0-9]\{1,3\}\.\)\{3\}[0-9]\{1,3\}$//g' | ${rset_end}"
    rset_spam404="${rset_start} | sed 's/^\|\|//g' | ${rset_end}"
    rset_winhelp="${rset_start} | sed 's/\([0-9]\{1,3\}\.\)\{3\}[0-1]\{1,1\}//g' | ${rset_end}"

    # set adblock/dnsmasq destination file and format
    #
    adb_dnsfile="/tmp/dnsmasq.d/adlist.conf"
    adb_dnsformat="sed 's/^/address=\//;s/$/\/'${adb_ip}'/'"

    # remove unused environment variables
    #
    env_list="$(set | grep -o "CONFIG_[A-Za-z_]*")"
    for var in ${env_list}
    do
        unset "${var}" 2>/dev/null
    done
}

#############################################
# f_envcheck: check environment prerequisites
#
f_envcheck()
{
    # check required config variables
    #
    adb_varlist="adb_ip adb_dev adb_if adb_domain adb_minspace adb_maxloop adb_maxtime adb_blacklist adb_whitelist"
    for var in ${adb_varlist}
    do
        if [ -z "$(eval printf \"\$"${var}"\")" ]
        then
            rc=525
            f_log "missing adblock config option (${var})" "${rc}"
            f_deltemp
        fi
    done

    # check main uhttpd configuration
    #
    check_uhttpd="$(uci get uhttpd.main.listen_http 2>/dev/null | grep -o "0.0.0.0")"
    if [ -n "${check_uhttpd}" ]
    then
        rc=530
        lan_ip="$(uci get network.lan.ipaddr 2>/dev/null)"
        f_log "main uhttpd instance listens to all network interfaces, please bind uhttpd to LAN only (${lan_ip})" "${rc}"
        f_deltemp
    fi

    # check adblock network device configuration
    #
    if [ ! -d "/sys/class/net/${adb_dev}" ]
    then
        rc=535
        f_log "invalid adblock network device input (${adb_dev})" "${rc}"
        f_deltemp
    fi

    # check adblock network interface configuration
    #
    check_if="$(printf "${adb_if}" | sed -n '/[^._0-9A-Za-z]/p')"
    banned_if="$(printf "${adb_if}" | sed -n '/.*lan.*\|.*wan.*\|.*switch.*\|main\|globals\|loopback\|px5g/p')"
    if [ -n "${check_if}" ] || [ -n "${banned_if}" ]
    then
        rc=540
        f_log "invalid adblock network interface input (${adb_if})" "${rc}"
        f_deltemp
    fi

    # check adblock ip address configuration
    #
    check_ip="$(printf "${adb_ip}" | sed -n '/\([0-9]\{1,3\}\.\)\{3\}[0-9]\{1,3\}/p')"
    if [ -z "${check_ip}" ]
    then
        rc=545
        f_log "invalid adblock ip address input (${adb_ip})" "${rc}"
        f_deltemp
    fi

    # check adblock blacklist/whitelist configuration
    #
    if [ ! -r "${adb_blacklist}" ]
    then
        rc=550
        f_log "adblock blacklist not found" "${rc}"
        f_deltemp
    elif [ ! -r "${adb_whitelist}" ]
    then
        rc=555
        f_log "adblock whitelist not found" "${rc}"
        f_deltemp
    fi

    # check adblock temp directory
    #
    if [ -n "${adb_tmpdir}" ] && [ -d "${adb_tmpdir}" ]
    then
        f_space "${adb_tmpdir}"
        tmp_ok="true"
    else
        rc=560
        tmp_ok="false"
        f_log "temp directory not found" "${rc}"
        f_deltemp
    fi

    # check curl package dependency
    #
    check="$(printf "${pkg_list}" | grep "^curl -")"
    if [ -z "${check}" ]
    then
        rc=565
        f_log "curl package not found" "${rc}"
        f_deltemp
    fi

    # check wget package dependency
    #
    check="$(printf "${pkg_list}" | grep "^wget -")"
    if [ -z "${check}" ]
    then
        rc=570
        f_log "wget package not found" "${rc}"
        f_deltemp
    fi

    # check ca-certificates package and set wget/curl parms accordingly
    #
    check="$(printf "${pkg_list}" | grep "^ca-certificates -")"
    if [ -z "${check}" ]
    then
        curl_parm="--insecure"
        wget_parm="--no-check-certificate"
    else
        unset curl_parm
        unset wget_parm
    fi

    # check total and swap memory
    #
    mem_total="$(cat /proc/meminfo | grep "MemTotal" | grep -o "[0-9]*")"
    mem_free="$(cat /proc/meminfo | grep "MemFree" | grep -o "[0-9]*")"
    swap_total="$(cat /proc/meminfo | grep "SwapTotal" | grep -o "[0-9]*")"
    if [ $((mem_total)) -le 64000 ] && [ $((swap_total)) -eq 0 ]
    then
        f_log "please consider to add an external swap device to supersize your /tmp directory (total: ${mem_total}, free: ${mem_free}, swap: ${mem_swap})"
    fi

    # check backup configuration
    #
    adb_backupdir="${adb_backupfile%/*}"
    if [ -n "${adb_backupdir}" ] && [ -d "${adb_backupdir}" ]
    then
        f_space "${adb_backupdir}"
        backup_ok="true"
    else
        backup_ok="false"
        f_log "backup/restore will be disabled"
    fi

    # check dns query log configuration
    #
    adb_querydir="${adb_queryfile%/*}"
    adb_querypid="/var/run/adb_query.pid"
    if [ -n "${adb_querydir}" ] && [ -d "${adb_querydir}" ]
    then
        # check find capabilities
        #
        check="$(find --help 2>&1 | grep "mtime")"
        if [ -z "${check}" ]
        then
            query_ok="false"
            f_log "busybox without 'find/mtime' support (min. r47362), dns query logging will be disabled"
        else
            f_space "${adb_querydir}"
            query_ok="true"
            query_name="${adb_queryfile##*/}"
            query_ip="${adb_ip//./\\.}"
        fi
    else
        query_ok="false"
        f_log "dns query logging will be disabled"
        if [ -s "${adb_querypid}" ]
        then
            kill -9 "$(cat "${adb_querypid}")" >/dev/null 2>&1
            f_log "remove old dns query log background process (pid: $(cat "${adb_querypid}"))"
            > "${adb_querypid}"
        fi
    fi

    # check debug log configuration
    #
    adb_logdir="${adb_logfile%/*}"
    if [ -n "${adb_logdir}" ] && [ -d "${adb_logdir}" ]
    then
        f_space "${adb_logdir}"
        log_ok="true"
    else
        log_ok="false"
        f_log "debug logging will be disabled"
    fi

    # check wan update configuration
    #
    if [ -n "${adb_wandev}" ]
    then
        f_wancheck "${adb_maxloop}"
    else
        wan_ok="false"
        f_log "wan update check will be disabled"
    fi

    # check ntp sync configuration
    #
    if [ -n "${adb_ntpsrv}" ]
    then
        f_ntpcheck "${adb_maxloop}"
    else
        ntp_ok="false"
        f_log "ntp time sync will be disabled"
    fi

    # check dynamic/volatile adblock network interface configuration
    #
    rc="$(ifstatus "${adb_if}" >/dev/null 2>&1; printf ${?})"
    if [ $((rc)) -ne 0 ]
    then
        json_init
        json_add_string name "${adb_if}"
        json_add_string ifname "${adb_dev}"
        json_add_string proto "static"
        json_add_array ipaddr
        json_add_string "" "${adb_ip}"
        json_close_array
        json_close_object
        ubus call network add_dynamic "$(json_dump)"
        rc=${?}
        if [ $((rc)) -eq 0 ]
        then
            f_log "created new dynamic/volatile network interface (${adb_if}, ${adb_ip})"
        else
            f_log "failed to initialize new dynamic/volatile network interface (${adb_if}, ${adb_ip})" "${rc}"
            f_remove
        fi
    fi

    # check dynamic/volatile adblock uhttpd instance configuration
    #
    rc="$(ps | grep "[u]httpd.*\-r ${adb_if}" >/dev/null 2>&1; printf ${?})"
    if [ $((rc)) -ne 0 ]
    then
        uhttpd -h "/www/adblock" -r "${adb_if}" -E "/adblock.html" -p "${adb_ip}:80" >/dev/null 2>&1
        rc=${?}
        if [ $((rc)) -eq 0 ]
        then
            f_log "created new dynamic/volatile uhttpd instance (${adb_if}, ${adb_ip})"
        else
            f_log "failed to initialize new dynamic/volatile uhttpd instance (${adb_if}, ${adb_ip})" "${rc}"
            f_remove
        fi
    fi
}

################################################
# f_log: log messages to stdout, syslog, logfile
#
f_log()
{
    local log_msg="${1}"
    local log_rc="${2}"
    local class="info "
    if [ -n "${log_msg}" ]
    then
        if [ $((log_rc)) -ne 0 ]
        then
            class="error"
            log_rc=", rc: ${log_rc}"
        fi
        /usr/bin/logger -s -t "adblock[${pid}] ${class}" "${log_msg}${log_rc}"
        if [ "${log_ok}" = "true" ] && [ "${ntp_ok}" = "true" ]
        then
            printf "%s\n" "$(/bin/date "+%d.%m.%Y %H:%M:%S") adblock[${pid}] ${class}: ${log_msg}${log_rc}" >> "${adb_logfile}"
        fi
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
        df "${mp}" 2>/dev/null |\
        tail -n1 |\
        while read filesystem overall used available scrap
        do
            av_space="${available}"
            if [ $((av_space)) -eq 0 ]
            then
                rc=575
                f_log "no space left on device/not mounted (${mp})" "${rc}"
                exit ${rc}
            elif [ $((av_space)) -lt $((adb_minspace)) ]
            then
                rc=580
                f_log "not enough space left on device (${mp})" "${rc}"
                exit ${rc}
            fi
        done
        rc=${?}
        if [ $((rc)) -eq 0 ]
        then
            space_ok="true"
        else
            space_ok="false"
            f_deltemp
        fi
    fi
}

####################################################
# f_deltemp: delete temp files, directories and exit
#
f_deltemp()
{
    if [ -f "${adb_tmpfile}" ]
    then
       rm -f "${adb_tmpfile}" >/dev/null 2>&1
    fi
    if [ -d "${adb_tmpdir}" ]
        then
       rm -rf "${adb_tmpdir}" >/dev/null 2>&1
    fi
    f_log "domain adblock processing finished (${adb_version})"
    exit ${rc}
}

####################################################
# f_remove: maintain and (re-)start domain query log
#
f_remove()
{
    if [ "${query_ok}" = "true" ] && [ "${ntp_ok}" = "true" ]
    then
        query_date="$(date "+%Y%m%d")"
        if [ -s "${adb_querypid}" ] && [ ! -f "${adb_queryfile}.${query_date}" ]
        then
            kill -9 "$(cat "${adb_querypid}")" >/dev/null 2>&1
            find "${adb_backupdir}" -maxdepth 1 -type f -mtime +"${adb_queryhistory}" -name "${query_name}.*" -exec rm -f {} \; 2>/dev/null
            f_log "remove old dns query log background process (pid: $(cat "${adb_querypid}")) and do logfile housekeeping"
            > "${adb_querypid}"
        fi
        if [ ! -s "${adb_querypid}" ]
        then
            ( logread -f 2>/dev/null & printf ${!} > "${adb_querypid}" ) | egrep -o "(query\[A\].*)|([a-z0-9\.\-]* is ${query_ip}$)" >> "${adb_queryfile}.${query_date}" &
            f_log "new domain query log background process started (pid: $(cat "${adb_querypid}"))"
        fi
    fi
    f_deltemp
}

################################################################
# f_restore: restore last adblocklist backup and restart dnsmasq
#
f_restore()
{
    if [ "${backup_ok}" = "true" ] && [ -f "${adb_backupfile}" ]
    then
        cp -f "${adb_backupfile}" "${adb_dnsfile}" >/dev/null 2>&1
        f_log "adblocklist backup restored"
    else
        > "${adb_dnsfile}"
        f_log="empty adblocklist generated"
    fi
    /etc/init.d/dnsmasq restart >/dev/null 2>&1
    f_remove
}

#######################################################
# f_wancheck: check for usable adblock update interface
#
f_wancheck()
{
    local cnt=0
    local cnt_max="${1}"
    local dev
    local dev_out
    while [ $((cnt)) -le $((cnt_max)) ]
    do
        for dev in ${adb_wandev}
        do
            if [ -d "/sys/class/net/${dev}" ]
            then
                dev_out="$(cat /sys/class/net/${dev}/operstate 2>/dev/null)"
                rc=${?}
                if [ "${dev_out}" = "up" ]
                then
                    wan_ok="true"
                    f_log "get wan/update interface (${dev}), after ${cnt} loops"
                    break 2
                fi
            fi
        done
        sleep 1
        cnt=$((cnt + 1))
    done
    if [ -z "${wan_ok}" ]
    then
        rc=585
        wan_ok="false"
        f_log "no wan/update interface(s) found (${adb_wandev# })" "${rc}"
        f_restore
    fi
}

#####################################
# f_ntpcheck: check/get ntp time sync
#
f_ntpcheck()
{
    local cnt=0
    local cnt_max="${1}"
    local ntp_pool
    for srv in ${adb_ntpsrv}
    do
        ntp_pool="${ntp_pool} -p ${srv}"
    done
    while [ $((cnt)) -le $((cnt_max)) ]
    do
        /usr/sbin/ntpd -nq ${ntp_pool} >/dev/null 2>&1
        rc=${?}
        if [ $((rc)) -eq 0 ]
        then
            ntp_ok="true"
            f_log "get ntp time sync (${adb_ntpsrv# }), after ${cnt} loops"
            break
        fi
        sleep 1
        cnt=$((cnt + 1))
    done
    if [ -z "${ntp_ok}" ]
    then
        rc=590
        ntp_ok="false"
        f_log "ntp time sync failed (${adb_ntpsrv# })" "${rc}"
        f_restore
    fi
}

####################################################################
# f_dnscheck: dnsmasq health check with newly generated adblock list
#
f_dnscheck()
{
    local dns_status
    dns_status="$(logread -l 20 -e "dnsmasq" -e "FAILED to start up")"
    rc=${?}
    if [ -z "${dns_status}" ]
    then
        dns_status="$(nslookup "${adb_domain}" 2>/dev/null | grep "${adb_ip}")"
        rc=${?}
        if [ -z "${dns_status}" ]
        then
            if [ "${backup_ok}" = "true" ]
            then
                cp -f "${adb_dnsfile}" "${adb_backupfile}" >/dev/null 2>&1
                f_log "new adblock list with ${adb_count} domains loaded, backup generated"
            else
                f_log "new adblock list with ${adb_count} domains loaded, no backup"
            fi
        else
            f_log "nslookup probe failed" "${rc}"
            f_restore
        fi
    else
        f_log "dnsmasq probe failed" "${rc}"
        f_restore
    fi
}

##########################################################
# f_footer: write footer with a few statistics to dns file
#
f_footer()
{
    local url
    adb_count="$(wc -l < "${adb_dnsfile}")"
    printf "%s\n" "####################################################" >> "${adb_dnsfile}"
    printf "%s\n" "# last adblock list update: $(date +"%d.%m.%Y - %T")" >> "${adb_dnsfile}"
    printf "%s\n" "# ${0##*/} (${adb_version}) - ${adb_count} ad/abuse domains blocked" >> "${adb_dnsfile}"
    printf "%s\n" "# domain blacklist sources:" >> "${adb_dnsfile}"
    for src in ${adb_sources}
    do
        url="${src//\&ruleset=*/}"
        printf "%s\n" "# ${url}" >> "${adb_dnsfile}"
    done
    printf "%s\n" "#####" >> "${adb_dnsfile}"
    printf "%s\n" "# ${adb_whitelist}" >> "${adb_dnsfile}"
    printf "%s\n" "####################################################" >> "${adb_dnsfile}"
}

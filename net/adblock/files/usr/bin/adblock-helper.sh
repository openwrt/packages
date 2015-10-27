##############################################
# function library used by adblock-update.sh #
# written by Dirk Brenken (dirk@brenken.org) #
##############################################

#############################################
# f_envcheck: check environment prerequisites
#
f_envcheck()
{
    # source in json helpers library
    #
    if [ -r "/usr/share/libubox/jshn.sh" ]
    then
        . "/usr/share/libubox/jshn.sh"
    else
        /usr/bin/logger -t "adblock[${pid}]" "json helpers library not found"
        f_deltemp
        exit 10
    fi

    # check adblock network device configuration
    #
    if [ ! -d "/sys/class/net/${adb_dev}" ]
    then
        /usr/bin/logger -t "adblock[${pid}]" "invalid adblock network device input (${adb_dev})"
        f_deltemp
        exit 15
    fi

    # check adblock network interface configuration
    #
    check_if="$(printf "${adb_if}" | sed -n '/[^_0-9A-Za-z]/p')"
    banned_if="$(printf "${adb_if}" | sed -n '/.*lan.*\|.*wan.*\|.*switch.*\|main\|globals\|loopback\|px5g/p')"
    if [ -n "${check_if}" ] || [ -n "${banned_if}" ]
    then
        /usr/bin/logger -t "adblock[${pid}]" "invalid adblock network interface input (${adb_if})"
        f_deltemp
        exit 20
    fi

    # check adblock ip address configuration
    #
    check_ip="$(printf "${adb_ip}" | sed -n '/\([0-9]\{1,3\}\.\)\{3\}[0-9]\{1,3\}/p')"
    if [ -z "${check_ip}" ]
    then
        /usr/bin/logger -t "adblock[${pid}]" "invalid adblock ip address input (${adb_ip})"
        f_deltemp
        exit 25
    fi

    # check adblock blacklist/whitelist configuration
    #
    if [ ! -r "${adb_blacklist}" ] || [ ! -r "${adb_whitelist}" ]
    then
        /usr/bin/logger -t "adblock[${pid}]" "adblock blacklist or whitelist not found"
        f_deltemp
        exit 30
    fi

    # check wan update configuration
    #
    if [ -n "${wan_dev}" ]
    then
        wan_ok="true"
    else
        wan_ok="false"
        /usr/bin/logger -t "adblock[${pid}]" "wan update check will be disabled"
    fi

    # check ntp sync configuration
    #
    if [ -n "${ntp_srv}" ]
    then
        ntp_ok="true"
    else
        ntp_ok="false"
        /usr/bin/logger -t "adblock[${pid}]" "ntp time sync will be disabled"
    fi

    # check backup configuration
    #
    if [ -n "${backup_dir}" ] && [ -d "${backup_dir}" ]
    then
        backup_ok="true"
        mounts="${backup_dir} ${tmp_dir}"
    else
        backup_ok="false"
        mounts="${tmp_dir}"
        /usr/bin/logger -t "adblock[${pid}]" "backup/restore will be disabled"
    fi

    # check error log configuration
    #
    if [ "${log_file}" = "/dev/stdout" ]
    then
        log_ok="true"
        log_file="/proc/self/fd/1"
    elif [ -n "${log_file}" ] && [ "${backup_ok}" = "true" ] && [ "${ntp_ok}" = "true" ]
    then
        log_ok="true"
    else
        log_ok="false"
        log_file="/dev/null"
        /usr/bin/logger -t "adblock[${pid}]" "error logging will be disabled"
    fi

    # check dns query log configuration
    #
    if [ -n "${query_file}" ] && [ "${backup_ok}" = "true" ]
    then
        # check find capabilities
        #
        base="$(find --help 2>&1 | grep "mtime")"
        if [[ -z "${base}" ]]
        then
            query_ok="false"
            /usr/bin/logger -t "adblock[${pid}]" "no 'find/mtime' support, dns query logging will be disabled"
        else
            query_ok="true"
        fi
    else
        query_ok="false"
        /usr/bin/logger -t "adblock[${pid}]" "dns query logging will be disabled"
    fi

    # check shallalist configuration
    #
    check_shalla="$(printf "${adb_source}" | sed -n '/.*shallalist.txt.*/p')"
    if [ -n "${check_shalla}" ]
    then
        shalla_ok="true"
    else
        shalla_ok="false"
        /usr/bin/logger -t "adblock[${pid}]" "shallalist processing will be disabled"
    fi

    # check mount points & space requirements
    #
    for mp in ${mounts}
    do
        df "${mp}" 2>/dev/null |\
        tail -n1 |\
        while read filesystem overall used available scrap
        do
            av_space="${available}"
            if [ $((av_space)) -eq 0 ]
            then
                /usr/bin/logger -t "adblock[${pid}]" "no space left on device, not mounted (${mp})"
                exit 35
            elif [ $((av_space)) -lt $((min_space)) ]
            then
                /usr/bin/logger -t "adblock[${pid}]" "not enough space on device (${mp})"
                exit 40
            fi
        done
        # subshell return code handling
        #
        rc=$?
        if [ $((rc)) -ne 0 ]
        then
            f_deltemp
            exit ${rc}
        fi
    done

    # get list with all installed packages
    #
    pkg_list="$(opkg list-installed 2>/dev/null)"

    # check openwrt release
    #
    base="$(printf "${pkg_list}" | grep "^base-files" | sed 's/\(.*r\)//g')"
    if [ $((base)) -lt $((min_release)) ]
    then
        /usr/bin/logger -t "adblock[${pid}]" "openwrt (r${wrt_release}) seems to be too old"
        f_deltemp
        exit 45
    fi

    # check curl package dependency
    #
    base="$(printf "${pkg_list}" | grep "^curl")"
    if [ -z "${base}" ]
    then
        /usr/bin/logger -t "adblock[${pid}]" "curl package not found"
        f_deltemp
        exit 50
    fi

    # check wget package dependency
    #
    base="$(printf "${pkg_list}" | grep "^wget")"
    if [ -z "${base}" ]
    then
        /usr/bin/logger -t "adblock[${pid}]" "wget package not found"
        f_deltemp
        exit 55
    fi

    # check dynamic/volatile adblock network interface configuration
    #
    rc="$(ifstatus "${adb_if}" >/dev/null 2>&1; printf $?)"
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
        /usr/bin/logger -t "adblock[${pid}]" "created new dynamic/volatile network interface (${adb_if}, ${adb_ip})"
    fi

    # check adblock uhttpd instance configuration
    #
    if [ -z "$(uci -q get uhttpd.${adb_if} 2>/dev/null)" ]
    then
        uci -q set uhttpd.${adb_if}="uhttpd"
        uci -q set uhttpd.${adb_if}.listen_http="${adb_ip}:80"
        uci -q set uhttpd.${adb_if}.home="/www/adblock"
        uci -q set uhttpd.${adb_if}.error_page="/adblock.html"
        uci -q commit uhttpd
        /etc/init.d/uhttpd reload
        /usr/bin/logger -t "adblock[${pid}]" "created new uhttpd instance (${adb_if}, ${adb_ip}) in /etc/config/uhttpd"
    fi
}

###################################################
# f_deltemp: delete temporary files and directories
f_deltemp()
{
    if [ -f "${tmp_file}" ]
    then
       rm -f "${tmp_file}" 2>/dev/null
    fi
    if [ -d "${tmp_dir}" ]
    then
       rm -rf "${tmp_dir}" 2>/dev/null
    fi
}

################################################################
# f_remove: remove temporary files, start and maintain query log
#
f_remove()
{
    # delete temporary files and directories
    #
    f_deltemp

    # kill existing domain query log background process,
    # housekeeping and start of a new process on daily basis
    #
    if [ "${query_ok}" = "true" ] && [ "${ntp_ok}" = "true" ]
    then
        query_date="$(date "+%Y%m%d")"
        if [ -s "${query_pid}" ] && [ ! -f "${query_file}.${query_date}" ]
        then
            kill -9 $(< "${query_pid}") 2>/dev/null
            > "${query_pid}"
            find "${backup_dir}" -maxdepth 1 -type f -mtime +${query_history} -name "${query_name}.*" -exec rm -f {} \; 2>/dev/null
            /usr/bin/logger -t "adblock[${pid}]" "kill old query log background process and do logfile housekeeping"
        fi
        if [ ! -s "${query_pid}" ]
        then
            ( logread -f 2>/dev/null & printf -n "$!" > "${query_pid}" ) | egrep -o "(query\[A\].*)|([a-z0-9\.\-]* is ${query_ip}$)" >> "${query_file}.${query_date}" &
            /usr/bin/logger -t "adblock[${pid}]" "start new domain query log background process"
        fi
    fi

    # final log entry
    #
    /usr/bin/logger -t "adblock[${pid}]" "domain adblock processing finished (${script_ver})"
}

#####################################################
# f_restore: if available, restore last adlist backup
#
f_restore()
{
    if [ "${backup_ok}" = "true" ] && [ -f "${backup_file}" ]
    then
        cp -f "${backup_file}" "${dns_file}" 2>/dev/null
        /usr/bin/logger -t "adblock[${pid}]" "${restore_msg}, adlist backup restored"
        printf "$(/bin/date "+%d.%m.%Y %H:%M:%S") - error: ${restore_msg}, adlist backup restored" >> "${log_file}"
    else
        > "${dns_file}"
        /usr/bin/logger -t "adblock[${pid}]" "${restore_msg}, empty adlist generated"
        printf "$(/bin/date "+%d.%m.%Y %H:%M:%S") - error: ${restore_msg}, empty adlist generated" >> "${log_file}"
    fi
    # restart dnsmasq
    #
    /etc/init.d/dnsmasq restart >/dev/null 2>&1

    # remove files and exit
    #
    f_remove
    exit 100
}

#######################################################
# f_wancheck: check for usable adblock update interface
#
f_wancheck()
{
    if [ "${wan_ok}" = "true" ]
    then
        # wait for wan update interface(s)
        #
        while [ $((cnt)) -le $((max_cnt)) ]
        do
            for dev in ${wan_dev}
            do
                dev_out=$(< /sys/class/net/${dev}/operstate 2>/dev/null)
                if [[ "${dev_out}" = "up" ]]
                then
                    /usr/bin/logger -t "adblock[${pid}]" "get wan/update interface: ${dev}, after ${cnt} loops"
                    break 2
                elif [ $((cnt)) -eq $((max_cnt)) ]
                then
                    /usr/bin/logger -t "adblock[${pid}]" "no wan/update interface(s) found (${wan_dev})"
                    printf "$(/bin/date "+%d.%m.%Y %H:%M:%S") - error: no wan/update interface(s) found (${wan_dev})" >> "${log_file}"
                    restore_msg="no wan/update interface(s)"
                    f_restore
                fi
            done
            sleep 1
            cnt=$((cnt + 1))
        done
    fi
}

#####################################
# f_ntpcheck: check/get ntp time sync
#
f_ntpcheck()
{
    if [ "${ntp_ok}" = "true" ]
    then
        # prepare ntp server pool
        #
        unset ntp_pool
        for srv in ${ntp_srv}
        do
            ntp_pool="${ntp_pool} -p ${srv}"
        done

        # wait for ntp time sync
        #
        while [ $((cnt)) -le $((max_cnt)) ]
        do
            /usr/sbin/ntpd -nq ${ntp_pool} >/dev/null 2>&1
            rc=$?
            if [ $((rc)) -eq 0 ]
            then
                /usr/bin/logger -t "adblock[${pid}]" "get ntp time sync (${ntp_srv}), after ${cnt} loops"
                break
            elif [ $((cnt)) -eq $((max_cnt)) ]
            then
                ntp_ok="false"
                /usr/bin/logger -t "adblock[${pid}]" "ntp time sync failed (${ntp_srv})"
                printf "$(/bin/date "+%d.%m.%Y %H:%M:%S") - error: ntp time sync failed (${ntp_srv})" >> "${log_file}"
                restore_msg="time sync failed"
                f_restore
            fi
            sleep 1
            cnt=$((cnt + 1))
        done
    fi
}

#################################################################
# f_dnscheck: dnsmasq health check with newly generated blocklist
#
f_dnscheck()
{
    # check 1: dnsmasq startup
    #
    dns_status="$(logread -l 20 -e "dnsmasq" -e "FAILED to start up")"
    if [ -z "${dns_status}" ]
    then
        # check 2: nslookup probe
        #
        dns_status="$(nslookup "${check_domain}" 2>/dev/null | grep "${adb_ip}")"
        if [ -z "${dns_status}" ]
        then
            # create backup of new block list only, if both checks are OK and backup enabled
            #
            if [ "${backup_ok}" = "true" ]
            then
                cp -f "${dns_file}" "${backup_file}" 2>/dev/null
                /usr/bin/logger -t "adblock[${pid}]" "new block list with ${adb_count} domains loaded, backup generated"
            else
                /usr/bin/logger -t "adblock[${pid}]" "new block list with ${adb_count} domains loaded"
            fi
        else
            restore_msg="nslookup probe failed"
            f_restore
        fi
    else
            restore_msg="dnsmasq probe failed"
            f_restore
    fi
}

##########################################################
# f_footer: write footer with a few statistics to dns file
#
f_footer()
{
    # count result of merged domain entries
    #
    adb_count="$(wc -l < "${dns_file}")"

    # write file footer with timestamp and merged ad count sum
    #
    printf "%s\n" "###################################################" >> "${dns_file}"
    printf "%s\n" "# last adblock file update: $(date +"%d.%m.%Y - %T")" >> "${dns_file}"
    printf "%s\n" "# ${0##*/} (${script_ver}) - ${adb_count} ad/abuse domains blocked" >> "${dns_file}"
    printf "%s\n" "# domain blacklist sources:" >> "${dns_file}"
    for src in ${adb_source}
    do
        url="$(printf "${src}" | sed 's/\(\&ruleset=.*\)//g')"
        printf "%s\n" "# ${url}" >> "${dns_file}"
    done
    printf "%s\n" "###################################################" >> "${dns_file}"
    printf "%s\n" "# domain whitelist source:" >> "${dns_file}"
    printf "%s\n" "# ${adb_whitelist}" >> "${dns_file}"
    printf "%s\n" "###################################################" >> "${dns_file}"
}

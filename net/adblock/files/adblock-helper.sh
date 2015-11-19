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
        /usr/bin/logger -t "adblock[${pid}]" "error: openwrt function library not found"
        f_deltemp
        exit 10
    fi

    # source in openwrt json helpers library
    #
    if [ -r "/usr/share/libubox/jshn.sh" ]
    then
        . "/usr/share/libubox/jshn.sh"
    else
        /usr/bin/logger -t "adblock[${pid}]" "error: openwrt json helpers library not found"
        f_deltemp
        exit 15
    fi

    # get list with all installed openwrt packages
    #
    pkg_list="$(opkg list-installed 2>/dev/null)"
    if [ -z "${pkg_list}" ]
    then
        /usr/bin/logger -t "adblock[${pid}]" "error: empty openwrt package list"
        f_deltemp
        exit 20
    fi
}

######################################################
# f_envparse: parse adblock config and set environment
#
f_envparse()
{
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
    adb_tmpfile="$(mktemp -tu)"
    adb_tmpdir="$(mktemp -d)"
    cnt=0
    max_cnt=30
    max_time=60

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
}

#############################################
# f_envcheck: check environment prerequisites
#
f_envcheck()
{
    # check adblock network device configuration
    #
    if [ ! -d "/sys/class/net/${adb_dev}" ]
    then
        /usr/bin/logger -t "adblock[${pid}]" "error: invalid adblock network device input (${adb_dev})"
        f_deltemp
        exit 25
    fi

    # check adblock network interface configuration
    #
    check_if="$(printf "${adb_if}" | sed -n '/[^_0-9A-Za-z]/p')"
    banned_if="$(printf "${adb_if}" | sed -n '/.*lan.*\|.*wan.*\|.*switch.*\|main\|globals\|loopback\|px5g/p')"
    if [ -n "${check_if}" ] || [ -n "${banned_if}" ]
    then
        /usr/bin/logger -t "adblock[${pid}]" "error: invalid adblock network interface input (${adb_if})"
        f_deltemp
        exit 30
    fi

    # check adblock ip address configuration
    #
    check_ip="$(printf "${adb_ip}" | sed -n '/\([0-9]\{1,3\}\.\)\{3\}[0-9]\{1,3\}/p')"
    if [ -z "${check_ip}" ]
    then
        /usr/bin/logger -t "adblock[${pid}]" "error: invalid adblock ip address input (${adb_ip})"
        f_deltemp
        exit 35
    fi

    # check adblock blacklist/whitelist configuration
    #
    if [ ! -r "${adb_blacklist}" ]
    then
        /usr/bin/logger -t "adblock[${pid}]" "error: adblock blacklist not found"
        f_deltemp
        exit 40
    elif [ ! -r "${adb_whitelist}" ]
    then
        /usr/bin/logger -t "adblock[${pid}]" "error: adblock whitelist not found"
        f_deltemp
        exit 45
    fi

    # check wan update configuration
    #
    if [ -n "${adb_wandev}" ]
    then
        wan_ok="true"
    else
        wan_ok="false"
        /usr/bin/logger -t "adblock[${pid}]" "info: wan update check will be disabled"
    fi

    # check ntp sync configuration
    #
    if [ -n "${adb_ntpsrv}" ]
    then
        ntp_ok="true"
    else
        ntp_ok="false"
        /usr/bin/logger -t "adblock[${pid}]" "info: ntp time sync will be disabled"
    fi

    # check backup configuration
    #
    adb_backupdir="${adb_backupfile%/*}"
    if [ -n "${adb_backupdir}" ] && [ -d "${adb_backupdir}" ]
    then
        backup_ok="true"
        adb_mounts="${adb_backupdir} ${adb_tmpdir}"
    else
        backup_ok="false"
        /usr/bin/logger -t "adblock[${pid}]" "info: backup/restore will be disabled"
    fi

    # check error log configuration
    #
    adb_logdir="${adb_logfile%/*}"
    if [ -n "${adb_logfile}" ] && [ "${adb_logfile}" = "/dev/stdout" ]
    then
        log_ok="true"
        adb_logfile="/proc/self/fd/1"
    elif [ -n "${adb_logdir}" ] && [ -d "${adb_logdir}" ] && [ "${ntp_ok}" = "true" ]
    then
        log_ok="true"
        adb_mounts="${adb_mounts} ${adb_logdir}"
    else
        log_ok="false"
        adb_logfile="/dev/null"
        /usr/bin/logger -t "adblock[${pid}]" "info: error logging will be disabled"
    fi

    # check dns query log configuration
    #
    adb_querydir="${adb_queryfile%/*}"
    query_pid="/var/run/adb_query.pid"
    if [ -n "${adb_querydir}" ] && [ -d "${adb_querydir}" ]
    then
        # check find capabilities
        #
        check="$(find --help 2>&1 | grep "mtime")"
        if [ -z "${check}" ]
        then
            query_ok="false"
            /usr/bin/logger -t "adblock[${pid}]" "info: busybox without 'find/mtime' support (min. r47362), dns query logging will be disabled"
        else
            query_ok="true"
            query_name="${adb_queryfile##*/}"
            query_ip="${adb_ip//./\\.}"
            adb_mounts="${adb_mounts} ${adb_querydir}"
        fi
    else
        query_ok="false"
        if [ -s "${query_pid}" ]
        then
            kill -9 $(cat "${query_pid}") 2>/dev/null
            > "${query_pid}"
            /usr/bin/logger -t "adblock[${pid}]" "info: remove old dns query log background process"
        fi
        /usr/bin/logger -t "adblock[${pid}]" "info: dns query logging will be disabled"
    fi

    # check mount points & space requirements
    #
    adb_mounts="${adb_mounts} ${adb_tmpdir}"
    for mp in ${adb_mounts}
    do
        df "${mp}" 2>/dev/null |\
        tail -n1 |\
        while read filesystem overall used available scrap
        do
            av_space="${available}"
            if [ $((av_space)) -eq 0 ]
            then
                /usr/bin/logger -t "adblock[${pid}]" "error: no space left on device/not mounted (${mp})"
                exit 50
            elif [ $((av_space)) -lt $((adb_minspace)) ]
            then
                /usr/bin/logger -t "adblock[${pid}]" "error: not enough space left on device (${mp})"
                exit 55
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

    # check curl package dependency
    #
    check="$(printf "${pkg_list}" | grep "^curl")"
    if [ -z "${check}" ]
    then
        /usr/bin/logger -t "adblock[${pid}]" "error: curl package not found"
        f_deltemp
        exit 60
    fi

    # check wget package dependency
    #
    check="$(printf "${pkg_list}" | grep "^wget")"
    if [ -z "${check}" ]
    then
        /usr/bin/logger -t "adblock[${pid}]" "error: wget package not found"
        f_deltemp
        exit 65
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
        /usr/bin/logger -t "adblock[${pid}]" "info: created new dynamic/volatile network interface (${adb_if}, ${adb_ip})"
    fi

    # check dynamic/volatile adblock uhttpd instance configuration
    #
    rc="$(ps | grep "[u]httpd.*\-r ${adb_if}" >/dev/null 2>&1; printf $?)"
    if [ $((rc)) -ne 0 ]
    then
        uhttpd -h "/www/adblock" -r "${adb_if}" -E "/adblock.html" -p "${adb_ip}:80"
        /usr/bin/logger -t "adblock[${pid}]" "info: created new dynamic/volatile uhttpd instance (${adb_if}, ${adb_ip})"
    fi
}

###################################################
# f_deltemp: delete temporary files and directories
#
f_deltemp()
{
    if [ -f "${adb_tmpfile}" ]
    then
       rm -f "${adb_tmpfile}" 2>/dev/null
    fi
    if [ -d "${adb_tmpdir}" ]
    then
       rm -rf "${adb_tmpdir}" 2>/dev/null
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

    # remove existing domain query log background process,
    # do housekeeping and start a new process on daily basis
    #
    if [ "${query_ok}" = "true" ] && [ "${ntp_ok}" = "true" ]
    then
        query_date="$(date "+%Y%m%d")"
        if [ -s "${query_pid}" ] && [ ! -f "${adb_queryfile}.${query_date}" ]
        then
            kill -9 $(cat "${query_pid}") 2>/dev/null
            > "${query_pid}"
            find "${adb_backupdir}" -maxdepth 1 -type f -mtime +${adb_queryhistory} -name "${query_name}.*" -exec rm -f {} \; 2>/dev/null
            /usr/bin/logger -t "adblock[${pid}]" "info: remove old dns query log background process and do logfile housekeeping"
        fi
        if [ ! -s "${query_pid}" ]
        then
            ( logread -f 2>/dev/null & printf "$!" > "${query_pid}" ) | egrep -o "(query\[A\].*)|([a-z0-9\.\-]* is ${query_ip}$)" >> "${adb_queryfile}.${query_date}" &
            /usr/bin/logger -t "adblock[${pid}]" "info: start new domain query log background process"
        fi
    fi

    # final log entry
    #
    /usr/bin/logger -t "adblock[${pid}]" "info: domain adblock processing finished (${adb_version})"
}

#####################################################
# f_restore: if available, restore last adlist backup
#
f_restore()
{
    if [ -z "${restore_msg}" ]
    then
        restore_msg="unknown"
    fi

    if [ "${backup_ok}" = "true" ] && [ -f "${adb_backupfile}" ]
    then
        cp -f "${adb_backupfile}" "${adb_dnsfile}" 2>/dev/null
        /usr/bin/logger -t "adblock[${pid}]" "error: ${restore_msg}, adlist backup restored"
        printf "%s\n" "$(/bin/date "+%d.%m.%Y %H:%M:%S") - error: ${restore_msg}, adlist backup restored" >> "${adb_logfile}"
    else
        > "${adb_dnsfile}"
        /usr/bin/logger -t "adblock[${pid}]" "error: ${restore_msg}, empty adlist generated"
        printf "%s\n" "$(/bin/date "+%d.%m.%Y %H:%M:%S") - error: ${restore_msg}, empty adlist generated" >> "${adb_logfile}"
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
            for dev in ${adb_wandev}
            do
                if [ -d "/sys/class/net/${dev}" ]
                then
                    dev_out="$(cat /sys/class/net/${dev}/operstate 2>/dev/null)"
                    if [ "${dev_out}" = "up" ]
                    then
                        /usr/bin/logger -t "adblock[${pid}]" "info: get wan/update interface: ${dev}, after ${cnt} loops"
                        break 2
                    fi
                fi
                if [ $((cnt)) -eq $((max_cnt)) ]
                then
                    wan_ok="false"
                    /usr/bin/logger -t "adblock[${pid}]" "error: no wan/update interface(s) found (${adb_wandev})"
                    printf "%s\n" "$(/bin/date "+%d.%m.%Y %H:%M:%S") - error: no wan/update interface(s) found (${adb_wandev})" >> "${adb_logfile}"
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
        for srv in ${adb_ntpsrv}
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
                /usr/bin/logger -t "adblock[${pid}]" "info: get ntp time sync (${adb_ntpsrv}), after ${cnt} loops"
                break
            fi
            if [ $((cnt)) -eq $((max_cnt)) ]
            then
                ntp_ok="false"
                /usr/bin/logger -t "adblock[${pid}]" "error: ntp time sync failed (${adb_ntpsrv})"
                printf "%s\n" "$(/bin/date "+%d.%m.%Y %H:%M:%S") - error: ntp time sync failed (${adb_ntpsrv})" >> "${adb_logfile}"
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
        dns_status="$(nslookup "${adb_domain}" 2>/dev/null | grep "${adb_ip}")"
        if [ -z "${dns_status}" ]
        then
            # create backup of new block list only, if both checks are OK and backup enabled
            #
            if [ "${backup_ok}" = "true" ]
            then
                cp -f "${adb_dnsfile}" "${adb_backupfile}" 2>/dev/null
                /usr/bin/logger -t "adblock[${pid}]" "info: new block list with ${adb_count} domains loaded, backup generated"
            else
                /usr/bin/logger -t "adblock[${pid}]" "info: new block list with ${adb_count} domains loaded, no backup"
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
    adb_count="$(wc -l < "${adb_dnsfile}")"
    printf "%s\n" "###################################################" >> "${adb_dnsfile}"
    printf "%s\n" "# last adblock file update: $(date +"%d.%m.%Y - %T")" >> "${adb_dnsfile}"
    printf "%s\n" "# ${0##*/} (${adb_version}) - ${adb_count} ad/abuse domains blocked" >> "${adb_dnsfile}"
    printf "%s\n" "# domain blacklist sources:" >> "${adb_dnsfile}"
    for src in ${adb_sources}
    do
        url="${src//\&ruleset=*/}"
        printf "%s\n" "# ${url}" >> "${adb_dnsfile}"
    done
    printf "%s\n" "###################################################" >> "${adb_dnsfile}"
    printf "%s\n" "# domain whitelist source:" >> "${adb_dnsfile}"
    printf "%s\n" "# ${adb_whitelist}" >> "${adb_dnsfile}"
    printf "%s\n" "###################################################" >> "${adb_dnsfile}"
}

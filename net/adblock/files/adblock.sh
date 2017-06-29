#!/bin/sh
# dns based ad/abuse domain blocking
# written by Dirk Brenken (dev@brenken.org)

# This is free software, licensed under the GNU General Public License v3.
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.

# set initial defaults
#
LC_ALL=C
PATH="/usr/sbin:/usr/bin:/sbin:/bin"
adb_ver="2.8.2"
adb_sysver="$(ubus -S call system board | jsonfilter -e '@.release.description')"
adb_enabled=1
adb_debug=0
adb_minfree=2
adb_manmode=0
adb_forcesrt=0
adb_forcedns=0
adb_backup=0
adb_backupdir="/mnt"
adb_whitelist="/etc/adblock/adblock.whitelist"
adb_whitelist_rset="\$1 ~/^([A-Za-z0-9_-]+\.){1,}[A-Za-z]+/{print tolower(\"^\"\$1\"\\\|[.]\"\$1)}"
adb_fetch="/usr/bin/wget"
adb_fetchparm="--quiet --no-cache --no-cookies --max-redirect=0 --timeout=10 --no-check-certificate -O"
adb_dnslist="dnsmasq unbound named"
adb_dnsprefix="adb_list"
adb_dnsfile="${adb_dnsprefix}.overall"
adb_rtfile="/tmp/adb_runtime.json"
adb_sources=""
adb_src_cat_shalla=""
adb_action="${1}"

# f_envload: load adblock environment
#
f_envload()
{
    local services dns_up cnt=0

    # source in system libraries
    #
    if [ -r "/lib/functions.sh" ] && [ -r "/usr/share/libubox/jshn.sh" ]
    then
        . "/lib/functions.sh"
        . "/usr/share/libubox/jshn.sh"
    else
        f_log "error" "system libraries not found"
    fi

    # parse global section by callback
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

    # parse 'source' sections
    #
    parse_config()
    {
        local value opt section="${1}" options="enabled adb_src adb_src_rset adb_src_cat"
        eval "adb_sources=\"${adb_sources} ${section}\""
        for opt in ${options}
        do
            config_get value "${section}" "${opt}"
            if [ -n "${value}" ]
            then
                eval "${opt}_${section}=\"${value}\""
            fi
        done
    }

    # load adblock config
    #
    config_load adblock
    config_foreach parse_config source

    # set dns backend environment
    #
    while [ ${cnt} -le 20 ]
    do
        services="$(ubus -S call service list 2>/dev/null)"
        if [ -n "${services}" ]
        then
            for dns in ${adb_dnslist}
            do
                dns_up="$(printf "%s" "${services}" | jsonfilter -l1 -e "@.${dns}.instances.*.running")"
                if [ "${dns_up}" = "true" ]
                then
                    case "${dns}" in
                        dnsmasq)
                            adb_dns="${dns}"
                            adb_dnsdir="${adb_dnsdir:="/tmp/dnsmasq.d"}"
                            adb_dnshidedir="${adb_dnsdir}/.adb_hidden"
                            adb_dnsformat="awk '{print \"local=/\"\$0\"/\"}'"
                            break 2
                            ;;
                        unbound)
                            adb_dns="${dns}"
                            adb_dnsdir="${adb_dnsdir:="/var/lib/unbound"}"
                            adb_dnshidedir="${adb_dnsdir}/.adb_hidden"
                            adb_dnsformat="awk '{print \"local-zone: \042\"\$0\"\042 static\"}'"
                            break 2
                            ;;
                        named)
                            adb_dns="${dns}"
                            adb_dnsdir="${adb_dnsdir:="/var/lib/bind"}"
                            adb_dnshidedir="${adb_dnsdir}/.adb_hidden"
                            adb_dnsformat="awk '{print \"\"\$0\" IN CNAME .\n*.\"\$0\" IN CNAME .\"}'"
                            break 2
                            ;;
                    esac
                fi
            done
        fi
        sleep 1
        cnt=$((cnt+1))
    done
    if [ -z "${adb_dns}" ] || [ -z "${adb_dnsformat}" ] || [ ! -x "$(command -v ${adb_dns})" ] || [ ! -d "${adb_dnsdir}" ]
    then
        f_log "error" "no active/supported DNS backend found"
    fi

    # force dns to local resolver
    #
    if [ ${adb_forcedns} -eq 1 ] && [ -z "$(uci -q get firewall.adblock_dns)" ]
    then
        uci -q set firewall.adblock_dns="redirect"
        uci -q set firewall.adblock_dns.name="Adblock DNS"
        uci -q set firewall.adblock_dns.src="lan"
        uci -q set firewall.adblock_dns.proto="tcp udp"
        uci -q set firewall.adblock_dns.src_dport="53"
        uci -q set firewall.adblock_dns.dest_port="53"
        uci -q set firewall.adblock_dns.target="DNAT"
    elif [ ${adb_forcedns} -eq 0 ] && [ -n "$(uci -q get firewall.adblock_dns)" ]
    then
        uci -q delete firewall.adblock_dns
    fi
    if [ -n "$(uci -q changes firewall)" ]
    then
        uci -q commit firewall
        if [ $(/etc/init.d/firewall enabled; printf "%u" ${?}) -eq 0 ]
        then
            /etc/init.d/firewall reload >/dev/null 2>&1
        fi
    fi
}

# f_envcheck: check/set environment prerequisites
#
f_envcheck()
{
    local ssl_lib

    # check 'enabled' option
    #
    if [ ${adb_enabled} -ne 1 ]
    then
        if [ -s "${adb_dnsdir}/${adb_dnsfile}" ]
        then
            f_rmdns
            f_dnsrestart
        fi
        f_log "info " "adblock is currently disabled, please set adb_enabled to '1' to use this service"
        exit 0
    fi

    # check fetch utility
    #
    ssl_lib="-"
    if [ -x "${adb_fetch}" ]
    then
        if [ "$(readlink -fn "${adb_fetch}")" = "/usr/bin/wget-nossl" ]
        then
            adb_fetchparm="--quiet --no-cache --no-cookies --max-redirect=0 --timeout=10 -O"
        elif [ "$(readlink -fn "/bin/wget")" = "/bin/busybox" ] || [ "$(readlink -fn "${adb_fetch}")" = "/bin/busybox" ]
        then
            adb_fetch="/bin/busybox"
            adb_fetchparm="-q -O"
        else
            ssl_lib="built-in"
        fi
    fi
    if [ ! -x "${adb_fetch}" ] && [ "$(readlink -fn "/bin/wget")" = "/bin/uclient-fetch" ]
    then
        adb_fetch="/bin/uclient-fetch"
        if [ -f "/lib/libustream-ssl.so" ]
        then
            adb_fetchparm="-q --timeout=10 --no-check-certificate -O"
            ssl_lib="libustream-ssl"
        else
            adb_fetchparm="-q --timeout=10 -O"
        fi
    fi
    if [ ! -x "${adb_fetch}" ] || [ -z "${adb_fetch}" ] || [ -z "${adb_fetchparm}" ]
    then
        f_log "error" "no download utility found, please install 'uclient-fetch' with 'libustream-mbedtls' or the full 'wget' package"
    fi
    adb_fetchinfo="${adb_fetch##*/} (${ssl_lib})"

    # create dns hideout directory
    #
    if [ ! -d "${adb_dnshidedir}" ]
    then
        mkdir -p -m 660 "${adb_dnshidedir}"
        chown -R "${adb_dns}":"${adb_dns}" "${adb_dnshidedir}" 2>/dev/null
    else
        rm -f "${adb_dnshidedir}/${adb_dnsprefix}"*
    fi

    # create adblock temp file/directory
    #
    adb_tmpload="$(mktemp -tu)"
    adb_tmpfile="$(mktemp -tu)"
    adb_tmpdir="$(mktemp -p /tmp -d)"

    # prepare whitelist entries
    #
    if [ -s "${adb_whitelist}" ]
    then
        awk "${adb_whitelist_rset}" "${adb_whitelist}" > "${adb_tmpdir}/tmp.whitelist"
    fi
}

# f_rmtemp: remove temporary files & directories
#
f_rmtemp()
{
    if [ -d "${adb_tmpdir}" ]
    then
        rm -f "${adb_tmpload}"
        rm -f "${adb_tmpfile}"
        rm -rf "${adb_tmpdir}"
    fi
}

# f_rmdns: remove dns related files & directories
#
f_rmdns()
{
    if [ -n "${adb_dns}" ]
    then
        rm -f "${adb_dnsdir}/${adb_dnsprefix}"*
        rm -f "${adb_backupdir}/${adb_dnsprefix}"*.gz
        rm -rf "${adb_dnshidedir}"
        > "${adb_rtfile}"
    fi
}

# f_dnsrestart: restart the dns backend
#
f_dnsrestart()
{
    local dns_up mem_free cnt=0

    "/etc/init.d/${adb_dns}" restart >/dev/null 2>&1
    while [ ${cnt} -le 10 ]
    do
        dns_up="$(ubus -S call service list "{\"name\":\"${adb_dns}\"}" | jsonfilter -l1 -e "@.${adb_dns}.instances.*.running")"
        if [ "${dns_up}" = "true" ]
        then
            mem_free="$(awk '/^MemFree/ {print int($2/1000)}' "/proc/meminfo")"
            if [ ${mem_free} -ge ${adb_minfree} ]
            then
                return 0
            fi
        fi
        cnt=$((cnt+1))
        sleep 1
    done
    return 1
}

# f_list: backup/restore/remove block lists
#
f_list()
{
    local mode="${1}" in_rc="${adb_rc}" cnt=0

    case "${mode}" in
        backup)
            cnt="$(wc -l < "${adb_tmpfile}")"
            if [ ${adb_backup} -eq 1 ] && [ -d "${adb_backupdir}" ]
            then
                gzip -cf "${adb_tmpfile}" > "${adb_backupdir}/${adb_dnsprefix}.${src_name}.gz"
                adb_rc=${?}
            fi
            ;;
        restore)
            if [ ${adb_backup} -eq 1 ] && [ -d "${adb_backupdir}" ] &&
                [ -f "${adb_backupdir}/${adb_dnsprefix}.${src_name}.gz" ]
            then
                gunzip -cf "${adb_backupdir}/${adb_dnsprefix}.${src_name}.gz" > "${adb_tmpfile}"
                adb_rc=${?}
            fi
            ;;
        remove)
            if [ -d "${adb_backupdir}" ]
            then
                rm -f "${adb_backupdir}/${adb_dnsprefix}.${src_name}.gz"
            fi
            adb_rc=${?}
            ;;
        format)
            if [ -s "${adb_tmpdir}/tmp.whitelist" ]
            then
                grep -vf "${adb_tmpdir}/tmp.whitelist" "${adb_tmpfile}" | eval "${adb_dnsformat}" >> "${adb_tmpdir}/${adb_dnsfile}"
            else
                eval "${adb_dnsformat}" "${adb_tmpfile}" >> "${adb_tmpdir}/${adb_dnsfile}"
            fi
            adb_rc=${?}
            ;;
    esac
    f_log "debug" "name: ${src_name}, mode: ${mode}, count: ${cnt}, in_rc: ${in_rc}, out_rc: ${adb_rc}"
}

# f_switch: suspend/resume adblock processing
#
f_switch()
{
    local source target status mode="${1}"

    if [ -d "${adb_dnshidedir}" ]
    then
        if [ -s "${adb_dnsdir}/${adb_dnsfile}" ] && [ "${mode}" = "suspend" ]
        then
            source="${adb_dnsdir}/${adb_dnsfile}"
            target="${adb_dnshidedir}"
            status="suspended"
        elif [ -s "${adb_dnshidedir}/${adb_dnsfile}" ] && [ "${mode}" = "resume" ]
        then
            source="${adb_dnshidedir}/${adb_dnsfile}"
            target="${adb_dnsdir}"
            status="resumed"
        fi
        if [ -n "${status}" ]
        then
            mv -f "${source}"* "${target}"
            f_dnsrestart
            f_log "info " "adblock processing ${status}"
        fi
    fi
}

# f_query: query block list for certain (sub-)domains
#
f_query()
{
    local search result cnt
    local domain="${1}"
    local tld="${domain#*.}"

    if [ ! -s "${adb_dnsdir}/${adb_dnsfile}" ]
    then
         printf "%s\n" "::: no active block list found, please start / resume adblock first"
    elif [ -z "${domain}" ] || [ "${domain}" = "${tld}" ]
    then
        printf "%s\n" "::: invalid domain input, please submit a specific (sub-)domain, e.g. 'www.abc.xyz'"
    else
        cd "${adb_dnsdir}"
        while [ "${domain}" != "${tld}" ]
        do
            search="${domain//./\.}"
            result="$(grep -Hm5 "[/\"\.]${search}[/\"]" "${adb_dnsfile}" | awk -F ':|=|/|\"' '{printf(" + %s\n",$4)}')"
            printf "%s\n" "::: results for (sub-)domain '${domain}' (max. 5)"
            printf "%s\n" "${result:=" - no match"}"
            domain="${tld}"
            tld="${domain#*.}"
        done
    fi
}

# f_status: output runtime information
#
f_status()
{
    local key keylist value

    if [ -s "${adb_rtfile}" ]
    then
        if [ -s "${adb_dnsdir}/${adb_dnsfile}" ]
        then
            value="active"
        else
            value="no domains blocked"
        fi
        printf "%s\n" "::: adblock runtime information"
        printf " %-15s : %s\n" "status" "${value}"
        json_load "$(cat "${adb_rtfile}" 2>/dev/null)"
        json_select data
        json_get_keys keylist
        for key in ${keylist}
        do
            json_get_var value "${key}"
            printf " %-15s : %s\n" "${key}" "${value}"
        done
    fi
}

# f_log: write to syslog, exit on error
#
f_log()
{
    local class="${1}" log_msg="${2}"

    if [ -n "${log_msg}" ] && ([ "${class}" != "debug" ] || [ ${adb_debug} -eq 1 ])
    then
        logger -t "adblock-[${adb_ver}] ${class}" "${log_msg}"
        if [ "${class}" = "error" ]
        then
            logger -t "adblock-[${adb_ver}] ${class}" "Please check 'https://github.com/openwrt/packages/blob/master/net/adblock/files/README.md' (${adb_sysver})"
            f_rmtemp
            if [ -s "${adb_dnsdir}/${adb_dnsfile}" ]
            then
                f_rmdns
                f_dnsrestart
            fi
            exit 1
        fi
    fi
}

# main function for block list processing
#
f_main()
{
    local src_name src_rset shalla_archive enabled url hash_old hash_new cnt=0
    local mem_total="$(awk '/^MemTotal/ {print int($2/1000)}' "/proc/meminfo")"

    f_log "info " "start adblock processing ..."
    f_log "debug" "action: ${adb_action}, manual_mode:${adb_manmode}, backup: ${adb_backup}, dns: ${adb_dns}, fetch: ${adb_fetchinfo}, mem_total: ${mem_total}, force_srt/_dns: ${adb_forcesrt}/${adb_forcedns}"
    > "${adb_rtfile}"
    for src_name in ${adb_sources}
    do
        eval "enabled=\"\${enabled_${src_name}}\""
        eval "url=\"\${adb_src_${src_name}}\""
        eval "src_rset=\"\${adb_src_rset_${src_name}}\""
        > "${adb_tmpload}"
        > "${adb_tmpfile}"
        adb_rc=4

        # basic pre-checks
        #
        f_log "debug" "name: ${src_name}, enabled: ${enabled}, url: ${url}, rset: ${src_rset}"
        if [ "${enabled}" != "1" ] || [ -z "${url}" ] || [ -z "${src_rset}" ]
        then
            f_list remove
            continue
        fi

        # manual mode
        #
        if [ ${adb_manmode} -eq 1 ] && [ -z "${adb_action}" ]
        then
            f_list restore
            if [ ${adb_rc} -eq 0 ] && [ -s "${adb_tmpfile}" ]
            then
                f_list format
                continue
            fi
        fi

        # download block list
        #
        if [ "${src_name}" = "blacklist" ] && [ -s "${url}" ]
        then
            cat "${url}" > "${adb_tmpload}"
            adb_rc=${?}
        elif [ "${src_name}" = "shalla" ]
        then
            shalla_archive="${adb_tmpdir}/shallalist.tar.gz"
            "${adb_fetch}" ${adb_fetchparm} "${shalla_archive}" "${url}" 2>/dev/null
            adb_rc=${?}
            if [ ${adb_rc} -eq 0 ]
            then
                for category in ${adb_src_cat_shalla}
                do
                    tar -xOzf "${shalla_archive}" "BL/${category}/domains" >> "${adb_tmpload}"
                    adb_rc=${?}
                    if [ ${adb_rc} -ne 0 ]
                    then
                        break
                    fi
                done
            fi
            rm -f "${shalla_archive}"
            rm -rf "${adb_tmpdir}/BL"
        else
            "${adb_fetch}" ${adb_fetchparm} "${adb_tmpload}" "${url}" 2>/dev/null
            adb_rc=${?}
        fi

        # check download result and prepare domain output (incl. tld compression, list backup & restore)
        #
        if [ ${adb_rc} -eq 0 ] && [ -s "${adb_tmpload}" ]
        then
            awk "${src_rset}" "${adb_tmpload}" 2>/dev/null > "${adb_tmpfile}"
            if [ -s "${adb_tmpfile}" ]
            then
                awk -F "." '{for(f=NF;f > 1;f--) printf "%s.", $f;print $1}' "${adb_tmpfile}" 2>/dev/null | sort -u > "${adb_tmpload}"
                awk '{if(NR==1){tld=$NF};while(getline){if($NF !~ tld"\\."){print tld;tld=$NF}}print tld}' "${adb_tmpload}" 2>/dev/null > "${adb_tmpfile}"
                awk -F "." '{for(f=NF;f > 1;f--) printf "%s.", $f;print $1}' "${adb_tmpfile}" 2>/dev/null > "${adb_tmpload}"
                mv -f "${adb_tmpload}" "${adb_tmpfile}"
                f_list backup
            else
                f_list restore
            fi
        else
            f_list restore
        fi

        # remove whitelist domains, final list preparation
        #
        if [ ${adb_rc} -eq 0 ] && [ -s "${adb_tmpfile}" ]
        then
            f_list format
            if [ ${adb_rc} -ne 0 ]
            then
                f_list remove
            fi
        else
            f_list remove
        fi
    done

    # hash preparation & overall sort
    #
    if [ -f "${adb_dnsdir}/${adb_dnsfile}" ]
    then
        hash_old="$(sha256sum "${adb_dnsdir}/${adb_dnsfile}" | awk '{print $1}')"
    fi
    if [ -s "${adb_tmpdir}/${adb_dnsfile}" ]
    then
        if [ ${mem_total} -ge 64 ] || [ ${adb_forcesrt} -eq 1 ]
        then
            sort -u "${adb_tmpdir}/${adb_dnsfile}" > "${adb_dnsdir}/${adb_dnsfile}"
        else
            mv -f "${adb_tmpdir}/${adb_dnsfile}" "${adb_dnsdir}" 2>/dev/null
        fi
    else
        > "${adb_dnsdir}/${adb_dnsfile}"
    fi
    hash_new="$(sha256sum "${adb_dnsdir}/${adb_dnsfile}" | awk '{print $1}')"
    cnt="$(wc -l < "${adb_dnsdir}/${adb_dnsfile}")"

    # conditional restart of the dns backend and runtime information export
    #
    chown "${adb_dns}":"${adb_dns}" "${adb_dnsdir}/${adb_dnsfile}" 2>/dev/null
    f_rmtemp
    if [ "${hash_old}" != "${hash_new}" ]
    then
        f_dnsrestart
    fi
    if [ ${?} -eq 0 ]
    then
        json_init
        json_add_object "data"
        json_add_string "adblock_version" "${adb_ver}"
        json_add_string "blocked_domains" "${cnt}"
        json_add_string "fetch_info" "${adb_fetchinfo}"
        json_add_string "dns_backend" "${adb_dns}"
        json_add_string "last_rundate" "$(/bin/date "+%d.%m.%Y %H:%M:%S")"
        json_add_string "system" "${adb_sysver}"
        json_close_object
        json_dump > "${adb_rtfile}"
        f_log "info " "block list with overall ${cnt} domains loaded successfully (${adb_sysver})"
    else
        f_log "error" "dns backend restart with active block list failed"
    fi
}

# handle different adblock actions
#
f_envload
case "${adb_action}" in
    stop)
        f_rmtemp
        f_rmdns
        f_dnsrestart
        ;;
    restart)
        f_rmtemp
        f_rmdns
        f_envcheck
        f_main
        ;;
    suspend)
        f_switch suspend
        ;;
    resume)
        f_switch resume
        ;;
    query)
        f_query "${2}"
        ;;
    status)
        f_status
        ;;
    *)
        f_envcheck
        f_main
        ;;
esac
exit 0

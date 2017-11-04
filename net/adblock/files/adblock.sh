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
adb_ver="3.1.0"
adb_sysver="unknown"
adb_enabled=0
adb_debug=0
adb_backup_mode=0
adb_whitelist_mode=0
adb_forcesrt=0
adb_forcedns=0
adb_triggerdelay=0
adb_backup=0
adb_backupdir="/mnt"
adb_fetch="/usr/bin/wget"
adb_fetchparm="--quiet --no-cache --no-cookies --max-redirect=0 --timeout=10 --no-check-certificate -O"
adb_dns="dnsmasq"
adb_dnsprefix="adb_list"
adb_dnsfile="${adb_dnsprefix}.overall"
adb_whitelist="/etc/adblock/adblock.whitelist"
adb_rtfile="/tmp/adb_runtime.json"
adb_action="${1:-"start"}"
adb_cnt=0
adb_rc=0

# f_envload: load adblock environment
#
f_envload()
{
    local dns_up sys_call sys_desc sys_model sys_ver cnt=0

    # get system information
    #
    sys_call="$(ubus -S call system board 2>/dev/null)"
    if [ -n "${sys_call}" ]
    then
        sys_desc="$(printf '%s' "${sys_call}" | jsonfilter -e '@.release.description')"
        sys_model="$(printf '%s' "${sys_call}" | jsonfilter -e '@.model')"
        sys_ver="$(cat /etc/turris-version 2>/dev/null)"
        if [ -n "${sys_ver}" ]
        then
            sys_desc="${sys_desc}/${sys_ver}"
        fi
        adb_sysver="${sys_model}, ${sys_desc}"
    fi

    # source in system libraries
    #
    if [ -r "/lib/functions.sh" ] && [ -r "/usr/share/libubox/jshn.sh" ]
    then
        . "/lib/functions.sh"
        . "/usr/share/libubox/jshn.sh"
    else
        f_log "error" "system libraries not found"
    fi

    # parse 'global' and 'extra' section by callback
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

    # parse 'source' typed sections
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

    # set/check dns backend environment
    #
    case "${adb_dns}" in
        dnsmasq)
            adb_dnsuser="${adb_dnsuser:-"dnsmasq"}"
            adb_dnsdir="${adb_dnsdir:-"/tmp/dnsmasq.d"}"
            adb_dnsformat="awk '{print \"local=/\"\$0\"/\"}'"
            if [ ${adb_whitelist_mode} -eq 1 ]
            then
                adb_dnsformat="awk '{print \"local=/\"\$0\"/#\"}'"
                adb_dnsblock="local=/#/"
            fi
            ;;
        unbound)
            adb_dnsuser="${adb_dnsuser:-"unbound"}"
            adb_dnsdir="${adb_dnsdir:-"/var/lib/unbound"}"
            adb_dnsformat="awk '{print \"local-zone: \042\"\$0\"\042 static\"}'"
            if [ ${adb_whitelist_mode} -eq 1 ]
            then
                adb_dnsformat="awk '{print \"local-zone: \042\"\$0\"\042 transparent\"}'"
                adb_dnsblock="local-zone: \".\" static"
            fi
            ;;
        named)
            adb_dnsuser="${adb_dnsuser:-"bind"}"
            adb_dnsdir="${adb_dnsdir:-"/var/lib/bind"}"
            adb_dnsheader="\$TTL 2h"$'\n'"@ IN SOA localhost. root.localhost. (1 6h 1h 1w 2h)"$'\n'"  IN NS localhost."
            adb_dnsformat="awk '{print \"\"\$0\" CNAME .\n*.\"\$0\" CNAME .\"}'"
            if [ ${adb_whitelist_mode} -eq 1 ]
            then
                adb_dnsformat="awk '{print \"\"\$0\" CNAME rpz-passthru.\n*.\"\$0\" CNAME rpz-passthru.\"}'"
                adb_dnsblock="* CNAME ."
            fi
            ;;
        kresd)
            adb_dnsuser="${adb_dnsuser:-"root"}"
            adb_dnsdir="${adb_dnsdir:-"/etc/kresd"}"
            adb_dnsheader="\$TTL 2h"$'\n'"@ IN SOA localhost. root.localhost. (1 6h 1h 1w 2h)"$'\n'"  IN NS  localhost."
            adb_dnsformat="awk '{print \"\"\$0\" CNAME .\n*.\"\$0\" CNAME .\"}'"
            if [ ${adb_whitelist_mode} -eq 1 ]
            then
                adb_dnsformat="awk '{print \"\"\$0\" CNAME rpz-passthru.\n*.\"\$0\" CNAME rpz-passthru.\"}'"
                adb_dnsblock="* CNAME ."
            fi
            ;;
        dnscrypt-proxy)
            adb_dnsuser="${adb_dnsuser:-"nobody"}"
            adb_dnsdir="${adb_dnsdir:-"/tmp"}"
            adb_dnsformat="awk '{print \$0}'"
            ;;
    esac

    if [ ${adb_enabled} -ne 1 ]
    then
        if [ -s "${adb_dnsdir}/${adb_dnsfile}" ]
        then
            f_rmdns
            f_dnsrestart
        fi
        f_jsnupdate
        f_log "info " "adblock is currently disabled, please set adb_enabled to '1' to use this service"
        exit 0
    fi

    if [ -d "${adb_dnsdir}" ] && [ ! -f "${adb_dnsdir}/${adb_dnsfile}" ]
    then
        > "${adb_dnsdir}/${adb_dnsfile}"
    fi

    case "${adb_action}" in
        start|restart|reload)
            > "${adb_rtfile}"
            if [ "${adb_action}" = "start" ] && [ "${adb_trigger}" = "timed" ]
            then
                sleep ${adb_triggerdelay}
            fi
        ;;
    esac

    while [ ${cnt} -le 30 ]
    do
        dns_up="$(ubus -S call service list "{\"name\":\"${adb_dns}\"}" 2>/dev/null | jsonfilter -l1 -e "@[\"${adb_dns}\"].instances.*.running" 2>/dev/null)"
        if [ "${dns_up}" = "true" ]
        then
            break
        fi
        sleep 1
        cnt=$((cnt+1))
    done

    if [ -z "${adb_dns}" ] || [ -z "${adb_dnsformat}" ] || [ ! -x "$(command -v ${adb_dns})" ] || [ ! -d "${adb_dnsdir}" ]
    then
        f_log "error" "'${adb_dns}' not running, DNS backend not found"
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

    # check fetch utility
    #
    ssl_lib="-"
    if [ -x "${adb_fetch}" ]
    then
        if [ "$(readlink -fn "${adb_fetch}")" = "/usr/bin/wget-nossl" ]
        then
            adb_fetchparm="--quiet --no-cache --no-cookies --max-redirect=0 --timeout=10 -O"
        elif [ "$(readlink -fn "${adb_fetch}")" = "/bin/busybox" ] ||
            ([ "$(readlink -fn "/bin/wget")" = "/bin/busybox" ] && [ "$(readlink -fn "${adb_fetch}")" != "/usr/bin/wget" ])
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

    # initialize temp files and directories
    #
    adb_tmpload="$(mktemp -tu)"
    adb_tmpfile="$(mktemp -tu)"
    adb_tmpdir="$(mktemp -p /tmp -d)"
    > "${adb_tmpdir}/tmp.whitelist"
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
        > "${adb_dnsdir}/${adb_dnsfile}"
        > "${adb_rtfile}"
        rm -f "${adb_dnsdir}/.${adb_dnsfile}"
        rm -f "${adb_backupdir}/${adb_dnsprefix}"*.gz
    fi
}

# f_dnsrestart: restart the dns backend
#
f_dnsrestart()
{
    local dns_up cnt=0

    "/etc/init.d/${adb_dns}" restart >/dev/null 2>&1
    while [ ${cnt} -le 10 ]
    do
        dns_up="$(ubus -S call service list "{\"name\":\"${adb_dns}\"}" | jsonfilter -l1 -e "@[\"${adb_dns}\"].instances.*.running")"
        if [ "${dns_up}" = "true" ]
        then
            return 0
        fi
        cnt=$((cnt+1))
        sleep 1
    done
    return 1
}

# f_list: backup/restore/remove blocklists
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
        merge)
            if [ -s "${adb_tmpfile}" ]
            then
                cat "${adb_tmpfile}" >> "${adb_tmpdir}/${adb_dnsfile}"
                adb_rc=${?}
            fi
            ;;
        format)
            if [ -s "${adb_tmpdir}/tmp.whitelist" ]
            then
                grep -vf "${adb_tmpdir}/tmp.whitelist" "${adb_tmpdir}/${adb_dnsfile}" | eval "${adb_dnsformat}" > "${adb_dnsdir}/${adb_dnsfile}"
            else
                eval "${adb_dnsformat}" "${adb_tmpdir}/${adb_dnsfile}" > "${adb_dnsdir}/${adb_dnsfile}"
            fi
            if [ -n "${adb_dnsheader}" ]
            then
                printf '%s\n' "${adb_dnsheader}" | cat - "${adb_dnsdir}/${adb_dnsfile}" > "${adb_tmpdir}/${adb_dnsfile}"
                cat "${adb_tmpdir}/${adb_dnsfile}" > "${adb_dnsdir}/${adb_dnsfile}"
            fi
            adb_rc=${?}
            ;;
    esac
    f_log "debug" "name: ${src_name}, mode: ${mode}, count: ${cnt}, in_rc: ${in_rc}, out_rc: ${adb_rc}"
}

# f_tldcompression: top level domain compression
#
f_tldcompression()
{
    local source="${1}" temp="${adb_tmpload}"

    awk -F "." '{for(f=NF;f > 1;f--) printf "%s.", $f;print $1}' "${source}" 2>/dev/null | sort -u > "${temp}"
    awk '{if(NR==1){tld=$NF};while(getline){if($NF !~ tld"\\."){print tld;tld=$NF}}print tld}' "${temp}" 2>/dev/null > "${source}"
    awk -F "." '{for(f=NF;f > 1;f--) printf "%s.", $f;print $1}' "${source}" 2>/dev/null > "${temp}"
    sort -u "${temp}" > "${source}"
}

# f_switch: suspend/resume adblock processing
#
f_switch()
{
    local source target status mode="${1}"

    if [ -s "${adb_dnsdir}/${adb_dnsfile}" ] && [ "${mode}" = "suspend" ]
    then
        source="${adb_dnsdir}/${adb_dnsfile}"
        target="${adb_dnsdir}/.${adb_dnsfile}"
        status="suspended"
    elif [ -s "${adb_dnsdir}/.${adb_dnsfile}" ] && [ "${mode}" = "resume" ]
    then
        source="${adb_dnsdir}/.${adb_dnsfile}"
        target="${adb_dnsdir}/${adb_dnsfile}"
        status="resumed"
    fi
    if [ -n "${status}" ]
    then
        cat "${source}" > "${target}"
        > "${source}"
        chown "${adb_dnsuser}" "${target}" 2>/dev/null
        f_dnsrestart
        f_jsnupdate
        f_log "info " "adblock processing ${status}"
    fi
}

# f_query: query blocklist for certain (sub-)domains
#
f_query()
{
    local search result cnt
    local domain="${1}"
    local tld="${domain#*.}"

    if [ ! -s "${adb_dnsdir}/${adb_dnsfile}" ]
    then
         printf "%s\n" "::: no active blocklist found, please start / resume adblock first"
    elif [ -z "${domain}" ] || [ "${domain}" = "${tld}" ]
    then
        printf "%s\n" "::: invalid domain input, please submit a single domain, e.g. 'doubleclick.net'"
    else
        cd "${adb_dnsdir}"
        while [ "${domain}" != "${tld}" ]
        do
            search="${domain//./\.}"
            if [ "${adb_dns}" = "dnsmasq" ] || [ "${adb_dns}" = "unbound" ]
            then
                result="$(awk -F '/|\"' "/[\/\"\.]${search}/{i++;{printf(\"  + %s\n\",\$2)};if(i>9){exit}}" "${adb_dnsfile}")"
            else
                result="$(awk "/(^[^\*][[:alpha:]]*[\.]+${search}|^${search})/{i++;{printf(\"  + %s\n\",\$1)};if(i>9){exit}}" "${adb_dnsfile}")"
            fi
            printf "%s\n" "::: max. ten results for domain '${domain}'"
            printf "%s\n" "${result:-"  - no match"}"
            domain="${tld}"
            tld="${domain#*.}"
        done
    fi
}

# f_jsnupdate: update runtime information
#
f_jsnupdate()
{
    local status rundate="$(/bin/date "+%d.%m.%Y %H:%M:%S")"

    if [ ${adb_rc} -gt 0 ]
    then
        status="error"
    elif [ ${adb_enabled} -ne 1 ]
    then
        status="disabled"
    elif [ -s "${adb_dnsdir}/.${adb_dnsfile}" ]
    then
        status="paused"
    else
        status="enabled"
        if [ -s "${adb_dnsdir}/${adb_dnsfile}" ]
        then
            if [ "${adb_dns}" = "named" ] || [ "${adb_dns}" = "kresd" ]
            then
                adb_cnt="$(( ( $(wc -l < "${adb_dnsdir}/${adb_dnsfile}") - $(printf "%s" "${adb_dnsheader}" | grep -c "^") ) / 2 ))"
            else
                adb_cnt="$(wc -l < "${adb_dnsdir}/${adb_dnsfile}")"
            fi
        fi
    fi

    if [ -z "${adb_fetchinfo}" ] && [ -s "${adb_rtfile}" ]
    then
        json_load "$(cat "${adb_rtfile}" 2>/dev/null)"
        json_select data
        json_get_var adb_fetchinfo "fetch_utility"
    fi

    json_init
    json_add_object "data"
    json_add_string "adblock_status" "${status}"
    json_add_string "adblock_version" "${adb_ver}"
    json_add_string "overall_domains" "${adb_cnt}"
    json_add_string "fetch_utility" "${adb_fetchinfo}"
    json_add_string "dns_backend" "${adb_dns} (${adb_dnsdir})"
    json_add_string "last_rundate" "${rundate}"
    json_add_string "system_release" "${adb_sysver}"
    json_close_object
    json_dump > "${adb_rtfile}"
}

# f_status: output runtime information
#
f_status()
{
    local key keylist value

    if [ -s "${adb_rtfile}" ]
    then
        printf "%s\n" "::: adblock runtime information"
        json_load "$(cat "${adb_rtfile}" 2>/dev/null)"
        json_select data
        json_get_keys keylist
        for key in ${keylist}
        do
            json_get_var value "${key}"
            printf "  + %-15s : %s\n" "${key}" "${value}"
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
            adb_rc=1
            f_jsnupdate
            exit 1
        fi
    fi
}

# main function for blocklist processing
#
f_main()
{
    local src_name src_rset shalla_archive enabled url hash_old hash_new
    local mem_total="$(awk '/^MemTotal/ {print int($2/1000)}' "/proc/meminfo")"

    f_log "info " "start adblock processing ..."
    f_log "debug" "action: ${adb_action}, dns: ${adb_dns}, fetch: ${adb_fetchinfo}, backup: ${adb_backup}, backup_mode: ${adb_backup_mode}, whitelist_mode: ${adb_whitelist_mode}, force_srt/_dns: ${adb_forcesrt}/${adb_forcedns}, mem_total: ${mem_total}"
    > "${adb_rtfile}"
    > "${adb_dnsdir}/.${adb_dnsfile}"

    # prepare whitelist entries
    #
    if [ -s "${adb_whitelist}" ]
    then
        if [ ${adb_whitelist_mode} -eq 1 ] && [ "${adb_dns}" != "dnscrypt-proxy" ]
        then
            adb_whitelist_rset="\$0~/^([[:alnum:]_-]+\.){1,}[[:alpha:]]+([[:space:]]|$)/{print tolower(\$1)}"
        else
            adb_whitelist_rset="\$0~/^([[:alnum:]_-]+\.){1,}[[:alpha:]]+([[:space:]]|$)/{gsub(\"\\\.\",\"\\\.\",\$1);print tolower(\"^\"\$1\"\\\|\\\.\"\$1)}"
        fi
        awk "${adb_whitelist_rset}" "${adb_whitelist}" > "${adb_tmpdir}/tmp.whitelist"
    fi

    # whitelist mode
    #
    if [ ${adb_whitelist_mode} -eq 1 ] && [ "${adb_dns}" != "dnscrypt-proxy" ]
    then
        f_tldcompression "${adb_tmpdir}/tmp.whitelist"
        eval "${adb_dnsformat}" "${adb_tmpdir}/tmp.whitelist" > "${adb_dnsdir}/${adb_dnsfile}"
        printf '%s\n' "${adb_dnsblock}" >> "${adb_dnsdir}/${adb_dnsfile}"
        if [ -n "${adb_dnsheader}" ]
        then
            printf '%s\n' "${adb_dnsheader}" | cat - "${adb_dnsdir}/${adb_dnsfile}" > "${adb_tmpdir}/${adb_dnsfile}"
            cat "${adb_tmpdir}/${adb_dnsfile}" > "${adb_dnsdir}/${adb_dnsfile}"
        fi
        f_dnsrestart
        if [ ${?} -eq 0 ]
        then
            f_jsnupdate "${adb_cnt}"
            f_log "info " "whitelist with overall ${adb_cnt} domains loaded successfully (${adb_sysver})"
        else
            f_log "error" "dns backend restart with active whitelist failed"
        fi
        return
    fi

    # normal & backup mode
    #
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

        # backup mode
        #
        if [ ${adb_backup_mode} -eq 1 ] && [ "${adb_action}" = "start" ] && [ "${src_name}" != "blacklist" ]
        then
            f_list restore
            if [ ${adb_rc} -eq 0 ] && [ -s "${adb_tmpfile}" ]
            then
                f_list merge
                continue
            fi
        fi

        # download blocklist
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

        # check download result and prepare list output (incl. tld compression, list backup & restore)
        #
        if [ ${adb_rc} -eq 0 ] && [ -s "${adb_tmpload}" ]
        then
            awk "${src_rset}" "${adb_tmpload}" 2>/dev/null > "${adb_tmpfile}"
            if [ -s "${adb_tmpfile}" ]
            then
                f_tldcompression "${adb_tmpfile}"
                if [ "${src_name}" != "blacklist" ]
                then
                    f_list backup
                fi
            else
                f_list restore
            fi
        else
            f_list restore
        fi

        # list merge
        #
        if [ ${adb_rc} -eq 0 ] && [ -s "${adb_tmpfile}" ]
        then
            f_list merge
            if [ ${adb_rc} -ne 0 ]
            then
                f_list remove
            fi
        else
            f_list remove
        fi
    done

    # hash preparation, whitelist removal and overall sort
    #
    if [ -f "${adb_dnsdir}/${adb_dnsfile}" ]
    then
        hash_old="$(sha256sum "${adb_dnsdir}/${adb_dnsfile}" 2>/dev/null | awk '{print $1}')"
    fi
    if [ -s "${adb_tmpdir}/${adb_dnsfile}" ]
    then
        if [ ${mem_total} -ge 64 ] || [ ${adb_forcesrt} -eq 1 ]
        then
            f_tldcompression "${adb_tmpdir}/${adb_dnsfile}"
        fi
        f_list format
    else
        > "${adb_dnsdir}/${adb_dnsfile}"
    fi
    chown "${adb_dnsuser}" "${adb_dnsdir}/${adb_dnsfile}" 2>/dev/null
    f_rmtemp

    # conditional restart of the dns backend and runtime information export
    #
    hash_new="$(sha256sum "${adb_dnsdir}/${adb_dnsfile}" 2>/dev/null | awk '{print $1}')"
    if [ -z "${hash_old}" ] || [ -z "${hash_new}" ] || [ "${hash_old}" != "${hash_new}" ]
    then
        f_dnsrestart
    fi
    if [ ${?} -eq 0 ]
    then
        f_jsnupdate "${adb_cnt}"
        f_log "info " "blocklist with overall ${adb_cnt} domains loaded successfully (${adb_sysver})"
    else
        f_log "error" "dns backend restart with active blocklist failed"
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

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
adb_ver="3.5.1"
adb_sysver="unknown"
adb_enabled=0
adb_debug=0
adb_backup_mode=0
adb_forcesrt=0
adb_forcedns=0
adb_jail=0
adb_maxqueue=4
adb_notify=0
adb_notifycnt=0
adb_triggerdelay=0
adb_backup=0
adb_backupdir="/mnt"
adb_fetchutil="uclient-fetch"
adb_dns="dnsmasq"
adb_dnsprefix="adb_list"
adb_dnsfile="${adb_dnsprefix}.overall"
adb_dnsjail="${adb_dnsprefix}.jail"
adb_dnsflush=0
adb_whitelist="/etc/adblock/adblock.whitelist"
adb_rtfile="/tmp/adb_runtime.json"
adb_hashutil="$(command -v sha256sum)"
adb_hashold=""
adb_hashnew=""
adb_cnt=0
adb_rc=0
adb_action="${1:-"start"}"
adb_pidfile="/var/run/adblock.pid"

# load adblock environment
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

    # check hash utility
    #
    if [ ! -x "${adb_hashutil}" ]
    then
        adb_hashutil="$(command -v md5sum)"
    fi

    # source in system libraries
    #
    if [ -r "/lib/functions.sh" ] && [ -r "/usr/share/libubox/jshn.sh" ]
    then
        . "/lib/functions.sh"
        . "/usr/share/libubox/jshn.sh"
    else
        f_log "err" "system libraries not found"
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

    # check dns backend
    #
    case "${adb_dns}" in
        dnsmasq)
            adb_dnsinstance="${adb_dnsinstance:-"0"}"
            adb_dnsuser="${adb_dnsuser:-"dnsmasq"}"
            adb_dnsdir="${adb_dnsdir:-"/tmp"}"
            adb_dnsheader=""
            adb_dnsdeny="awk '{print \"server=/\"\$0\"/\"}'"
            if [ ${adb_jail} -eq 1 ]
            then
                adb_dnsallow="awk '{print \"server=/\"\$0\"/#\"}'"
                adb_dnshalt="server=/#/"
            fi
        ;;
        unbound)
            adb_dnsinstance="${adb_dnsinstance:-"0"}"
            adb_dnsuser="${adb_dnsuser:-"unbound"}"
            adb_dnsdir="${adb_dnsdir:-"/var/lib/unbound"}"
            adb_dnsheader=""
            adb_dnsdeny="awk '{print \"local-zone: \042\"\$0\"\042 static\"}'"
            if [ ${adb_jail} -eq 1 ]
            then
                adb_dnsallow="awk '{print \"local-zone: \042\"\$0\"\042 transparent\"}'"
                adb_dnshalt="local-zone: \".\" static"
            fi
        ;;
        named)
            adb_dnsinstance="${adb_dnsinstance:-"0"}"
            adb_dnsuser="${adb_dnsuser:-"bind"}"
            adb_dnsdir="${adb_dnsdir:-"/var/lib/bind"}"
            adb_dnsheader="\$TTL 2h"$'\n'"@ IN SOA localhost. root.localhost. (1 6h 1h 1w 2h)"$'\n'"  IN NS localhost."
            adb_dnsdeny="awk '{print \"\"\$0\" CNAME .\n*.\"\$0\" CNAME .\"}'"
            if [ ${adb_jail} -eq 1 ]
            then
                adb_dnsallow="awk '{print \"\"\$0\" CNAME rpz-passthru.\n*.\"\$0\" CNAME rpz-passthru.\"}'"
                adb_dnshalt="* CNAME ."
            fi
        ;;
        kresd)
            adb_dnsinstance="${adb_dnsinstance:-"0"}"
            adb_dnsuser="${adb_dnsuser:-"root"}"
            adb_dnsdir="${adb_dnsdir:-"/etc/kresd"}"
            adb_dnsheader="\$TTL 2h"$'\n'"@ IN SOA localhost. root.localhost. (1 6h 1h 1w 2h)"$'\n'"  IN NS  localhost."
            adb_dnsdeny="awk '{print \"\"\$0\" CNAME .\n*.\"\$0\" CNAME .\"}'"
            if [ ${adb_jail} -eq 1 ]
            then
                adb_dnsallow="awk '{print \"\"\$0\" CNAME rpz-passthru.\n*.\"\$0\" CNAME rpz-passthru.\"}'"
                adb_dnshalt="* CNAME ."
            fi
        ;;
        dnscrypt-proxy)
            adb_dnsinstance="${adb_dnsinstance:-"0"}"
            adb_dnsuser="${adb_dnsuser:-"nobody"}"
            adb_dnsdir="${adb_dnsdir:-"/tmp"}"
            adb_dnsheader=""
            adb_dnsdeny="awk '{print \$0}'"
        ;;
    esac

    # check adblock status
    #
    if [ ${adb_enabled} -eq 0 ]
    then
        f_extconf
        f_temp
        f_rmdns
        f_jsnup
        f_log "info" "adblock is currently disabled, please set adb_enabled to '1' to use this service"
        exit 0
    fi

    if [ -d "${adb_dnsdir}" ] && [ ! -f "${adb_dnsdir}/${adb_dnsfile}" ]
    then
        printf '%s\n' "${adb_dnsheader}" > "${adb_dnsdir}/${adb_dnsfile}"
    fi

    if [ "${adb_action}" = "start" ] && [ "${adb_trigger}" = "timed" ]
    then
        sleep ${adb_triggerdelay}
    fi

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

    if [ -z "${adb_dns}" ] || [ -z "${adb_dnsdeny}" ] || [ ! -x "$(command -v ${adb_dns})" ] || [ ! -d "${adb_dnsdir}" ]
    then
        f_log "err" "'${adb_dns}' not running, DNS backend not found"
    fi
}

# check environment
#
f_envcheck()
{
    local ssl_lib

    # check external uci config files
    #
    f_extconf

    # check fetch utility
    #
    case "${adb_fetchutil}" in
        uclient-fetch)
            if [ -f "/lib/libustream-ssl.so" ]
            then
                adb_fetchparm="${adb_fetchparm:-"--timeout=10 --no-check-certificate -O"}"
                ssl_lib="libustream-ssl"
            else
                adb_fetchparm="${adb_fetchparm:-"--timeout=10 -O"}"
            fi
        ;;
        wget)
            adb_fetchparm="${adb_fetchparm:-"--no-cache --no-cookies --max-redirect=0 --timeout=10 --no-check-certificate -O"}"
            ssl_lib="built-in"
        ;;
        wget-nossl)
            adb_fetchparm="${adb_fetchparm:-"--no-cache --no-cookies --max-redirect=0 --timeout=10 -O"}"
        ;;
        busybox)
            adb_fetchparm="${adb_fetchparm:-"-O"}"
        ;;
        curl)
            adb_fetchparm="${adb_fetchparm:-"--connect-timeout 10 --insecure -o"}"
            ssl_lib="built-in"
        ;;
        aria2c)
            adb_fetchparm="${adb_fetchparm:-"--timeout=10 --allow-overwrite=true --auto-file-renaming=false --check-certificate=false -o"}"
            ssl_lib="built-in"
        ;;
    esac
    adb_fetchutil="$(command -v "${adb_fetchutil}")"

    if [ ! -x "${adb_fetchutil}" ] || [ -z "${adb_fetchutil}" ] || [ -z "${adb_fetchparm}" ]
    then
        f_log "err" "download utility not found, please install 'uclient-fetch' with 'libustream-mbedtls' or the full 'wget' package"
    fi
    adb_fetchinfo="${adb_fetchutil} (${ssl_lib:-"-"})"

    f_temp
    f_jsnup "running"
    f_log "info" "start adblock processing (${adb_action})"
}

# create temporay files and directories
#
f_temp()
{
    if [ -z "${adb_tmpdir}" ]
    then
        adb_tmpdir="$(mktemp -p /tmp -d)"
        adb_tmpload="$(mktemp -p ${adb_tmpdir} -tu)"
        adb_tmpfile="$(mktemp -p ${adb_tmpdir} -tu)"
    fi
    if [ ! -s "${adb_pidfile}" ]
    then
        printf '%s' "${$}" > "${adb_pidfile}"
    fi
}

# remove temporay files and directories
#
f_rmtemp()
{
    if [ -d "${adb_tmpdir}" ]
    then
        rm -rf "${adb_tmpdir}"
    fi
    > "${adb_pidfile}"
}

# remove dns related files and directories
#
f_rmdns()
{
    if [ -n "${adb_dns}" ]
    then
        f_hash
        printf '%s\n' "${adb_dnsheader}" > "${adb_dnsdir}/${adb_dnsfile}"
        > "${adb_dnsdir}/.${adb_dnsfile}"
        > "${adb_rtfile}"
        rm -f "${adb_backupdir}/${adb_dnsprefix}"*.gz
        f_hash
        if [ ${?} -eq 1 ]
        then
            f_dnsup
        fi
        f_rmtemp
    fi
    f_log "debug" "f_rmdns::: dns: ${adb_dns}, dns_dir: ${adb_dnsdir}, dns_prefix: ${adb_dnsprefix}, dns_file: ${adb_dnsfile}, rt_file: ${adb_rtfile}, backup_dir: ${adb_backupdir}"
}

# commit uci changes
#
f_uci()
{
    local change config="${1}"

    if [ -n "${config}" ]
    then
        change="$(uci -q changes "${config}" | awk '{ORS=" "; print $0}')"
        if [ -n "${change}" ]
        then
            uci -q commit "${config}"
            case "${config}" in
                firewall)
                    /etc/init.d/firewall reload >/dev/null 2>&1
                ;;
                *)
                    /etc/init.d/"${adb_dns}" reload >/dev/null 2>&1
                ;;
            esac
        fi
    fi
    f_log "debug" "f_uci  ::: config: ${config}, change: ${change}"
}

# list/overall count
#
f_count()
{
    local mode="${1}"

    adb_cnt=0
    if [ -s "${adb_dnsdir}/${adb_dnsfile}" ] && ([ -z "${mode}" ] || [ "${mode}" = "final" ])
    then
        if [ "${adb_dns}" = "named" ] || [ "${adb_dns}" = "kresd" ]
        then
            adb_cnt="$(( ($(wc -l 2>/dev/null < "${adb_dnsdir}/${adb_dnsfile}") - $(printf "%s" "${adb_dnsheader}" | grep -c "^")) / 2 ))"
        else
            adb_cnt="$(wc -l 2>/dev/null < "${adb_dnsdir}/${adb_dnsfile}")"
        fi
    elif [ "${mode}" = "whitelist" ] && [ -s "${adb_tmpdir}/tmp.whitelist" ]
    then
        adb_cnt="$(wc -l 2>/dev/null < "${adb_tmpdir}/tmp.whitelist")"
    elif [ -s "${adb_tmpfile}" ]
    then
        adb_cnt="$(wc -l 2>/dev/null < "${adb_tmpfile}")"
    fi
}

# set external config options
#
f_extconf()
{
    local uci_config

    case "${adb_dns}" in
        dnsmasq)
            uci_config="dhcp"
            if [ ${adb_enabled} -eq 1 ] && [ -z "$(uci -q get dhcp.@dnsmasq[${adb_dnsinstance}].serversfile | grep -Fo "${adb_dnsdir}/${adb_dnsfile}")" ]
            then
                uci -q set dhcp.@dnsmasq[${adb_dnsinstance}].serversfile="${adb_dnsdir}/${adb_dnsfile}"
            elif [ ${adb_enabled} -eq 0 ] && [ -n "$(uci -q get dhcp.@dnsmasq[${adb_dnsinstance}].serversfile | grep -Fo "${adb_dnsdir}/${adb_dnsfile}")" ]
            then
                uci -q delete dhcp.@dnsmasq[${adb_dnsinstance}].serversfile
            fi
        ;;
        kresd)
            uci_config="resolver"
            if [ ${adb_enabled} -eq 1 ] && [ -z "$(uci -q get resolver.kresd.rpz_file | grep -Fo "${adb_dnsdir}/${adb_dnsfile}")" ]
            then
                uci -q add_list resolver.kresd.rpz_file="${adb_dnsdir}/${adb_dnsfile}"
            elif [ ${adb_enabled} -eq 0 ] && [ -n "$(uci -q get resolver.kresd.rpz_file | grep -Fo "${adb_dnsdir}/${adb_dnsfile}")" ]
            then
                uci -q del_list resolver.kresd.rpz_file="${adb_dnsdir}/${adb_dnsfile}"
            fi
            if [ ${adb_enabled} -eq 1 ] && [ ${adb_dnsflush} -eq 0 ] && [ "$(uci -q get resolver.kresd.keep_cache)" != "1" ]
            then
                uci -q set resolver.kresd.keep_cache="1"
            elif [ ${adb_enabled} -eq 0 ] || ([ ${adb_dnsflush} -eq 1 ] && [ "$(uci -q get resolver.kresd.keep_cache)" = "1" ])
            then
                uci -q set resolver.kresd.keep_cache="0"
            fi
        ;;
    esac
    f_uci "${uci_config}"

    uci_config="firewall"
    if [ ${adb_enabled} -eq 1 ] && [ ${adb_forcedns} -eq 1 ] && \
       [ -z "$(uci -q get firewall.adblock_dns)" ] && [ $(/etc/init.d/firewall enabled; printf "%u" ${?}) -eq 0 ]
    then
        uci -q set firewall.adblock_dns="redirect"
        uci -q set firewall.adblock_dns.name="Adblock DNS"
        uci -q set firewall.adblock_dns.src="lan"
        uci -q set firewall.adblock_dns.proto="tcp udp"
        uci -q set firewall.adblock_dns.src_dport="53"
        uci -q set firewall.adblock_dns.dest_port="53"
        uci -q set firewall.adblock_dns.target="DNAT"
    elif [ -n "$(uci -q get firewall.adblock_dns)" ] && ([ ${adb_enabled} -eq 0 ] || [ ${adb_forcedns} -eq 0 ])
    then
        uci -q delete firewall.adblock_dns
    fi
    f_uci "${uci_config}"
}

# restart of the dns backend
#
f_dnsup()
{
    local dns_up cache_util cache_rc cnt=0

    if [ ${adb_dnsflush} -eq 0 ] && [ ${adb_enabled} -eq 1 ] && [ "${adb_rc}" -eq 0 ]
    then
        case "${adb_dns}" in
            dnsmasq)
                killall -q -HUP "${adb_dns}"
                cache_rc=${?}
            ;;
            unbound)
                cache_util="$(command -v unbound-control)"
                if [ -x "${cache_util}" ] && [ -d "${adb_tmpdir}" ] && [ -f "${adb_dnsdir}"/unbound.conf ]
                then
                    "${cache_util}" -c "${adb_dnsdir}"/unbound.conf dump_cache > "${adb_tmpdir}"/adb_cache.dump 2>/dev/null
                fi
                "/etc/init.d/${adb_dns}" restart >/dev/null 2>&1
            ;;
            kresd)
                cache_util="keep_cache"
                "/etc/init.d/${adb_dns}" restart >/dev/null 2>&1
                cache_rc=${?}
            ;;
            named)
                cache_util="$(command -v rndc)"
                if [ -x "${cache_util}" ] && [ -f /etc/bind/rndc.conf ]
                then
                    "${cache_util}" -c /etc/bind/rndc.conf reload >/dev/null 2>&1
                    cache_rc=${?}
                else
                    "/etc/init.d/${adb_dns}" restart >/dev/null 2>&1
                fi
            ;;
            *)
                "/etc/init.d/${adb_dns}" restart >/dev/null 2>&1
            ;;
        esac
    else
        "/etc/init.d/${adb_dns}" restart >/dev/null 2>&1
    fi

    adb_rc=1
    while [ ${cnt} -le 10 ]
    do
        dns_up="$(ubus -S call service list "{\"name\":\"${adb_dns}\"}" | jsonfilter -l1 -e "@[\"${adb_dns}\"].instances.*.running")"
        if [ "${dns_up}" = "true" ]
        then
            case "${adb_dns}" in
                unbound)
                    cache_util="$(command -v unbound-control)"
                    if [ -x "${cache_util}" ] && [ -d "${adb_tmpdir}" ] && [ -s "${adb_tmpdir}"/adb_cache.dump ]
                    then
                        while [ ${cnt} -le 10 ]
                        do
                            "${cache_util}" -c "${adb_dnsdir}"/unbound.conf load_cache < "${adb_tmpdir}"/adb_cache.dump >/dev/null 2>&1
                            cache_rc=${?}
                            if [ ${cache_rc} -eq 0 ]
                            then
                                break
                            fi
                            cnt=$((cnt+1))
                            sleep 1
                        done
                    fi
                ;;
            esac
            adb_rc=0
            break
        fi
        cnt=$((cnt+1))
        sleep 1
    done
    f_log "debug" "f_dnsup::: cache_util: ${cache_util:-"-"}, cache_rc: ${cache_rc:-"-"}, cache_flush: ${adb_dnsflush}, cache_cnt: ${cnt}, rc: ${adb_rc}"
    return ${adb_rc}
}

# backup/restore/remove blocklists
#
f_list()
{
    local file mode="${1}" in_rc="${adb_rc}"

    case "${mode}" in
        backup)
            if [ -d "${adb_backupdir}" ]
            then
                gzip -cf "${adb_tmpfile}" 2>/dev/null > "${adb_backupdir}/${adb_dnsprefix}.${src_name}.gz"
                adb_rc=${?}
            fi
        ;;
        restore)
            if [ -d "${adb_backupdir}" ] && [ -f "${adb_backupdir}/${adb_dnsprefix}.${src_name}.gz" ]
            then
                gunzip -cf "${adb_backupdir}/${adb_dnsprefix}.${src_name}.gz" 2>/dev/null > "${adb_tmpfile}"
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
            for file in "${adb_tmpfile}".*
            do
                cat "${file}" 2>/dev/null >> "${adb_tmpdir}/${adb_dnsfile}"
                if [ ${?} -ne 0 ]
                then
                    adb_rc=${?}
                    break
                fi
                rm -f "${file}"
            done
            adb_tmpfile="${adb_tmpdir}/${adb_dnsfile}"
        ;;
        final)
            if [ -s "${adb_tmpdir}/tmp.whitelist" ]
            then
                grep -vf "${adb_tmpdir}/tmp.whitelist" "${adb_tmpdir}/${adb_dnsfile}" | eval "${adb_dnsdeny}" > "${adb_dnsdir}/${adb_dnsfile}"
            else
                eval "${adb_dnsdeny}" "${adb_tmpdir}/${adb_dnsfile}" > "${adb_dnsdir}/${adb_dnsfile}"
            fi
            if [ ${?} -eq 0 ] && [ -n "${adb_dnsheader}" ]
            then
                printf '%s\n' "${adb_dnsheader}" | cat - "${adb_dnsdir}/${adb_dnsfile}" > "${adb_tmpdir}/${adb_dnsfile}"
                cat "${adb_tmpdir}/${adb_dnsfile}" > "${adb_dnsdir}/${adb_dnsfile}"
            fi
            adb_rc=${?}
        ;;
    esac
    f_count "${mode}"
    f_log "debug" "f_list ::: name: ${src_name:-"-"}, mode: ${mode}, cnt: ${adb_cnt}, in_rc: ${in_rc}, out_rc: ${adb_rc}"
}

# top level domain compression
#
f_tld()
{
    local cnt cnt_srt cnt_tld source="${1}" temp="${1}.tld"

    cnt="$(wc -l 2>/dev/null < "${source}")"
    sort -u "${source}" > "${temp}"
    if [ ${?} -eq 0 ]
    then
        cnt_srt="$(wc -l 2>/dev/null < "${temp}")"
        awk -F "." '{for(f=NF;f>1;f--)printf "%s.",$f;print $1}' "${temp}" > "${source}"
        if [ ${?} -eq 0 ]
        then
            sort "${source}" > "${temp}"
            if [ ${?} -eq 0 ]
            then
                awk '{if(NR==1){tld=$NF};while(getline){if($NF!~tld"\\."){print tld;tld=$NF}}print tld}' "${temp}" > "${source}"
                if [ ${?} -eq 0 ]
                then
                    awk -F "." '{for(f=NF;f>1;f--)printf "%s.",$f;print $1}' "${source}" > "${temp}"
                    if [ ${?} -eq 0 ]
                    then
                        sort "${temp}" > "${source}"
                        if [ ${?} -eq 0 ]
                        then
                            cnt_tld="$(wc -l 2>/dev/null < "${source}")"
                        else
                            cat "${temp}" > "${source}"
                        fi
                    fi
                else
                    cat "${temp}" > "${source}"
                fi
            fi
        else
            cat "${temp}" > "${source}"
        fi
    fi
    rm -f "${temp}"
    f_log "debug" "f_tld  ::: source: ${source}, cnt: ${cnt:-"-"}, cnt_srt: ${cnt_srt:-"-"}, cnt_tld: ${cnt_tld:-"-"}"
}

# blocklist hash compare
#
f_hash()
{
    local hash hash_rc=1

    if [ -x "${adb_hashutil}" ] && [ -f "${adb_dnsdir}/${adb_dnsfile}" ]
    then
        hash="$(${adb_hashutil} "${adb_dnsdir}/${adb_dnsfile}" 2>/dev/null | awk '{print $1}')"
        if [ -z "${adb_hashold}" ] && [ -n "${hash}" ]
        then
            adb_hashold="${hash}"
        elif [ -z "${adb_hashnew}" ] && [ -n "${hash}" ]
        then
            adb_hashnew="${hash}"
        fi
        if [ -n "${adb_hashold}" ] && [ -n "${adb_hashnew}" ]
        then
            if [ "${adb_hashold}" = "${adb_hashnew}" ]
            then
                hash_rc=0
            fi
            adb_hashold=""
            adb_hashnew=""
        fi
    fi
    f_log "debug" "f_hash ::: hash_util: ${adb_hashutil}, hash: ${hash}, out_rc: ${hash_rc}"
    return ${hash_rc}
}

# suspend/resume adblock processing
#
f_switch()
{
    local mode="${1}"

    if [ ! -s "${adb_dnsdir}/.${adb_dnsfile}" ] && [ "${mode}" = "suspend" ]
    then
        f_hash
        cat "${adb_dnsdir}/${adb_dnsfile}" > "${adb_dnsdir}/.${adb_dnsfile}"
        printf '%s\n' "${adb_dnsheader}" > "${adb_dnsdir}/${adb_dnsfile}"
        f_hash
    elif [ -s "${adb_dnsdir}/.${adb_dnsfile}" ] && [ "${mode}" = "resume" ]
    then
        f_hash
        cat "${adb_dnsdir}/.${adb_dnsfile}" > "${adb_dnsdir}/${adb_dnsfile}"
        > "${adb_dnsdir}/.${adb_dnsfile}"
        f_hash
    fi
    if [ ${?} -eq 1 ]
    then
        f_temp
        f_dnsup
        f_jsnup "${mode}"
        f_log "info" "${mode} adblock processing"
        f_rmtemp
        exit 0
    fi
}

# query blocklist for certain (sub-)domains
#
f_query()
{
    local search result field=1 domain="${1}" tld="${1#*.}"

    if [ -z "${domain}" ] || [ "${domain}" = "${tld}" ]
    then
        printf "%s\n" "::: invalid domain input, please submit a single domain, e.g. 'doubleclick.net'"
    else
        case "${adb_dns}" in
            dnsmasq)
                field=2
            ;;
            unbound)
                field=3
            ;;
        esac
        while [ "${domain}" != "${tld}" ]
        do
            search="${domain//./\.}"
            result="$(awk -F '/|\"| ' "/^($search|[^\*].*[\/\"\. ]+${search})/{i++;{printf(\"  + %s\n\",\$${field})};if(i>9){printf(\"  + %s\n\",\"[...]\");exit}}" "${adb_dnsdir}/${adb_dnsfile}")"
            printf "%s\n" "::: results for domain '${domain}'"
            printf "%s\n" "${result:-"  - no match"}"
            domain="${tld}"
            tld="${domain#*.}"
        done
    fi
}

# update runtime information
#
f_jsnup()
{
    local bg_pid rundate="$(/bin/date "+%d.%m.%Y %H:%M:%S")" status="${1:-"enabled"}" mode="normal mode" no_mail=0

    if [ ${adb_rc} -gt 0 ]
    then
        status="error"
    fi
    if [ ${adb_enabled} -eq 0 ]
    then
        status="disabled"
    fi
    if [ "${status}" = "suspend" ]
    then
        status="paused"
    fi
    if [ "${status}" = "resume" ]
    then
        no_mail=1
        status="enabled"
    fi
    if [ "${status}" = "enabled" ]
    then
        f_count
    fi

    if [ ${adb_backup_mode} -eq 1 ]
    then
        mode="backup mode"
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
    json_add_string "overall_domains" "${adb_cnt} (${mode})"
    json_add_string "fetch_utility" "${adb_fetchinfo:-"-"}"
    json_add_string "dns_backend" "${adb_dns} (${adb_dnsdir})"
    json_add_string "last_rundate" "${rundate:-"-"}"
    json_add_string "system_release" "${adb_sysver}"
    json_close_object
    json_dump > "${adb_rtfile}"

    if [ ${adb_notify} -eq 1 ] && [ ${no_mail} -eq 0 ] && [ -x /etc/adblock/adblock.notify ] && \
      ([ "${status}" = "error" ] || ([ "${status}" = "enabled" ] && [ ${adb_cnt} -le ${adb_notifycnt} ]))
    then
        (/etc/adblock/adblock.notify >/dev/null 2>&1) &
        bg_pid=${!}
    fi
    f_log "debug" "f_jsnup::: status: ${status}, mode: ${mode}, cnt: ${adb_cnt}, notify: ${adb_notify}, notify_cnt: ${adb_notifycnt}, notify_pid: ${bg_pid:-"-"}"
}

# write to syslog
#
f_log()
{
    local class="${1}" log_msg="${2}"

    if [ -n "${log_msg}" ] && ([ "${class}" != "debug" ] || [ ${adb_debug} -eq 1 ])
    then
        logger -p "${class}" -t "adblock-[${adb_ver}]" "${log_msg}"
        if [ "${class}" = "err" ]
        then
            f_rmdns
            f_jsnup
            logger -p "${class}" -t "adblock-[${adb_ver}]" "Please also check 'https://github.com/openwrt/packages/blob/master/net/adblock/files/README.md' (${adb_sysver})"
            exit 1
        fi
    fi
}

# main function for blocklist processing
#
f_main()
{
    local tmp_load tmp_file src_name src_rset src_arc src_log mem_total mem_free enabled url cnt=1

    mem_total="$(awk '/^MemTotal/ {print int($2/1000)}' "/proc/meminfo" 2>/dev/null)"
    mem_free="$(awk '/^MemFree/ {print int($2/1000)}' "/proc/meminfo" 2>/dev/null)"
    tmp_load="${adb_tmpload}"
    tmp_file="${adb_tmpfile}"
    > "${adb_dnsdir}/.${adb_dnsfile}"
    > "${adb_tmpdir}/tmp.whitelist"
    f_log "debug" "f_main ::: dns: ${adb_dns}, fetch_util: ${adb_fetchinfo}, backup: ${adb_backup}, backup_mode: ${adb_backup_mode}, dns_jail: ${adb_jail}, force_srt: ${adb_forcesrt}, force_dns: ${adb_forcedns}, mem_total: ${mem_total:-0}, mem_free: ${mem_free:-0}, max_queue: ${adb_maxqueue}"

    # prepare whitelist entries
    #
    if [ -s "${adb_whitelist}" ]
    then
        adb_whitelist_rset="/^([^([:space:]|\#|\*|\/).]+\.)+[[:alpha:]]+([[:space:]]|$)/{gsub(\"\\\.\",\"\\\.\",\$1);print tolower(\"^\"\$1\"\\\|\\\.\"\$1)}"
        awk "${adb_whitelist_rset}" "${adb_whitelist}" > "${adb_tmpdir}/tmp.whitelist"
        f_list whitelist
        if [ ${adb_jail} -eq 1 ] && [ "${adb_dns}" != "dnscrypt-proxy" ]
        then
            adb_whitelist_rset="/^([^([:space:]|\#|\*|\/).]+\.)+[[:alpha:]]+([[:space:]]|$)/{print tolower(\$1)}"
            awk "${adb_whitelist_rset}" "${adb_whitelist}" > "${adb_tmpdir}/tmp.dnsjail"
        fi
    fi

    # build 'dnsjail' list
    #
    if [ ${adb_jail} -eq 1 ] && [ "${adb_dns}" != "dnscrypt-proxy" ]
    then
        f_tld "${adb_tmpdir}/tmp.dnsjail"
        eval "${adb_dnsallow}" "${adb_tmpdir}/tmp.dnsjail" > "/tmp/${adb_dnsjail}"
        printf '%s\n' "${adb_dnshalt}" >> "/tmp/${adb_dnsjail}"
        if [ -n "${adb_dnsheader}" ]
        then
            printf '%s\n' "${adb_dnsheader}" | cat - "/tmp/${adb_dnsjail}" > "${adb_tmpdir}/tmp.dnsjail"
            cat "${adb_tmpdir}/tmp.dnsjail" > "/tmp/${adb_dnsjail}"
        fi
    fi

    # main loop
    #
    for src_name in ${adb_sources}
    do
        eval "enabled=\"\${enabled_${src_name}}\""
        eval "url=\"\${adb_src_${src_name}}\""
        eval "src_rset=\"\${adb_src_rset_${src_name}}\""
        adb_tmpload="${tmp_load}.${src_name}"
        adb_tmpfile="${tmp_file}.${src_name}"

        # basic pre-checks
        #
        f_log "debug" "f_main ::: name: ${src_name}, enabled: ${enabled}"
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
                if ([ ${mem_total} -lt 64 ] || [ ${mem_free} -lt 40 ]) && [ ${adb_forcesrt} -eq 0 ]
                then
                    f_tld "${adb_tmpfile}"
                fi
                continue
            fi
        fi

        # download queue processing
        #
        if [ "${src_name}" = "blacklist" ]
        then
            if [ -s "${url}" ]
            then
                (
                  src_log="$(cat "${url}" > "${adb_tmpload}" 2>&1)"
                  adb_rc=${?}
                  if [ ${adb_rc} -eq 0 ] && [ -s "${adb_tmpload}" ]
                  then
                      awk "${src_rset}" "${adb_tmpload}" 2>/dev/null > "${adb_tmpfile}"
                      adb_rc=${?}
                      if [ ${adb_rc} -eq 0 ] && [ -s "${adb_tmpfile}" ]
                      then
                          rm -f "${adb_tmpload}"
                          f_list download
                          if ([ ${mem_total} -lt 64 ] || [ ${mem_free} -lt 40 ]) && [ ${adb_forcesrt} -eq 0 ]
                          then
                              f_tld "${adb_tmpfile}"
                          fi
                      fi
                  else
                      src_log="$(printf '%s' "${src_log}" | awk '{ORS=" ";print $0}')"
                      f_log "debug" "f_main ::: name: ${src_name}, url: ${url}, rc: ${adb_rc}, log: ${src_log:-"-"}"
                  fi
                ) &
            else
                continue
            fi
        elif [ "${src_name}" = "shalla" ]
        then
            (
              src_arc="${adb_tmpdir}"/shallalist.tar.gz
              src_log="$("${adb_fetchutil}" ${adb_fetchparm} "${src_arc}" "${url}" 2>&1)"
              adb_rc=${?}
              if [ ${adb_rc} -eq 0 ] && [ -s "${src_arc}" ]
              then
                  for category in ${adb_src_cat_shalla}
                  do
                      tar -xOzf "${src_arc}" "BL/${category}/domains" >> "${adb_tmpload}"
                      adb_rc=${?}
                      if [ ${adb_rc} -ne 0 ]
                      then
                          break
                      fi
                  done
              else
                  src_log="$(printf '%s' "${src_log}" | awk '{ORS=" ";print $0}')"
                  f_log "debug" "f_main ::: name: ${src_name}, url: ${url}, rc: ${adb_rc}, log: ${src_log:-"-"}"
              fi
              if [ ${adb_rc} -eq 0 ] && [ -s "${adb_tmpload}" ]
              then
                  rm -f "${src_arc}"
                  awk "${src_rset}" "${adb_tmpload}" 2>/dev/null > "${adb_tmpfile}"
                  adb_rc=${?}
                  if [ ${adb_rc} -eq 0 ] && [ -s "${adb_tmpfile}" ]
                  then
                      rm -f "${adb_tmpload}"
                      f_list download
                      if [ ${adb_backup} -eq 1 ]
                      then
                          f_list backup
                      fi
                      if ([ ${mem_total} -lt 64 ] || [ ${mem_free} -lt 40 ]) && [ ${adb_forcesrt} -eq 0 ]
                      then
                          f_tld "${adb_tmpfile}"
                      fi
                  elif [ ${adb_backup} -eq 1 ]
                  then
                      f_list restore
                  fi
              elif [ ${adb_backup} -eq 1 ]
              then
                  f_list restore
              fi
            ) &
        else
            (
              src_log="$("${adb_fetchutil}" ${adb_fetchparm} "${adb_tmpload}" "${url}" 2>&1)"
              adb_rc=${?}
              if [ ${adb_rc} -eq 0 ] && [ -s "${adb_tmpload}" ]
              then
                  awk "${src_rset}" "${adb_tmpload}" 2>/dev/null > "${adb_tmpfile}"
                  adb_rc=${?}
                  if [ ${adb_rc} -eq 0 ] && [ -s "${adb_tmpfile}" ]
                  then
                      rm -f "${adb_tmpload}"
                      f_list download
                      if [ ${adb_backup} -eq 1 ]
                      then
                          f_list backup
                      fi
                      if ([ ${mem_total} -lt 64 ] || [ ${mem_free} -lt 40 ]) && [ ${adb_forcesrt} -eq 0 ]
                      then
                          f_tld "${adb_tmpfile}"
                      fi
                  elif [ ${adb_backup} -eq 1 ]
                  then
                      f_list restore
                  fi
              else
                  src_log="$(printf '%s' "${src_log}" | awk '{ORS=" ";print $0}')"
                  f_log "debug" "f_main ::: name: ${src_name}, url: ${url}, rc: ${adb_rc}, log: ${src_log:-"-"}"
                  if [ ${adb_backup} -eq 1 ]
                  then
                      f_list restore
                  fi
              fi
            ) &
        fi
        hold=$(( cnt % adb_maxqueue ))
        if [ ${hold} -eq 0 ]
        then
            wait
        fi
        cnt=$(( cnt + 1 ))
    done

    # list merge
    #
    wait
    src_name="overall"
    adb_tmpfile="${tmp_file}"
    f_list merge

    # overall sort and conditional dns restart
    #
    f_hash
    if [ -s "${adb_tmpdir}/${adb_dnsfile}" ]
    then
        if ([ ${mem_total} -ge 64 ] && [ ${mem_free} -ge 40 ]) || [ ${adb_forcesrt} -eq 1 ]
        then
            f_tld "${adb_tmpdir}/${adb_dnsfile}"
        fi
        f_list final
    else
        > "${adb_dnsdir}/${adb_dnsfile}"
    fi
    chown "${adb_dnsuser}" "${adb_dnsdir}/${adb_dnsfile}" 2>/dev/null
    f_hash
    if [ ${?} -eq 1 ]
    then
        f_dnsup
    fi
    f_jsnup
    if [ ${?} -eq 0 ]
    then
        f_log "info" "blocklist with overall ${adb_cnt} domains loaded successfully (${adb_sysver})"
    else
        f_log "err" "dns backend restart with active blocklist failed"
    fi
    f_rmtemp
    exit ${adb_rc}
}

# handle different adblock actions
#
f_envload
case "${adb_action}" in
    stop)
        f_rmdns
    ;;
    restart)
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
    start|reload)
        f_envcheck
        f_main
    ;;
esac

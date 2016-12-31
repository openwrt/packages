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
adb_ver="2.0.4"
adb_enabled=1
adb_debug=0
adb_whitelist="/etc/adblock/adblock.whitelist"
adb_whitelist_rset="\$1 ~/^([A-Za-z0-9_-]+\.){1,}[A-Za-z]+/{print tolower(\"^\"\$1\"\\\|[.]\"\$1)}"
adb_dns="dnsmasq"
adb_dnsdir="/tmp/dnsmasq.d"
adb_dnshidedir="${adb_dnsdir}/.adb_hidden"
adb_dnsprefix="adb_list"
adb_dnsformat="awk '{print \"local=/\"\$0\"/\"}'"
adb_fetch="/usr/bin/wget"
adb_fetchparm="--no-config --quiet --tries=1 --no-cache --no-cookies --max-redirect=0 --timeout=5 --no-check-certificate -O"

# f_envload: load adblock environment
#
f_envload()
{
    # source in system library
    #
    if [ -r "/lib/functions.sh" ]
    then
        . "/lib/functions.sh"
    else
        f_log "error" "status ::: system library not found"
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

    # parse 'service' and 'source' sections
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

    # load adblock config
    #
    config_load adblock
    config_foreach parse_config service
    config_foreach parse_config source
}

# f_envcheck: check/set environment prerequisites
#
f_envcheck()
{
    # check 'enabled' option
    #
    if [ ${adb_enabled} -ne 1 ]
    then
        if [ "$(ls -dA "${adb_dnsdir}/${adb_dnsprefix}"* >/dev/null 2>&1)" ]
        then
            f_rmdns
            f_dnsrestart
        fi
        f_log "info " "status ::: adblock is currently disabled, please set adb_enabled to '1' to use this service"
        exit 0
    fi

    # check fetch utility
    #
    if [ -z "${adb_fetch}" ] || [ ! -f "${adb_fetch}" ]
    then
        f_log "error" "status ::: no download utility with ssl support found/configured"
    fi

    # create dns hideout directory
    #
    if [ ! -d "${adb_dnshidedir}" ]
    then
        mkdir -p -m 660 "${adb_dnshidedir}"
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
    rm -f "${adb_tmpload}"
    rm -f "${adb_tmpfile}"
    rm -rf "${adb_tmpdir}"
}

# f_rmdns: remove dns related files & directories
#
f_rmdns()
{
    rm -f "${adb_dnsdir}/${adb_dnsprefix}"*
    rm -f "${adb_dir_backup}/${adb_dnsprefix}"*.gz
    rm -rf "${adb_dnshidedir}"
    ubus call service delete "{\"name\":\"adblock_stats\",\"instances\":\"stats\"}" 2>/dev/null
}

# f_dnsrestart: restart the dns server
#
f_dnsrestart()
{
    local cnt=0
    dns_running="false"

    sync
    killall -q -TERM "${adb_dns}"
    while [ ${cnt} -le 10 ]
    do
        dns_running="$(ubus -S call service list '{"name":"dnsmasq"}' | jsonfilter -l 1 -e '@.dnsmasq.instances.*.running')"
        if [ "${dns_running}" = "true" ]
        then
            return 0
        fi
        cnt=$((cnt+1))
        sleep 1
    done
    /etc/init.d/"${adb_dns}" restart
    sleep 1
}

# f_list: backup/restore/remove block lists
#
f_list()
{
    local mode="${1}"

    if [ "${enabled_backup}" = "1" ] && [ -d "${adb_dir_backup}" ]
    then
        case "${mode}" in
            backup)
                gzip -cf "${adb_tmpfile}" > "${adb_dir_backup}/${adb_dnsprefix}.${src_name}.gz"
                ;;
            restore)
                rm -f "${adb_dnsdir}/${adb_dnsprefix}.${src_name}"
                if [ -f "${adb_dir_backup}/${adb_dnsprefix}.${src_name}.gz" ]
                then
                    gunzip -cf "${adb_dir_backup}/${adb_dnsprefix}.${src_name}.gz" > "${adb_tmpfile}"
                fi
                ;;
            remove)
                rm -f "${adb_dnsdir}/${adb_dnsprefix}.${src_name}"
                if [ -f "${adb_dir_backup}/${adb_dnsprefix}.${src_name}.gz" ]
                then
                    rm -f "${adb_dir_backup}/${adb_dnsprefix}.${src_name}.gz"
                fi
                ;;
        esac
    fi
}

# f_switch: suspend/resume adblock processing
#
f_switch()
{
    if [ -d "${adb_dnshidedir}" ]
    then
        local source target status mode="${1}"
        local dns_active="$(find "${adb_dnsdir}" -maxdepth 1 -type f -name "${adb_dnsprefix}*" -print)"
        local dns_passive="$(find "${adb_dnshidedir}" -maxdepth 1 -type f -name "${adb_dnsprefix}*" -print)"

        if [ -n "${dns_active}" ] && [ "${mode}" = "suspend" ]
        then
            source="${adb_dnsdir}/${adb_dnsprefix}"
            target="${adb_dnshidedir}"
            status="suspended"
        elif [ -n "${dns_passive}" ] && [ "${mode}" = "resume" ]
        then
            source="${adb_dnshidedir}/${adb_dnsprefix}"
            target="${adb_dnsdir}"
            status="resumed"
        fi
        if [ -n "${status}" ]
        then
            mv -f "${source}"* "${target}"
            f_dnsrestart
            f_log "info " "status ::: adblock processing ${status}"
        fi
    fi
}

# f_query: query block lists for certain (sub-)domains
#
f_query()
{
    local search result cnt
    local domain="${1}"
    local tld="${domain#*.}"
    local dns_active="$(find "${adb_dnsdir}" -maxdepth 1 -type f -name "${adb_dnsprefix}*" -print)"

    if [ -z "${dns_active}" ]
    then
         printf "%s\n" ":: no active block lists found, please start adblock first"
    elif [ -z "${domain}" ] || [ "${domain}" = "${tld}" ]
    then
        printf "%s\n" ":: invalid domain input, please submit a specific (sub-)domain, i.e. 'www.abc.xyz'"
    else
        while [ "${domain}" != "${tld}" ]
        do
            search="${domain//./\.}"
            result="$(grep -Hm 1 "[/\.]${search}/" "${adb_dnsdir}/${adb_dnsprefix}"* | awk -F ':|/' '{print "   "$4"\t: "$6}')"
            cnt="$(grep -hc "[/\.]${search}/" "${adb_dnsdir}/${adb_dnsprefix}"* | awk '{sum += $1} END {printf sum}')"
            printf "%s\n" ":: distinct results for domain '${domain}' (overall ${cnt})"
            if [ -z "${result}" ]
            then
                printf "%s\n" "   no matches in active block lists"
            else
                printf "%s\n" "${result}"
            fi
            domain="${tld}"
            tld="${domain#*.}"
        done
    fi
}

# f_log: write to syslog, exit on error
#
f_log()
{
    local class="${1}"
    local log_msg="${2}"

    if [ -n "${log_msg}" ] && ([ "${class}" != "debug" ] || [ ${adb_debug} -eq 1 ])
    then
        logger -t "adblock-[${adb_ver}] ${class}" "${log_msg}"
        if [ "${class}" = "error" ]
        then
            f_rmtemp
            f_rmdns
            f_dnsrestart
            exit 255
        fi
    fi
}

# f_debug: gather memory & space information
f_debug()
{
        local mem_total=0 mem_free=0 mem_swap=0 tmp_space=0 backup_space=0

        if [ ${adb_debug} -eq 1 ]
        then
        mem_total="$(awk '$1 ~ /^MemTotal/ {printf $2}' "/proc/meminfo")"
        mem_free="$(awk '$1 ~ /^MemFree/ {printf $2}' "/proc/meminfo")"
        mem_swap="$(awk '$1 ~ /^SwapTotal/ {printf $2}' "/proc/meminfo")"
        f_log "debug" "memory ::: total: ${mem_total}, free: ${mem_free}, swap: ${mem_swap}"

        if [ -d "${adb_tmpdir}" ]
        then
            tmp_space="$(df "${adb_tmpdir}" 2>/dev/null | tail -n1 | awk '{printf $4}')"
        fi
        if [ -d "${adb_dir_backup}" ]
        then
            backup_space="$(df "${adb_dir_backup}" 2>/dev/null | tail -n1 | awk '{printf $4}')"
        fi
        f_log "debug" "space  ::: tmp_dir: ${adb_tmpdir}, tmp_kb: ${tmp_space}, backup: ${enabled_backup}, backup_dir: ${adb_dir_backup}, backup_kb: ${backup_space}"
    fi
}

# main function for block list processing
#
f_main()
{
    local enabled url rc cnt sum_cnt=0
    local src_name src_rset shalla_file shalla_archive list active_lists
    local sysver="$(ubus -S call system board | jsonfilter -e '@.release.description')"

    f_debug
    f_log "debug" "main   ::: tool: ${adb_fetch}, parm: ${adb_fetchparm}"
    for src_name in ${adb_sources}
    do
        eval "enabled=\"\${enabled_${src_name}}\""
        eval "url=\"\${adb_src_${src_name}}\""
        eval "src_rset=\"\${adb_src_rset_${src_name}}\""
        adb_dnsfile="${adb_dnsdir}/${adb_dnsprefix}.${src_name}"
        > "${adb_tmpload}"
        > "${adb_tmpfile}"

        # basic pre-checks
        #
        if [ "${enabled}" = "0" ] || [ -z "${url}" ] || [ -z "${src_rset}" ]
        then
            f_list remove
            continue
        fi

        # download block list
        #
        f_log "debug" "loop   ::: name: ${src_name}, enabled: ${enabled}, dnsfile: ${adb_dnsfile}"
        if [ "${src_name}" = "blacklist" ]
        then
            cat "${url}" > "${adb_tmpload}"
            rc=${?}
        elif [ "${src_name}" = "shalla" ]
        then
            shalla_archive="${adb_tmpdir}/shallalist.tar.gz"
            shalla_file="${adb_tmpdir}/shallalist.txt"
            "${adb_fetch}" ${adb_fetchparm} "${shalla_archive}" "${url}"
            rc=${?}
            if [ ${rc} -eq 0 ]
            then
                > "${shalla_file}"
                for category in ${adb_src_cat_shalla}
                do
                    tar -xOzf "${shalla_archive}" BL/${category}/domains >> "${shalla_file}"
                    rc=${?}
                    if [ ${rc} -ne 0 ]
                    then
                        break
                    fi
                done
                cat "${shalla_file}" > "${adb_tmpload}"
                rm -f "${shalla_file}"
            fi
            rm -f "${shalla_archive}"
            rm -rf "${adb_tmpdir}/BL"
        else
            "${adb_fetch}" ${adb_fetchparm} "${adb_tmpload}" "${url}"
            rc=${?}
        fi

        # check download result and prepare domain output (incl. list backup/restore)
        #
        f_log "debug" "loop   ::: name: ${src_name}, load-rc: ${rc}"
        if [ ${rc} -eq 0 ] && [ -s "${adb_tmpload}" ]
        then
            awk "${src_rset}" "${adb_tmpload}" > "${adb_tmpfile}"
            if [ -s "${adb_tmpfile}" ]
            then
                f_list backup
            else
                f_list restore
            fi
        else
            f_list restore
        fi

        # remove whitelist domains, sort and make them unique, final list preparation
        #
        if [ -s "${adb_tmpfile}" ]
        then
            if [ -s "${adb_tmpdir}/tmp.whitelist" ]
            then
                grep -vf "${adb_tmpdir}/tmp.whitelist" "${adb_tmpfile}" | sort -u | eval "${adb_dnsformat}" > "${adb_dnsfile}"
            else
                sort -u "${adb_tmpfile}" | eval "${adb_dnsformat}" > "${adb_dnsfile}"
            fi
            rc=${?}
            if [ ${rc} -ne 0 ]
            then
                f_list remove
            fi
        fi
        f_log "debug" "loop   ::: name: ${src_name}, list-rc: ${rc}"
    done

    # make overall sort, restart & check dns server
    #
    for src_name in $(ls -dASr "${adb_dnsdir}/${adb_dnsprefix}"* 2>/dev/null)
    do
        if [ -s "${adb_tmpdir}/blocklist.overall" ]
        then
            sort "${adb_tmpdir}/blocklist.overall" "${adb_tmpdir}/blocklist.overall" "${src_name}" | uniq -u > "${adb_tmpdir}/tmp.blocklist"
            cat "${adb_tmpdir}/tmp.blocklist" > "${src_name}"
        fi
        cat "${src_name}" >> "${adb_tmpdir}/blocklist.overall"
        cnt="$(wc -l < "${src_name}")"
        sum_cnt=$((sum_cnt + cnt))
        list="${src_name/*./}"
        if [ -z "${active_lists}" ]
        then
            active_lists="\"${list}\":\"${cnt}\""
        else
            active_lists="${active_lists},\"${list}\":\"${cnt}\""
        fi
    done
    f_dnsrestart
    if [ "${dns_running}" = "true" ]
    then
        f_debug
        f_rmtemp
        f_log "info " "status ::: block lists with overall ${sum_cnt} domains loaded (${sysver})"
        ubus call service add "{\"name\":\"adblock_stats\",
            \"instances\":{\"stats\":{\"command\":[\"\"],
            \"data\":{\"blocked_domains\":\"${sum_cnt}\",
            \"last_rundate\":\"$(/bin/date "+%d.%m.%Y %H:%M:%S")\",
            \"active_lists\":[{${active_lists}}],
            \"system\":\"${sysver}\"}}}}"
        return 0
    fi
    f_debug
    f_log "error" "status ::: dns server restart with active block lists failed (${sysver})"
}

# handle different adblock actions
#
if [ "${adb_procd}" = "true" ]
then
    f_envload
    case "${1}" in
        stop)
            f_rmtemp
            f_rmdns
            f_dnsrestart
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
        *)
            f_envcheck
            f_main
            ;;
    esac
fi
exit 0
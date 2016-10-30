#!/bin/sh
# dns based ad/abuse domain blocking script
# written by Dirk Brenken (dev@brenken.org)

# This is free software, licensed under the GNU General Public License v3.
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.

# prepare environment
#
adb_pid="${$}"
adb_pidfile="/var/run/adblock.pid"
adb_scriptdir="${0%/*}"

if [ -r "${adb_pidfile}" ]
then
    rc=255
    logger -s -t "adblock[${adb_pid}] error" "adblock service already running ($(cat ${adb_pidfile}))"
    exit ${rc}
else
    printf "${adb_pid}" > "${adb_pidfile}"
    if [ -r "${adb_scriptdir}/adblock-helper.sh" ]
    then
        . "${adb_scriptdir}/adblock-helper.sh"
        f_envload
    else
        rc=254
        logger -s -t "adblock[${adb_pid}] error" "adblock function library not found"
        rm -f "${adb_pidfile}"
        exit ${rc}
    fi
fi

# call trap function on error signals (HUP, INT, QUIT, BUS, SEGV, TERM)
#
trap "rc=250; f_log 'error signal received/trapped'; f_exit" 1 2 3 10 11 15

# check environment
#
f_envcheck

# main loop for all block list sources
#
f_log "use '${adb_fetch}' for list downloads"

for src_name in ${adb_sources}
do
    # check disabled sources
    #
    eval "enabled=\"\${enabled_${src_name}}\""
    if [ "${enabled}" = "0" ]
    then
        if [ -r "${adb_dnsdir}/${adb_dnsprefix}.${src_name}" ]
        then
            rm -f "${adb_dnsdir}/${adb_dnsprefix}.${src_name}"
            if [ "${backup_ok}" = "true" ] && [ -r "${adb_dir_backup}/${adb_dnsprefix}.${src_name}.gz" ]
            then
                rm -f "${adb_dir_backup}/${adb_dnsprefix}.${src_name}.gz"
            fi
            rm_done="true"
            f_log "=> disabled source '${src_name}' removed"
        fi
        "${adb_uci}" -q delete "adblock.${src_name}.adb_src_count"
        "${adb_uci}" -q delete "adblock.${src_name}.adb_src_timestamp"
        continue
    fi

    f_log "=> processing source '${src_name}'"
    eval "url=\"\${adb_src_${src_name}}\""
    eval "src_rset=\"\${adb_src_rset_${src_name}}\""
    eval "list_time=\"\${CONFIG_${src_name}_adb_src_timestamp}\""
    adb_dnsfile="${adb_dnsdir}/${adb_dnsprefix}.${src_name}"

    # check 'url' and 'src_rset' values
    #
    if [ -z "${url}" ] || [ -z "${src_rset}" ]
    then
        "${adb_uci}" -q set "adblock.${src_name}.adb_src_timestamp=broken config"
        f_log "   broken source configuration, skipped"
        continue
    fi

    # download only block list with newer/updated timestamp
    #
    if [ "${src_name}" = "blacklist" ]
    then
        url_time="$(date -r "${url}")"
    else
        url_time="$(${adb_fetch} ${fetch_parm} ${response_parm} "${url}" 2>&1 | awk '$0 ~ /Last-Modified/ {printf substr($0,18)}')"
    fi
    if [ -z "${url_time}" ]
    then
        url_time="$(date)"
        f_log "   no online timestamp"
    fi
    if [ -z "${list_time}" ] || [ "${list_time}" != "${url_time}" ] || [ ! -r "${adb_dnsfile}" ] ||\
      ([ "${backup_ok}" = "true" ] && [ ! -r "${adb_dir_backup}/${adb_dnsprefix}.${src_name}.gz" ])
    then
        if [ "${src_name}" = "blacklist" ]
        then
            tmp_domains="$(strings -n 1 "${url}")"
        elif [ "${src_name}" = "shalla" ]
        then
            shalla_archive="${adb_tmpdir}/shallalist.tar.gz"
            shalla_file="${adb_tmpdir}/shallalist.txt"
            "${adb_fetch}" ${fetch_parm} -O "${shalla_archive}" "${url}"
            rc=${?}
            if [ $((rc)) -eq 0 ]
            then
                > "${shalla_file}"
                for category in ${adb_src_cat_shalla}
                do
                    tar -xOzf "${shalla_archive}" BL/${category}/domains >> "${shalla_file}"
                    rc=${?}
                    if [ $((rc)) -ne 0 ]
                    then
                        f_log "   archive extraction failed (${category})"
                        break
                    fi
                done
                tmp_domains="$(strings -n 1 "${shalla_file}")"
                rm -rf "${adb_tmpdir}/BL"
                rm -f "${shalla_archive}"
                rm -f "${shalla_file}"
            fi
        else
            tmp_domains="$(${adb_fetch} ${fetch_parm} -O- "${url}" | strings -n 1)"
        fi
        rc=${?}
    else
        f_log "   source doesn't change, skipped"
        continue
    fi

    # check download result and prepare domain output, backup/restore if needed
    #
    if [ $((rc)) -eq 0 ] && [ -n "${tmp_domains}" ]
    then
        count="$(printf "%s\n" "${tmp_domains}" | awk "${src_rset}" | tee "${adb_tmpfile}" | wc -l)"
        "${adb_uci}" -q set "adblock.${src_name}.adb_src_timestamp=${url_time}"
        if [ "${backup_ok}" = "true" ]
        then
            gzip -cf "${adb_tmpfile}" > "${adb_dir_backup}/${adb_dnsprefix}.${src_name}.gz"
        fi
        f_log "   source download finished (${count} entries)"
        unset tmp_domains
    elif [ $((rc)) -eq 0 ] && [ -z "${tmp_domains}" ]
    then
        if [ "${backup_ok}" = "true" ] && [ -r "${adb_dir_backup}/${adb_dnsprefix}.${src_name}.gz" ]
        then
            gunzip -cf "${adb_dir_backup}/${adb_dnsprefix}.${src_name}.gz" > "${adb_tmpfile}"
            count="$(wc -l < "${adb_tmpfile}")"
            "${adb_uci}" -q set "adblock.${src_name}.adb_src_timestamp=list restored"
            f_log "   empty source download, restored (${count} entries)"
        else
            if [ -r "${adb_dnsdir}/${adb_dnsprefix}.${src_name}" ]
            then
                rm -f "${adb_dnsdir}/${adb_dnsprefix}.${src_name}"
                rm_done="true"
            fi
            "${adb_uci}" -q delete "adblock.${src_name}.adb_src_count"
            "${adb_uci}" -q set "adblock.${src_name}.adb_src_timestamp=empty download"
            f_log "   empty source download, skipped"
            continue
        fi
    else
        rc=0
        if [ "${backup_ok}" = "true" ] && [ -r "${adb_dir_backup}/${adb_dnsprefix}.${src_name}.gz" ]
        then
            gunzip -cf "${adb_dir_backup}/${adb_dnsprefix}.${src_name}.gz" > "${adb_tmpfile}"
            count="$(wc -l < "${adb_tmpfile}")"
            "${adb_uci}" -q set "adblock.${src_name}.adb_src_timestamp=list restored"
            f_log "   source download failed, restored (${count} entries)"
        else
            if [ -r "${adb_dnsdir}/${adb_dnsprefix}.${src_name}" ]
            then
                rm -f "${adb_dnsdir}/${adb_dnsprefix}.${src_name}"
                rm_done="true"
            fi
            "${adb_uci}" -q delete "adblock.${src_name}.adb_src_count"
            "${adb_uci}" -q set "adblock.${src_name}.adb_src_timestamp=download failed"
            f_log "   source download failed, skipped"
            continue
        fi
    fi

    # remove whitelist domains, sort domains and make them unique,
    # rewrite ad/abuse domain information to separate dnsmasq files
    #
    if [ $((count)) -gt 0 ] && [ -n "${adb_tmpfile}" ]
    then
        if [ -s "${adb_tmpdir}/tmp.whitelist" ]
        then
            grep -vf "${adb_tmpdir}/tmp.whitelist" "${adb_tmpfile}" | sort -u | eval "${adb_dnsformat}" > "${adb_dnsfile}"
        else
            sort -u "${adb_tmpfile}" | eval "${adb_dnsformat}" > "${adb_dnsfile}"
        fi
        rc=${?}
        if [ $((rc)) -eq 0 ]
        then
            rev_done="true"
            f_log "   domain merging finished"
        else
            rc=0
            rm -f "${adb_dnsfile}"
            if [ "${backup_ok}" = "true" ] && [ -r "${adb_dir_backup}/${adb_dnsprefix}.${src_name}.gz" ]
            then
                rm -f "${adb_dir_backup}/${adb_dnsprefix}.${src_name}.gz"
            fi
            "${adb_uci}" -q delete "adblock.${src_name}.adb_src_count"
            "${adb_uci}" -q set "adblock.${src_name}.adb_src_timestamp=domain merging failed"
            f_log "   domain merging failed, skipped"
            continue
        fi
    else
        rm -f "${adb_dnsfile}"
        if [ "${backup_ok}" = "true" ] && [ -r "${adb_dir_backup}/${adb_dnsprefix}.${src_name}.gz" ]
        then
            rm -f "${adb_dir_backup}/${adb_dnsprefix}.${src_name}.gz"
        fi
        "${adb_uci}" -q delete "adblock.${src_name}.adb_src_count"
        "${adb_uci}" -q set "adblock.${src_name}.adb_src_timestamp=empty domain input"
        f_log "   empty domain input, skipped"
        continue
    fi
done

# overall sort, make block list entries unique
#
if [ "${rev_done}" = "true" ] && [ "${mem_ok}" = "true" ]
then
    f_log "remove duplicates in separate block lists"
    for list in $(ls -ASr "${adb_dnsdir}/${adb_dnsprefix}"*)
    do
        list="${list/*./}"
        if [ -s "${adb_tmpdir}/blocklist.overall" ]
        then
            sort "${adb_tmpdir}/blocklist.overall" "${adb_tmpdir}/blocklist.overall" "${adb_dnsdir}/${adb_dnsprefix}.${list}" | uniq -u > "${adb_tmpdir}/tmp.blocklist"
            cat "${adb_tmpdir}/tmp.blocklist" > "${adb_dnsdir}/${adb_dnsprefix}.${list}"
        fi
        cat "${adb_dnsdir}/${adb_dnsprefix}.${list}" >> "${adb_tmpdir}/blocklist.overall"
    done
fi

# restart & check dnsmasq with generated set of block lists
#
if [ "${rev_done}" = "true" ] || [ "${rm_done}" = "true" ] || [ -n "${mv_done}" ]
then
    "${adb_uci}" -q delete "adblock.global.adb_dnstoggle"
    /etc/init.d/dnsmasq restart
    sleep 1
    check="$(pgrep -f "dnsmasq")"
    if [ -n "${check}" ]
    then
        f_cntconfig
        f_log "block lists with overall ${adb_count} domains loaded"
    else
        f_rmdns
        sleep 1
        check="$(pgrep -f "dnsmasq")"
        if [ -n "${check}" ]
        then
            f_log "dnsmasq restart without block lists succeeded, please check your configuration"
        else
            f_log "dnsmasq restart without block lists failed, please check your configuration"
        fi
        rc=100
        f_exit
    fi
else
    f_cntconfig
    f_log "block lists with overall ${adb_count} domains are still valid, no update required"
fi

# remove temporary files and exit
#
f_exit

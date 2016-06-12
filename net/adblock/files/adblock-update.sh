#!/bin/sh
# dns based ad/abuse domain blocking script
# written by Dirk Brenken (dev@brenken.org)

# This is free software, licensed under the GNU General Public License v3.
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.

# set the C locale
#
LC_ALL=C

# set pid & logger
#
adb_pid="${$}"
adb_pidfile="/var/run/adblock.pid"
adb_log="$(which logger)"

if [ -r "${adb_pidfile}" ]
then
    rc=255
    "${adb_log}" -s -t "adblock[${adb_pid}] error" "adblock service already running ($(cat ${adb_pidfile}))"
    exit ${rc}
else
    printf "${adb_pid}" > "${adb_pidfile}"
fi

# get current directory and set script/config version
#
adb_scriptdir="${0%/*}"
adb_scriptver="1.2.1"
adb_mincfgver="2.2"

# source in adblock function library
#
if [ -r "${adb_scriptdir}/adblock-helper.sh" ]
then
    . "${adb_scriptdir}/adblock-helper.sh"
else
    rc=254
    "${adb_log}" -s -t "adblock[${adb_pid}] error" "adblock function library not found"
    rm -f "${adb_pidfile}"
    exit ${rc}
fi

# call trap function on error signals (HUP, INT, QUIT, BUS, SEGV, TERM)
#
trap "rc=250; f_log 'error signal received/trapped' '${rc}'; f_exit" 1 2 3 10 11 15

# load environment
#
f_envload

# start logging
#
f_log "domain adblock processing started (${adb_scriptver}, ${adb_sysver}, $(/bin/date "+%d.%m.%Y %H:%M:%S"))"

# check environment
#
f_envcheck

# loop through active adblock domain sources,
# download sources, prepare output and store all extracted domains in temp file
#
for src_name in ${adb_sources}
do
    eval "url=\"\${adb_src_${src_name}}\""
    eval "src_rset=\"\${adb_src_rset_${src_name}}\""
    adb_dnsfile="${adb_dnsdir}/${adb_dnsprefix}.${src_name}"
    list_time="$(${adb_uci} -q get "adblock.${src_name}.adb_src_timestamp")"
    f_log "=> processing adblock source '${src_name}'"

    # check 'url' and 'src_rset' values
    #
    if [ -z "${url}" ] || [ -z "${src_rset}" ]
    then
        "${adb_uci}" -q set "adblock.${src_name}.adb_src_timestamp=broken config"
        f_log "   broken source configuration, check 'adb_src' and 'adb_src_rset' in config"
        continue
    fi

    # prepare find statement with active adblock list sources
    #
    if [ -z "${adb_srclist}" ]
    then
        adb_srclist="! -name ${adb_dnsprefix}.${src_name}*"
    else
        adb_srclist="${adb_srclist} -a ! -name ${adb_dnsprefix}.${src_name}*"
    fi

    # download only block list with newer/updated timestamp
    #
    if [ "${src_name}" = "blacklist" ]
    then
        url_time="$(date -r "${url}")"
    else
        url_time="$(${adb_fetch} ${fetch_parm} --server-response --spider "${url}" 2>&1 | awk '$0 ~ /Last-Modified/ {printf substr($0,18)}')"
    fi
    if [ -z "${url_time}" ]
    then
        url_time="$(date)"
        f_log "   no online timestamp received"
    fi
    if [ -z "${list_time}" ] || [ "${list_time}" != "${url_time}" ] || [ ! -r "${adb_dnsfile}" ] ||\
      ([ "${backup_ok}" = "true" ] && [ ! -r "${adb_dir_backup}/${adb_dnsprefix}.${src_name}.gz" ])
    then
        if [ "${src_name}" = "blacklist" ]
        then
            tmp_domains="$(cat "${url}")"
        elif [ "${src_name}" = "shalla" ]
        then
            shalla_archive="${adb_tmpdir}/shallalist.tar.gz"
            shalla_file="${adb_tmpdir}/shallalist.txt"
            "${adb_fetch}" ${fetch_parm} --output-document="${shalla_archive}" "${url}"
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
                tmp_domains="$(cat "${shalla_file}")"
                rm -rf "${adb_tmpdir}/BL"
                rm -f "${shalla_archive}"
                rm -f "${shalla_file}"
            fi
        else
            tmp_domains="$(${adb_fetch} ${fetch_parm} --output-document=- "${url}")"
        fi
        rc=${?}
    else
        f_log "   source doesn't change, no update required"
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
        "${adb_uci}" -q set "adblock.${src_name}.adb_src_timestamp=empty download"
        f_log "   empty source download finished"
        continue
    else
        rc=0
        if [ "${backup_ok}" = "true" ] && [ -r "${adb_dir_backup}/${adb_dnsprefix}.${src_name}.gz" ]
        then
            gunzip -cf "${adb_dir_backup}/${adb_dnsprefix}.${src_name}.gz" > "${adb_tmpfile}"
            count="$(wc -l < "${adb_tmpfile}")"
            "${adb_uci}" -q set "adblock.${src_name}.adb_src_timestamp=list restored"
            f_log "   source download failed, list restored (${count} entries)"
        else
            "${adb_uci}" -q set "adblock.${src_name}.adb_src_timestamp=download failed"
            f_log "   source download failed"
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

        # finish domain processing, prepare find statement with revised adblock list source
        #
        if [ $((rc)) -eq 0 ]
        then
            if [ -z "${adb_revsrclist}" ]
            then
                adb_revsrclist="-name ${adb_dnsprefix}.${src_name}"
            else
                adb_revsrclist="${adb_revsrclist} -o -name ${adb_dnsprefix}.${src_name}"
            fi
            f_log "   domain merging finished"
        else
            rc=0
            rm -f "${adb_dnsfile}"
            if [ "${backup_ok}" = "true" ] && [ -r "${adb_dir_backup}/${adb_dnsprefix}.${src_name}.gz" ]
            then
                rm -f "${adb_dir_backup}/${adb_dnsprefix}.${src_name}.gz"
            fi
            f_log "   domain merging failed, list removed"
            continue
        fi
    else
        rm -f "${adb_dnsfile}"
        if [ "${backup_ok}" = "true" ] && [ -r "${adb_dir_backup}/${adb_dnsprefix}.${src_name}.gz" ]
        then
            rm -f "${adb_dir_backup}/${adb_dnsprefix}.${src_name}.gz"
        fi
        "${adb_uci}" -q set "adblock.${src_name}.adb_src_timestamp=empty domain input"
        f_log "   empty domain input received, list removed"
        continue
    fi
done

# remove disabled adblock lists and their backups
#
if [ -n "${adb_srclist}" ]
then
    rm_done="$(find "${adb_dnsdir}" -maxdepth 1 -type f \( ${adb_srclist} \) -print -exec rm -f "{}" \;)"
    if [ "${backup_ok}" = "true" ] && [ -n "${rm_done}" ]
    then
        find "${adb_dir_backup}" -maxdepth 1 -type f \( ${adb_srclist} \) -exec rm -f "{}" \;
    fi
else
    rm_done="$(find "${adb_dnsdir}" -maxdepth 1 -type f -name "${adb_dnsprefix}*" -print -exec rm -f "{}" \;)"
    if [ "${backup_ok}" = "true" ]
    then
        find "${adb_dir_backup}" -maxdepth 1 -type f -name "${adb_dnsprefix}*" -exec rm -f "{}" \;
    fi
fi
if [ -n "${rm_done}" ]
then
    f_rmconfig "${rm_done}"
    f_log "disabled adblock lists removed"
fi

# make separate adblock lists entries unique
#
if [ "${mem_ok}" = "true" ] && [ -n "${adb_revsrclist}" ]
then
    f_log "remove duplicates in separate adblock lists"

    # generate a unique overall block list
    #
    sort -u "${adb_dnsdir}/${adb_dnsprefix}."* > "${adb_tmpdir}/blocklist.overall"

    # loop through all separate lists, ordered by size (ascending)
    #
    for list in $(ls -ASr "${adb_dnsdir}/${adb_dnsprefix}"*)
    do
        # check overall block list vs. separate block list,
        # write all duplicate entries to separate list
        #
        list="${list/*./}"
        sort "${adb_tmpdir}/blocklist.overall" "${adb_dnsdir}/${adb_dnsprefix}.${list}" | uniq -d > "${adb_tmpdir}/tmp.${list}"
        mv -f "${adb_tmpdir}/tmp.${list}" "${adb_dnsdir}/${adb_dnsprefix}.${list}"

        # write all unique entries back to overall block list
        #
        sort "${adb_tmpdir}/blocklist.overall" "${adb_dnsdir}/${adb_dnsprefix}.${list}" | uniq -u > "${adb_tmpdir}/tmp.overall"
        mv -f "${adb_tmpdir}/tmp.overall" "${adb_tmpdir}/blocklist.overall"
    done
    rm -f "${adb_tmpdir}/blocklist.overall"
fi

# restart & check dnsmasq with newly generated set of adblock lists
#
f_cntconfig
adb_count="$(${adb_uci} -q get "adblock.global.adb_overall_count")"
if [ -n "${adb_revsrclist}" ] || [ -n "${rm_done}" ]
then
    "${adb_uci}" -q set "adblock.global.adb_dnstoggle=on"
    /etc/init.d/dnsmasq restart
    sleep 1
    check="$(pgrep -f "dnsmasq")"
    if [ -n "${check}" ]
    then
        f_log "adblock lists with overall ${adb_count} domains loaded"
    else
        f_log "dnsmasq restart failed, retry without newly generated block lists"
        rm_done="$(find "${adb_dnsdir}" -maxdepth 1 -type f \( ${adb_revsrclist} \) -print -exec rm -f "{}" \;)"
        if [ -n "${rm_done}" ]
        then
            f_log "bogus adblock lists removed"
            f_rmconfig "${rm_done}"
            /etc/init.d/dnsmasq restart
            sleep 1
            check="$(pgrep -f "dnsmasq")"
            if [ -n "${check}" ]
            then
                f_cntconfig
                f_log "adblock lists with overall ${adb_count} domains loaded"
            else
                rc=100
                f_log "dnsmasq restart failed, please check 'logread' output" "${rc}"
                f_exit
            fi
        fi
    fi
else
    f_log "adblock lists with overall ${adb_count} domains are still valid, no update required"
fi

# remove temporary files and exit
#
f_exit

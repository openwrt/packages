#!/bin/sh
# ad/abuse domain blocking script for dnsmasq/openwrt
# written by Dirk Brenken (openwrt@brenken.org)

# This is free software, licensed under the GNU General Public License v3.
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.

# set the C locale
#
LC_ALL=C

# script debug switch (disabled by default)
# set 'DEBUG=1' to enable script debugging
#
DEBUG=0
if [ $((DEBUG)) -eq 0 ]
then
    exec 2>/dev/null
fi

# pid handling
#
adb_pid="${$}"
adb_pidfile="/var/run/adblock.pid"

if [ -r "${adb_pidfile}" ]
then
    rc=255
    /usr/bin/logger -s -t "adblock[${adb_pid}] error" "adblock service already running ($(cat ${adb_pidfile}))"
    exit ${rc}
else
    printf "${adb_pid}" > "${adb_pidfile}"
fi

# get current directory, script- and openwrt version
#
adb_scriptdir="${0%/*}"
adb_scriptver="1.0.3"
openwrt_version="$(cat /etc/openwrt_version)"

# source in adblock function library
#
if [ -r "${adb_scriptdir}/adblock-helper.sh" ]
then
    . "${adb_scriptdir}/adblock-helper.sh"
else
    rc=254
    /usr/bin/logger -s -t "adblock[${adb_pid}] error" "adblock function library not found"
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
f_log "domain adblock processing started (${adb_scriptver}, ${openwrt_version}, $(/bin/date "+%d.%m.%Y %H:%M:%S"))"

# parse environment
#
f_envparse

# check environment
#
f_envcheck

# start shallalist (pre-)processing
#
if [ -n "${adb_arc_shalla}" ]
then
    # start shallalist processing
    #
    shalla_archive="${adb_tmpdir}/shallalist.tar.gz"
    shalla_file="${adb_tmpdir}/shallalist.txt"
    src_name="shalla"
    adb_dnsfile="${adb_dnsdir}/${adb_dnsprefix}.${src_name}"
    if [ -r "${adb_dnsfile}" ]
    then
        list_time="$(awk '$0 ~ /^# last modified/ {printf substr($0,18)}' "${adb_dnsfile}")"
    fi
    f_log "=> (pre-)processing adblock source '${src_name}'"

    # only process shallalist archive with updated timestamp,
    # extract and merge only domains of selected shallalist categories
    #
    shalla_time="$(${adb_fetch} ${wget_parm} --server-response --spider "${adb_arc_shalla}" 2>&1 | awk '$0 ~ /Last-Modified/ {printf substr($0,18)}')"
    if [ -z "${shalla_time}" ]
    then
        shalla_time="$(date)"
        f_log "   no online timestamp received, current date will be used"
    fi
    if [ -z "${list_time}" ] || [ "${list_time}" != "${shalla_time}" ]
    then
        ${adb_fetch} ${wget_parm} --output-document="${shalla_archive}" "${adb_arc_shalla}"
        rc=${?}
        if [ $((rc)) -eq 0 ]
        then
            > "${shalla_file}"
            for category in ${adb_cat_shalla}
            do
                tar -xOzf "${shalla_archive}" BL/${category}/domains >> "${shalla_file}"
                rc=${?}
                if [ $((rc)) -ne 0 ]
                then
                    f_log "   archive extraction failed (${category})"
                    break
                fi
            done

            # remove temporary files
            #
            rm -f "${shalla_archive}"
            rm -rf "${adb_tmpdir}/BL"
            if [ $((rc)) -eq 0 ]
            then
                adb_sources="${adb_sources} ${shalla_file}&ruleset=rset_shalla"
                f_log "   source archive (pre-)processing finished"
            else
                rc=0
                adb_srclist="! -name ${adb_dnsprefix}.${src_name}"
                adb_errsrclist="-name ${adb_dnsprefix}.${src_name}"
            fi
        else
            rc=0
            adb_srclist="! -name ${adb_dnsprefix}.${src_name}"
            adb_errsrclist="-name ${adb_dnsprefix}.${src_name}"
            f_log "   source archive download failed"
        fi
    else
        adb_srclist="! -name ${adb_dnsprefix}.${src_name}"
        f_log "   source archive doesn't change, no update required"
    fi
fi

# add blacklist source to active adblock domain sources
#
if [ -s "${adb_blacklist}" ]
then
    adb_sources="${adb_sources} ${adb_blacklist}&ruleset=rset_blacklist"
fi

# loop through active adblock domain sources,
# download sources, prepare output and store all extracted domains in temp file
#
for src in ${adb_sources}
do
    url="${src/\&ruleset=*/}"
    src_name="${src/*\&ruleset=rset_/}"
    adb_dnsfile="${adb_dnsdir}/${adb_dnsprefix}.${src_name}"
    if [ -r "${adb_dnsfile}" ]
    then
        list_time="$(awk '$0 ~ /^# last modified/ {printf substr($0,18)}' "${adb_dnsfile}")"
    fi
    f_log "=> processing adblock source '${src_name}'"

    # prepare find statement with active adblock list sources
    #
    if [ -z "${adb_srclist}" ]
    then
        adb_srclist="! -name ${adb_dnsprefix}.${src_name}"
    else
        adb_srclist="${adb_srclist} -a ! -name ${adb_dnsprefix}.${src_name}"
    fi

    # only download adblock list with newer/updated timestamp
    #
    if [ "${src_name}" = "blacklist" ]
    then
        url_time="$(date -r "${adb_blacklist}")"
    elif [ "${src_name}" = "shalla" ]
    then
        url_time="${shalla_time}"
    else
        url_time="$(${adb_fetch} ${wget_parm} --server-response --spider "${url}" 2>&1 | awk '$0 ~ /Last-Modified/ {printf substr($0,18)}')"
    fi
    if [ -z "${url_time}" ]
    then
        url_time="$(date)"
        f_log "   no online timestamp received, current date will be used"
    fi
    if [ -z "${list_time}" ] || [ "${list_time}" != "${url_time}" ]
    then
        if [ "${src_name}" = "blacklist" ]
        then
            tmp_domains="$(cat "${adb_blacklist}")"
            rc=${?}
        elif [ "${src_name}" = "shalla" ]
        then
            tmp_domains="$(cat "${shalla_file}")"
            rc=${?}
        else
            tmp_domains="$(${adb_fetch} ${wget_parm} --output-document=- "${url}")"
            rc=${?}
        fi
    else
        f_log "   source doesn't change, no update required"
        continue
    fi

    # check download result and prepare domain output by regex patterns
    #
    if [ $((rc)) -eq 0 ] && [ -n "${tmp_domains}" ]
    then
        eval "src_rset=\${rset_${src_name}}"
        count="$(printf "%s\n" "${tmp_domains}" | eval "${src_rset}" | tee "${adb_tmpfile}" | wc -l)"
        f_log "   source download finished (${count} entries)"
        if [ "${src_name}" = "shalla" ]
        then
            rm -f "${shalla_file}"
        fi
        unset tmp_domains
    elif [ $((rc)) -eq 0 ] && [ -z "${tmp_domains}" ]
    then
        f_log "   empty source download finished"
        continue
    else
        rc=0
        if [ -z "${adb_errsrclist}" ]
        then
            adb_errsrclist="-name ${adb_dnsprefix}.${src_name}"
        else
            adb_errsrclist="${adb_errsrclist} -o -name ${adb_dnsprefix}.${src_name}"
        fi
        f_log "   source download failed"
        continue
    fi

    # remove whitelist domains, sort domains and make them unique,
    # finally rewrite ad/abuse domain information to separate dnsmasq files
    #
    if [ $((count)) -gt 0 ] && [ -n "${adb_tmpfile}" ]
    then
        if [ -s "${adb_whitelist}" ]
        then
            grep -Fvxf "${adb_whitelist}" "${adb_tmpfile}" | sort -u | eval "${adb_dnsformat}" > "${adb_dnsfile}"
            rc=${?}
        else
            sort -u "${adb_tmpfile}" | eval "${adb_dnsformat}" > "${adb_dnsfile}"
            rc=${?}
        fi

        # prepare find statement with revised adblock list sources
        #
        if [ -z "${adb_revsrclist}" ]
        then
            adb_revsrclist="-name ${adb_dnsprefix}.${src_name}"
        else
            adb_revsrclist="${adb_revsrclist} -o -name ${adb_dnsprefix}.${src_name}"
        fi

        # write preliminary footer
        #
        if [ $((rc)) -eq 0 ]
        then
            printf "%s\n" "#---------------------------------------------" >> "${adb_dnsfile}"
            printf "%s\n" "# last modified: ${url_time}" >> "${adb_dnsfile}"
            printf "%s\n" "##" >> "${adb_dnsfile}"
            f_log "   domain merging finished"
        else
            f_log "   domain merging failed" "${rc}"
            f_restore
        fi
    else
        f_log "   empty domain input received"
        continue
    fi
done

# remove disabled adblock lists and their backups
#
if [ -n "${adb_srclist}" ]
then
    rm_done="$(find "${adb_dnsdir}" -maxdepth 1 -type f -name "${adb_dnsprefix}.*" \( ${adb_srclist} \) -print -exec rm -f "{}" \;)"
    rc=${?}
else
    rm_done="$(find "${adb_dnsdir}" -maxdepth 1 -type f -name "${adb_dnsprefix}.*" -print -exec rm -f "{}" \;)"
    rc=${?}
fi
if [ $((rc)) -eq 0 ] && [ -n "${rm_done}" ]
then
    f_log "disabled adblock lists removed"
    if [ "${backup_ok}" = "true" ]
    then
        if [ -n "${adb_srclist}" ]
        then
            rm_done="$(find "${adb_backupdir}" -maxdepth 1 -type f -name "${adb_dnsprefix}.*" \( ${adb_srclist} \) -print -exec rm -f "{}" \;)"
            rc=${?}
        else
            rm_done="$(find "${adb_backupdir}" -maxdepth 1 -type f -name "${adb_dnsprefix}.*" -print -exec rm -f "{}" \;)"
            rc=${?}
        fi
        if  [ $((rc)) -eq 0 ] && [ -n "${rm_done}" ]
        then
            f_log "disabled adblock list backups removed"
        elif [ $((rc)) -ne 0 ]
        then
            f_log "error during removal of disabled adblock list backups" "${rc}"
            f_exit
        fi
    fi
elif [ $((rc)) -ne 0 ]
then
    f_log "error during removal of disabled adblock lists" "${rc}"
    f_exit
fi

# partial restore of adblock lists in case of download errors
#
if [ "${backup_ok}" = "true" ] && [ -n "${adb_errsrclist}" ]
then
    restore_done="$(find "${adb_backupdir}" -maxdepth 1 -type f \( ${adb_errsrclist} \) -print -exec cp -pf "{}" "${adb_dnsdir}" \;)"
    rc=${?}
    if [ $((rc)) -eq 0 ] && [ -n "${restore_done}" ]
    then
        f_log "partial restore done"
    elif [ $((rc)) -ne 0 ]
    then
        f_log "error during partial restore" "${rc}"
        f_exit
    fi
fi

# make separate adblock lists entries unique
#
if [ "${mem_ok}" = "true" ] && [ -n "${adb_revsrclist}" ]
then
    f_log "remove duplicates in separate adblock lists"

    # generate a unique overall block list
    #
    head -qn -3 "${adb_dnsdir}/${adb_dnsprefix}."* | sort -u > "${adb_tmpdir}/blocklist.overall"

    # loop through all separate lists, ordered by size (ascending)
    #
    for list in $(ls -Sr "${adb_dnsdir}/${adb_dnsprefix}."*)
    do
        # check overall block list vs. separate block list,
        # write only duplicate entries to a temporary separate list
        #
        list="${list/*./}"
        sort "${adb_tmpdir}/blocklist.overall" "${adb_dnsdir}/${adb_dnsprefix}.${list}" | uniq -d > "${adb_tmpdir}/tmp.${list}"

        # write only unique entries back to overall block list
        #
        sort "${adb_tmpdir}/blocklist.overall" "${adb_tmpdir}/tmp.${list}" | uniq -u > "${adb_tmpdir}/tmp.overall"
        mv -f "${adb_tmpdir}/tmp.overall" "${adb_tmpdir}/blocklist.overall"

        # write unique result back to original separate list
        #
        tail -qn 3 "${adb_dnsdir}/${adb_dnsprefix}.${list}" >> "${adb_tmpdir}/tmp.${list}"
        mv -f "${adb_tmpdir}/tmp.${list}" "${adb_dnsdir}/${adb_dnsprefix}.${list}"
    done
    rm -f "${adb_tmpdir}/blocklist.overall"
fi

# set separate list count & get overall count
#
for list in $(ls -Sr "${adb_dnsdir}/${adb_dnsprefix}."*)
do
    list="${list/*./}"
    count="$(head -qn -3 "${adb_dnsdir}/${adb_dnsprefix}.${list}" | wc -l)"
    if [ -n "${adb_wanif4}" ] && [ -n "${adb_wanif6}" ]
    then
        count=$((count / 2))
    fi
    if [ "$(tail -qn 1 "${adb_dnsdir}/${adb_dnsprefix}.${list}")" = "##" ]
    then
        last_line="# ${0##*/} (${adb_scriptver}) - ${count} ad\/abuse domains blocked"
        sed -i "s/^##$/${last_line}/" "${adb_dnsdir}/${adb_dnsprefix}.${list}"
    fi
    adb_count=$((adb_count + count))
done

# restart dnsmasq with newly generated or deleted adblock lists,
# check dnsmasq startup afterwards
#
if [ -n "${adb_revsrclist}" ] || [ -n "${rm_done}" ] || [ -n "${restore_done}" ]
then
    /etc/init.d/dnsmasq restart
    sleep 1
    rc="$(ps | grep -q "[d]nsmasq"; printf ${?})"
    if [ $((rc)) -eq 0 ]
    then
        f_log "adblock lists with overall ${adb_count} domains loaded"
    else
        rc=100
        f_log "dnsmasq restart failed, please check 'logread' output" "${rc}"
        f_restore
    fi
else
    f_log "adblock lists with overall ${adb_count} domains are still valid, no dnsmasq restart required"
fi

# create adblock list backups
#
if [ "${backup_ok}" = "true" ] && [ -n "${adb_revsrclist}" ] && [ "$(printf "${adb_dnsdir}/${adb_dnsprefix}."*)" != "${adb_dnsdir}/${adb_dnsprefix}.*" ]
then
    backup_done="$(find "${adb_dnsdir}" -maxdepth 1 -type f \( ${adb_revsrclist} \) -print -exec cp -pf "{}" "${adb_backupdir}" \;)"
    rc=${?}
    if [ $((rc)) -eq 0 ] && [ -n "${backup_done}" ]
    then
        f_log "new adblock list backups generated"
    elif [ $((rc)) -ne 0 ]
    then
        f_log "error during backup of adblock lists" "${rc}"
        f_exit
    fi
fi

# remove temporary files and exit
#
f_exit

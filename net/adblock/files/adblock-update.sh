#!/bin/sh
#######################################################
# ad/abuse domain blocking script for dnsmasq/openwrt #
# written by Dirk Brenken (openwrt@brenken.org)       #
#######################################################

# LICENSE
# ========
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.

###############
# environment #
###############

# set the C locale, characters are single bytes, the charset is ASCII
# speeds up things like sort, grep etc.
#
LC_ALL=C

# pid handling
#
adb_pid="${$}"
adb_pidfile="/var/run/adblock.pid"

if [ -r "${adb_pidfile}" ]
then
    rc=255
    /usr/bin/logger -t "adblock[${adb_pid}] error" "adblock service already running ($(cat ${adb_pidfile} 2>/dev/null))"
    exit ${rc}
else
    printf "${adb_pid}" > "${adb_pidfile}"
fi

# get current directory, script- and openwrt version
#
adb_scriptdir="${0%/*}"
adb_scriptver="0.70.1"
openwrt_version="$(cat /etc/openwrt_version 2>/dev/null)"

# source in adblock function library
#
if [ -r "${adb_scriptdir}/adblock-helper.sh" ]
then
    . "${adb_scriptdir}/adblock-helper.sh" 2>/dev/null
else
    rc=254
    /usr/bin/logger -t "adblock[${adb_pid}] error" "adblock function library not found"
    exit ${rc}
fi

################
# main program #
################

# call trap function on error signals (HUP, INT, QUIT, BUS, SEGV, TERM)
#
trap "rc=253; f_log 'error signal received/trapped' '${rc}'; f_exit" 1 2 3 10 11 15

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
    list_time="$(grep -F "# last modified: " "${adb_dnsfile}" 2>/dev/null)"
    list_time="${list_time/*: /}"
    f_log "=> (pre-)processing adblock source '${src_name}'"

    # only process shallalist archive with updated timestamp,
    # extract and merge only domains of selected shallalist categories
    #
    shalla_time="$(${adb_fetch} ${wget_parm} --timeout=5 --server-response --spider "${adb_arc_shalla}" 2>&1 | grep -F "Last-Modified: " 2>/dev/null | tr -d '\r' 2>/dev/null)"
    shalla_time="${shalla_time/*: /}"
    if [ -z "${shalla_time}" ]
    then
        shalla_time="$(date)"
        f_log "   no online timestamp received, current date will be used"
    fi
    if [ -z "${list_time}" ] || [ "${list_time}" != "${shalla_time}" ]
    then
        ${adb_fetch} ${wget_parm} --timeout="${adb_maxtime}" --output-document="${shalla_archive}" "${adb_arc_shalla}" 2>/dev/null
        rc=${?}
        if [ $((rc)) -eq 0 ]
        then
            > "${shalla_file}"
            for category in ${adb_cat_shalla}
            do
                tar -xOzf "${shalla_archive}" BL/${category}/domains 2>/dev/null >> "${shalla_file}"
                rc=${?}
                if [ $((rc)) -ne 0 ]
                then
                    f_log "   archive extraction failed (${category})"
                    break
                fi
            done

            # remove temporary files
            #
            rm -f "${shalla_archive}" >/dev/null 2>&1
            rm -rf "${adb_tmpdir}/BL" >/dev/null 2>&1 
            if [ $((rc)) -eq 0 ]
            then
                adb_sources="${adb_sources} ${shalla_file}&ruleset=rset_shalla"
                f_log "   source archive (pre-)processing finished"
            else
                rc=0
            fi
        else
            rc=0
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
    list_time="$(grep -F "# last modified: " "${adb_dnsfile}" 2>/dev/null)"
    list_time="${list_time/*: /}"
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
        url_time="$(date -r "${adb_blacklist}" 2>/dev/null)"
    elif [ "${src_name}" = "shalla" ]
    then
        url_time="${shalla_time}"
    else
        url_time="$(${adb_fetch} ${wget_parm} --timeout=5 --server-response --spider "${url}" 2>&1 | grep -F "Last-Modified: " 2>/dev/null | tr -d '\r' 2>/dev/null)"
        url_time="${url_time/*: /}"
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
            tmp_domains="$(cat "${adb_blacklist}" 2>/dev/null)"
            rc=${?}
        elif [ "${src_name}" = "shalla" ]
        then
            tmp_domains="$(cat "${shalla_file}" 2>/dev/null)"
            rc=${?}
        else
            tmp_domains="$(${adb_fetch} ${wget_parm} --timeout="${adb_maxtime}" --output-document=- "${url}" 2>/dev/null)"
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
        eval "$(printf "${src}" | sed 's/\(.*\&ruleset=\)/ruleset=\$/g')"
        count="$(printf "%s\n" "${tmp_domains}" | tr '[A-Z]' '[a-z]' | eval "${ruleset}" | tee "${adb_tmpfile}" | wc -l)"
        f_log "   source download finished (${count} entries)"
        if [ "${src_name}" = "shalla" ]
        then
            rm -f "${shalla_file}" >/dev/null 2>&1
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
            grep -Fvxf "${adb_whitelist}" "${adb_tmpfile}" 2>/dev/null | sort 2>/dev/null | uniq -u 2>/dev/null | eval "${adb_dnsformat}" 2>/dev/null > "${adb_dnsfile}"
            rc=${?}
        else
            sort "${adb_tmpfile}" 2>/dev/null | uniq -u 2>/dev/null | eval "${adb_dnsformat}" 2>/dev/null > "${adb_dnsfile}"
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

        # write preliminary adblock list footer
        #
        if [ $((rc)) -eq 0 ]
        then
            if [ -n "${adb_wanif4}" ] && [ -n "${adb_wanif6}" ]
            then
                count="$(($(wc -l < "${adb_dnsdir}/${adb_dnsprefix}.${src_name}") / 2))"
            else
                count="$(wc -l < "${adb_dnsdir}/${adb_dnsprefix}.${src_name}")"
            fi
            printf "%s\n" "#------------------------------------------------------------------" >> "${adb_dnsfile}"
            printf "%s\n" "# ${0##*/} (${adb_scriptver}) - ${count} ad/abuse domains blocked" >> "${adb_dnsfile}"
            printf "%s\n" "# source: ${url}" >> "${adb_dnsfile}"
            printf "%s\n" "# last modified: ${url_time}" >> "${adb_dnsfile}"
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
    rm_done="$(find "${adb_dnsdir}" -maxdepth 1 -type f -name "${adb_dnsprefix}.*" \( ${adb_srclist} \) -print -exec rm -f "{}" \; 2>/dev/null)"
    rc=${?}
    if [ $((rc)) -eq 0 ] && [ -n "${rm_done}" ]
    then
        f_log "disabled adblock lists removed"
        if [ "${backup_ok}" = "true" ]
        then
            rm_done="$(find "${adb_backupdir}" -maxdepth 1 -type f -name "${adb_dnsprefix}.*" \( ${adb_srclist} \) -print -exec rm -f "{}" \; 2>/dev/null)"
            rc=${?}
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
else
    rm_done="$(find "${adb_dnsdir}" -maxdepth 1 -type f -name "${adb_dnsprefix}.*" -print -exec rm -f "{}" \; 2>/dev/null)"
    rc=${?}
    if [ $((rc)) -eq 0 ] && [ -n "${rm_done}" ]
    then
        f_log "all adblock lists removed"
        if [ "${backup_ok}" = "true" ]
        then
            rm_done="$(find "${adb_backupdir}" -maxdepth 1 -type f -name "${adb_dnsprefix}.*" -print -exec rm -f "{}" \; 2>/dev/null)"
            rc=${?}
            if [ $((rc)) -eq 0 ] && [ -n "${rm_done}" ]
            then
                f_log "all adblock list backups removed"
            elif [ $((rc)) -ne 0 ]
            then
                f_log "error during removal of all adblock list backups" "${rc}"
                f_exit
            fi
        fi
    elif [ $((rc)) -ne 0 ]
    then
        f_log "error during removal of all adblock lists" "${rc}"
        f_exit
    fi
fi

# partial restore of adblock lists in case of download errors
#
if [ "${backup_ok}" = "true" ] && [ -n "${adb_errsrclist}" ]
then
    restore_done="$(find "${adb_backupdir}" -maxdepth 1 -type f \( ${adb_errsrclist} \) -print -exec cp -pf "{}" "${adb_dnsdir}" \; 2>/dev/null)"
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

# make separate adblock lists unique
#
if [ $((adb_unique)) -eq 1 ]
then
    if [ -n "${adb_revsrclist}" ]
    then
        f_log "remove duplicates in separate adblock lists"

        # generate a temporary, unique overall list
        #
        head -qn -4 "${adb_dnsdir}/${adb_dnsprefix}."* 2>/dev/null | sort -u 2>/dev/null > "${adb_dnsdir}/tmp.overall"

        # loop through all separate lists, ordered by size (ascending)
        #
        for list in $(ls -Sr "${adb_dnsdir}/${adb_dnsprefix}."* 2>/dev/null)
        do
            # check separate lists vs. overall list,
            # rewrite only duplicate entries back to separate lists
            #
            list="${list/*./}"
            sort "${adb_dnsdir}/tmp.overall" "${adb_dnsdir}/${adb_dnsprefix}.${list}" 2>/dev/null | uniq -d 2>/dev/null > "${adb_dnsdir}/tmp.${list}"

            # remove these entries from overall list,
            # rewrite only unique entries back to overall list
            #
            tmp_unique="$(sort "${adb_dnsdir}/tmp.overall" "${adb_dnsdir}/tmp.${list}" 2>/dev/null | uniq -u 2>/dev/null)"
            printf "%s\n" "${tmp_unique}" > "${adb_dnsdir}/tmp.overall"

            # write final adblocklist footer
            #
            if [ -n "${adb_wanif4}" ] && [ -n "${adb_wanif6}" ]
            then
                count="$(($(wc -l < "${adb_dnsdir}/tmp.${list}") / 2))"
            else
                count="$(wc -l < "${adb_dnsdir}/tmp.${list}")"
            fi
            printf "%s\n" "#------------------------------------------------------------------" >> "${adb_dnsdir}/tmp.${list}"
            printf "%s\n" "# ${0##*/} (${adb_scriptver}) - ${count} ad/abuse domains blocked" >> "${adb_dnsdir}/tmp.${list}"
            tail -qn -2 "${adb_dnsdir}/$adb_dnsprefix.${list}" 2>/dev/null >> "${adb_dnsdir}/tmp.${list}"
            mv -f "${adb_dnsdir}/tmp.${list}" "${adb_dnsdir}/${adb_dnsprefix}.${list}" >/dev/null 2>&1
        done
        rm -f "${adb_dnsdir}/tmp.overall" >/dev/null 2>&1
    fi
fi

# get overall count
#
if [ -n "${adb_wanif4}" ] && [ -n "${adb_wanif6}" ]
then
    adb_count="$(($(head -qn -4 "${adb_dnsdir}/${adb_dnsprefix}."* 2>/dev/null | wc -l) / 2))"
else
    adb_count="$(head -qn -4 "${adb_dnsdir}/${adb_dnsprefix}."* 2>/dev/null | wc -l)"
fi

# restart dnsmasq with newly generated or deleted adblock lists,
# check dnsmasq startup afterwards
#
if [ -n "${adb_revsrclist}" ] || [ -n "${rm_done}" ]
then
    /etc/init.d/dnsmasq restart >/dev/null 2>&1
    sleep 2
    dns_status="$(ps 2>/dev/null | grep "[d]nsmasq" 2>/dev/null)"
    if [ -n "${dns_status}" ]
    then
        f_log "adblock lists with overall ${adb_count} domains loaded"
    else
        rc=105
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
    backup_done="$(find "${adb_dnsdir}" -maxdepth 1 -type f \( ${adb_revsrclist} \) -print -exec cp -pf "{}" "${adb_backupdir}" \; 2>/dev/null)"
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

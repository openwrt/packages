#!/bin/sh
#######################################################
# ad/abuse domain blocking script for dnsmasq/openwrt #
# written by Dirk Brenken (dirk@brenken.org)          #
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

# set script version
#
adb_version="0.40.2"

# get current pid, script directory and openwrt version
#
pid=${$}
adb_scriptdir="${0%/*}"
openwrt_version="$(cat /etc/openwrt_version 2>/dev/null)"

# source in adblock function library
#
if [ -r "${adb_scriptdir}/adblock-helper.sh" ]
then
    . "${adb_scriptdir}/adblock-helper.sh" 2>/dev/null
else
    rc=600
    /usr/bin/logger -s -t "adblock[${pid}] error" "adblock function library not found, rc: ${rc}"
    exit ${rc}
fi

################
# main program #
################

# call restore function on trap signals (HUP, INT, QUIT, BUS, SEGV, TERM)
#
trap "f_log 'trap error' '700'; f_restore" 1 2 3 10 11 15

# start logging
#
f_log "domain adblock processing started (${adb_version}, ${openwrt_version}, $(/bin/date "+%d.%m.%Y %H:%M:%S"))"

# load environment
#
f_envload

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

    # only process shallalist archive with updated timestamp
    #
    shalla_time="$(curl ${curl_parm} --max-time 5 --head "${adb_arc_shalla}" 2>/dev/null | grep -F "Last-Modified: " 2>/dev/null | tr -d '\r' 2>/dev/null)"
    shalla_time="${shalla_time/*: /}"
    if [ -z "${shalla_time}" ]
    then
        shalla_time="$(date)"
        f_log "no online timestamp received, current date will be used (${src_name})"
    fi
    if [ -z "${list_time}" ] || [ "${list_time}" != "${shalla_time}" ]
    then
        f_log "shallalist (pre-)processing started ..."
        curl ${curl_parm} --max-time "${adb_maxtime}" "${adb_arc_shalla}" --output "${shalla_archive}" 2>/dev/null
        rc=${?}
        if [ $((rc)) -ne 0 ]
        then
            f_log "source download failed (${src_name})" "${rc}"
            f_restore
        fi

        # extract and merge only domains of selected shallalist categories
        #
        > "${shalla_file}"
        for category in ${adb_cat_shalla}
        do
            tar -xOzf "${shalla_archive}" BL/${category}/domains 2>/dev/null >> "${shalla_file}"
            rc=${?}
            if [ $((rc)) -ne 0 ]
            then
                f_log "source archive extraction failed (${category})" "${rc}"
                f_restore
            fi
        done

        # remove temporary files
        #
        rm -f "${shalla_archive}" >/dev/null 2>&1
        rm -rf "${adb_tmpdir}/BL" >/dev/null 2>&1 
    fi
    adb_sources="${adb_sources} file:///${shalla_file}&ruleset=rset_shalla"
fi

# add blacklist source to active adblock domain sources
#
if [ -n "${adb_sources}" ] && [ -s "${adb_blacklist}" ]
then
    adb_sources="${adb_sources} file://${adb_blacklist}&ruleset=rset_blacklist"
fi

# loop through active adblock domain sources,
# prepare output and store all extracted domains in temp file
#
for src in ${adb_sources}
do
    # download selected adblock sources
    #
    url="${src/\&ruleset=*/}"
    check_url="$(printf "${url}" | sed -n '/^https:/p' 2>/dev/null)"
    src_name="${src/*\&ruleset=rset_/}"
    adb_dnsfile="${adb_dnsdir}/${adb_dnsprefix}.${src_name}"
    list_time="$(grep -F "# last modified: " "${adb_dnsfile}" 2>/dev/null)"
    list_time="${list_time/*: /}"

    # prepare find statement for all active adblocklist sources
    #
    if [ -z "${adb_srcfind}" ]
    then
        adb_srcfind="! -name ${adb_dnsprefix}.${src_name}"
    else
        adb_srcfind="${adb_srcfind} -a ! -name ${adb_dnsprefix}.${src_name}"
    fi

    # wget/curl switch
    # only download blocklist with newer/updated timestamp
    #
    if [ -n "${check_url}" ]
    then
        url_time="$(wget ${wget_parm} --timeout=5 --server-response --spider "${url}" 2>&1 | grep -F "Last-Modified: " 2>/dev/null | tr -d '\r' 2>/dev/null)"
        url_time="${url_time/*: /}"
        if [ -z "${url_time}" ]
        then
            url_time="$(date)"
            f_log "no online timestamp received, current date will be used (${src_name})"
        fi
        if [ -z "${list_time}" ] || [ "${list_time}" != "${url_time}" ]
        then
            tmp_domains="$(wget ${wget_parm} --timeout="${adb_maxtime}" --tries=1 --output-document=- "${url}" 2>/dev/null)"
            rc=${?}
        else
            f_log "source doesn't change, no update required (${src_name})"
            continue
        fi
    else
        if [ "${src_name}" = "shalla" ]
        then
            url_time="${shalla_time}"
        else
            url_time="$(curl ${curl_parm} --max-time 5 --head "${url}" 2>/dev/null | grep -F "Last-Modified: " | tr -d '\r')"
            url_time="${url_time/*: /}"
        fi
        if [ -z "${url_time}" ]
        then
            url_time="$(date)"
            f_log "no online timestamp received, current date will be used (${src_name})"
        fi
        if [ -z "${list_time}" ] || [ "${list_time}" != "${url_time}" ]
        then
            tmp_domains="$(curl ${curl_parm} --max-time "${adb_maxtime}" "${url}" 2>/dev/null)"
            rc=${?}
        else
            f_log "source doesn't change, no update required (${src_name})"
            continue
        fi
    fi

    # check download result and prepare domain output by regex patterns
    #
    if [ $((rc)) -eq 0 ] && [ -n "${tmp_domains}" ]
    then
        eval "$(printf "${src}" | sed 's/\(.*\&ruleset=\)/ruleset=\$/g')"
        count="$(printf "%s\n" "${tmp_domains}" | tr '[A-Z]' '[a-z]' | eval "${ruleset}" | tee "${adb_tmpfile}" | wc -l)"
        f_log "source download finished (${url}, ${count} entries)"
        if [ "${src_name}" = "shalla" ]
        then
            rm -f "${shalla_file}" >/dev/null 2>&1
        fi
        unset tmp_domains
    elif [ $((rc)) -eq 0 ] && [ -z "${tmp_domains}" ]
    then
        f_log "empty source download finished (${src_name})"
        continue
    else
        f_log "source download failed (${src_name})" "${rc}"
        f_restore
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

        # prepare find statement for revised adblocklist sources
        #
        if [ -z "${adb_revsrcfind}" ]
        then
            adb_revsrcfind="-name ${adb_dnsprefix}.${src_name}"
        else
            adb_revsrcfind="${adb_revsrcfind} -o -name ${adb_dnsprefix}.${src_name}"
        fi

        # write preliminary adblocklist footer
        #
        if [ $((rc)) -eq 0 ]
        then
            count="$(wc -l < "${adb_dnsdir}/${adb_dnsprefix}.${src_name}")"
            printf "%s\n" "#------------------------------------------------------------------" >> "${adb_dnsfile}"
            printf "%s\n" "# ${0##*/} (${adb_version}) - ${count} ad/abuse domains blocked" >> "${adb_dnsfile}"
            printf "%s\n" "# source: ${url}" >> "${adb_dnsfile}"
            printf "%s\n" "# last modified: ${url_time}" >> "${adb_dnsfile}"
            f_log "domain merging finished (${src_name})"
        else
            f_log "domain merging failed (${src_name})" "${rc}"
            f_restore
        fi
    else
        f_log "empty domain input received (${src_name})"
        continue
    fi
done

# remove old adblocklists and their backups
#
if [ -n "${adb_srcfind}" ]
then
    find "${adb_dnsdir}" -maxdepth 1 -type f -name "${adb_dnsprefix}.*" \( ${adb_srcfind} \) -exec rm -f "{}" \; 2>/dev/null
    if [ $((rc)) -ne 0 ]
    then
        f_log "error during removal of old adblocklists" "${rc}"
        f_remove
    fi
    if [ "${backup_ok}" = "true" ]
    then
        find "${adb_backupdir}" -maxdepth 1 -type f -name "${adb_dnsprefix}.*" \( ${adb_srcfind} \) -exec rm -f "{}" \; 2>/dev/null
        if [ $((rc)) -ne 0 ]
        then
            f_log "error during removal of old backups" "${rc}"
            f_remove
        fi
    fi
else
    rm -f "${adb_dnsdir}/${adb_dnsprefix}."* >/dev/null 2>&1
    if [ "${backup_ok}" = "true" ]
    then
        rm -f "${adb_backupdir}/${adb_dnsprefix}."* >/dev/null 2>&1
        f_log "all available adblocklists and backups removed"
    else
        f_log "all available adblocklists removed"
    fi
fi

# make separate adblocklists unique
#
if [ $((adb_unique)) -eq 1 ]
then
    if [ -n "${adb_revsrcfind}" ]
    then
        f_log "remove duplicates in separate adblocklists ..."

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
            count="$(wc -l < "${adb_dnsdir}/tmp.${list}")"
            printf "%s\n" "#------------------------------------------------------------------" >> "${adb_dnsdir}/tmp.${list}"
            printf "%s\n" "# ${0##*/} (${adb_version}) - ${count} ad/abuse domains blocked" >> "${adb_dnsdir}/tmp.${list}"
            tail -qn -2 "${adb_dnsdir}/$adb_dnsprefix.${list}" 2>/dev/null >> "${adb_dnsdir}/tmp.${list}"
            mv -f "${adb_dnsdir}/tmp.${list}" "${adb_dnsdir}/${adb_dnsprefix}.${list}" >/dev/null 2>&1
        done
        rm -f "${adb_dnsdir}/tmp.overall" >/dev/null 2>&1
    fi
fi

# restart dnsmasq with newly generated block lists
#
/etc/init.d/dnsmasq restart >/dev/null 2>&1
sleep 3

# dnsmasq health check
#
dns_status="$(logread -l 20 -e "dnsmasq" -e "FAILED to start up" 2>/dev/null)"
if [ -z "${dns_status}" ]
then
    dns_status="$(nslookup "${adb_domain}" 2>/dev/null | grep -F "${adb_ip}" 2>/dev/null)"
    if [ -z "${dns_status}" ]
    then
        adb_count="$(head -qn -4 "${adb_dnsdir}/${adb_dnsprefix}."* 2>/dev/null | wc -l)"
        if [ "${backup_ok}" = "true" ]
        then
            if [ -n "${adb_revsrcfind}" ]
            then
                find "${adb_dnsdir}" -maxdepth 1 -type f \( ${adb_revsrcfind} \) -exec cp -f "{}" "${adb_backupdir}" \; 2>/dev/null
                rc=${?}
                if [ $((rc)) -ne 0 ]
                then
                    f_log "error during backup of adblocklists" "${rc}"
                    f_remove
                fi
                f_log "adblocklists with overall ${adb_count} domains loaded, new backups generated"
            else
                f_log "adblocklists with overall ${adb_count} domains loaded, no new backups"
            fi
        else
            f_log "adblocklists with overall ${adb_count} domains loaded, backups disabled"
        fi
    else
        rc=605
        f_log "nslookup probe failed" "${rc}"
        f_restore
    fi
else
    rc=610
    f_log "dnsmasq probe failed" "${rc}"
    f_restore
fi

# remove temporary files and exit
#
f_remove

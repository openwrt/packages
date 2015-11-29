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
adb_version="0.22.2"

# get current pid, script directory and openwrt version
#
pid=${$}
adb_scriptdir="${0%/*}"
openwrt_version="$(cat /etc/openwrt_version 2>/dev/null)"

# source in adblock function library
#
if [ -r "${adb_scriptdir}/adblock-helper.sh" ]
then
    . "${adb_scriptdir}/adblock-helper.sh"
else
    rc=500
    /usr/bin/logger -s -t "adblock[${pid}] error" "adblock function library not found, rc: ${rc}"
    exit ${rc}
fi

################
# main program #
################

# call restore function on trap signals (HUP, INT, QUIT, BUS, SEGV, TERM)
#
trap "f_log 'trap error' '600'; f_restore" 1 2 3 10 11 15

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
    # download shallalist archive
    #
    f_log "shallalist (pre-)processing started ..."
    shalla_archive="${adb_tmpdir}/shallalist.tar.gz"
    shalla_file="${adb_tmpdir}/shallalist.txt"
    curl ${curl_parm} --max-time "${adb_maxtime}" "${adb_arc_shalla}" --output "${shalla_archive}" 2>/dev/null
    rc=${?}
    if [ $((rc)) -ne 0 ]
    then
        f_log "shallalist archive download failed (${adb_arc_shalla})" "${rc}"
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
            f_log "shallalist archive extraction failed (${category})" "${rc}"
            f_restore
        fi
    done

    # finish shallalist (pre-)processing
    #
    rm -f "${shalla_archive}" >/dev/null 2>&1
    rm -rf "${adb_tmpdir}/BL" >/dev/null 2>&1 
    adb_sources="${adb_sources} file:///${shalla_file}&ruleset=rset_shalla"
    f_log "shallalist (pre-)processing finished (${adb_cat_shalla# })"
fi

# loop through active adblock domain sources,
# prepare output and store all extracted domains in temp file
#
adb_sources="${adb_sources} file://${adb_blacklist}&ruleset=rset_default"
for src in ${adb_sources}
do
    # download selected adblock sources
    #
    url="${src//\&ruleset=*/}"
    check_url="$(printf "${url}" | sed -n '/^https:/p')"
    if [ -n "${check_url}" ]
    then
        tmp_var="$(wget ${wget_parm} --timeout="${adb_maxtime}" --tries=1 --output-document=- "${url}" 2>/dev/null)"
        rc=${?}
    else
        tmp_var="$(curl ${curl_parm} --max-time "${adb_maxtime}" "${url}" 2>/dev/null)"
        rc=${?}
    fi

    # check download result and prepare domain output by regex patterns
    #
    if [ $((rc)) -eq 0 ] && [ -n "${tmp_var}" ]
    then
        eval "$(printf "${src}" | sed 's/\(.*\&ruleset=\)/ruleset=\$/g')"
        tmp_var="$(printf "%s\n" "${tmp_var}" | tr '[A-Z]' '[a-z]')"
        count="$(printf "%s\n" "${tmp_var}" | eval "${ruleset}" | tee -a "${adb_tmpfile}" | wc -l)"
        f_log "source download finished (${url}, ${count} entries)"
        if [ "${url}" = "file:///${shalla_file}" ]
        then
            rm -f "${shalla_file}" >/dev/null 2>&1
        fi
        unset tmp_var 2>/dev/null
    elif [ $((rc)) -eq 0 ] && [ -z "${tmp_var}" ]
    then
        f_log "empty source download finished (${url})"
    else
        f_log "source download failed (${url})" "${rc}"
        f_restore
    fi
done

# remove whitelist domains, sort domains and make them unique
# and finally rewrite ad/abuse domain information to dnsmasq file
#
if [ -s "${adb_whitelist}" ]
then
    grep -Fvxf "${adb_whitelist}" "${adb_tmpfile}" 2>/dev/null | sort -u 2>/dev/null | eval "${adb_dnsformat}" 2>/dev/null > "${adb_dnsfile}"
    rc=${?}
else
    sort -u "${adb_tmpfile}" 2>/dev/null | eval "${adb_dnsformat}" 2>/dev/null > "${adb_dnsfile}"
    rc=${?}
fi

if [ $((rc)) -eq 0 ]
then
    rm -f "${adb_tmpfile}" >/dev/null 2>&1
    f_log "domain merging finished"
else
    f_log "domain merging failed" "${rc}"
    f_restore
fi

# write dns file footer
#
f_footer

# restart dnsmasq with newly generated block list
#
/etc/init.d/dnsmasq restart >/dev/null 2>&1
sleep 2

# dnsmasq health check
#
f_dnscheck

# remove files and exit
#
f_remove

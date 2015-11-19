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
adb_version="0.20.3"

# get current pid and script directory
#
pid=$$
adb_scriptdir="${0%/*}"

# source in adblock function library
#
if [ -r "${adb_scriptdir}/adblock-helper.sh" ]
then
    . "${adb_scriptdir}/adblock-helper.sh"
else
    /usr/bin/logger -t "adblock[${pid}]" "error: adblock function library not found"
    exit 200
fi

################
# main program #
################

# call restore function on trap signals (HUP, INT, QUIT, BUS, SEGV, TERM)
#
trap "restore_msg='trap error'; f_restore" 1 2 3 10 11 15

# start logging
#
/usr/bin/logger -t "adblock[${pid}]" "info: domain adblock processing started (${adb_version})"

# load environment
#
f_envload

# parse environment
#
f_envparse

# check environment
#
f_envcheck

# check ntp time sync
#
f_ntpcheck

# check wan update interface(s)
#
f_wancheck

# check/start shallalist (pre-)processing
#
if [ -n "${adb_arc_shalla}" ]
then
    # download shallalist archive
    #
    shalla_archive="${adb_tmpdir}/shallalist.tar.gz"
    shalla_file="${adb_tmpdir}/shallalist.txt"
    curl --insecure --max-time "${max_time}" "${adb_arc_shalla}" -o "${shalla_archive}" 2>/dev/null
    rc=$?
    if [ $((rc)) -eq 0 ]
    then
        /usr/bin/logger -t "adblock[${pid}]" "info: shallalist archive download finished"
    else
        /usr/bin/logger -t "adblock[${pid}]" "error: shallalist archive download failed (${adb_arc_shalla})"
        printf "%s\n" "$(/bin/date "+%d.%m.%Y %H:%M:%S") - error: shallalist archive download failed (${adb_arc_shalla})" >> "${adb_logfile}"
        restore_msg="archive download failed"
        f_restore
    fi

    # extract shallalist archive
    #
    tar -xzf "${shalla_archive}" -C "${adb_tmpdir}" 2>/dev/null
    rc=$?
    if [ $((rc)) -eq 0 ]
    then
        /usr/bin/logger -t "adblock[${pid}]" "info: shallalist archive extraction finished"
    else
        /usr/bin/logger -t "adblock[${pid}]" "error: shallalist archive extraction failed"
        printf "%s\n" "$(/bin/date "+%d.%m.%Y %H:%M:%S") - error: shallalist archive extraction failed" >> "${adb_logfile}"
        restore_msg="archive extraction failed"
        f_restore
    fi

    # merge selected shallalist categories
    #
    > "${shalla_file}"
    for category in ${adb_cat_shalla}
    do
        if [ -f "${adb_tmpdir}/BL/${category}/domains" ]
        then
            cat "${adb_tmpdir}/BL/${category}/domains" >> "${shalla_file}" 2>/dev/null
            rc=$?
        else
            rc=220
        fi
        if [ $((rc)) -ne 0 ]
        then
            break
        fi
    done

    # finish shallalist (pre-)processing
    #
    if [ $((rc)) -eq 0 ]
    then
        adb_sources="${adb_sources} file:///${shalla_file}&ruleset=rset_shalla"
        /usr/bin/logger -t "adblock[${pid}]" "info: shallalist (pre-)processing finished (${adb_cat_shalla})"
    else
        /usr/bin/logger -t "adblock[${pid}]" "error: shallalist (pre-)processing failed (${rc}, ${adb_cat_shalla})"
        printf "%s\n" "$(/bin/date "+%d.%m.%Y %H:%M:%S") - error: shallalist (pre-)processing failed (${rc}, ${adb_cat_shalla})" >> "${adb_logfile}"
        restore_msg="shallalist merge failed"
        f_restore
    fi
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
        tmp_var="$(wget --timeout="${max_time}" --tries=1 --output-document=- "${url}" 2>/dev/null)"
        rc=$?
    else
        tmp_var="$(curl --insecure --max-time "${max_time}" "${url}" 2>/dev/null)"
        rc=$?
    fi

    # check download result and prepare domain output by regex patterns
    #
    if [ $((rc)) -eq 0 ] && [ -n "${tmp_var}" ]
    then
        eval "$(printf "${src}" | sed 's/\(.*\&ruleset=\)/ruleset=\$/g')"
        tmp_var="$(printf "%s\n" "${tmp_var}" | tr '[A-Z]' '[a-z]')"
        adb_count="$(printf "%s\n" "${tmp_var}" | eval "${ruleset}" | tee -a "${adb_tmpfile}" | wc -l)"
        /usr/bin/logger -t "adblock[${pid}]" "info: source download finished (${url}, ${adb_count} entries)"
    elif [ $((rc)) -eq 0 ] && [ -z "${tmp_var}" ]
    then
        /usr/bin/logger -t "adblock[${pid}]" "info: empty source download finished (${url})"
    else
        /usr/bin/logger -t "adblock[${pid}]" "error: source download failed (${url})"
        printf "%s\n" "$(/bin/date "+%d.%m.%Y %H:%M:%S") - error: source download failed (${url})" >> "${adb_logfile}"
        restore_msg="download failed"
        f_restore
    fi
done

# create empty destination file
#
> "${adb_dnsfile}"

# rewrite ad/abuse domain information to dns file,
# remove duplicates and whitelist entries
#
grep -vxf "${adb_whitelist}" < "${adb_tmpfile}" | eval "${adb_dnsformat}" | sort -u 2>/dev/null >> "${adb_dnsfile}"

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
exit 0

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
script_ver="0.11.0"

# get current pid and script directory
#
pid=$$
script_dir="$(printf "${0}" | sed 's/\(.*\)\/.*/\1/')"

# set temp variables
#
tmp_file="$(mktemp -tu)"
tmp_dir="$(mktemp -d)"

# source in adblock configuration
#
if [ -r "/etc/adblock/adblock.conf" ]
then
    . "/etc/adblock/adblock.conf"
else
    /usr/bin/logger -t "adblock[${pid}]" "adblock configuration not found"
    rm -rf "${tmp_dir}" 2>/dev/null
    exit 200
fi

# source in adblock function library
#
if [ -r "${script_dir}/adblock-helper.sh" ]
then
    . "${script_dir}/adblock-helper.sh"
else
    /usr/bin/logger -t "adblock[${pid}]" "adblock function library not found"
    rm -rf "${tmp_dir}" 2>/dev/null
    exit 210
fi

################
# main program #
################

# call restore function on trap signals (HUP, INT, QUIT, BUS, SEGV, TERM)
#
trap "restore_msg='trap error'; f_restore" 1 2 3 10 11 15

# start logging
#
/usr/bin/logger -t "adblock[${pid}]" "domain adblock processing started (${script_ver})"

# check environment
#
f_envcheck

# check wan update interface(s)
#
f_wancheck

# check for ntp time sync
#
f_ntpcheck

# download shallalist archive
#
if [ "${shalla_ok}" = "true" ]
then
    curl --insecure --max-time "${max_time}" "${shalla_url}" -o "${shalla_archive}" 2>/dev/null
    rc=$?
    if [ $((rc)) -eq 0 ]
    then
        /usr/bin/logger -t "adblock[${pid}]" "shallalist archive download finished"
    else
        /usr/bin/logger -t "adblock[${pid}]" "shallalist archive download failed (${shalla_url})"
        printf "$(/bin/date "+%d.%m.%Y %H:%M:%S") - error: shallalist archive download failed (${shalla_url})" >> "${log_file}"
        restore_msg="archive download failed"
        f_restore
    fi

    # extract shallalist archive
    #
    tar -xzf "${shalla_archive}" -C "${tmp_dir}" 2>/dev/null
    rc=$?
    if [ $((rc)) -eq 0 ]
    then
        /usr/bin/logger -t "adblock[${pid}]" "shallalist archive extraction finished"
    else
        /usr/bin/logger -t "adblock[${pid}]" "shallalist archive extraction failed"
        printf "$(/bin/date "+%d.%m.%Y %H:%M:%S") - error: shallalist archive extraction failed" >> "${log_file}"
        restore_msg="archive extraction failed"
        f_restore
    fi

    # merge selected shallalist categories
    #
    > "${shalla_file}"
    for category in ${shalla_cat}
    do
        if [ -f "${tmp_dir}/BL/${category}/domains" ]
        then
            cat "${tmp_dir}/BL/${category}/domains" >> "${shalla_file}" 2>/dev/null
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
        /usr/bin/logger -t "adblock[${pid}]" "shallalist (pre-)processing finished (${shalla_cat})"
    else
        /usr/bin/logger -t "adblock[${pid}]" "shallalist category merge failed (${rc}, ${shalla_cat})"
        printf "$(/bin/date "+%d.%m.%Y %H:%M:%S") - error: shallalist category merge failed (${rc}, ${shalla_cat})" >> "${log_file}"
        restore_msg="shallalist merge failed"
        f_restore
    fi
fi

# loop through domain source list,
# prepare output and store all extracted domains in temp file
#
for src in ${adb_source}
do
    # download selected adblock sources
    #
    url="$(printf "${src}" | sed 's/\(\&ruleset=.*\)//g')"
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
        eval "$(printf "${src}" | sed 's/\(.*\&ruleset=\)/ruleset=\$rset_/g')"
        tmp_var="$(printf "%s\n" "${tmp_var}" |  tr '[[:upper:]]' '[[:lower:]]')"
        adb_count="$(printf "%s\n" "${tmp_var}" | eval "${ruleset}" | tee -a "${tmp_file}" | wc -l)"
        /usr/bin/logger -t "adblock[${pid}]" "source download finished (${url}, ${adb_count} entries)"
    elif [ $((rc)) -eq 0 ] && [ -z "${tmp_var}" ]
    then
        /usr/bin/logger -t "adblock[${pid}]" "empty source download finished (${url})"
    else
        /usr/bin/logger -t "adblock[${pid}]" "source download failed (${url})"
        printf "$(/bin/date "+%d.%m.%Y %H:%M:%S") - error: source download failed (${url})" >> "${log_file}"
        restore_msg="download failed"
        f_restore
    fi
done

# create empty destination file
#
> "${dns_file}"

# rewrite ad/abuse domain information to dns file,
# remove duplicates and whitelist entries
#
grep -vxf "${adb_whitelist}" < "${tmp_file}" | eval "${dns_format}" | sort -u 2>/dev/null >> "${dns_file}"

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

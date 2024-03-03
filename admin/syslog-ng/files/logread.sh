#!/bin/sh
# Shell script compatibility wrapper for /sbin/logread
#
# Copyright (C) 2019 Dirk Brenken <dev@brenken.org>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
#

logfile="/var/log/messages"

usage()
{
	echo "Usage: logread [options]"
	echo "Options:"
	echo " -l <count>   Got only the last 'count' messages"
	echo " -e <pattern> Filter messages with a regexp"
	echo " -f           Follow log messages"
	echo " -h           Print this help message"
	exit 1
}

count=
pattern=
follow=
while getopts "l:e:fh" OPT
do
	case "$OPT" in
		l) count=$OPTARG;;
		e) pattern=$OPTARG;;
		f) follow="-F";;
		h) usage;;
		?) echo "Unsupported option. See $0 -h"
	esac
done

# if no count and follow then print from beginning
[ -z "$count$follow" ] && count="+1"
# if no count but follow then print only new lines
[ -z "$count" ] && count="0"

# shellcheck disable=SC2086
if [ -z "$pattern" ]; then
	tail -n "$count" $follow "$logfile"
else
	tail -n "$count" $follow "$logfile" | grep -E "$pattern"
fi

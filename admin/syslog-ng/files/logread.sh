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
follow_arg=
while getopts "l:e:fh" OPT
do
	case "$OPT" in
		l) count=$OPTARG;;
		e) pattern=$OPTARG;;
		f) follow_arg="-F";;
		h) usage;;
		?) echo "Unsupported option. See $0 -h"
	esac
done

if [ -z "$count" ]; then
	# if follow then print only new lines, otherwise from beginning
	if [ -n "$follow_arg" ]; then
		count="0"
	else
		count="+1"
	fi
fi

# shellcheck disable=SC2086
if [ -z "$pattern" ]; then
	echo tail -n "$count" $follow_arg "$logfile"
else
	echo tail -n "$count" $follow_arg "$logfile" | grep -E "$pattern"
fi

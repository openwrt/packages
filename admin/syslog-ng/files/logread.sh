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

if [ -z "${1}" ]
then
	cat "${logfile}"
	exit 0
else
	while [ "${1}" ]
	do
		case "${1}" in
			-l)
				shift
				count="${1//[^0-9]/}"
				tail -n "${count:-50}" "${logfile}"
				exit 0
				;;
			-e)
				shift
				pattern="${1}"
				grep -E "${pattern}" "${logfile}"
				exit 0
				;;
			-f)
				tail -f "${logfile}"
				exit 0
				;;
			-fe)
				shift
				pattern="${1}"
				tail -f "${logfile}" | grep -E "${pattern}"
				exit 0
				;;
			-h|*)
				usage
				;;
		esac
		shift
	done
fi

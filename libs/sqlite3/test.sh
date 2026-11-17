#!/bin/sh
#
# SPDX-License-Identifier: GPL-2.0-only

case "$PKG_NAME" in
	libsqlite3)
		apk add binutils

		readelf_out=$(readelf --dynamic "/usr/lib/libsqlite3.so.$PKG_VERSION")
		if [ $? -ne 0 ]; then
			echo "readelf failed for /usr/lib/libsqlite3.so.$PKG_VERSION" >&2
			exit 1
		fi

		soname=$(echo "$readelf_out" \
			| grep -F '(SONAME)' \
			| sed -E 's/.*\[(.*)\]/\1/')

		if [ -z "$soname" ]; then
			echo "soname not found in /usr/lib/libsqlite3.so.$PKG_VERSION" >&2
			exit 1
		fi

		link_target=$(readlink "/usr/lib/$soname")
		if [ $? -ne 0 ]; then
			echo "Failed to read soname link /usr/lib/$soname" >&2
			exit 1
		fi

		expected_target="libsqlite3.so.$PKG_VERSION"
		if [ "$link_target" != "$expected_target" ]; then
			echo "soname link /usr/lib/$soname points to '$link_target', expected '$expected_target'" >&2
			exit 1
		fi

		if [ -f '/usr/lib/libsqlite3.so' ]; then
			echo "/usr/lib/libsqlite3.so shouldn't be installed" >&2
			exit 1
		fi
		;;

	sqlite3-cli)
		sqlite3 -version | grep -F "$PKG_VERSION"
		;;
esac

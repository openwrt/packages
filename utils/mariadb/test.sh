#!/bin/sh

# shellcheck disable=SC1090

check_version() {
	bin="$1"
	ver="$2"
	com="$3"

	if [ -x "$bin" ]; then
		if "$bin" --version | grep " $ver-MariaDB"; then
			echo "MariaDB $com is in version $2"
		else
			echo "MariaDB $com seems to be in wrong version"
			exit 1
		fi
	else
		echo "Can't find $com server binary"
		exit 1
	fi
}

case "$PKG_NAME" in
	mariadb-server) check_version /usr/bin/mysqld "$PKG_VERSION" "server" ;;
	mariadb-client) check_version /usr/bin/mysql "$PKG_VERSION" "client";;
	*) info "Skipping $PKG_NAME" ;;
esac

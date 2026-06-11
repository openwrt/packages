#!/bin/sh

PSQL="/usr/bin/psql"

free_megs() {
	fsdir=$1
	while [ ! -d "$fsdir" ]; do
		fsdir="$(dirname "$fsdir")"
	done
	df -m $fsdir | while read fs bl us av cap mnt; do [ "$av" = "Available" ] || echo $av; done
}

pg_init_data() {
	# make sure we got at least 50MB of free space
	[ $(free_megs "$1") -lt 50 ] && return 1
	pg_ctl initdb -U postgres -D "$1"
}

pg_server_ready() {
	t=0
	while [ $t -le 90 ]; do
		psql -h /var/run/postgresql/ -U postgres -c "\q" 1>/dev/null 2>/dev/null && return 0
		t=$((t+1))
		sleep 1
	done
	return 1
}


pg_test_db() {
	echo "SELECT datname FROM pg_catalog.pg_database WHERE datname = '$1';" |
		$PSQL -h /var/run/postgresql -w -U "postgres" -d "template1" -q |
			grep -q "0 rows" && return 1

	return 0
}

pg_include_sql() {
	if [ "$3" ]; then
		env PGPASSWORD="$3" $PSQL -h /var/run/postgresql -U "$2" -d "$1" -e -f "$4"
		return $?
	else
		$PSQL -w -h /var/run/postgresql -U "$2" -d "$1" -e -f "$4"
		return $?
	fi
}

# $1: dbname, $2: username, $3: password, $4: sql populate script
pg_require_db() {
	local ret
	local dbname="$1"
	local dbuser="$2"
	local dbpass="$3"
	local exuser

	pg_test_db $@ && return 0

	shift ; shift ; shift

	echo "CREATE DATABASE $dbname;" |
		$PSQL -h /var/run/postgresql -U postgres -d template1 -e || return $?

	if [ "$dbuser" ]; then
		echo "SELECT usename FROM pg_catalog.pg_user WHERE usename = '$dbuser';" |
			$PSQL -h /var/run/postgresql -U postgres -d template1 -e | grep -q "0 rows" &&
			( echo -n "CREATE USER $dbuser"
			[ "$dbpass" ] && echo -n " WITH PASSWORD '$dbpass'"
			echo " NOCREATEDB NOSUPERUSER NOCREATEROLE NOINHERIT;" ) |
				$PSQL -h /var/run/postgresql -U postgres -d template1 -e

		echo "GRANT ALL PRIVILEGES ON DATABASE \"$dbname\" TO $dbuser;" |
			$PSQL -h /var/run/postgresql -U postgres -d template1 -e
	fi

	while [ "$1" ]; do
		pg_include_sql "$dbname" "$dbuser" "$dbpass" "$1"
		ret=$?
		[ $ret != 0 ] && break
		shift
	done

	return $ret
}

uci_require_db() {
	local dbname dbuser dbpass dbscript
	config_get dbname $1 name
	config_get dbuser $1 user
	config_get dbpass $1 pass
	config_get dbscript $1 script
	pg_require_db "$dbname" "$dbuser" "$dbpass" $dbscript
}

[ "$1" = "init" ] && {
	. /lib/functions.sh
	pg_server_ready $2 || exit 1
	config_load postgresql
	config_foreach uci_require_db postgres-db
}

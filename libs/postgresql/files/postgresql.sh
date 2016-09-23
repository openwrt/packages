#!/bin/sh

PSQL="/usr/bin/psql"

free_megs() {
	fsdir=$1
	while [ ! -d "$fsdir" ]; do
		fsdir=$(dirname $fsdir)
	done
	df -m $fsdir | while read fs bl us av cap mnt; do [ "$av" = "Available" ] || echo $av; done
}

pg_init_data() {
	# make sure we got at least 50MB of free space
	[ $(free_megs $1) -lt 50 ] && return 1
	pg_ctl initdb -U postgres -D $1
}

pg_server_ready() {
	t=0
	while [ $t -le 90 ]; do
		pg_ctl status -U postgres -D $1 2>/dev/null >/dev/null && return 0
		t=$((t+1))
		sleep 1
	done
	return 1
}

# $1: dbname, $2: username, $3: password
pg_require_db() {
	pg_test_db $@ && return 0
	( echo "CREATE DATABASE $1;"
	echo -n "CREATE USER $2"
	[ "$3" ] && echo -n " WITH PASSWORD '$3'"
	echo ";"
	echo "GRANT ALL PRIVILEGES ON DATABASE \"$1\" to $2;" ) |
		$PSQL -U postgres -d template1 -e
	return $?
}

pg_test_db() {
	PGPASSWORD=$3
	echo "SHOW ALL;" | $PSQL -U $2 -d $1 -q 2>/dev/null >/dev/null
	return $?
}

uci_require_db() {
	local dbname dbuser dbpass
	config_get dbname $1 name
	config_get dbuser $1 user
	config_get dbpass $1 pass
	pg_require_db $dbname $dbuser $dbpass
}

[ "$1" = "init" ] && {
	. /lib/functions.sh
	pg_server_ready $2 || exit 1
	config_load postgresql
	config_foreach uci_require_db postgres-db
}

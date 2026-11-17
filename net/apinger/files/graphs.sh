#!/bin/sh

. /lib/functions.sh
. /usr/share/libubox/jshn.sh

APINGER="/usr/sbin/apinger"
RRDCGI="/www/cgi-bin/apinger"
GRAPH_DIR="/apinger/graphs"
WWW_LOCATION="/www${GRAPH_DIR}"

update_interface_graphs() {
	local iface cfg cmd

	iface=$1
	cfg=/var/run/apinger-$iface.conf

	[ ! -f $cfg ] && return

	cmd="$APINGER -c $cfg -g $WWW_LOCATION -l $GRAPH_DIR"

	if [ -x $RRDCGI ]; then
		$cmd 2>/dev/null | sed -e '/\(HTML\|TITLE\|H1\|H2\|by\|^#\)/d' >> $RRDCGI
	else
		$cmd 2>/dev/null | sed -e '/\(HTML\|TITLE\|H1\|H2\|by\)/d' > $RRDCGI
		chmod 755 $RRDCGI
	fi
}

update_graphs() {
	[ ! -d $WWW_LOCATION ] && mkdir -p $WWW_LOCATION
	[ -e $RRDCGI ] && rm -f $RRDCGI

	config_load apinger
	config_foreach update_interface_graphs interface

	json_init
	json_add_string rrdcgi "$RRDCGI"
	json_dump
}

graphs_help() {
	json_add_object update_graphs
	json_close_object
}

#!/bin/sh

FW4="$(command -v fw4)"
[ -n "$FW4" ] && exit 0

IPT_LEGACY="$(command -v iptables-legacy)"
IPT="$(command -v iptables)"
BIN="${IPT_LEGACY:-$IPT}"
[ -z "$BIN" ] && exit 0

LIBRESWAN_INPUT="libreswan_input"
LIBRESWAN_FORWARD="libreswan_forward"
LIBRESWAN_OUTPUT="libreswan_output"
LIBRESWAN_NFLOG_INPUT="libreswan_nflog_input"
LIBRESWAN_NFLOG_OUTPUT="libreswan_nflog_output"
LIBRESWAN_POSTROUTING="libreswan_postrouting"

FW_DIR="/tmp/libreswan/firewall.d"
LIBRESWAN_RULES_FILE="$FW_DIR/libreswan.rules"

flush_delete_chain() {
	[ $# -lt 2 ] && return

	$BIN -t $1 -nL $2 > /dev/null 2>&1 || return

	$BIN -t $1 -F $2
	$BIN -t $1 -X $2
}

cleanup_libreswan_rules() {
	$BIN -t filter -C input_rule -j $LIBRESWAN_INPUT > /dev/null 2>&1
	[ $? -eq 0 ] && $BIN -t filter -D input_rule -j $LIBRESWAN_INPUT

	$BIN -t filter -C output_rule -j $LIBRESWAN_OUTPUT > /dev/null 2>&1
	[ $? -eq 0 ] && $BIN -t filter -D output_rule -j $LIBRESWAN_OUTPUT

	$BIN -t filter -C forwarding_rule -j $LIBRESWAN_FORWARD > /dev/null 2>&1
	[ $? -eq 0 ] && $BIN -t filter -D forwarding_rule -j $LIBRESWAN_FORWARD

	$BIN -t nat -C postrouting_rule -j $LIBRESWAN_POSTROUTING > /dev/null 2>&1
	[ $? -eq 0 ] && $BIN -t nat -D postrouting_rule -j $LIBRESWAN_POSTROUTING

	flush_delete_chain filter $LIBRESWAN_NFLOG_INPUT
	flush_delete_chain filter $LIBRESWAN_INPUT
	flush_delete_chain filter $LIBRESWAN_FORWARD
	flush_delete_chain filter $LIBRESWAN_NFLOG_OUTPUT
	flush_delete_chain filter $LIBRESWAN_OUTPUT
	flush_delete_chain filter $LIBRESWAN_NFLOG_INPUT
	flush_delete_chain filter $LIBRESWAN_NFLOG_OUTPUT
	flush_delete_chain nat $LIBRESWAN_POSTROUTING
}

create_chain_jump() {
	[ $# -lt 3 ] && return

	local table=$1
	local chain=$2
	local base_chain=$3

	$BIN -t $table -N $chain
	$BIN -t $table -C $base_chain -j $chain
	[ $? -ne 0 ] && $BIN -t $table -I $base_chain -j $chain
	$BIN -t $table -F $chain
}

if ! /etc/init.d/ipsec running; then
	cleanup_libreswan_rules
	exit 0
fi

eval $(ipsec addconn --configsetup)

create_chain_jump filter "$LIBRESWAN_INPUT" "insert_rule"
create_chain_jump filter "$LIBRESWAN_FORWARD" "forwarding_rule"
create_chain_jump filter "$LIBRESWAN_OUTPUT" "output_rule"

create_chain_jump filter "$LIBRESWAN_NFLOG_INPUT" "$LIBRESWAN_INPUT"
create_chain_jump filter "$LIBRESWAN_NFLOG_OUTPUT" "$LIBRESWAN_OUTPUT"

create_chain_jump nat "$LIBRESWAN_POSTROUTING" "postrouting_rule"

[ ! -f $LIBRESWAN_RULES_FILE ] && exit 0

if [ -n "$nflog_all" ]; then
	sed -i -e '/NFLOG/d' "$LIBRESWAN_RULES_FILE"
	$BIN -t filter -I $LIBRESWAN_NFLOG_INPUT -m policy --dir in --pol ipsec -j NFLOG --nflog-group ${nflog_all} --nflog-prefix all-ipsec
	$BIN -t filter -I $LIBRESWAN_NFLOG_OUTPUT -m policy --dir out --pol ipsec -j NFLOG --nflog-group ${nflog_all} --nflog-prefix all-ipsec
fi

sh $LIBRESWAN_RULES_FILE

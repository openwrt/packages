#!/bin/sh
# Wrapper for acme.sh to work on openwrt.
#
# This program is free software; you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Author: Toke Høiland-Jørgensen <toke@toke.dk>

CHECK_CRON=$1
ACME=/usr/lib/acme/acme.sh
export SSL_CERT_DIR=/etc/ssl/certs

UHTTPD_LISTEN_HTTP=
STATE_DIR='/etc/acme'
ACCOUNT_EMAIL=
DEBUG=0

. /lib/functions.sh

check_cron()
{
    [ -f "/etc/crontabs/root" ] && grep -q '/etc/init.d/acme' /etc/crontabs/root && return
    echo "0 0 * * * /etc/init.d/acme start" >> /etc/crontabs/root
    /etc/init.d/cron start
}

pre_checks()
{
    echo "Running pre checks."
    check_cron

    if [ -e /etc/init.d/uhttpd ]; then

       UHTTPD_LISTEN_HTTP=$(uci get uhttpd.main.listen_http)

       uci set uhttpd.main.listen_http=''
       uci commit uhttpd
       /etc/init.d/uhttpd reload || return 1
    fi

    iptables -I input_rule -p tcp --dport 80 -j ACCEPT || return 1
    ip6tables -I input_rule -p tcp --dport 80 -j ACCEPT || return 1
    return 0
}

post_checks()
{
    echo "Running post checks (cleanup)."
    iptables -D input_rule -p tcp --dport 80 -j ACCEPT
    ip6tables -D input_rule -p tcp --dport 80 -j ACCEPT

    if [ -e /etc/init.d/uhttpd ]; then
        uci set uhttpd.main.listen_http="$UHTTPD_LISTEN_HTTP"
        uci commit uhttpd
        /etc/init.d/uhttpd reload
    fi
}

err_out()
{
    post_checks
    exit 1
}

int_out()
{
    post_checks
    trap - INT
    kill -INT $$
}

issue_cert()
{
    local section="$1"
    local acme_args=
    local enabled
    local use_staging
    local update_uhttpd
    local keylength
    local domains
    local main_domain

    config_get_bool enabled "$section" enabled 0
    config_get_bool use_staging "$section" use_staging
    config_get_bool update_uhttpd "$section" update_uhttpd
    config_get domains "$section" domains
    config_get keylength "$section" keylength

    [ "$enabled" -eq "1" ] || return

    [ "$DEBUG" -eq "1" ] && acme_args="$acme_args --debug"

    set -- $domains
    main_domain=$1

    if [ -e "$STATE_DIR/$main_domain" ]; then
        $ACME --home "$STATE_DIR" --renew -d "$main_domain" $acme_args || return 1
        return 0
    fi


    acme_args="$acme_args $(for d in $domains; do echo -n "-d $d "; done)"
    acme_args="$acme_args --standalone"
    acme_args="$acme_args --keylength $keylength"
    [ -n "$ACCOUNT_EMAIL" ] && acme_args="$acme_args --accountemail $ACCOUNT_EMAIL"
    [ "$use_staging" -eq "1" ] && acme_args="$acme_args --staging"

    if ! $ACME --home "$STATE_DIR" --issue $acme_args; then
        echo "Issuing cert for $main_domain failed. It may be necessary to remove $STATE_DIR/$main_domain to recover." >&2
        return 1
    fi

    if [ "$update_uhttpd" -eq "1" ]; then
        uci set uhttpd.main.key="$STATE_DIR/${main_domain}/${main_domain}.key"
        uci set uhttpd.main.cert="$STATE_DIR/${main_domain}/fullchain.cer"
        # commit and reload is in post_checks
    fi

}

load_vars()
{
    local section="$1"

    STATE_DIR=$(config_get "$section" state_dir)
    ACCOUNT_EMAIL=$(config_get "$section" account_email)
    DEBUG=$(config_get "$section" debug)
}

if [ -n "$CHECK_CRON" ]; then
    check_cron
    exit 0
fi

config_load acme
config_foreach load_vars acme

pre_checks || exit 1
trap err_out HUP TERM
trap int_out INT

config_foreach issue_cert cert
post_checks

exit 0

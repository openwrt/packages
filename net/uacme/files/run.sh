#!/bin/sh
# Wrapper for uacme to work on openwrt.
#
# This program is free software; you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Initial Author: Toke Høiland-Jørgensen <toke@toke.dk>
# Adapted for uacme: Lucian Cristian <lucian.cristian@gmail.com>
# Adapted for custom CA and TLS-ALPN-01: Peter Putzer <openwrt@mundschenk.at>
# Readapted uacme implementation: Sebastian Bogaci <sebastian.bogaci@gmail.com>
#   - removed acme.sh code base as this wrapper should support only uacme package
#   - fixed get_listeners()
#   - added option to support tls-alpn-01 ACME challenge
#   - added option to set which interface to open for ACME challenge (normal is 'wan')
#   - tested only with uhttpd

CHECK_CRON=$1

#check for installed package, support only uacme
if [ -e "/usr/sbin/uacme" ]; then
    ACME=/usr/sbin/uacme
    HPROGRAM=/usr/share/uacme/uacme.sh
    APP=uacme
else
    echo "Please install uACME package"
    return 1
fi

#export CURL_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt
export NO_TIMESTAMP=1

UHTTPD_LISTEN_HTTP=
UHTTPD_REDIRECT_HTTPS=
PRODUCTION_STATE_DIR='/etc/acme'
STAGING_STATE_DIR='/etc/acme/staging'

ACCOUNT_EMAIL=
DEBUG=0
NGINX_WEBSERVER=0
UPDATE_NGINX=0
UPDATE_UHTTPD=0
UPDATE_HAPROXY=0
FW_RULE=
USER_CLEANUP=
ACME_URL=
ACME_STAGING_URL=
ACME_INTERFACE=

. /lib/functions.sh

check_cron()
{
    [ -f "/etc/crontabs/root" ] && grep -q '/etc/init.d/acme' /etc/crontabs/root && return
    echo "0 0 * * * /etc/init.d/acme start" >> /etc/crontabs/root
    /etc/init.d/cron start
}

log()
{
    logger -t $APP -s -p daemon.info "$@"
}

err()
{
    logger -t $APP -s -p daemon.err "$@"
}

debug()
{
    [ "$DEBUG" -eq "1" ] && logger -t $APP -s -p daemon.debug "$@"
}

get_listeners()
{
    local proto rq sq listen remote state program
    netstat -nptl 2>/dev/null | while read proto rq sq listen remote state program; do
        case "$proto#$listen#$program" in
            tcp#*:80#[0-9]*/*) echo -n "${program%% *} " ;
            break;
        esac
    done
}

pre_checks()
{
    main_domain="$1"

    log "Running pre checks for $main_domain."

    listeners="$(get_listeners)"

    debug "port80 listens: $listeners"

    for listener in $listeners; do
    pid="${listener%/*}"
    cmd="${listener#*/}"

    case "$cmd" in
        uhttpd)
            debug "Found uhttpd listening on port 80"
            UHTTPD_REDIRECT_HTTPS=$(uci get uhttpd.main.redirect_https)
            if [ ! -z "$UHTTPD_REDIRECT_HTTPS" ]; then
                if [ "$UHTTPD_REDIRECT_HTTPS" -eq "1" ]; then
                    uci set uhttpd.main.redirect_https='0'
                    uci commit uhttpd
                    /etc/init.d/uhttpd reload
                    debug "disabled uhttpd redirect https config"
                else
                    debug "uhttpd redirect https is disabled, skipping re-config"
                fi
            fi
            ;;
        nginx*)
            debug "Found nginx listening on port 80"
            NGINX_WEBSERVER=1
            local tries=0
            while grep -sq "$cmd" "/proc/$pid/cmdline" && kill -0 "$pid"; do
            /etc/init.d/nginx stop
            if [ $tries -gt 10 ]; then
                debug "Can't stop nginx. Terminating script."
                return 1
            fi
            debug "Waiting for nginx to stop..."
            tries=$((tries + 1))
            sleep 1
            done
            ;;
        "")
            err "Nothing listening on port 80."
            err "Standalone mode not supported, setup uhttpd or nginx"
            return 1
            ;;
        *)
            err "$main_domain: unsupported (apache/haproxy?) daemon is listening on port 80."
            err "if webroot is set on your current webserver comment line 132 (return 1) from this script."
            return 1
            ;;
    esac
    done

    FW_RULE=$(uci add firewall rule) || return 1
    uci set firewall."$FW_RULE".enabled='1'
    uci set firewall."$FW_RULE".target='ACCEPT'
    debug "the ACME interface is: $ACME_INTERFACE"
    uci set firewall."$FW_RULE".src="$ACME_INTERFACE"
    uci set firewall."$FW_RULE".proto='tcp'
    if [ "$tls" -eq "1" ]; then
        uci set firewall."$FW_RULE".name='uacme: temporarily allow incoming https'
        uci set firewall."$FW_RULE".dest_port='443'
    else
        uci set firewall."$FW_RULE".name='uacme: temporarily allow incoming http'
        uci set firewall."$FW_RULE".dest_port='80'
    fi
    uci commit firewall
    /etc/init.d/firewall reload

    debug "added firewall rule: $FW_RULE"
    return 0
}

post_checks()
{
    log "Running post checks (cleanup)."
    # $FW_RULE contains the string to identify firewall rule created earlier
    if [ -n "$FW_RULE" ]; then
        uci delete firewall."$FW_RULE"
        uci commit firewall
        /etc/init.d/firewall reload
    fi

    if [ -e /etc/init.d/uhttpd ] && [ "$UPDATE_UHTTPD" -eq 1 ]; then
        if [ "$UHTTPD_REDIRECT_HTTPS" -eq "1" ]; then
            uci set uhttpd.main.redirect_https="$UHTTPD_REDIRECT_HTTPS"
            debug "re-enabled uhttpd redirect https config"
        fi
        uci commit uhttpd
        /etc/init.d/uhttpd restart
        log "Restarting uhttpd..."
    fi

    if [ -e /etc/init.d/nginx ] && ( [ "$NGINX_WEBSERVER" -eq 1 ] || [ "$UPDATE_NGINX" -eq 1 ]; ); then
        NGINX_WEBSERVER=0
        /etc/init.d/nginx restart
        log "Restarting nginx..."
    fi

    if [ -e /etc/init.d/haproxy ] && [ "$UPDATE_HAPROXY" -eq 1 ]; then
        /etc/init.d/haproxy restart
        log "Restarting haproxy..."
    fi

    if [ -n "$USER_CLEANUP" ] && [ -f "$USER_CLEANUP" ]; then
        log "Running user-provided cleanup script from $USER_CLEANUP."
        "$USER_CLEANUP" || return 1
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

is_staging()
{
    local main_domain="$1"

    grep -q "acme-staging" "$STATE_DIR/$main_domain/${main_domain}.conf"
    return $?
}

issue_cert()
{
    local section="$1"
    local acme_args=
    local debug=
    local enabled
    local use_staging
    local update_uhttpd
    local update_nginx
    local update_haproxy
    local keylength
    local domains
    local main_domain
    local failed_dir
    local webroot
    local dns
    local tls
    local user_setup
    local user_cleanup
    local ret
    local staging=
    local HOOK=

    # reload uci values, as the value of use_staging may have changed
    config_load acme
    config_get_bool enabled "$section" enabled 0
    config_get_bool use_staging "$section" use_staging
    config_get_bool update_uhttpd "$section" update_uhttpd
    config_get_bool update_nginx "$section" update_nginx
    config_get_bool update_haproxy "$section" update_haproxy
    config_get domains "$section" domains
    config_get keylength "$section" keylength
    config_get webroot "$section" webroot
    config_get dns "$section" dns
    config_get tls "$section" tls
    config_get user_setup "$section" user_setup
    config_get user_cleanup "$section" user_cleanup

    UPDATE_NGINX=$update_nginx
    UPDATE_UHTTPD=$update_uhttpd
    UPDATE_HAPROXY=$update_haproxy
    USER_CLEANUP=$user_cleanup

    [ "$enabled" -eq "1" ] || return 0

    [ "$DEBUG" -eq "1" ] && debug="--verbose --verbose" && echo "debug: $debug"
    [ "$tls" -eq "1" ] && HPROGRAM="/usr/share/uacme/ualpn.sh" && echo "HPROGRAM: $HPROGRAM"

    if [ "$use_staging" -eq "1" ]; then
        STATE_DIR="$STAGING_STATE_DIR";
        staging="--staging";
        # Check if we should use a custom stagin URL
        if [ -n "$ACME_STAGING_URL" ]; then
            ACME="$ACME --acme-url $ACME_STAGING_URL"
        fi
    else
        STATE_DIR="$PRODUCTION_STATE_DIR";
        staging="";
        if [ -n "$ACME_URL" ]; then
            ACME="$ACME --acme-url $ACME_URL"
        fi
    fi

    set -- $domains
    main_domain=$1

    if [ -n "$user_setup" ] && [ -f "$user_setup" ]; then
    log "Running user-provided setup script from $user_setup."
    "$user_setup" "$main_domain" || return 2
    else
    pre_checks "$main_domain" || [ -n "$webroot" ] || [ -n "$dns" ] || [ -n "$tls" ] || return 2
    fi

    log "Running $APP for $main_domain"

    if [ "$APP" = "uacme" ]; then
    if [ ! -f  "$STATE_DIR/private/key.pem" ]; then
        log "Create a new ACME account with email $ACCOUNT_EMAIL use staging=$use_staging"
        $ACME $debug --confdir "$STATE_DIR" $staging --yes new $ACCOUNT_EMAIL
    fi

    if [ -f "$STATE_DIR/$main_domain/cert.pem" ]; then
        log "Found previous cert config, use staging=$use_staging. Issuing renew."
        export CHALLENGE_PATH="$webroot"
        $ACME $debug --confdir "$STATE_DIR" $staging --never-create --hook="$HPROGRAM" issue $domains; ret=$?
        log "purging old expired certificates"
        rm -v $STATE_DIR/$main_domain/cert-*
        post_checks
        return $ret
    fi
    fi

    acme_args="$acme_args --bits $keylength"
    acme_args="$acme_args $(for d in $domains; do echo -n " $d "; done)"
    if [ "$APP" = "acme" ]; then
    [ -n "$ACCOUNT_EMAIL" ] && acme_args="$acme_args --accountemail $ACCOUNT_EMAIL"
    [ "$use_staging" -eq "1" ] && acme_args="$acme_args --staging"
    fi
    if [ -n "$dns" ]; then
#TO-DO
        log "Using dns mode, dns-01 is not wrapped yet"
        return 2
#        uacme_args="$uacme_args --dns $dns"
    elif [ -n "$tls" ]; then
        log "Using TLS mode"
    elif [ -z "$webroot" ]; then
        log "Standalone not supported by $APP"
        return 2
    else
        if [ ! -d "$webroot" ]; then
            err "$main_domain: Webroot dir '$webroot' does not exist!"
            post_checks
            return 2
        fi
        log "Using webroot dir: $webroot"
        export CHALLENGE_PATH="$webroot"
    fi

    workdir="--confdir"
    HOOK="--hook=$HPROGRAM"

    $ACME $debug $workdir "$STATE_DIR" $staging issue $acme_args $HOOK; ret=$?
    if [ "$ret" -ne 0 ]; then
    failed_dir="$STATE_DIR/${main_domain}.failed-$(date +%s)"
    err "Issuing cert for $main_domain failed. Moving state to $failed_dir"
    [ -d "$STATE_DIR/$main_domain" ] && mv "$STATE_DIR/$main_domain" "$failed_dir"
    [ -d "$STATE_DIR/private/$main_domain" ] && mv "$STATE_DIR/private/$main_domain" "$failed_dir"
    post_checks
    return $ret
    fi

    if [ -e /etc/init.d/uhttpd ] && [ "$update_uhttpd" -eq "1" ]; then
        uci set uhttpd.main.key="$STATE_DIR/private/${main_domain}/key.pem"
        uci set uhttpd.main.cert="$STATE_DIR/${main_domain}/cert.pem"
        # commit and reload is in post_checks
    fi

    local nginx_updated
    nginx_updated=0
    if command -v nginx-util 2>/dev/null && [ "$update_nginx" -eq "1" ]; then
    nginx_updated=1
    for domain in $domains; do
        nginx-util add_ssl "${domain}" uacme "$STATE_DIR/${main_domain}/cert.pem" \
            "$STATE_DIR/private/${main_domain}/key.pem" || nginx_updated=0
    done
    # reload is in post_checks
    fi

    if [ "$nginx_updated" -eq "0" ] && [ -w /etc/nginx/nginx.conf ] && [ "$update_nginx" -eq "1" ]; then
        sed -i "s#ssl_certificate\ .*#ssl_certificate $STATE_DIR/${main_domain}/cert.pem;#g" /etc/nginx/nginx.conf
        sed -i "s#ssl_certificate_key\ .*#ssl_certificate_key $STATE_DIR/private/${main_domain}/key.pem;#g" /etc/nginx/nginx.conf
        # commit and reload is in post_checks
    fi

    if [ -e /etc/init.d/haproxy ] && [ "$update_haproxy" -eq 1 ]; then
        cat $STATE_DIR/${main_domain}/cert.pem $STATE_DIR/private/${main_domain}/key.pem > $STATE_DIR/${main_domain}/full_haproxy.pem
    fi

    post_checks
}

issue_cert_with_retries() {
    local section="$1"
    local use_staging
    local retries
    local use_auto_staging
    local infinite_retries
    config_get_bool use_staging "$section" use_staging
    config_get_bool use_auto_staging "$section" use_auto_staging
    config_get_bool enabled "$section" enabled
    config_get retries "$section" retries

    [ -z "$retries" ] && retries=1
    [ -z "$use_auto_staging" ] && use_auto_staging=0
    [ "$retries" -eq "0" ] && infinite_retries=1
    [ "$enabled" -eq "1" ] || return 0

    while true; do
        issue_cert "$1"; ret=$?

        if [ "$ret" -eq "2" ]; then
            # An error occurred while retrieving the certificate.
            retries="$((retries-1))"

            if [ "$use_auto_staging" -eq "1" ] && [ "$use_staging" -eq "0" ]; then
                log "Production certificate could not be obtained. Switching to staging server."
                use_staging=1
                uci set "acme.$1.use_staging=1"
                uci commit acme
            fi

            if [ -z "$infinite_retries" ] && [ "$retries" -lt "1" ]; then
                log "An error occurred while retrieving the certificate. Retries exceeded."
                return "$ret"
            fi

            if [ "$use_staging" -eq "1" ]; then
                # The "Failed Validations" limit of LetsEncrypt is 60 per hour. This
                # means one failure every minute. Here we wait 2 minutes to be within
                # limits for sure.
                sleeptime=120
            else
                # There is a "Failed Validation" limit of LetsEncrypt is 5 failures per
                # account, per hostname, per hour. This means one failure every 12
                # minutes. Here we wait 25 minutes to be within limits for sure.
                sleeptime=1500
            fi

            log "An error occurred while retrieving the certificate. Retrying in $sleeptime seconds."
            sleep "$sleeptime"
            continue
        else
            if [ "$use_auto_staging" -eq "1" ]; then
                if [ "$use_staging" -eq "0" ]; then
                    log "Production certificate obtained. Exiting."
                else
                    log "Staging certificate obtained. Continuing with production server."
                    use_staging=0
                    uci set "acme.$1.use_staging=0"
                    uci commit acme
                    continue
                fi
            fi

            return "$ret"
        fi
    done
}

load_vars()
{
    local section="$1"

    PRODUCTION_STATE_DIR=$(config_get "$section" state_dir)
    STAGING_STATE_DIR=$PRODUCTION_STATE_DIR/staging
    ACCOUNT_EMAIL=$(config_get "$section" account_email)
    DEBUG=$(config_get "$section" debug)
    ACME_URL=$(config_get "$section" acme_url)
    ACME_STAGING_URL=$(config_get "$section" acme_staging_url)
    ACME_INTERFACE=$(config_get "$section" acme_interface)
}

if [ -z "$INCLUDE_ONLY" ]; then
    check_cron
    [ -n "$CHECK_CRON" ] && exit 0
    [ -e "/var/run/acme_boot" ] && rm -f "/var/run/acme_boot" && exit 0
fi

config_load acme
config_foreach load_vars acme

if [ -z "$PRODUCTION_STATE_DIR" ] || [ -z "$ACCOUNT_EMAIL" ]; then
    err "state_dir and account_email must be set"
    exit 1
fi

[ -d "$PRODUCTION_STATE_DIR" ] || mkdir -p "$PRODUCTION_STATE_DIR"
[ -d "$STAGING_STATE_DIR" ] || mkdir -p "$STAGING_STATE_DIR"

trap err_out HUP TERM
trap int_out INT

if [ -z "$INCLUDE_ONLY" ]; then
    config_foreach issue_cert_with_retries cert

    exit 0
fi

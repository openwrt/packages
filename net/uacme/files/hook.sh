#!/bin/sh
# Wrapper for uacme to work on openwrt.

set -u
ACME=/usr/sbin/uacme
HPROGRAM=/usr/share/uacme/uacme.sh
LOG_TAG=acme-uacme
NOTIFY=/usr/lib/acme/notify
HOOKDIR=/usr/lib/acme

# shellcheck source=net/acme/files/functions.sh
. /usr/lib/acme/functions.sh

link_certs() {
	local main_domain
	local domain_dir
	domain_dir="$1"
	main_domain="$2"
#uacme saves only fullchain as cert.pem
	(
		umask 077
		cat "$domain_dir/cert.pem" "$state_dir/private/$main_domain/key.pem" >"$domain_dir/combined.cer"
		sed -n '1,/-----END CERTIFICATE-----/p' "$domain_dir/cert.pem" >"$domain_dir/leaf_cert.pem"
		sed '1,/-----END CERTIFICATE-----/d' "$domain_dir/cert.pem" >"$domain_dir/chain.crt"
	)

	if [ ! -e "$CERT_DIR/$main_domain.crt" ]; then
		ln -s "$domain_dir/leaf_cert.pem" "$CERT_DIR/$main_domain.crt"
	fi
#uacme doesn't rotate key, and it saves ../private/$main_domain dir
	if [ ! -e "$CERT_DIR/$main_domain.key" ]; then
		ln -s "$state_dir/private/$main_domain/key.pem" "$CERT_DIR/$main_domain.key"
	fi
	if [ ! -e "$CERT_DIR/$main_domain.fullchain.crt" ]; then
		ln -s "$domain_dir/cert.pem" "$CERT_DIR/$main_domain.fullchain.crt"
	fi
	if [ ! -e "$CERT_DIR/$main_domain.combined.crt" ]; then
		ln -s "$domain_dir/combined.cer" "$CERT_DIR/$main_domain.combined.crt"
	fi
	if [ ! -e "$CERT_DIR/$main_domain.chain.crt" ]; then
		ln -s "$domain_dir/chain.crt" "$CERT_DIR/$main_domain.chain.crt"
	fi
}

#expand acme server short alias
case $acme_server in
				letsencrypt)
					unset acme_server
					;;
				letsencrypt_test)
					acme_server=https://acme-staging-v02.api.letsencrypt.org/directory
					;;
				zerossl)
					acme_server=https://acme.zerossl.com/v2/DV90
					;;
				google)
					acme_server=https://dv.acme-v02.api.pki.goog/directory
					;;
				actalis)
					acme_server=https://acme-api.actalis.com/acme/directory
					;;
				*)
					;;
				esac

case $1 in
get)
	#uacme doesn't save account per ca nor it make new account when not registered
	#while server doesn't care, we record which CAs we have account to reduce noise
	#using staging var for default letsencrypts.
	if grep -q "^${acme_server:-$staging}$" $state_dir/accounts; then
		:
	else
		#not found
		if [ "$acme_server" ]; then
				$ACME new $account_email -t EC -y --confdir "$state_dir" -a $acme_server
				echo $acme_server >> $state_dir/accounts
		elif [ "$staging" = 1 ]; then
			$ACME new $account_email -t EC -y --confdir "$state_dir" -s
			echo $staging >> $state_dir/accounts
		else
			$ACME new $account_email -t EC -y --confdir "$state_dir"
			echo $staging >> $state_dir/accounts
		fi
	fi
	set --
	[ "$debug" = 1 ] && set -- "$@" -v
#uacme doesn't rotate privkey
	case $key_type in
	ec*)
		keylength=${key_type#ec}
		domain_dir="$state_dir/$main_domain"
		set -- "$@" -t EC 
		;;
	rsa*)
		keylength=${key_type#rsa}
		domain_dir="$state_dir/$main_domain"
		;;
	esac

	set -- "$@" --bits "$keylength"

	if [ "$acme_server" ]; then
		set -- "$@" --acme-url "$acme_server"
	elif [ "$staging" = 1 ]; then
		set -- "$@" --staging
	else
		set -- "$@"
	fi

	log info "Running ACME for $main_domain with validation_method $validation_method"

	staging_moved=0
	is_renew=0
	if [ -e "$domain_dir" ]; then
		if [ "$staging" = 0 ] && grep -q "acme-staging" "$domain_dir/$main_domain.conf"; then
			mv "$domain_dir" "$domain_dir.staging"
			mv "$state_dir/private/$main_domain" "$state_dir/private/$main_domain.staging"
			log info "Certificates are previously issued from a staging server, but staging option is disabled, moved to $domain_dir.staging."
			staging_moved=1
		else
			#this is renewal
			is_renew=1
		fi
	else
		log info no prv certificate remembered
	fi

	if [ "$days" ]; then
		set -- "$@" --days "$days"
	fi

	# uacme handles challange select by hook script
	case "$validation_method" in
	"alpn")
		log info "using already running ualpn, it's user's duty to config ualpn server deamon"
		set -- "$@" -h "$HOOKDIR/client/ualpn.sh"
		;;
	"dns")
		export dns
		set -- "$@" -h "$HOOKDIR/client/dnschalhook.sh"
		if [ "$dalias" ]; then
			set -- "$@" --domain-alias "$dalias"
			if [ "$calias" ]; then
				log err "Both domain and challenge aliases are defined. Ignoring the challenge alias."
			fi
		elif [ "$calias" ]; then
			set -- "$@" --challenge-alias "$calias"
		fi
		if [ "$dns_wait" ]; then
			export dns_wait
		fi
		;;
	"standalone")
		set -- "$@" --standalone --listen-v6
		log err "standalone server is not implmented for uacme"
		exit 1
		;;
	"webroot")
		mkdir -p "$CHALLENGE_DIR"
		export CHALLENGE_DIR
		set -- "$@" -h "$HOOKDIR/client/httpchalhook.sh"
		;;
	*)
		log err "Unsupported validation_method $validation_method"
		;;
	esac

	set -- "$@"  --confdir "$state_dir" issue
		for d in $domains; do
		set -- "$@" "$d"
	done

	log info "$ACME $*"
	trap '$NOTIFY issue-failed;exit 1' INT
	"$ACME" "$@" 2>&1
	status=$?
	trap - INT

	case $status in
	0)
		link_certs "$domain_dir" "$main_domain"
		if [ -e is_renew ]; then
			$NOTIFY issued
		else
			$NOTIFY renewed
		fi
		;;
	1)
		#server didn't run so don't do anything
		if [ "$staging_moved" = 1 ]; then
			log err "Staging certificate '$domain_dir' restored"
			mv "$domain_dir.staging" "$domain_dir"
			log err "Staging certificate restored"
		fi
		log debug "not due to renewal"
		;;
	*)
		if [ -e is_renew ]; then
			$NOTIFY renew-failed
			exit 1;
		fi
		if [ "$staging_moved" = 1 ]; then
			log err "Staging certificate '$domain_dir' restored"
			mv "$domain_dir.staging" "$domain_dir"
			log err "Staging certificate restored"
		elif [ -d "$domain_dir" ]; then
			failed_dir="$domain_dir.failed-$(date +%s)"
			mv "$domain_dir" "$failed_dir"
			log err "State moved to $failed_dir"
		fi
		$NOTIFY issue-failed
		;;
	esac
	;;
esac

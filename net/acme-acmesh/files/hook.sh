#!/bin/sh
set -u
ACME=/usr/lib/acme/client/acme.sh
LOG_TAG=acme-acmesh
NOTIFY=/usr/lib/acme/notify

# shellcheck source=net/acme/files/functions.sh
. /usr/lib/acme/functions.sh

# Needed by acme.sh
export CURL_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt
export NO_TIMESTAMP=1

link_certs() {
	local main_domain
	local domain_dir
	domain_dir="$1"
	main_domain="$2"

	(
		umask 077
		cat "$domain_dir/fullchain.cer" "$domain_dir/$main_domain.key" >"$domain_dir/combined.cer"
	)

	if [ ! -e "$CERT_DIR/$main_domain.crt" ]; then
		ln -s "$domain_dir/$main_domain.cer" "$CERT_DIR/$main_domain.crt"
	fi
	if [ ! -e "$CERT_DIR/$main_domain.key" ]; then
		ln -s "$domain_dir/$main_domain.key" "$CERT_DIR/$main_domain.key"
	fi
	if [ ! -e "$CERT_DIR/$main_domain.fullchain.crt" ]; then
		ln -s "$domain_dir/fullchain.cer" "$CERT_DIR/$main_domain.fullchain.crt"
	fi
	if [ ! -e "$CERT_DIR/$main_domain.combined.crt" ]; then
		ln -s "$domain_dir/combined.cer" "$CERT_DIR/$main_domain.combined.crt"
	fi
	if [ ! -e "$CERT_DIR/$main_domain.chain.crt" ]; then
		ln -s "$domain_dir/ca.cer" "$CERT_DIR/$main_domain.chain.crt"
	fi
}

case $1 in
get)
	set --
	[ "$debug" = 1 ] && set -- "$@" --debug

	case $key_type in
	ec*)
		keylength=${key_type/ec/ec-}
		domain_dir="$state_dir/${main_domain}_ecc"
		set -- "$@" --ecc
		;;
	rsa*)
		keylength=${key_type#rsa}
		domain_dir="$state_dir/$main_domain"
		;;
	esac

	log info "Running ACME for $main_domain with validation_method $validation_method"

	staging_moved=0
	if [ -e "$domain_dir" ]; then
		if [ "$staging" = 0 ] && grep -q "acme-staging" "$domain_dir/$main_domain.conf"; then
			mv "$domain_dir" "$domain_dir.staging"
			log info "Certificates are previously issued from a staging server, but staging option is disabled, moved to $domain_dir.staging."
			staging_moved=1
		else
			set -- "$@" --renew --home "$state_dir" -d "$main_domain"
			log info "$ACME $*"
			trap 'log err "Renew failed: SIGINT";$NOTIFY renew-failed;exit 1' INT
			$ACME "$@"
			status=$?
			trap - INT

			case $status in
			0)
				link_certs "$domain_dir" "$main_domain"
				$NOTIFY renewed
				exit
				;;
			2)
				# renew skipped, ignore.
				exit
				;;
			*)
				$NOTIFY renew-failed
				exit 1
				;;
			esac
		fi
	fi

	for d in $domains; do
		set -- "$@" -d "$d"
	done
	set -- "$@" --keylength "$keylength" --accountemail "$account_email"

	if [ "$acme_server" ]; then
		set -- "$@" --server "$acme_server"
	# default to letsencrypt because the upstream default may change
	elif [ "$staging" = 1 ]; then
		set -- "$@" --server letsencrypt_test
	else
		set -- "$@" --server letsencrypt
	fi

	if [ "$days" ]; then
		set -- "$@" --days "$days"
	fi

	case "$validation_method" in
	"dns")
		set -- "$@" --dns "$dns"
		if [ "$dalias" ]; then
			set -- "$@" --domain-alias "$dalias"
			if [ "$calias" ]; then
				log err "Both domain and challenge aliases are defined. Ignoring the challenge alias."
			fi
		elif [ "$calias" ]; then
			set -- "$@" --challenge-alias "$calias"
		fi
		if [ "$dns_wait" ]; then
			set -- "$@" --dnssleep "$dns_wait"
		fi
		;;
	"standalone")
		set -- "$@" --standalone --listen-v6 --httpport "$listen_port"
		;;
	"alpn")
		set -- "$@" --alpn --listen-v6 --tlsport "$listen_port"
		;;
	"webroot")
		mkdir -p "$CHALLENGE_DIR"
		set -- "$@" --webroot "$CHALLENGE_DIR"
		;;
	*)
		log err "Unsupported validation_method $validation_method"
		;;
	esac

	set -- "$@" --issue --home "$state_dir"

	log info "$ACME $*"
	trap 'log err "Issue failed: SIGINT";$NOTIFY issue-failed;exit 1' INT
	"$ACME" "$@" \
		--pre-hook "$NOTIFY prepare" \
		--renew-hook "$NOTIFY renewed"
	status=$?
	trap - INT

	case $status in
	0)
		link_certs "$domain_dir" "$main_domain"
		$NOTIFY issued
		;;
	*)
		if [ "$staging_moved" = 1 ]; then
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

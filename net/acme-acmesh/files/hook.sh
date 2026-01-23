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

handle_signal() {
	local notify_op=$1
	local label_op=$2
	wait_notify() {
		# wait for acme.sh child job to die, *then* notify about status
		wait
		log warn "$label_op aborted: $main_domain"
		$NOTIFY "${notify_op}-failed"
		exit 1
	}

	trap wait_notify TERM
	# try to kill the cgroup
	local cgroup=$(cut -d : -f 3 /proc/$$/cgroup)
	if [[ "$cgroup" == '/services/acme/*' ]]; then
		# send SIGTERM to all processes in this process's cgroup. this
		# relies on procd's having set up the cgroup for the instance.
		read -r -d '' pids < /sys/fs/cgroup${cgroup}/cgroup.procs 
		kill -TERM $pids 2> /dev/null
	fi

	# if we're here, either the cgroup wasn't as exected to be set up by
	# procd or killing the cgroup PIDs failed. try to kill the process
	# group, assuming this process is the group leader. this is actually
	# unlikely since procd doesn't set service PGIDs (so they aren't group
	# leaders).
	kill -TERM -$$ 2> /dev/null

	# if we're here, cgroup-based killing was avoided or didn't work and
	# PGID-based killing didn't work. fall back to the raciest option.
	trap "" TERM
	term_descendants() {
		local pids=$@
		local pid=
		# `pgrep -P` returns nothing if given a non-existent PID
		# (even if the PID has live children), so children must
		# be killed first
		for pid in $pids; do
			term_descendants $(pgrep -P "$pid")
			kill -TERM "$pid" 2> /dev/null
		done
	}
	term_descendants $(jobs -p)

	wait_notify
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
			trap "handle_signal renew Renewal" INT TERM
			$ACME "$@" &
			wait $!
			status=$?
			trap - INT TERM

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

	if [ "$cert_profile" ]; then
		set -- "$@" --cert-profile "$cert_profile"
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
	trap "handle_signal issue Issuance" INT TERM
	"$ACME" "$@" \
		--pre-hook "$NOTIFY prepare" \
		--renew-hook "$NOTIFY renewed" &
	wait $!
	status=$?
	trap - INT TERM

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

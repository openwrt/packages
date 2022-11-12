. /lib/functions.sh
. /lib/functions/network.sh

PX5G_BIN="/usr/sbin/px5g"
OPENSSL_BIN="/usr/bin/openssl"

ngx_listen() {
	local interface="$1"
	shift
	local addrs addr addr6s addr6

	network_get_ipaddrs addrs "$interface"
	network_get_ipaddrs6 addr6s "$interface"
	if [ -z "$addrs" ] && [ -z "$addr6s" ]; then
		exit 1
	fi
	for addr in $addrs; do
		echo "listen $addr:$*;"
	done
	for addr6 in $addr6s; do
		echo "listen [$addr6]:$*;"
	done
}

_generate_crt() {
	local cfg="$1"
	local key="$2"
	local crt="$3"
	local days bits country state location organization commonname

	config_get days "$cfg" days
	config_get bits "$cfg" bits
	config_get country "$cfg" country
	config_get state "$cfg" state
	config_get location "$cfg" location
	config_get organization "$cfg" organization
	config_get commonname "$cfg" commonname
	config_get key_type "$cfg" key_type
	config_get ec_curve "$cfg" ec_curve

	# Prefer px5g for certificate generation (existence evaluated last)
	local GENKEY_CMD=""
	local KEY_OPTS="rsa:${bits:-2048}"
	local UNIQUEID=$(dd if=/dev/urandom bs=1 count=4 | hexdump -e '1/1 "%02x"')
	[ "$key_type" = "ec" ] && KEY_OPTS="ec -pkeyopt ec_paramgen_curve:${ec_curve:-P-256}"
	[ -x "$OPENSSL_BIN" ] && GENKEY_CMD="$OPENSSL_BIN req -x509 -sha256 -outform pem -nodes"
	[ -x "$PX5G_BIN" ] && GENKEY_CMD="$PX5G_BIN selfsigned -pem"
	if [ -n "$GENKEY_CMD" ]; then
		$GENKEY_CMD \
			-days ${days:-730} -newkey ${KEY_OPTS} -keyout "$key.new" -out "$crt.new" \
			-subj /C="${country:-ZZ}"/ST="${state:-Somewhere}"/L="${location:-Unknown}"/O="${organization:-OpenWrt$UNIQUEID}"/CN="${commonname:-OpenWrt}"
		sync
		mv "$key.new" "$key"
		mv "$crt.new" "$crt"
	else
		# If neither tools exists, don't let ssl conf take effect
		exit 1
	fi
}

ngx_ssl_cert() {
	if [ -z "$CONFIG_SECTIONS" ]; then
		config_load nginx
	fi

	cd /etc/nginx
	local key="${1:-nginx.key}"
	local crt="${2:-nginx.crt}"
	if [ ! -s "$key" ] || [ ! -s "$crt" ]; then
		config_foreach _generate_crt cert "$key" "$crt"
	fi
	echo "ssl_certificate_key $key;"
	echo "ssl_certificate $crt;"
}

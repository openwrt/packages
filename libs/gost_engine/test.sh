#!/bin/sh
# shellcheck disable=SC2059

run_md_test () {
	[ $# -ge 3 ] || {
		echo "Error: insufficient args to run_md_test()" >&2
		exit 1
	}
	DGST="$1";  shift
	INP="$1"; shift
	EXP="$1"; shift
	printf "Testing digest %s: " "$DGST" >&2
	OUT="$(printf "$INP" | openssl dgst -"$DGST" "$@")" || exit 1
	[ -z "${OUT%%*"$EXP"}" ] || {
		printf "Failure: expected: '%s', got '%s'\n" "$EXP" "$OUT" >&2
		exit 1
	}
	echo OK >&2 || true
}

run_cipher_test() {
	[ $# -ge 5 ] || {
		echo "Error: insufficient args to run_cipher_test()" >&2
		exit 1
	}
	ALG="$1"; shift
	KEY="$1"; shift
	IV="$1"; shift
	CLEAR_TEXT="$1"; shift
	CIPHER_TEXT="$1"; shift
	printf "Testing %s encryption: " "$ALG" >&2
	OUT="$(printf "$CLEAR_TEXT" | openssl enc -e -"$ALG" -K "$KEY" -iv "$IV" "$@" -a -A)" || exit 1
	[ -z "${OUT%"$CIPHER_TEXT"}" ] || {
		printf "Encryption failure: expected: '%s', got '%s'\n" "$CIPHER_TEXT" "$OUT" >&2
		exit 1
	}
	echo OK >&2
	printf "Testing %s decryption: " "$ALG" >&2
	OUT="$(printf "$CIPHER_TEXT" | openssl enc -d -"$ALG" -K "$KEY" -iv "$IV" "$@" -a -A)" || exit 1
	[ -z "${OUT%"$(printf "$CLEAR_TEXT")"}" ] || {
		echo "Decryption failure!" >&2
		echo "----------- expected hexdump -------------" >&2
		printf "$CLEAR_TEXT" | hexdump -C
		echo "------------ result hexdump --------------" >&2
		echo "$OUT" | hexdump -C >&2
		exit 1
	}
	echo OK >&2 || true
}

case "$1" in
	libopenssl-gost_engine)
		run_md_test \
			md_gost12_256 \
			012345678901234567890123456789012345678901234567890123456789012 \
			9d151eefd8590b89daa6ba6cb74af9275dd051026bb149a452fd84e5e57b5500
		export CRYPT_PARAMS="1.2.643.2.2.31.1"
		run_cipher_test \
			gost89 \
			0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF \
			0000000000000000 \
			"The quick brown fox jumps over the lazy dog\n" \
			"B/QQLGGFxKCeZ24mm/pLycXfZXWRa4eb0TqJOiKF7maQEHze73oxXS61S/o="
		;;
	gost_engine-util)
		printf "Testing gost12sum: "
		EXP=9d151eefd8590b89daa6ba6cb74af9275dd051026bb149a452fd84e5e57b5500
		OUT=$(printf 012345678901234567890123456789012345678901234567890123456789012 | gost12sum)
		[ -z "${OUT##"$EXP"*}" ] || {
			printf "Failure: expected: '%s', got '%s'\n" "$EXP" "$OUT" >&2
			exit 1
		}
		echo OK >&2 || true
		;;
	*)
		echo "Unexpected package '$1'" >&2
		exit 1
		;;
esac

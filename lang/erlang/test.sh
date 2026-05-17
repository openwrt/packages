#!/bin/sh

case "$1" in
erlang)
	# Check erl binary is present and prints the right OTP version
	otp_major="${2%%.*}"
	timeout 60s erl -noshell -eval "V = erlang:system_info(otp_release), io:format(\"OTP ~s~n\", [V])" -s init stop 2>&1 | \
		grep -qF "OTP ${otp_major}" || {
		echo "FAIL: erl did not report expected OTP version '$2' (major: $otp_major)"
		exit 1
	}
	echo "erl OTP version: OK"

	# Verify epmd (Erlang port mapper daemon) is present
	[ -x /usr/bin/epmd ] || [ -x /usr/lib/erlang/bin/epmd ] || {
		echo "FAIL: epmd not found"
		exit 1
	}
	echo "epmd: OK"

	# Basic arithmetic eval
	result=$(timeout 60s erl -noshell -eval "io:format(\"~w~n\", [2+2])" -s init stop 2>/dev/null)
	[ "$result" = "4" ] || {
		echo "FAIL: erl basic eval returned '$result', expected '4'"
		exit 1
	}
	echo "erl eval: OK"
	;;
esac

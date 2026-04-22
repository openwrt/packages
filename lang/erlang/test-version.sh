#!/bin/sh
# erl -version prints ERTS version, not OTP release — use system_info instead
case "$1" in
erlang)
	otp_major="${2%%.*}"
	timeout 60s erl -noshell \
		-eval "V = erlang:system_info(otp_release), io:format(\"OTP ~s~n\", [V])" \
		-s init stop 2>&1 | \
		grep -qF "OTP ${otp_major}"
	;;
esac
